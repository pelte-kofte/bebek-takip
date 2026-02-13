import Flutter
import UIKit
import Foundation

#if canImport(ActivityKit)
import ActivityKit
#endif

class LiveActivityHandler {

    static let shared = LiveActivityHandler()
    private let userDefaults = UserDefaults.standard

    func register(with controller: FlutterViewController) {
        let channel = FlutterMethodChannel(
            name: "com.Nilico.Baby/liveActivity",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterError(code: "UNAVAILABLE", message: "Handler deallocated", details: nil))
                return
            }

            switch call.method {
            case "startSleepLiveActivity":
                self.handleStartSleep(call: call, result: result)
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

    // MARK: - Sleep

    private func handleStartSleep(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let babyId = args["babyId"] as? String,
              let epochSeconds = args["startEpochSeconds"] as? Int else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        if #available(iOS 16.1, *) {
            startLiveActivity(babyId: babyId, activityType: "sleep", startEpochSeconds: epochSeconds, side: nil)
            result(nil)
        } else {
            result(nil) // Silently succeed on older iOS
        }
    }

    private func handleStopSleep(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let babyId = args["babyId"] as? String else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        if #available(iOS 16.1, *) {
            stopLiveActivity(babyId: babyId, activityType: "sleep")
        }
        result(nil)
    }

    // MARK: - Nursing

    private func handleStartNursing(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let babyId = args["babyId"] as? String,
              let epochSeconds = args["startEpochSeconds"] as? Int,
              let side = args["side"] as? String else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        if #available(iOS 16.1, *) {
            startLiveActivity(babyId: babyId, activityType: "nursing", startEpochSeconds: epochSeconds, side: side)
            result(nil)
        } else {
            result(nil)
        }
    }

    private func handleUpdateNursingSide(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let babyId = args["babyId"] as? String,
              let side = args["side"] as? String else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        if #available(iOS 16.1, *) {
            updateLiveActivitySide(babyId: babyId, newSide: side)
        }
        result(nil)
    }

    private func handleStopNursing(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let babyId = args["babyId"] as? String else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        if #available(iOS 16.1, *) {
            stopLiveActivity(babyId: babyId, activityType: "nursing")
        }
        result(nil)
    }

    // MARK: - ActivityKit Operations

    @available(iOS 16.1, *)
    private func startLiveActivity(babyId: String, activityType: String, startEpochSeconds: Int, side: String?) {
        // End any existing activity for this baby+type first
        stopLiveActivity(babyId: babyId, activityType: activityType)

        let attributes = BabyTimerAttributes(
            babyId: babyId,
            activityType: activityType
        )

        let startDate = Date(timeIntervalSince1970: TimeInterval(startEpochSeconds))
        let contentState = BabyTimerAttributes.ContentState(
            startDate: startDate,
            side: side
        )

        do {
            if #available(iOS 16.2, *) {
                let content = ActivityContent(state: contentState, staleDate: nil)
                let activity = try Activity<BabyTimerAttributes>.request(
                    attributes: attributes,
                    content: content,
                    pushType: nil
                )
                let key = "liveactivity_\(activityType)_\(babyId)"
                userDefaults.set(activity.id, forKey: key)
            } else {
                let activity = try Activity<BabyTimerAttributes>.request(
                    attributes: attributes,
                    contentState: contentState,
                    pushType: nil
                )
                let key = "liveactivity_\(activityType)_\(babyId)"
                userDefaults.set(activity.id, forKey: key)
            }
        } catch {
            print("[LiveActivityHandler] Failed to start activity: \(error)")
        }
    }

    @available(iOS 16.1, *)
    private func stopLiveActivity(babyId: String, activityType: String) {
        let key = "liveactivity_\(activityType)_\(babyId)"

        for activity in Activity<BabyTimerAttributes>.activities {
            if activity.attributes.babyId == babyId &&
               activity.attributes.activityType == activityType {
                Task {
                    await activity.end(dismissalPolicy: .immediate)
                }
            }
        }

        userDefaults.removeObject(forKey: key)
    }

    @available(iOS 16.1, *)
    private func updateLiveActivitySide(babyId: String, newSide: String) {
        for activity in Activity<BabyTimerAttributes>.activities {
            if activity.attributes.babyId == babyId &&
               activity.attributes.activityType == "nursing" {
                Task {
                    let currentState = activity.content.state
                    let newState = BabyTimerAttributes.ContentState(
                        startDate: currentState.startDate,
                        side: newSide
                    )
                    if #available(iOS 16.2, *) {
                        let content = ActivityContent(state: newState, staleDate: nil)
                        await activity.update(content)
                    } else {
                        await activity.update(using: newState)
                    }
                }
            }
        }
    }
}
