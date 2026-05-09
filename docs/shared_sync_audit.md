# Shared Sync Audit

## Release Status

Current release decision: `Go for TestFlight`.

The current shared parenting and activity sync implementation is suitable for TestFlight based on the latest audit. No confirmed shared-sync correctness blocker was found in the core activity flows below.

## Confirmed Working Areas

- Feeding, nursing, diaper, and sleep shared add/edit/delete
- Allergies
- Medications
- Vaccines
- Memories
- Tombstone/delete propagation
- Revoked access pruning

## Sync Safety Notes

### Strict shared writes for key paths

For shared babies, key save/delete paths use strict shared writes rather than silent fire-and-forget behavior. Shared failures are surfaced instead of being treated as success.

### Rollback on shared failure

Several shared activity paths keep a rollback bundle and restore local state when a strict shared sync fails. This reduces the risk of local/remote divergence for shared babies.

### Listener lifecycle

Shared record listeners are explicitly started, stopped, and restarted during refresh and membership changes. Listener cleanup and baby pruning logic are present for revoked or missing access scenarios.

### Permissions and rules

Firestore rules correctly scope shared baby access to owner/member access for the shared collections in active use, including:

- `records`
- `medications`
- `medicationLogs`
- `allergies`

## Non-Blocking Risks

### Notification-triggered full refresh

Shared activity inbox notifications still trigger a broad `refreshForCurrentUser()` call. This is not a correctness blocker, but it increases cost and can create avoidable refresh churn.

### Full collection reads in scoped refresh

`_refreshSharedBabyFromCloud()` still performs full reads of shared baby collections even when the refresh reason is small or localized.

### Invite-time broad flush/backfill

`ensureBabySharedCloudSync()` is used in invite-related flows and can flush broad baby datasets before the invite action proceeds.

### Remaining broad sync for vaccines, memories, and medications

Some save paths still call broad sync helpers instead of smaller per-document shared upserts, especially for:

- Vaccines
- Memories
- Medications
- Medication logs

### Legacy records missing `babyId`

Some legacy local loaders still fall back to the current active baby when `babyId` is missing. This is mainly a compatibility risk for older local records.

### Memory photo eventual propagation

Memory and milestone photos are not fully atomic with record sync. The memory record can sync before the related remote photo becomes available to the co-parent.

## Minimal Safe Fix Order

1. Remove notification-driven full refresh
2. Convert vaccine saves to scoped per-doc sync
3. Convert memory/medication/medication-log saves to scoped per-doc sync
4. Narrow invite-time `ensureBabySharedCloudSync`
5. Add a one-time repair for legacy rows missing `babyId`
