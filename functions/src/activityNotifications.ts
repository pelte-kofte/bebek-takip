/* eslint-disable require-jsdoc */
import {getApp, getApps, initializeApp} from "firebase-admin/app";
import {FieldValue, getFirestore, Timestamp} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {HttpsError, onCall} from "firebase-functions/v2/https";

if (getApps().length === 0) {
  initializeApp();
} else {
  getApp();
}

const VALID_ACTIVITY_TYPES = new Set([
  "feeding", "sleep", "diaper", "medication",
]);

const ACTIVITY_LABELS: Record<string, string> = {
  feeding: "a feeding",
  sleep: "sleep",
  diaper: "a diaper change",
  medication: "medication",
};

/**
 * Notifies all co-parents of a shared baby when an activity is logged.
 *
 * Callable by any authenticated user who is the owner or a member of the baby.
 * The caller is excluded from the recipient list (no self-notification).
 * Returns early with {notified: 0} for babies with no co-parents.
 *
 * Writes to users/{recipientUid}/inboxNotifications — picked up by the
 * Flutter ActivityNotificationService stream on the recipient's device.
 */
export const notifySharedActivity = onCall(
  {region: "us-central1"},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in.");
    }
    const callerUid = request.auth.uid;
    const {babyId, activityType, babyName} = request.data ?? {};

    // ── Input validation ───────────────────────────────────────────────────
    if (!babyId || typeof babyId !== "string" || babyId.trim() === "") {
      throw new HttpsError("invalid-argument", "babyId is required.");
    }
    if (
      !activityType ||
      typeof activityType !== "string" ||
      !VALID_ACTIVITY_TYPES.has(activityType)
    ) {
      // Unknown type — not an error, just a no-op.
      return {notified: 0};
    }

    const db = getFirestore();
    const babyRef = db.collection("babies").doc(babyId.trim());

    // ── Load baby doc ──────────────────────────────────────────────────────
    const babySnap = await babyRef.get();
    if (!babySnap.exists) return {notified: 0};

    const babyData = babySnap.data() ?? {};
    const ownerId = (babyData.ownerId as string) ?? "";
    const members = (babyData.members as Record<string, unknown>) ?? {};

    // ── Verify caller is a participant ─────────────────────────────────────
    const isParticipant =
      callerUid === ownerId ||
      Object.prototype.hasOwnProperty.call(members, callerUid);
    if (!isParticipant) {
      // Silently ignore — don't leak baby existence to non-participants.
      return {notified: 0};
    }

    // ── Build recipient list (all participants minus the caller) ───────────
    const allParticipants = new Set<string>([ownerId, ...Object.keys(members)]);
    allParticipants.delete(callerUid);
    if (allParticipants.size === 0) return {notified: 0};

    // ── Build notification body ────────────────────────────────────────────
    const name =
      typeof babyName === "string" && babyName.trim() !== "" ?
        babyName.trim() :
        "Baby";
    const label = ACTIVITY_LABELS[activityType] ?? activityType;
    const body = `${name} had ${label} logged.`;

    // ── Write notification docs ────────────────────────────────────────────
    const batch = db.batch();
    for (const uid of allParticipants) {
      const ref = db
        .collection("users")
        .doc(uid)
        .collection("inboxNotifications")
        .doc();
      batch.set(ref, {
        activityType,
        babyId: babyId.trim(),
        babyName: name,
        actorUid: callerUid,
        body,
        createdAt: FieldValue.serverTimestamp(),
        read: false,
      });
    }
    await batch.commit();

    logger.info("notifySharedActivity: notified", {
      babyId,
      activityType,
      callerUid,
      recipientCount: allParticipants.size,
    });

    return {notified: allParticipants.size};
  }
);

/**
 * Prunes old inboxNotifications for a user (max 50 most recent kept).
 * Triggered by a Firestore write so cleanup is automatic — no cron needed.
 * Exported for potential future use; not registered as a trigger here to keep
 * the footprint minimal. Callers can invoke it via a scheduled function
 * if needed.
 * @param {string} uid The UID of the user whose notifications to prune.
 * @param {number} keepCount Max notifications to retain (default 50).
 */
export async function pruneInboxNotifications(
  uid: string,
  keepCount = 50
): Promise<void> {
  const db = getFirestore();
  const col = db
    .collection("users")
    .doc(uid)
    .collection("inboxNotifications");

  const snap = await col.orderBy("createdAt", "desc").offset(keepCount).get();
  if (snap.empty) return;

  const batch = db.batch();
  for (const doc of snap.docs) {
    batch.delete(doc.ref);
  }
  await batch.commit();
  logger.info("pruneInboxNotifications: pruned", {
    uid,
    deleted: snap.size,
  });
}

// Re-export Timestamp for use in other modules if needed.
export {Timestamp};
