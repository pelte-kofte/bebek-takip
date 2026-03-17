/* eslint-disable require-jsdoc */
import {randomUUID} from "node:crypto";

import {getApp, getApps, initializeApp} from "firebase-admin/app";
import {
  FieldValue,
  Firestore,
  getFirestore,
} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {logger} from "firebase-functions";
import {defineSecret} from "firebase-functions/params";
import {onDocumentCreated} from "firebase-functions/v2/firestore";

if (getApps().length === 0) {
  initializeApp();
} else {
  getApp();
}

const REPLICATE_API_TOKEN = defineSecret("REPLICATE_API_TOKEN");

const REQUEST_COLLECTION = "illustrationRequests";
const CREDIT_DOC_PATH_SUFFIX = "illustrationCredits/balance";
const REQUEST_STATUS_PENDING = "pending";
const REQUEST_STATUS_PROCESSING = "processing";
const REQUEST_STATUS_COMPLETED = "completed";
const REQUEST_STATUS_FAILED = "failed";
const DEFAULT_PLAN_TIER = "free";
const REPLICATE_API_BASE_URL = "https://api.replicate.com/v1";
const REPLICATE_MODEL = "black-forest-labs/flux-kontext-pro";
const REPLICATE_PREFER_WAIT_SECONDS = 60;
const REPLICATE_CANCEL_AFTER = "5m";
const REPLICATE_POLL_INTERVAL_MS = 2500;
const REPLICATE_POLL_TIMEOUT_MS = 5 * 60 * 1000;
const REPLICATE_FETCH_TIMEOUT_MS = 30 * 1000;
const REPLICATE_RESULT_DOWNLOAD_TIMEOUT_MS = 60 * 1000;
const SOURCE_URL_EXPIRY_MS = 15 * 60 * 1000;
const GENERATED_IMAGE_CONTENT_TYPE = "image/jpeg";

type IllustrationRequestData = {
  uid: string;
  babyId: string;
  memoryId: string;
  sourcePhotoStoragePath: string;
  sourcePhotoUrl: string;
  status: string;
  requestType?: string | null;
  promptVersion?: string | null;
  resultStoragePath?: string | null;
  resultImageUrl?: string | null;
  errorCode?: string | null;
  errorMessage?: string | null;
};

type UserIllustrationCredits = {
  freeIllustrationAvailable: boolean;
  monthlyCreditsRemaining: number;
  purchasedCreditsRemaining: number;
  planTier: string;
};

type CreditConsumption =
  | "freeIllustrationAvailable"
  | "monthlyCreditsRemaining"
  | "purchasedCreditsRemaining";

type GenerationResult = {
  imageBytes: Buffer;
  contentType: string;
};

type ReplicatePrediction = {
  id?: string;
  status?: string | null;
  error?: string | null;
  output?: unknown;
  urls?: {
    get?: string | null;
  };
};

type RequestValidationResult =
  | {ok: true; data: IllustrationRequestData}
  | {ok: false; errorCode: string; errorMessage: string};

const db = getFirestore();
const storage = getStorage();

export const processIllustrationRequest = onDocumentCreated(
  {
    document: `${REQUEST_COLLECTION}/{requestId}`,
    region: "us-central1",
    timeoutSeconds: 120,
    memory: "512MiB",
    secrets: [REPLICATE_API_TOKEN],
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
    if (request.status !== REQUEST_STATUS_PENDING) {
      logger.info("Skipping illustration request with non-pending status.", {
        requestId,
        status: request.status,
      });
      return;
    }

    logger.info("Illustration request received.", {
      requestId,
      uid: request.uid,
      babyId: request.babyId,
      memoryId: request.memoryId,
      requestType: request.requestType,
      promptVersion: request.promptVersion,
    });

    await requestRef.update({
      status: REQUEST_STATUS_PROCESSING,
      updatedAt: FieldValue.serverTimestamp(),
      errorCode: null,
      errorMessage: null,
    });

    try {
      const creditCheck = await loadCreditsOrThrow(db, request.uid);
      logger.info("Illustration credit check passed.", {
        requestId,
        uid: request.uid,
        availableCredits: availableCreditsCount(creditCheck.credits),
        planTier: creditCheck.credits.planTier,
      });

      await assertSourcePhotoExists(request.sourcePhotoStoragePath);

      const generationResult = await generateIllustrationFromSource({
        requestId,
        request,
      });

      const resultStoragePath =
          `users/${request.uid}/babies/${request.babyId}/memories/` +
          `${request.memoryId}/illustrations/${requestId}.jpg`;
      const resultImageUrl = await saveGeneratedIllustration({
        storagePath: resultStoragePath,
        imageBytes: generationResult.imageBytes,
        contentType: generationResult.contentType,
      });

      await consumeOneCredit(db, request.uid);

      await requestRef.update({
        status: REQUEST_STATUS_COMPLETED,
        resultStoragePath,
        resultImageUrl,
        updatedAt: FieldValue.serverTimestamp(),
        errorCode: null,
        errorMessage: null,
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
    resultStoragePath: toOptionalString(rawData.resultStoragePath),
    resultImageUrl: toOptionalString(rawData.resultImageUrl),
    errorCode: toOptionalString(rawData.errorCode),
    errorMessage: toOptionalString(rawData.errorMessage),
  };

  const missingFields = [
    ["uid", data.uid],
    ["babyId", data.babyId],
    ["memoryId", data.memoryId],
    ["sourcePhotoStoragePath", data.sourcePhotoStoragePath],
    ["sourcePhotoUrl", data.sourcePhotoUrl],
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

async function loadCreditsOrThrow(
  firestore: Firestore,
  uid: string,
): Promise<{
  credits: UserIllustrationCredits;
}> {
  const ref = firestore
    .doc(`users/${uid}/${CREDIT_DOC_PATH_SUFFIX}`);
  const snapshot = await ref.get();
  const credits = snapshot.exists ?
    creditsFromSnapshot(snapshot.data()) :
    defaultCredits();

  if (availableCreditsCount(credits) <= 0) {
    throw new WorkerError(
      "no-credits-available",
      "No illustration credits are available for this account.",
    );
  }

  return {credits};
}

async function consumeOneCredit(
  firestore: Firestore,
  uid: string,
): Promise<void> {
  const ref = firestore.doc(`users/${uid}/${CREDIT_DOC_PATH_SUFFIX}`);
  await firestore.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const credits = snapshot.exists ?
      creditsFromSnapshot(snapshot.data()) :
      defaultCredits();

    const bucket = pickCreditBucketToConsume(credits);
    if (!bucket) {
      throw new WorkerError(
        "no-credits-available",
        "Credits were no longer available when generation completed.",
      );
    }

    const update: Record<string, unknown> = {
      uid,
      planTier: credits.planTier || DEFAULT_PLAN_TIER,
      updatedAt: FieldValue.serverTimestamp(),
    };
    if (bucket === "freeIllustrationAvailable") {
      update.freeIllustrationAvailable = false;
    } else if (bucket === "monthlyCreditsRemaining") {
      update.monthlyCreditsRemaining =
        Math.max(0, credits.monthlyCreditsRemaining - 1);
    } else {
      update.purchasedCreditsRemaining =
        Math.max(0, credits.purchasedCreditsRemaining - 1);
    }

    transaction.set(ref, update, {merge: true});
  });
}

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
}: {
  requestId: string;
  request: IllustrationRequestData;
}): Promise<GenerationResult> {
  const replicateApiToken = REPLICATE_API_TOKEN.value();
  if (!replicateApiToken) {
    throw new WorkerError(
      "replicate-not-configured",
      "Illustration generation is not configured on the server yet.",
    );
  }

  logger.info("Illustration generation scaffold reached.", {
    requestId,
    uid: request.uid,
    requestType: request.requestType,
    promptVersion: request.promptVersion,
    provider: "replicate",
    model: REPLICATE_MODEL,
  });

  const sourceInputImageUrl = await createSignedSourceImageUrl(
    request.sourcePhotoStoragePath,
  );
  const prompt = buildIllustrationPrompt(request);

  let prediction = await createReplicatePrediction({
    token: replicateApiToken,
    input: {
      prompt,
      input_image: sourceInputImageUrl,
      output_format: "jpg",
    },
  });

  if (isPredictionPending(prediction.status)) {
    prediction = await pollReplicatePredictionUntilTerminal({
      token: replicateApiToken,
      initialPrediction: prediction,
    });
  }

  if (prediction.status !== "succeeded") {
    throw new WorkerError(
      "replicate-prediction-failed",
      prediction.error ||
        "Replicate prediction ended with status " +
          `${prediction.status ?? "unknown"}.`,
    );
  }

  const outputUrl = extractReplicateOutputUrl(prediction.output);
  if (!outputUrl) {
    throw new WorkerError(
      "replicate-missing-output",
      "Replicate completed without a usable image output.",
    );
  }

  return downloadReplicateOutput({
    token: replicateApiToken,
    outputUrl,
  });
}

function buildIllustrationPrompt(request: IllustrationRequestData): string {
  const requestTypeHint = request.requestType || "memory-photo-illustration";
  const promptVersionHint = request.promptVersion || "memory-photo-v1";

  // TODO(illustration-prompt): Replace this with the final hidden prompt once
  // the art direction is approved. Keep all prompt construction server-side.
  return [
    "Transform this baby memory photo into a warm illustrated keepsake.",
    "Preserve the real composition, identity, pose, and emotional tone.",
    "Use a soft storybook illustration style with gentle textures,",
    "clean lines,",
    "subtle depth, cozy lighting, and child-safe family-friendly aesthetics.",
    "Keep the baby and important scene details recognizable.",
    "Do not add text, watermarks, frames, extra limbs, duplicate subjects,",
    "distorted anatomy, horror elements, or unrelated background objects.",
    "Output a polished single illustration suitable for a parenting",
    "memory app.",
    `Internal request type: ${requestTypeHint}.`,
    `Internal prompt version: ${promptVersionHint}.`,
  ].join(" ");
}

async function createSignedSourceImageUrl(
  storagePath: string,
): Promise<string> {
  const file = storage.bucket().file(storagePath);
  const [signedUrl] = await file.getSignedUrl({
    action: "read",
    expires: Date.now() + SOURCE_URL_EXPIRY_MS,
  });
  return signedUrl;
}

async function createReplicatePrediction({
  token,
  input,
}: {
  token: string;
  input: Record<string, unknown>;
}): Promise<ReplicatePrediction> {
  const response = await fetchWithTimeout(
    `${REPLICATE_API_BASE_URL}/models/${REPLICATE_MODEL}/predictions`,
    {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${token}`,
        "Content-Type": "application/json",
        "Prefer": `wait=${REPLICATE_PREFER_WAIT_SECONDS}`,
        "Cancel-After": REPLICATE_CANCEL_AFTER,
      },
      body: JSON.stringify({input}),
    },
    REPLICATE_FETCH_TIMEOUT_MS,
    "replicate-request-timeout",
  );

  if (!response.ok) {
    throw await buildReplicateHttpError(
      response,
      "replicate-request-failed",
      "Replicate prediction creation failed.",
    );
  }

  return response.json() as Promise<ReplicatePrediction>;
}

async function pollReplicatePredictionUntilTerminal({
  token,
  initialPrediction,
}: {
  token: string;
  initialPrediction: ReplicatePrediction;
}): Promise<ReplicatePrediction> {
  const getUrl = initialPrediction.urls?.get;
  if (!getUrl) {
    throw new WorkerError(
      "replicate-missing-get-url",
      "Replicate did not return a polling URL for the prediction.",
    );
  }

  const startedAt = Date.now();
  let latestPrediction = initialPrediction;
  while (isPredictionPending(latestPrediction.status)) {
    if (Date.now() - startedAt > REPLICATE_POLL_TIMEOUT_MS) {
      throw new WorkerError(
        "replicate-poll-timeout",
        "Timed out while waiting for Replicate prediction completion.",
      );
    }

    await sleep(REPLICATE_POLL_INTERVAL_MS);
    const response = await fetchWithTimeout(
      getUrl,
      {
        headers: {
          "Authorization": `Bearer ${token}`,
        },
      },
      REPLICATE_FETCH_TIMEOUT_MS,
      "replicate-poll-request-timeout",
    );

    if (!response.ok) {
      throw await buildReplicateHttpError(
        response,
        "replicate-poll-failed",
        "Replicate prediction polling failed.",
      );
    }

    latestPrediction = await response.json() as ReplicatePrediction;
  }

  return latestPrediction;
}

function isPredictionPending(status: string | null | undefined): boolean {
  return status === "starting" || status === "processing";
}

function extractReplicateOutputUrl(output: unknown): string | null {
  if (typeof output === "string" && output.trim()) {
    return output.trim();
  }

  if (Array.isArray(output)) {
    for (const item of output) {
      const candidate = extractReplicateOutputUrl(item);
      if (candidate) return candidate;
    }
  }

  if (output && typeof output === "object") {
    const record = output as Record<string, unknown>;
    const directUrl = toTrimmedString(record.url);
    if (directUrl) return directUrl;
  }

  return null;
}

async function downloadReplicateOutput({
  token,
  outputUrl,
}: {
  token: string;
  outputUrl: string;
}): Promise<GenerationResult> {
  const response = await fetchWithTimeout(
    outputUrl,
    {
      headers: {
        "Authorization": `Bearer ${token}`,
      },
    },
    REPLICATE_RESULT_DOWNLOAD_TIMEOUT_MS,
    "replicate-output-download-timeout",
  );

  if (!response.ok) {
    throw await buildReplicateHttpError(
      response,
      "replicate-output-download-failed",
      "Failed to download generated illustration from Replicate.",
    );
  }

  const arrayBuffer = await response.arrayBuffer();
  const imageBytes = Buffer.from(arrayBuffer);
  if (imageBytes.length === 0) {
    throw new WorkerError(
      "replicate-empty-output",
      "Replicate returned an empty generated image.",
    );
  }

  const contentType = response.headers.get("content-type")?.trim() ||
    GENERATED_IMAGE_CONTENT_TYPE;
  return {imageBytes, contentType};
}

async function buildReplicateHttpError(
  response: Response,
  errorCode: string,
  fallbackMessage: string,
): Promise<WorkerError> {
  const responseText = await response.text();
  let detail = responseText.trim();

  try {
    const parsed = JSON.parse(responseText) as Record<string, unknown>;
    detail = toTrimmedString(parsed.detail) ||
      toTrimmedString(parsed.error) ||
      detail;
  } catch (_) {
    // Keep the raw response text if it is not JSON.
  }

  return new WorkerError(
    errorCode,
    `${fallbackMessage} HTTP ${response.status}${detail ? `: ${detail}` : ""}`,
  );
}

async function fetchWithTimeout(
  input: string,
  init: RequestInit,
  timeoutMs: number,
  errorCode: string,
): Promise<Response> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);

  try {
    return await fetch(input, {
      ...init,
      signal: controller.signal,
    });
  } catch (error) {
    if (error instanceof Error && error.name === "AbortError") {
      throw new WorkerError(
        errorCode,
        `Timed out after ${timeoutMs}ms.`,
      );
    }
    throw error;
  } finally {
    clearTimeout(timeout);
  }
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
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

function buildDownloadUrl(
  bucketName: string,
  storagePath: string,
  downloadToken: string,
): string {
  const encodedPath = encodeURIComponent(storagePath);
  return `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/` +
    `${encodedPath}?alt=media&token=${downloadToken}`;
}

function creditsFromSnapshot(
  rawData: FirebaseFirestore.DocumentData | undefined,
): UserIllustrationCredits {
  return {
    freeIllustrationAvailable: rawData?.freeIllustrationAvailable !== false,
    monthlyCreditsRemaining: toNonNegativeInt(rawData?.monthlyCreditsRemaining),
    purchasedCreditsRemaining: toNonNegativeInt(
      rawData?.purchasedCreditsRemaining,
    ),
    planTier: toTrimmedString(rawData?.planTier) || DEFAULT_PLAN_TIER,
  };
}

function defaultCredits(): UserIllustrationCredits {
  return {
    freeIllustrationAvailable: true,
    monthlyCreditsRemaining: 0,
    purchasedCreditsRemaining: 0,
    planTier: DEFAULT_PLAN_TIER,
  };
}

function availableCreditsCount(credits: UserIllustrationCredits): number {
  return (credits.freeIllustrationAvailable ? 1 : 0) +
    credits.monthlyCreditsRemaining +
    credits.purchasedCreditsRemaining;
}

function pickCreditBucketToConsume(
  credits: UserIllustrationCredits,
): CreditConsumption | null {
  if (credits.freeIllustrationAvailable) {
    return "freeIllustrationAvailable";
  }
  if (credits.monthlyCreditsRemaining > 0) {
    return "monthlyCreditsRemaining";
  }
  if (credits.purchasedCreditsRemaining > 0) {
    return "purchasedCreditsRemaining";
  }
  return null;
}

function toTrimmedString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function toOptionalString(value: unknown): string | null {
  const normalized = toTrimmedString(value);
  return normalized || null;
}

function toNonNegativeInt(value: unknown): number {
  if (typeof value === "number" && Number.isFinite(value)) {
    return Math.max(0, Math.floor(value));
  }
  return 0;
}

function normalizeWorkerError(error: unknown): WorkerError {
  if (error instanceof WorkerError) {
    return error;
  }
  if (error instanceof Error) {
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
