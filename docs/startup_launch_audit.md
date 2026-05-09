# Startup Launch Audit

## Summary

This audit focused on the cold-start white screen and launch delay before the first visible app or onboarding screen appears.

## Confirmed Cause

The most likely cause is heavy awaited work before `runApp()`, combined with an almost blank iOS native launch screen while that work runs.

Confirmed startup blockers before first Flutter UI paint include:

- `Firebase.initializeApp`
- anonymous session bootstrap
- `VeriYonetici.init`
- `_syncFromCloudIfSignedIn`
- `_loadSharedBabiesFromCloud`
- `TimerYonetici.init`
- `SyncManager.syncCurrentUserData`
- a blank-looking `iOS LaunchScreen.storyboard`

## Startup Timeline

1. Native iOS launch screen is shown first
2. Flutter bindings are initialized
3. Firebase is initialized
4. Anonymous auth bootstrap is awaited
5. `VeriYonetici.init()` is awaited
6. `VeriYonetici.init()` performs local cache setup plus cloud/shared startup work
7. Timer and notification startup is awaited inside `VeriYonetici.init()`
8. `SyncManager.syncCurrentUserData()` performs another broad refresh before `runApp()`
9. Only after all of the above does Flutter render `SplashScreen`

## Blockers vs Secondary Causes

### Primary blockers

- Heavy awaited work before `runApp()`
- Cloud sync during cold start
- Shared baby loading during cold start
- Timer/notification initialization during cold start
- A second startup sync before any Flutter UI appears
- A nearly blank white native launch screen on iOS

### Secondary causes

- The in-app `SplashScreen` only appears after `runApp()`, so it is not the root cause of the white screen
- The splash hero asset may add some in-app decode cost, but it is not the main cause of the pre-Flutter delay
- Premium initialization is not a first-frame blocker because it is started asynchronously after boot work

## Safe Fix Plan

- Render Flutter UI earlier
- Split startup work into:
  - must happen before first frame
  - safe to run after first frame
- Avoid duplicate startup sync
- Defer notification permission requests
- Keep shared sync correctness by changing timing, not logic
- Improve native iOS launch screen artwork and color treatment

## Fix Scope

### Flutter-only changes

Flutter-side startup restructuring is enough to fix the real first-frame blocking problem.

### Native iOS changes

Native iOS launch screen improvements will not fix the root blocking by themselves, but they will significantly improve the perceived blank white launch experience.

### Best result

The best result requires both:

- Flutter startup timing improvements
- native iOS launch screen improvements
