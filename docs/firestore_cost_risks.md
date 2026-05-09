# Firestore Cost Risks

Firestore cost should remain a priority. The current architecture is functionally workable, but future changes should prefer low-read and low-write sync behavior wherever possible.

## Cost Hotspots

### `ActivityNotificationService._startListening()` -> `VeriYonetici.refreshForCurrentUser()`

- Severity: `high`
- Impact:
  - A small shared activity event can trigger a broad user refresh
  - This increases read volume, listener churn, and startup-like work during normal use
  - It can also add unnecessary UI refresh overhead
- Safe optimization recommendation:
  - Stop using inbox notifications to force a full `refreshForCurrentUser()`
  - Prefer relying on existing shared collection listeners for activity visibility
  - Keep notification handling lightweight and scoped

### `_refreshSharedBabyFromCloud()` full collection reads

- Severity: `high`
- Impact:
  - A scoped refresh still performs full reads of the shared baby metadata, `records`, `medications`, and `medicationLogs`
  - Cost grows with baby history size
  - Cold paths and listener recovery paths become more expensive over time
- Safe optimization recommendation:
  - Reserve full shared baby refresh for true recovery cases
  - Prefer incremental listener-driven updates whenever possible
  - Avoid calling this path for small, known, single-record changes

### `ensureBabySharedCloudSync()` broad invite-time flush

- Severity: `high`
- Impact:
  - Invite-related flows can flush babies, records, memories, medications, and medication logs before the invite action completes
  - This creates broad write amplification at a moment that should ideally stay narrow and predictable
- Safe optimization recommendation:
  - Narrow usage of `ensureBabySharedCloudSync()` to actual repair/backfill cases
  - Avoid unconditional broad flush behavior in invite-time flows

### `_syncActiveBabyRecordsToCloud`

- Severity: `medium`
- Impact:
  - A small change in one record type can still cause broader record-set synchronization for that baby
  - The cost increases with activity history size
- Safe optimization recommendation:
  - Prefer scoped per-document upserts where the calling path already knows which rows changed

### `_syncActiveBabyMemoriesToCloud`

- Severity: `medium`
- Impact:
  - Memory and milestone changes can rewrite the whole memory dataset for the baby
  - This is more expensive than necessary for single-item add/edit/delete
- Safe optimization recommendation:
  - Convert memory and milestone sync to per-document shared writes with the existing stable IDs and tombstone model

### `_syncActiveBabyMedicationsToCloud`

- Severity: `medium`
- Impact:
  - Medication changes can rewrite the full medication set for the baby
  - Write amplification increases as active and historical medications grow
- Safe optimization recommendation:
  - Move medication add/edit/delete toward scoped per-document writes

### `_syncActiveBabyMedicationLogsToCloud`

- Severity: `medium`
- Impact:
  - Medication log changes can rewrite the full medication log set for the baby
  - Daily usage can make this path progressively more expensive
- Safe optimization recommendation:
  - Use per-log scoped sync for add/delete/update where the changed log IDs are already known

## Engineering Note

Firestore cost should remain a standing engineering priority. The safest direction is a low-read, low-write shared sync architecture that:

- avoids full refreshes for small changes
- avoids broad collection rewrites for single-item saves
- reserves full backfill/repair for rare recovery paths only
