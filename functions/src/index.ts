import {setGlobalOptions} from "firebase-functions";

setGlobalOptions({maxInstances: 10});

export {
  processIllustrationRequest,
  grantPurchasedIllustrationCredits,
} from "./illustrationRequests.js";
export {
  createInviteCode,
  sendInvitation,
  acceptInvitationCode,
  acceptInvitation,
  cancelInvitation,
  declineInvitation,
  removeMember,
  syncPremiumStatus,
} from "./invitations.js";
export {syncPremiumFromAdaptyWebhook} from "./premiumWebhook.js";
export {notifySharedActivity} from "./activityNotifications.js";
