/* eslint-disable require-jsdoc */
import {randomUUID} from "node:crypto";

import {getApp, getApps, initializeApp} from "firebase-admin/app";
import {
  FieldValue,
  getFirestore,
} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {logger} from "firebase-functions";
import {defineSecret} from "firebase-functions/params";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import OpenAI, {toFile} from "openai";

if (getApps().length === 0) {
  initializeApp();
} else {
  getApp();
}

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

const REQUEST_COLLECTION = "illustrationRequests";
const REQUEST_STATUS_PENDING = "pending";
const REQUEST_STATUS_PROCESSING = "processing";
const REQUEST_STATUS_COMPLETED = "completed";
const REQUEST_STATUS_FAILED = "failed";
const CREDIT_RESERVATION_STATE_CONSUMED = "consumed";
const OPENAI_IMAGE_MODEL = "gpt-image-1.5";
const FUNCTION_TIMEOUT_SECONDS = 300;
const WORKER_DEADLINE_BUFFER_MS = 30 * 1000;
// Complex family photos (3+ people) can take 90-150 s with gpt-image-1.5.
// The function has 300 s total; we keep 30 s buffer for overhead and storage,
// leaving ~240 s available. Cap the OpenAI call at 200 s to stay safely under.
const OPENAI_IMAGE_REQUEST_TIMEOUT_MS = 200 * 1000;
const GENERATED_IMAGE_CONTENT_TYPE = "image/jpeg";
const DEADLINE_SAFETY_MARGIN_MS = 5000;

const MONTHLY_INCLUDED_LIMIT = 3;

const ALLOWED_SOURCE_IMAGE_EXTENSIONS = new Set([
  "jpg",
  "jpeg",
  "png",
  "webp",
]);

const ILLUSTRATION_STYLE_DEFAULT = "default";
const ILLUSTRATION_STYLE_LOFI = "lofi";

function sanitizeStyle(value: unknown): string {
  if (value === ILLUSTRATION_STYLE_LOFI) return ILLUSTRATION_STYLE_LOFI;
  return ILLUSTRATION_STYLE_DEFAULT;
}

type IllustrationRequestData = {
  uid: string;
  babyId: string;
  memoryId: string;
  sourcePhotoStoragePath: string;
  sourcePhotoUrl: string;
  status: string;
  requestType?: string | null;
  promptVersion?: string | null;
  style?: string | null;
  resultStoragePath?: string | null;
  resultImageUrl?: string | null;
  errorCode?: string | null;
  errorMessage?: string | null;
  reservedCreditBucket?: CreditConsumption | null;
  creditReservationState?: string | null;
};

type CreditConsumption =
  | "freeIllustrationAvailable"
  | "monthlyCreditsRemaining"
  | "purchasedCreditsRemaining";

type GenerationResult = {
  imageBytes: Buffer;
  contentType: string;
};

type RequestValidationResult =
  | {ok: true; data: IllustrationRequestData}
  | {ok: false; errorCode: string; errorMessage: string};

type ParsedSourcePhotoPath = {
  uid: string;
  babyId: string;
  memoryId: string;
  extension: string;
};

const storage = getStorage();

export const processIllustrationRequest = onDocumentCreated(
  {
    document: `${REQUEST_COLLECTION}/{requestId}`,
    region: "us-central1",
    timeoutSeconds: FUNCTION_TIMEOUT_SECONDS,
    memory: "512MiB",
    secrets: [OPENAI_API_KEY],
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn("Illustration request trigger fired without snapshot.", {
        params: event.params,
      });
      return;
    }

    const requestId = snapshot.id;
    const requestRef = snapshot.ref;
    const validation = validateRequestData(snapshot.data());
    if (!validation.ok) {
      await markRequestFailed(
        requestRef,
        validation.errorCode,
        validation.errorMessage,
      );
      return;
    }

    const request = validation.data;

    // Atomically claim the request (pending → processing).
    // Prevents double credit consumption on Cloud Function retries.
    const claimed = await claimRequestOrSkip(requestRef, requestId);
    if (!claimed) {
      return;
    }

    logger.info("Illustration request received.", {
      requestId,
      uid: request.uid,
      babyId: request.babyId,
      memoryId: request.memoryId,
      requestType: request.requestType,
      promptVersion: request.promptVersion,
      style: request.style ?? ILLUSTRATION_STYLE_DEFAULT,
    });
    const workerDeadlineMs =
      Date.now() +
      (FUNCTION_TIMEOUT_SECONDS * 1000) -
      WORKER_DEADLINE_BUFFER_MS;

    let resultStoragePath: string | null = null;
    let consumedCreditBucket: CreditConsumption | null = null;

    try {
      await assertRequestOwnershipOrThrow(request);
      await assertSourcePhotoExists(request.sourcePhotoStoragePath);

      // Atomically validate and consume one credit server-side.
      // This is the authoritative gate — client-side credit checks are UX only.
      consumedCreditBucket = await consumeCreditServerSide(request.uid);

      const generationResult = await generateIllustrationFromSource({
        requestId,
        request,
        deadlineMs: workerDeadlineMs,
      });

      resultStoragePath =
        `users/${request.uid}/babies/${request.babyId}/memories/` +
        `${request.memoryId}/illustrations/${requestId}.jpg`;
      const resultImageUrl = await saveGeneratedIllustration({
        storagePath: resultStoragePath,
        imageBytes: generationResult.imageBytes,
        contentType: generationResult.contentType,
      });

      // Generation succeeded — credit is earned, clear the refund flag.
      consumedCreditBucket = null;

      await requestRef.update({
        status: REQUEST_STATUS_COMPLETED,
        resultStoragePath,
        resultImageUrl,
        updatedAt: FieldValue.serverTimestamp(),
        errorCode: null,
        errorMessage: null,
        reservedCreditBucket: null,
        creditReservationState: CREDIT_RESERVATION_STATE_CONSUMED,
      });

      logger.info("Illustration request completed.", {
        requestId,
        uid: request.uid,
        resultStoragePath,
      });
    } catch (error) {
      const normalized = normalizeWorkerError(error);
      logger.error("Illustration request failed.", {
        requestId,
        uid: request.uid,
        errorCode: normalized.errorCode,
        errorMessage: normalized.errorMessage,
      });

      // Refund the credit if it was consumed before the failure.
      if (consumedCreditBucket !== null) {
        await refundCreditServerSide(request.uid, consumedCreditBucket).catch(
          (refundErr) => {
            logger.error("Credit refund failed after worker error.", {
              requestId,
              uid: request.uid,
              refundErr,
            });
          },
        );
      }

      if (resultStoragePath) {
        await deleteGeneratedIllustrationIfPresent(resultStoragePath);
      }

      await markRequestFailed(
        requestRef,
        normalized.errorCode,
        normalized.errorMessage,
      );
    }
  },
);

function validateRequestData(
  rawData: FirebaseFirestore.DocumentData | undefined,
): RequestValidationResult {
  if (!rawData) {
    return {
      ok: false,
      errorCode: "missing-request-data",
      errorMessage: "Illustration request is missing data.",
    };
  }

  const data: IllustrationRequestData = {
    uid: toTrimmedString(rawData.uid),
    babyId: toTrimmedString(rawData.babyId),
    memoryId: toTrimmedString(rawData.memoryId),
    sourcePhotoStoragePath: toTrimmedString(rawData.sourcePhotoStoragePath),
    sourcePhotoUrl: toTrimmedString(rawData.sourcePhotoUrl),
    status: toTrimmedString(rawData.status),
    requestType: toOptionalString(rawData.requestType),
    promptVersion: toOptionalString(rawData.promptVersion),
    style: sanitizeStyle(rawData.style),
    resultStoragePath: toOptionalString(rawData.resultStoragePath),
    resultImageUrl: toOptionalString(rawData.resultImageUrl),
    errorCode: toOptionalString(rawData.errorCode),
    errorMessage: toOptionalString(rawData.errorMessage),
    reservedCreditBucket: toCreditConsumption(rawData.reservedCreditBucket),
    creditReservationState: toOptionalString(rawData.creditReservationState),
  };

  const missingFields = [
    ["uid", data.uid],
    ["babyId", data.babyId],
    ["memoryId", data.memoryId],
    ["sourcePhotoStoragePath", data.sourcePhotoStoragePath],
    ["status", data.status],
  ].filter(([, value]) => !value);

  if (missingFields.length > 0) {
    return {
      ok: false,
      errorCode: "missing-required-fields",
      errorMessage:
        `Missing required request fields: ${missingFields.map(([key]) => key)}`,
    };
  }

  return {ok: true, data};
}

/**
 * Atomically transitions the request status from "pending" to "processing"
 * and stamps a unique workerId. Returns true if this worker won the claim;
 * false if the request was already claimed or in a terminal state (which
 * means a previous invocation already handled it — caller should exit).
 * @param {FirebaseFirestore.DocumentReference} requestRef Reference to the
 *   illustration request document to claim.
 * @param {string} requestId Firestore document ID used for log context.
 * @return {Promise<boolean>} True if this worker successfully claimed it.
 */
async function claimRequestOrSkip(
  requestRef: FirebaseFirestore.DocumentReference,
  requestId: string,
): Promise<boolean> {
  const db = getFirestore();
  let claimed = false;

  try {
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(requestRef);
      if (!snap.exists) {
        logger.warn("claimRequestOrSkip: request doc not found.", {requestId});
        return;
      }
      const currentStatus = (snap.data()?.status ?? "") as string;
      if (currentStatus !== REQUEST_STATUS_PENDING) {
        logger.info("claimRequestOrSkip: already claimed — skipping.", {
          requestId,
          currentStatus,
        });
        return;
      }
      tx.update(requestRef, {
        status: REQUEST_STATUS_PROCESSING,
        workerId: randomUUID(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      claimed = true;
    });
  } catch (error) {
    logger.error("claimRequestOrSkip: transaction failed.", {requestId, error});
    return false;
  }

  return claimed;
}

async function markRequestFailed(
  requestRef: FirebaseFirestore.DocumentReference,
  errorCode: string,
  errorMessage: string,
): Promise<void> {
  await requestRef.set(
    {
      status: REQUEST_STATUS_FAILED,
      errorCode,
      errorMessage,
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );
}

// ---------------------------------------------------------------------------
// Server-side credit helpers
// ---------------------------------------------------------------------------
// These run inside admin-SDK Firestore transactions and are the ONLY
// authoritative writers of the illustrationCredits/balance document.
// Client-side Firestore rules deny all writes to this path.
// ---------------------------------------------------------------------------

/**
 * Atomically validates that the user has at least one credit and consumes it.
 * Monthly-included credits are consumed first; purchased credits second.
 * Throws WorkerError('insufficient-credits') when the balance is zero.
 * Returns which bucket was consumed so it can be refunded on failure.
 * @param {string} uid Authenticated user ID owning the credit balance document.
 */
async function consumeCreditServerSide(
  uid: string,
): Promise<CreditConsumption> {
  const db = getFirestore();
  const creditsRef = db
    .collection("users")
    .doc(uid)
    .collection("illustrationCredits")
    .doc("balance");
  const currentMonth = serverYearMonth();

  let consumed: CreditConsumption | null = null;

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(creditsRef);
    const data = snap.data() ?? {};

    const storedMonth = String(data["usageMonth"] ?? "");
    const usedThisMonth =
      storedMonth === currentMonth ? toIntSafe(data["usedThisMonth"]) : 0;
    const monthlyRemaining = Math.max(
      0,
      MONTHLY_INCLUDED_LIMIT - usedThisMonth,
    );
    const purchasedRemaining = toIntSafe(data["purchasedCreditsRemaining"]);

    if (monthlyRemaining <= 0 && purchasedRemaining <= 0) {
      throw new WorkerError(
        "insufficient-credits",
        "No illustration credits remaining.",
      );
    }

    if (monthlyRemaining > 0) {
      consumed = "monthlyCreditsRemaining";
      tx.set(
        creditsRef,
        {
          usageMonth: currentMonth,
          usedThisMonth: usedThisMonth + 1,
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true},
      );
    } else {
      consumed = "purchasedCreditsRemaining";
      tx.set(
        creditsRef,
        {
          purchasedCreditsRemaining: Math.max(0, purchasedRemaining - 1),
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true},
      );
    }
  });

  if (consumed === null) {
    throw new WorkerError(
      "credit-consumption-failed",
      "Credit consumption completed without selecting a bucket.",
    );
  }

  return consumed;
}

/**
 * Refunds one credit to the bucket that was previously consumed.
 * Called when illustration generation fails after a credit was already taken.
 * Best-effort: caller should catch and log errors rather than rethrowing.
 * @param {string} uid Authenticated user ID owning the credit balance document.
 * @param {CreditConsumption} bucket The credit bucket that should receive
 *   the refunded credit.
 */
async function refundCreditServerSide(
  uid: string,
  bucket: CreditConsumption,
): Promise<void> {
  const db = getFirestore();
  const creditsRef = db
    .collection("users")
    .doc(uid)
    .collection("illustrationCredits")
    .doc("balance");
  const currentMonth = serverYearMonth();

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(creditsRef);
    const data = snap.data() ?? {};

    if (bucket === "monthlyCreditsRemaining") {
      const storedMonth = String(data["usageMonth"] ?? "");
      if (storedMonth === currentMonth) {
        tx.set(
          creditsRef,
          {
            usedThisMonth: Math.max(0, toIntSafe(data["usedThisMonth"]) - 1),
            updatedAt: FieldValue.serverTimestamp(),
          },
          {merge: true},
        );
      }
    } else if (bucket === "purchasedCreditsRemaining") {
      tx.set(
        creditsRef,
        {
          purchasedCreditsRemaining:
            toIntSafe(data["purchasedCreditsRemaining"]) + 1,
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true},
      );
    }
  });
}

// ---------------------------------------------------------------------------
// Callable: grant purchased illustration credits
// ---------------------------------------------------------------------------
// DISABLED: Not wired to Adapty purchase verification yet.
// Keep exported so the function name is reserved in Cloud Functions.
// Wire up purchase verification here once Adapty IAP integration is complete.
// ---------------------------------------------------------------------------
export const grantPurchasedIllustrationCredits = onCall(
  {region: "us-central1"},
  async () => {
    // TODO: verify Adapty purchase receipt, then use admin SDK to increment
    // purchasedCreditsRemaining in illustrationCredits/balance.
    throw new HttpsError(
      "unimplemented",
      "Paid illustration packs are not yet available.",
    );
  },
);

async function assertSourcePhotoExists(storagePath: string): Promise<void> {
  const [exists] = await storage.bucket().file(storagePath).exists();
  if (!exists) {
    throw new WorkerError(
      "source-photo-missing",
      "Source memory photo could not be found in Cloud Storage.",
    );
  }
}

async function generateIllustrationFromSource({
  requestId,
  request,
  deadlineMs,
}: {
  requestId: string;
  request: IllustrationRequestData;
  deadlineMs: number;
}): Promise<GenerationResult> {
  const openaiApiKey = OPENAI_API_KEY.value();
  if (!openaiApiKey) {
    throw new WorkerError(
      "openai-not-configured",
      "Illustration generation is not configured on the server yet.",
    );
  }

  const client = new OpenAI({
    apiKey: openaiApiKey,
  });

  logger.info("Illustration generation scaffold reached.", {
    requestId,
    uid: request.uid,
    requestType: request.requestType,
    promptVersion: request.promptVersion,
    provider: "openai",
    model: OPENAI_IMAGE_MODEL,
  });

  const sourceImage = await downloadSourceImageForEdit(
    request.sourcePhotoStoragePath,
  );
  const prompt = buildIllustrationPrompt(request);
  const timeoutMs = resolveDeadlineAwareTimeout(
    deadlineMs,
    OPENAI_IMAGE_REQUEST_TIMEOUT_MS,
  );

  const response = await client.images.edit(
    {
      model: OPENAI_IMAGE_MODEL,
      image: [
        await toFile(sourceImage.bytes, sourceImage.fileName, {
          type: sourceImage.mimeType,
        }),
      ],
      prompt,
      quality: "high",
      output_format: "jpeg",
    },
    {
      timeout: timeoutMs,
    },
  );

  const imageBase64 = response.data?.[0]?.b64_json;
  if (!imageBase64) {
    throw new WorkerError(
      "openai-missing-output",
      "OpenAI completed without returning generated image data.",
    );
  }

  const imageBytes = Buffer.from(imageBase64, "base64");
  if (imageBytes.length === 0) {
    throw new WorkerError(
      "openai-empty-output",
      "OpenAI returned an empty generated image.",
    );
  }

  return {
    imageBytes,
    contentType: GENERATED_IMAGE_CONTENT_TYPE,
  };
}

async function assertRequestOwnershipOrThrow(
  request: IllustrationRequestData,
): Promise<void> {
  const parsedPath = parseSourcePhotoStoragePath(
    request.sourcePhotoStoragePath,
  );

  if (parsedPath.uid !== request.uid) {
    throw new WorkerError(
      "source-photo-uid-mismatch",
      "Source photo path does not belong to the request owner.",
    );
  }
  if (parsedPath.babyId !== request.babyId) {
    throw new WorkerError(
      "source-photo-baby-mismatch",
      "Source photo path does not belong to the requested baby.",
    );
  }
  if (parsedPath.memoryId !== request.memoryId) {
    throw new WorkerError(
      "source-photo-memory-mismatch",
      "Source photo path does not match the requested memory.",
    );
  }
}

function buildIllustrationPrompt(request: IllustrationRequestData): string {
  const style = sanitizeStyle(request.style);
  if (style === ILLUSTRATION_STYLE_LOFI) {
    return buildLofiPrompt(request);
  }
  return buildDefaultPrompt(request);
}

function buildDefaultPrompt(request: IllustrationRequestData): string {
  const requestTypeHint = request.requestType || "memory-photo-illustration";
  const promptVersionHint = request.promptVersion || "memory-photo-v1";

  return [
    "Transform this photo into a clean premium children's book illustration.",
    "COMPOSITION: keep every subject, pose, framing, and scene layout",
    "exactly as in the original. Do NOT add any new people, animals, or",
    "objects. Do NOT remove or replace any person visible in the photo.",
    "The result must show the same number of subjects in the same positions.",
    "STYLE: clean vector-like illustration with soft but clearly visible",
    "outlines and smooth shape separation. Warm pastel palette —",
    "peach, beige, soft brown, warm cream — colors must be soft but",
    "vivid and saturated enough to feel warm and alive, NOT faded,",
    "NOT grey, NOT washed-out. Apply soft gradients only where needed.",
    "Slightly richer contrast than a watercolor while still feeling gentle.",
    "CHARACTERS: cute slightly-stylized baby proportions, simple but",
    "expressive warm facial features, soft blush on cheeks, healthy",
    "skin tones (warm peach/beige, not pale or desaturated).",
    "QUALITY: clean sharp edges, no blur, no haze, no fog effect,",
    "no painterly texture, not realistic, not a filtered photo,",
    "premium modern baby app illustration.",
    "Do not include text, logos, watermarks, extra limbs, distorted",
    "anatomy, or horror elements.",
    `Internal request type: ${requestTypeHint}.`,
    `Internal prompt version: ${promptVersionHint}.`,
  ].join(" ");
}

function buildLofiPrompt(request: IllustrationRequestData): string {
  const requestTypeHint = request.requestType || "memory-photo-illustration";
  const promptVersionHint = request.promptVersion || "memory-photo-v1";

  return [
    "Create a high-quality image-to-image transformation based on the",
    "provided input image.",
    "Transform the subject into a soft, Lo-Fi 2D anime illustration while",
    "preserving: original facial structure, identity, pose, composition.",
    "STYLE REQUIREMENTS: clean, soft anime linework (not harsh, not overly",
    "detailed). Flat cel-shading with very subtle gradients.",
    "Warm, cozy, nostalgic aesthetic.",
    "SKIN: smooth skin texture, warm peach and soft orange undertones,",
    "subtle rosy blush on cheeks and nose tip,",
    "very light natural grain texture.",
    "HAIR: preserve original hairstyle and flow, add soft natural flyaway",
    "strands, avoid overly sharp or artificial shapes.",
    "LIGHTING: warm cinematic lighting, golden hour glow,",
    "soft shadows, no harsh contrast.",
    "COLOR PALETTE: warm terracotta, soft beige, muted orange tones,",
    "overall warm harmony (no cold tones).",
    "MOOD: cozy, emotional, nostalgic, calm and intimate atmosphere.",
    "QUALITY: high resolution (4k), sharp but soft finish",
    "(no over-sharpening).",
    "IMPORTANT: do not distort facial identity,",
    "do not exaggerate anime features too much,",
    "avoid overly stylized or cartoonish output.",
    `Internal request type: ${requestTypeHint}.`,
    `Internal prompt version: ${promptVersionHint}.`,
  ].join(" ");
}

async function downloadSourceImageForEdit(
  storagePath: string,
): Promise<{bytes: Buffer; mimeType: string; fileName: string}> {
  const parsedPath = parseSourcePhotoStoragePath(storagePath);
  const mimeType =
    parsedPath.extension === "png" ? "image/png" :
      parsedPath.extension === "webp" ? "image/webp" :
        "image/jpeg";

  const [bytes] = await storage.bucket().file(storagePath).download();
  return {
    bytes,
    mimeType,
    fileName: `source.${parsedPath.extension}`,
  };
}

async function saveGeneratedIllustration({
  storagePath,
  imageBytes,
  contentType,
}: {
  storagePath: string;
  imageBytes: Buffer;
  contentType: string;
}): Promise<string> {
  const file = storage.bucket().file(storagePath);
  const downloadToken = randomUUID();
  await file.save(imageBytes, {
    resumable: false,
    contentType,
    metadata: {
      contentType,
      metadata: {
        firebaseStorageDownloadTokens: downloadToken,
      },
    },
  });

  return buildDownloadUrl(file.bucket.name, storagePath, downloadToken);
}

async function deleteGeneratedIllustrationIfPresent(
  storagePath: string,
): Promise<void> {
  try {
    await storage.bucket().file(storagePath).delete({ignoreNotFound: true});
  } catch (error) {
    logger.warn("Failed to delete generated illustration after failure.", {
      storagePath,
      error,
    });
  }
}

function buildDownloadUrl(
  bucketName: string,
  storagePath: string,
  downloadToken: string,
): string {
  const encodedPath = encodeURIComponent(storagePath);
  return `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/` +
    `${encodedPath}?alt=media&token=${downloadToken}`;
}

function toTrimmedString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function toOptionalString(value: unknown): string | null {
  const normalized = toTrimmedString(value);
  return normalized || null;
}

function toCreditConsumption(value: unknown): CreditConsumption | null {
  return isCreditConsumption(value) ? value : null;
}

function isCreditConsumption(value: unknown): value is CreditConsumption {
  return value === "freeIllustrationAvailable" ||
    value === "monthlyCreditsRemaining" ||
    value === "purchasedCreditsRemaining";
}

function parseSourcePhotoStoragePath(
  storagePath: string,
): ParsedSourcePhotoPath {
  const segments = storagePath.split("/");
  if (
    segments.length !== 6 ||
    segments[0] !== "users" ||
    !segments[1] ||
    segments[2] !== "babies" ||
    !segments[3] ||
    segments[4] !== "memories" ||
    !segments[5]
  ) {
    throw new WorkerError(
      "invalid-source-photo-path",
      "Source photo path must match " +
        "users/{uid}/babies/{babyId}/memories/{memoryId}.{ext}.",
    );
  }

  const fileName = segments[5];
  const dotIndex = fileName.lastIndexOf(".");
  if (dotIndex <= 0 || dotIndex === fileName.length - 1) {
    throw new WorkerError(
      "invalid-source-photo-path",
      "Source photo path is missing a valid file extension.",
    );
  }

  const memoryId = fileName.slice(0, dotIndex).trim();
  const extension = fileName.slice(dotIndex + 1).toLowerCase().trim();
  if (!memoryId || !ALLOWED_SOURCE_IMAGE_EXTENSIONS.has(extension)) {
    throw new WorkerError(
      "invalid-source-photo-path",
      "Source photo path must point to a supported image file.",
    );
  }

  return {
    uid: segments[1],
    babyId: segments[3],
    memoryId,
    extension,
  };
}


function resolveDeadlineAwareTimeout(
  deadlineMs: number,
  maxTimeoutMs: number,
): number {
  const remainingMs = deadlineMs - Date.now();
  if (remainingMs <= DEADLINE_SAFETY_MARGIN_MS) {
    throw new WorkerError(
      "worker-deadline-exceeded",
      "Not enough time remained to safely finish the illustration request.",
    );
  }

  return Math.min(
    maxTimeoutMs,
    Math.max(1000, remainingMs - DEADLINE_SAFETY_MARGIN_MS),
  );
}

function normalizeWorkerError(error: unknown): WorkerError {
  if (error instanceof WorkerError) {
    return error;
  }
  if (error instanceof Error) {
    // OpenAI SDK surfaces request timeouts with this message pattern.
    // Tag them with a dedicated code so the Flutter client can show a
    // friendlier "took too long" message instead of a hard failure.
    const msg = error.message ?? "";
    if (
      msg.toLowerCase().includes("timeout") ||
      msg.toLowerCase().includes("timed out") ||
      msg.toLowerCase().includes("connection error") ||
      error.constructor?.name === "APIConnectionTimeoutError"
    ) {
      return new WorkerError(
        "generation-timeout",
        "The illustration took too long to generate. " +
          "Your credit has been refunded — please try again.",
      );
    }
    return new WorkerError("illustration-worker-error", error.message);
  }
  return new WorkerError(
    "illustration-worker-error",
    "Unknown illustration worker error.",
  );
}

class WorkerError extends Error {
  errorCode: string;
  errorMessage: string;

  constructor(errorCode: string, message: string) {
    super(message);
    this.errorCode = errorCode;
    this.errorMessage = message;
  }
}

function serverYearMonth(): string {
  const now = new Date();
  const year = now.getUTCFullYear();
  const month = String(now.getUTCMonth() + 1).padStart(2, "0");
  return `${year}-${month}`;
}

function toIntSafe(value: unknown): number {
  if (typeof value === "number" && Number.isFinite(value)) {
    return Math.trunc(value);
  }
  return 0;
}
