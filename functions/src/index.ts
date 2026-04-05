import {setGlobalOptions} from "firebase-functions";

setGlobalOptions({maxInstances: 10});

export {
  processIllustrationRequest,
  grantPurchasedIllustrationCredits,
} from "./illustrationRequests.js";
export {
  sendInvitation,
  acceptInvitation,
  declineInvitation,
  syncPremiumStatus,
} from "./invitations.js";
export {syncPremiumFromAdaptyWebhook} from "./premiumWebhook.js";
