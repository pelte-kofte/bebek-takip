/* eslint-disable require-jsdoc */
import {getApp, getApps, initializeApp} from "firebase-admin/app";
import {FieldValue, getFirestore, Timestamp} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {defineSecret} from "firebase-functions/params";
import {HttpsError, onCall} from "firebase-functions/v2/https";

if (getApps().length === 0) {
  initializeApp();
} else {
  getApp();
}

const INVITATIONS_COLLECTION = "babyInvitations";
const INVITATION_EXPIRY_HOURS = 48;
const PREMIUM_ACCESS_LEVEL_ID = "premium";
const ADAPTY_SECRET_API_KEY = defineSecret("ADAPTY_SECRET_API_KEY");

type AdaptyProfileResponse = {
  data?: {
    access_levels?: Array<{
      access_level_id?: string | null;
      starts_at?: string | null;
      expires_at?: string | null;
    }> | null;
  } | null;
};

function isValidEmail(email: string): boolean {
  // RFC-5322 lite: local@domain.tld
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function parseAdaptyDate(value: string | null | undefined): Date | null {
  if (value == null || value.trim() === "") return null;
  const parsed = Date.parse(value);
  return Number.isNaN(parsed) ? null : new Date(parsed);
}

function hasActivePremiumAccess(profile: AdaptyProfileResponse): boolean {
  const levels = profile.data?.access_levels ?? [];
  const premiumLevel = levels.find(
    (level) => level.access_level_id === PREMIUM_ACCESS_LEVEL_ID
  );
  if (!premiumLevel) return false;

  const now = new Date();
  const startsAt = parseAdaptyDate(premiumLevel.starts_at);
  if (startsAt != null && startsAt > now) return false;

  const expiresAt = parseAdaptyDate(premiumLevel.expires_at);
  if (expiresAt == null) return true;
  return expiresAt > now;
}

async function syncPremiumTruthFromAdapty(
  uid: string
): Promise<boolean> {
  const apiKey = ADAPTY_SECRET_API_KEY.value();
  if (!apiKey) {
    logger.error("syncPremiumTruthFromAdapty: missing secret API key");
    return false;
  }

  const response = await fetch(
    "https://api.adapty.io/api/v2/server-side-api/profile/",
    {
      method: "GET",
      headers: {
        "Accept": "application/json",
        "Authorization": `Api-Key ${apiKey}`,
        "adapty-customer-user-id": uid,
      },
    }
  );

  if (response.status === 404) {
    // Profile not found on Adapty. Do NOT write isPremium: false here — this
    // can happen immediately after a purchase or account creation before Adapty
    // has fully processed the receipt. Writing false would create a permanent
    // false-negative that blocks the user. The webhook will write the correct
    // value once Adapty finishes processing.
    logger.warn(
      "syncPremiumTruthFromAdapty: Adapty profile not found, skipping write",
      {uid}
    );
    return false;
  }

  if (!response.ok) {
    logger.error("syncPremiumTruthFromAdapty: profile fetch failed", {
      uid,
      status: response.status,
    });
    return false;
  }

  const profile = await response.json() as AdaptyProfileResponse;
  const isPremium = hasActivePremiumAccess(profile);
  await getFirestore().collection("users").doc(uid).set({
    isPremium,
  }, {merge: true});
  return isPremium;
}

export const syncPremiumStatus = onCall(
  {
    region: "us-central1",
    secrets: [ADAPTY_SECRET_API_KEY],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in.");
    }

    const isPremium = await syncPremiumTruthFromAdapty(request.auth.uid);
    return {isPremium};
  }
);

export const sendInvitation = onCall(
  {
    region: "us-central1",
    secrets: [ADAPTY_SECRET_API_KEY],
  },
  async (request) => {
    // 1. Auth
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in.");
    }
    const callerUid = request.auth.uid;

    // 2. Input validation
    const {babyId, inviteeEmail: rawEmail} = request.data ?? {};

    if (
      !babyId ||
      typeof babyId !== "string" ||
      babyId.trim() === ""
    ) {
      throw new HttpsError("invalid-argument", "babyId is required.");
    }
    if (
      !rawEmail ||
      typeof rawEmail !== "string" ||
      rawEmail.trim() === ""
    ) {
      throw new HttpsError("invalid-argument", "inviteeEmail is required.");
    }

    const inviteeEmail = rawEmail.trim().toLowerCase();
    if (!isValidEmail(inviteeEmail)) {
      throw new HttpsError(
        "invalid-argument",
        "inviteeEmail is not a valid email address."
      );
    }

    const db = getFirestore();

    // 3. Baby ownership check
    // Source of truth for ownership is babies/{babyId}.ownerId.
    // We load the top-level document and assert ownerId == callerUid.
    const babyRef = db.collection("babies").doc(babyId.trim());
    const babySnap = await babyRef.get();

    if (!babySnap.exists) {
      throw new HttpsError("not-found", "Baby not found.");
    }

    const babyData = babySnap.data();
    if (!babyData) {
      throw new HttpsError("not-found", "Baby not found.");
    }

    if (babyData.ownerId !== callerUid) {
      logger.error("sendInvitation: ownership check failed", {
        babyId,
        callerUid,
        recordedOwnerId: babyData.ownerId ?? null,
      });
      throw new HttpsError(
        "permission-denied", "Not the baby owner.");
    }

    // 4. Premium check
    // We read users/{callerUid}.isPremium from Firestore (server-side only).
    //
    // TODO(premium-backend): This field must be written by a TRUSTED backend
    // source, never by the client. Recommended options:
    //   a) Adapty webhook → a dedicated Cloud Function → admin SDK write
    //      users/{uid}.isPremium = true/false
    //   b) Firebase Extension "Adapty Entitlements" (if available)
    //   c) For testing: manually set the field via Firebase Console
    //      or admin SDK.
    //
    // The current Firestore rules MUST deny client writes to this field.
    // Until the webhook is wired, test by setting the field manually.
    const userSnap = await db.collection("users").doc(callerUid).get();
    const isPremium = userSnap.exists && userSnap.data()?.isPremium === true;

    if (!isPremium) {
      throw new HttpsError(
        "permission-denied",
        "Shared Parenting requires a premium subscription."
      );
    }

    // 5. Duplicate invitation check
    logger.info("Checking for existing pending invitation", {
      babyId,
      inviteeEmail,
    });
    const duplicateQuery = await db
      .collection(INVITATIONS_COLLECTION)
      .where("babyId", "==", babyId.trim())
      .where("inviteeEmail", "==", inviteeEmail)
      .where("status", "==", "pending")
      .limit(1)
      .get();

    if (!duplicateQuery.empty) {
      const existingId = duplicateQuery.docs[0].id;
      logger.info("Returning existing pending invitation", {
        invitationId: existingId,
        babyId,
        inviteeEmail,
      });
      return {
        success: true,
        existingInvitation: true,
        invitationId: existingId,
      };
    }

    // 6 & 7. Write invitation
    const expiresAt = new Date(
      Date.now() + INVITATION_EXPIRY_HOURS * 60 * 60 * 1000
    );

    logger.info("Before creating invitation");
    logger.info("Creating invitation", {babyId, email: inviteeEmail});

    const docRef = await db
      .collection(INVITATIONS_COLLECTION)
      .add({
        babyId: babyId.trim(),
        babyName: babyData.name ?? null,
        ownerUid: callerUid,
        ownerDisplayName: request.auth.token.name ?? null,
        inviteeEmail,
        status: "pending",
        createdAt: FieldValue.serverTimestamp(),
        expiresAt,
      });

    logger.info("Invitation created", {id: docRef.id});

    // 8. Return — only reached after confirmed Firestore write
    return {
      success: true,
      existingInvitation: false,
      invitationId: docRef.id,
    };
  }
);

// ─────────────────────────────────────────────────────────────────────────────

/**
 * Parses a Firestore Timestamp or Date-like value into a JS Date.
 * @param {unknown} value Date-like value from Firestore.
 * @return {Date} Parsed date instance.
 */
function toDate(value: unknown): Date {
  if (value instanceof Timestamp) return value.toDate();
  if (value instanceof Date) return value;
  return new Date(value as string | number);
}

/**
 * Validates a loaded invitation document against the calling user.
 * Shared pre-flight for acceptInvitation and declineInvitation.
 * @param {FirebaseFirestore.DocumentData} inv Invitation document data.
 * @param {string} callerEmail Signed-in caller email.
 */
function validateInvitationForCallee(
  inv: FirebaseFirestore.DocumentData,
  callerEmail: string
): void {
  if (inv.status !== "pending") {
    throw new HttpsError(
      "failed-precondition",
      "Invitation is no longer pending."
    );
  }
  if (toDate(inv.expiresAt) <= new Date()) {
    throw new HttpsError("deadline-exceeded", "Invitation has expired.");
  }
  if (inv.inviteeEmail !== callerEmail) {
    throw new HttpsError(
      "permission-denied",
      "This invitation is not addressed to you."
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

export const acceptInvitation = onCall(
  {region: "us-central1"},
  async (request) => {
    // 1. Auth
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in.");
    }
    const callerUid = request.auth.uid;
    const callerEmail =
      (request.auth.token.email ?? "").trim().toLowerCase();

    if (!callerEmail) {
      throw new HttpsError(
        "failed-precondition",
        "Caller account has no verified email address."
      );
    }

    // 2. Input validation
    const {invitationId} = request.data ?? {};

    if (
      !invitationId ||
      typeof invitationId !== "string" ||
      invitationId.trim() === ""
    ) {
      throw new HttpsError("invalid-argument", "invitationId is required.");
    }

    const db = getFirestore();
    const invitationRef = db
      .collection(INVITATIONS_COLLECTION)
      .doc(invitationId.trim());

    // 3. Load invitation
    const invitationSnap = await invitationRef.get();

    if (!invitationSnap.exists) {
      throw new HttpsError("not-found", "Invitation not found.");
    }

    // 4. Validate invitation
    // Pre-flight outside the transaction to return clear errors immediately.
    const invData = invitationSnap.data();
    if (!invData) {
      throw new HttpsError("not-found", "Invitation not found.");
    }
    validateInvitationForCallee(invData, callerEmail);

    const babyId: string = invData.babyId;
    const babyRef = db.collection("babies").doc(babyId);

    // 5. Transaction
    await db.runTransaction(async (tx) => {
      // Re-read invitation inside the transaction to guard against races.
      const invSnap = await tx.get(invitationRef);
      const txInvitation = invSnap.data();
      if (
        !invSnap.exists ||
        !txInvitation ||
        txInvitation.status !== "pending"
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Invitation is no longer pending."
        );
      }

      // a+b. Load baby and verify it still exists.
      const babySnap = await tx.get(babyRef);
      if (!babySnap.exists) {
        throw new HttpsError("not-found", "Baby no longer exists.");
      }

      // c. Add caller to babies/{babyId}.members
      // (dot-path merge keeps other members).
      tx.update(babyRef, {
        [`members.${callerUid}`]: {
          role: "member",
          joinedAt: FieldValue.serverTimestamp(),
        },
      });

      // d. Write users/{callerUid}/sharedBabies/{babyId}.
      const sharedBabyRef = db
        .collection("users")
        .doc(callerUid)
        .collection("sharedBabies")
        .doc(babyId);

      tx.set(sharedBabyRef, {
        babyId,
        role: "member",
        addedAt: FieldValue.serverTimestamp(),
      });

      // e. Mark invitation accepted.
      tx.update(invitationRef, {status: "accepted"});
    });

    logger.info("acceptInvitation: accepted", {
      invitationId,
      callerUid,
      babyId,
    });

    // 6. Return
    return {success: true, babyId};
  }
);

// ─────────────────────────────────────────────────────────────────────────────

export const declineInvitation = onCall(
  {region: "us-central1"},
  async (request) => {
    // 1. Auth
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in.");
    }
    const callerUid = request.auth.uid;
    const callerEmail =
      (request.auth.token.email ?? "").trim().toLowerCase();

    if (!callerEmail) {
      throw new HttpsError(
        "failed-precondition",
        "Caller account has no verified email address."
      );
    }

    // 2. Input validation
    const {invitationId} = request.data ?? {};

    if (
      !invitationId ||
      typeof invitationId !== "string" ||
      invitationId.trim() === ""
    ) {
      throw new HttpsError("invalid-argument", "invitationId is required.");
    }

    const db = getFirestore();
    const invitationRef = db
      .collection(INVITATIONS_COLLECTION)
      .doc(invitationId.trim());

    // 3. Load and validate invitation
    const invitationSnap = await invitationRef.get();

    if (!invitationSnap.exists) {
      throw new HttpsError("not-found", "Invitation not found.");
    }

    const invitationData = invitationSnap.data();
    if (!invitationData) {
      throw new HttpsError("not-found", "Invitation not found.");
    }
    validateInvitationForCallee(invitationData, callerEmail);

    // 4. Mark declined
    await invitationRef.update({status: "declined"});

    logger.info("declineInvitation: declined", {invitationId, callerUid});

    return {success: true};
  }
);
