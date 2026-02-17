import Flutter
import UIKit
import Foundation
#if canImport(ActivityKit)
import ActivityKit
#endif

class LiveActivityHandler {

    static let shared = LiveActivityHandler()

    // MARK: - App Group Configuration
    private let appGroupID = "group.com.Nilico.Baby"
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupID)
    }

    // MARK: - Registration

    func register(with registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "LiveActivityHandler") else { return }

    let channel = FlutterMethodChannel(
        name: "com.Nilico.Baby/liveActivity",
        binaryMessenger: registrar.messenger()
    )

    channel.setMethodCallHandler { [weak self] (call, result) in
        guard let self = self else {
            result(FlutterError(code: "UNAVAILABLE", message: "Handler deallocated", details: nil))
            return
        }

        switch call.method {
        case "startSleepLiveActivity":
            self.handleStartSleep(call: call, result: result)
        case "updateSleepLiveActivity":
            self.handleUpdateSleep(call: call, result: result)
        case "stopSleepLiveActivity":
            self.handleStopSleep(call: call, result: result)
        case "startNursingLiveActivity":
            self.handleStartNursing(call: call, result: result)
        case "updateNursingSide":
            self.handleUpdateNursingSide(call: call, result: result)
        case "stopNursingLiveActivity":
            self.handleStopNursing(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

    // MARK: - Sleep Handlers

    private func handleStartSleep(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let babyId = args["babyId"] as? String,
              let startEpochSeconds = args["startEpochSeconds"] as? Int else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        let localizedTitle = (args["localizedTitle"] as? String) ?? "Sleep"
        let localizedSubtitle = (args["localizedSubtitle"] as? String) ?? ""
        let babyName = (args["babyName"] as? String) ?? ""

        let data: [String: Any] = [
            "babyId": babyId,
            "activityType": "sleep",
            "startEpochSeconds": startEpochSeconds,
            "babyName": babyName,
            "localizedTitle": localizedTitle,
            "localizedSubtitle": localizedSubtitle,
            "isActive": true
        ]

        writeToAppGroup(key: "liveactivity_sleep_\(babyId)", data: data)
        startSleepActivity(
            babyId: babyId,
            startEpochSeconds: startEpochSeconds,
            babyName: babyName,
            localizedTitle: localizedTitle,
            localizedSubtitle: localizedSubtitle,
            result: result
        )
    }

    private func handleUpdateSleep(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let babyId = args["babyId"] as? String else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        let localizedTitle = (args["localizedTitle"] as? String) ?? "Sleep"
        let localizedSubtitle = (args["localizedSubtitle"] as? String) ?? ""
        let babyName = (args["babyName"] as? String) ?? ""
        let key = "liveactivity_sleep_\(babyId)"
        if var existingData = readFromAppGroup(key: key) {
            existingData["babyName"] = babyName
            existingData["localizedTitle"] = localizedTitle
            existingData["localizedSubtitle"] = localizedSubtitle
            writeToAppGroup(key: key, data: existingData)
        }

        updateSleepActivity(
            babyId: babyId,
            babyName: babyName,
            localizedTitle: localizedTitle,
            localizedSubtitle: localizedSubtitle,
            result: result
        )
    }

    private func handleStopSleep(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let babyId = args["babyId"] as? String else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        removeFromAppGroup(key: "liveactivity_sleep_\(babyId)")
        stopActivity(babyId: babyId, type: "sleep", result: result)
    }

    // MARK: - Nursing Handlers

    private func handleStartNursing(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let babyId = args["babyId"] as? String,
              let startEpochSeconds = args["startEpochSeconds"] as? Int,
              let side = args["side"] as? String else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        let localizedTitle = (args["localizedTitle"] as? String) ?? "Nursing"
        let localizedSubtitle = (args["localizedSubtitle"] as? String) ?? ""
        let babyName = (args["babyName"] as? String) ?? ""

        let data: [String: Any] = [
            "babyId": babyId,
            "activityType": "nursing",
            "startEpochSeconds": startEpochSeconds,
            "side": side,
            "babyName": babyName,
            "localizedTitle": localizedTitle,
            "localizedSubtitle": localizedSubtitle,
            "isActive": true
        ]

        writeToAppGroup(key: "liveactivity_nursing_\(babyId)", data: data)
        startNursingActivity(
            babyId: babyId,
            startEpochSeconds: startEpochSeconds,
            side: side,
            babyName: babyName,
            localizedTitle: localizedTitle,
            localizedSubtitle: localizedSubtitle,
            result: result
        )
    }

    private func handleUpdateNursingSide(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let babyId = args["babyId"] as? String,
              let side = args["side"] as? String else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        // Read existing data, update side
        let key = "liveactivity_nursing_\(babyId)"
        let localizedTitle = (args["localizedTitle"] as? String) ?? "Nursing"
        let localizedSubtitle = (args["localizedSubtitle"] as? String) ?? ""
        let babyName = (args["babyName"] as? String) ?? ""

        if var existingData = readFromAppGroup(key: key) {
            existingData["side"] = side
            existingData["babyName"] = babyName
            existingData["localizedTitle"] = localizedTitle
            existingData["localizedSubtitle"] = localizedSubtitle
            writeToAppGroup(key: key, data: existingData)
        }

        updateNursingSideActivity(
            babyId: babyId,
            side: side,
            babyName: babyName,
            localizedTitle: localizedTitle,
            localizedSubtitle: localizedSubtitle,
            result: result
        )
    }

    private func handleStopNursing(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let babyId = args["babyId"] as? String else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        removeFromAppGroup(key: "liveactivity_nursing_\(babyId)")
        stopActivity(babyId: babyId, type: "nursing", result: result)
    }

    // MARK: - ActivityKit Integration

    private func startSleepActivity(
        babyId: String,
        startEpochSeconds: Int,
        babyName: String,
        localizedTitle: String,
        localizedSubtitle: String,
        result: @escaping FlutterResult
    ) {
#if canImport(ActivityKit)
        guard #available(iOS 16.1, *) else {
            result(nil)
            return
        }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            result(FlutterError(code: "LIVE_ACTIVITY_DISABLED", message: "Live Activities are disabled", details: nil))
            return
        }

        Task {
            do {
                try await endActivities(babyId: babyId, type: "sleep")

                let attributes = BabyTimerAttributes(babyId: babyId, activityType: "sleep")
                let state = BabyTimerAttributes.ContentState(
                    startDate: Date(timeIntervalSince1970: TimeInterval(startEpochSeconds)),
                    side: nil,
                    babyName: babyName,
                    localizedTitle: localizedTitle,
                    localizedSubtitle: localizedSubtitle.isEmpty ? nil : localizedSubtitle
                )

                if #available(iOS 16.2, *) {
                    let content = ActivityContent(state: state, staleDate: nil)
                    _ = try Activity.request(attributes: attributes, content: content, pushType: nil)
                } else {
                    _ = try Activity.request(attributes: attributes, contentState: state, pushType: nil)
                }
                result(nil)
            } catch {
                result(FlutterError(code: "LIVE_ACTIVITY_START_FAILED", message: error.localizedDescription, details: nil))
            }
        }
#else
        result(nil)
#endif
    }

    private func updateSleepActivity(
        babyId: String,
        babyName: String,
        localizedTitle: String,
        localizedSubtitle: String,
        result: @escaping FlutterResult
    ) {
#if canImport(ActivityKit)
        guard #available(iOS 16.1, *) else {
            result(nil)
            return
        }

        Task {
            let activities = matchingActivities(babyId: babyId, type: "sleep")
            for activity in activities {
                let updatedState = BabyTimerAttributes.ContentState(
                    startDate: activity.contentState.startDate,
                    side: activity.contentState.side,
                    babyName: babyName,
                    localizedTitle: localizedTitle,
                    localizedSubtitle: localizedSubtitle.isEmpty ? nil : localizedSubtitle
                )
                if #available(iOS 16.2, *) {
                    let content = ActivityContent(state: updatedState, staleDate: nil)
                    await activity.update(content)
                } else {
                    await activity.update(using: updatedState)
                }
            }
            result(nil)
        }
#else
        result(nil)
#endif
    }

    private func startNursingActivity(
        babyId: String,
        startEpochSeconds: Int,
        side: String,
        babyName: String,
        localizedTitle: String,
        localizedSubtitle: String,
        result: @escaping FlutterResult
    ) {
#if canImport(ActivityKit)
        guard #available(iOS 16.1, *) else {
            result(nil)
            return
        }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            result(FlutterError(code: "LIVE_ACTIVITY_DISABLED", message: "Live Activities are disabled", details: nil))
            return
        }

        Task {
            do {
                try await endActivities(babyId: babyId, type: "nursing")

                let attributes = BabyTimerAttributes(babyId: babyId, activityType: "nursing")
                let state = BabyTimerAttributes.ContentState(
                    startDate: Date(timeIntervalSince1970: TimeInterval(startEpochSeconds)),
                    side: side,
                    babyName: babyName,
                    localizedTitle: localizedTitle,
                    localizedSubtitle: localizedSubtitle.isEmpty ? nil : localizedSubtitle
                )

                if #available(iOS 16.2, *) {
                    let content = ActivityContent(state: state, staleDate: nil)
                    _ = try Activity.request(attributes: attributes, content: content, pushType: nil)
                } else {
                    _ = try Activity.request(attributes: attributes, contentState: state, pushType: nil)
                }
                result(nil)
            } catch {
                result(FlutterError(code: "LIVE_ACTIVITY_START_FAILED", message: error.localizedDescription, details: nil))
            }
        }
#else
        result(nil)
#endif
    }

    private func updateNursingSideActivity(
        babyId: String,
        side: String,
        babyName: String,
        localizedTitle: String,
        localizedSubtitle: String,
        result: @escaping FlutterResult
    ) {
#if canImport(ActivityKit)
        guard #available(iOS 16.1, *) else {
            result(nil)
            return
        }

        Task {
            let activities = matchingActivities(babyId: babyId, type: "nursing")
            for activity in activities {
                let updatedState = BabyTimerAttributes.ContentState(
                    startDate: activity.contentState.startDate,
                    side: side,
                    babyName: babyName,
                    localizedTitle: localizedTitle,
                    localizedSubtitle: localizedSubtitle.isEmpty ? nil : localizedSubtitle
                )
                if #available(iOS 16.2, *) {
                    let content = ActivityContent(state: updatedState, staleDate: nil)
                    await activity.update(content)
                } else {
                    await activity.update(using: updatedState)
                }
            }
            result(nil)
        }
#else
        result(nil)
#endif
    }

    private func stopActivity(babyId: String, type: String, result: @escaping FlutterResult) {
#if canImport(ActivityKit)
        guard #available(iOS 16.1, *) else {
            result(nil)
            return
        }

        Task {
            do {
                try await endActivities(babyId: babyId, type: type)
                result(nil)
            } catch {
                result(FlutterError(code: "LIVE_ACTIVITY_STOP_FAILED", message: error.localizedDescription, details: nil))
            }
        }
#else
        result(nil)
#endif
    }

#if canImport(ActivityKit)
    @available(iOS 16.1, *)
    private func matchingActivities(babyId: String, type: String) -> [Activity<BabyTimerAttributes>] {
        Activity<BabyTimerAttributes>.activities.filter {
            $0.attributes.babyId == babyId && $0.attributes.activityType == type
        }
    }

    @available(iOS 16.1, *)
    private func endActivities(babyId: String, type: String) async throws {
        let activities = matchingActivities(babyId: babyId, type: type)
        for activity in activities {
            if #available(iOS 16.2, *) {
                let content = ActivityContent(state: activity.contentState, staleDate: nil)
                await activity.end(content, dismissalPolicy: .immediate)
            } else {
                await activity.end(using: activity.contentState, dismissalPolicy: .immediate)
            }
        }
    }
#endif

    // MARK: - App Group Storage

    private func writeToAppGroup(key: String, data: [String: Any]) {
        guard let defaults = sharedDefaults else {
            print("[LiveActivityHandler] App Group not available: \(appGroupID)")
            return
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            defaults.set(jsonData, forKey: key)
            print("[LiveActivityHandler] Wrote to App Group: \(key)")
        } catch {
            print("[LiveActivityHandler] Failed to serialize data: \(error)")
        }
    }

    private func readFromAppGroup(key: String) -> [String: Any]? {
        guard let defaults = sharedDefaults,
              let jsonData = defaults.data(forKey: key) else {
            return nil
        }

        do {
            if let data = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                return data
            }
        } catch {
            print("[LiveActivityHandler] Failed to deserialize data: \(error)")
        }

        return nil
    }

    private func removeFromAppGroup(key: String) {
        guard let defaults = sharedDefaults else {
            print("[LiveActivityHandler] App Group not available: \(appGroupID)")
            return
        }

        defaults.removeObject(forKey: key)
        print("[LiveActivityHandler] Removed from App Group: \(key)")
    }
}
