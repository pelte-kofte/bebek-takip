/* eslint-disable require-jsdoc */
import type {Response} from "express";
import {getApp, getApps, initializeApp} from "firebase-admin/app";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {logger} from "firebase-functions";
import {defineSecret} from "firebase-functions/params";
import {onRequest} from "firebase-functions/v2/https";

if (getApps().length === 0) {
  initializeApp();
} else {
  getApp();
}

const ADAPTY_WEBHOOK_AUTH_HEADER = defineSecret("ADAPTY_WEBHOOK_AUTH_HEADER");
const PREMIUM_ACCESS_LEVEL_ID = "premium";

// ---------------------------------------------------------------------------
// Illustration pack → credit mapping
// Single source of truth. Product IDs must match App Store Connect /
// Google Play Console AND the Adapty product configuration exactly.
// ---------------------------------------------------------------------------
const ILLUSTRATION_PACK_CREDITS: Record<string, number> = {
  "illustration_credits_3": 3,
  "illustration_credits_10": 10,
  "illustration_credits_25": 25,
};

type AdaptyAccessLevelUpdatedEvent = {
  customer_user_id?: string | null;
  event_type?: string | null;
  event_properties?: {
    access_level_id?: string | null;
    is_active?: boolean | null;
    profile_event_id?: string | null;
    environment?: string | null;
  } | null;
};

type AdaptyNonSubscriptionPurchaseEvent = {
  customer_user_id?: string | null;
  event_type?: string | null;
  event_properties?: {
    // Adapty's per-event UUID — used as the idempotency key.
    profile_event_id?: string | null;
    // Store product identifier (App Store / Play Store).
    // Adapty sends this as vendor_product_id; fall back to product_id.
    vendor_product_id?: string | null;
    product_id?: string | null;
    environment?: string | null;
  } | null;
};

function isPlainObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

export const syncPremiumFromAdaptyWebhook = onRequest(
  {
    region: "us-central1",
    secrets: [ADAPTY_WEBHOOK_AUTH_HEADER],
  },
  async (request, response) => {
    if (request.method !== "POST") {
      response.status(405).json({error: "method-not-allowed"});
      return;
    }

    const expectedAuthHeader = ADAPTY_WEBHOOK_AUTH_HEADER.value();
    const providedAuthHeader = request.get("Authorization") ?? "";
    if (!expectedAuthHeader || providedAuthHeader !== expectedAuthHeader) {
      logger.warn(
        "Adapty premium webhook rejected due to invalid auth header."
      );
      response.status(401).json({error: "unauthorized"});
      return;
    }

    const payload = request.body;
    if (!isPlainObject(payload) || Object.keys(payload).length === 0) {
      response.status(200).json({});
      return;
    }

    const eventType = (payload as {event_type?: string}).event_type ?? null;

    if (eventType === "access_level_updated") {
      const event = payload as AdaptyAccessLevelUpdatedEvent;

      const uid = event.customer_user_id?.trim();
      if (!uid) {
        logger.warn(
          "Ignoring Adapty access_level_updated without customer_user_id."
        );
        response.status(200).json({ignored: true});
        return;
      }

      const accessLevelId = event.event_properties?.access_level_id?.trim();
      if (accessLevelId !== PREMIUM_ACCESS_LEVEL_ID) {
        logger.info("Ignoring Adapty webhook for non-premium access level.", {
          uid,
          accessLevelId: accessLevelId ?? null,
        });
        response.status(200).json({ignored: true});
        return;
      }

      const isPremium = event.event_properties?.is_active === true;
      await getFirestore().collection("users").doc(uid).set(
        {isPremium},
        {merge: true},
      );

      logger.info("Updated backend premium truth from Adapty webhook.", {
        uid,
        isPremium,
        profileEventId: event.event_properties?.profile_event_id ?? null,
        environment: event.event_properties?.environment ?? null,
      });

      response.status(200).json({ok: true});
      return;
    }

    if (eventType === "non_subscription_purchase") {
      await handleIllustrationPackPurchase(
        payload as AdaptyNonSubscriptionPurchaseEvent,
        response,
      );
      return;
    }

    logger.info("Ignoring unsupported Adapty webhook event.", {
      eventType,
    });
    response.status(200).json({ignored: true});
  }
);

// ---------------------------------------------------------------------------
// Illustration pack credit grant
// ---------------------------------------------------------------------------

/**
 * Handles a verified non_subscription_purchase event from Adapty.
 * Maps the product ID to a credit amount and atomically grants the credits.
 * Idempotent: duplicate events (same profile_event_id) are silently skipped.
 * @param {AdaptyNonSubscriptionPurchaseEvent} event Parsed Adapty
 *   non-subscription purchase webhook payload.
 * @param {Response} response Express response used to return the
 *   webhook result.
 */
async function handleIllustrationPackPurchase(
  event: AdaptyNonSubscriptionPurchaseEvent,
  response: Response,
): Promise<void> {
  const uid = event.customer_user_id?.trim() ?? "";
  const profileEventId = event.event_properties?.profile_event_id?.trim() ?? "";
  // Adapty sends vendor_product_id (store product ID); fall back to product_id.
  const productId = (
    event.event_properties?.vendor_product_id?.trim() ||
    event.event_properties?.product_id?.trim() ||
    ""
  );
  const environment = event.event_properties?.environment?.trim() ?? "unknown";

  if (!uid || !profileEventId || !productId) {
    logger.warn("non_subscription_purchase missing required fields.", {
      uid: uid || null,
      profileEventId: profileEventId || null,
      productId: productId || null,
    });
    // Return 200 so Adapty does not retry a structurally invalid event.
    response.status(200).json({ignored: true});
    return;
  }

  const creditsToGrant = ILLUSTRATION_PACK_CREDITS[productId];
  if (creditsToGrant == null) {
    logger.info("non_subscription_purchase for unknown product — ignored.", {
      uid,
      productId,
      environment,
    });
    response.status(200).json({ignored: true});
    return;
  }

  const db = getFirestore();
  const grantRef = db
    .collection("users")
    .doc(uid)
    .collection("illustrationCreditGrants")
    .doc(profileEventId);
  const creditsRef = db
    .collection("users")
    .doc(uid)
    .collection("illustrationCredits")
    .doc("balance");

  let duplicate = false;

  await db.runTransaction(async (tx) => {
    const grantSnap = await tx.get(grantRef);
    if (grantSnap.exists) {
      duplicate = true;
      return; // idempotent — no writes
    }

    const creditsSnap = await tx.get(creditsRef);
    const current = toIntSafe(
      (creditsSnap.data() ?? {})["purchasedCreditsRemaining"],
    );

    tx.set(
      creditsRef,
      {
        purchasedCreditsRemaining: current + creditsToGrant,
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
    );

    tx.set(grantRef, {
      profileEventId,
      productId,
      creditsGranted: creditsToGrant,
      environment,
      grantedAt: FieldValue.serverTimestamp(),
    });
  });

  if (duplicate) {
    logger.info("Duplicate illustration credit grant skipped (idempotent).", {
      uid,
      profileEventId,
      productId,
    });
  } else {
    logger.info("Illustration credits granted from verified purchase.", {
      uid,
      productId,
      creditsGranted: creditsToGrant,
      profileEventId,
      environment,
    });
  }

  response.status(200).json({ok: true});
}

function toIntSafe(value: unknown): number {
  if (typeof value === "number" && Number.isFinite(value)) {
    return Math.trunc(value);
  }
  return 0;
}
