import Flutter
import UIKit
import Foundation

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

        let data: [String: Any] = [
            "babyId": babyId,
            "activityType": "sleep",
            "startEpochSeconds": startEpochSeconds,
            "isActive": true
        ]

        writeToAppGroup(key: "liveactivity_sleep_\(babyId)", data: data)
        result(nil)
    }

    private func handleStopSleep(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let babyId = args["babyId"] as? String else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        removeFromAppGroup(key: "liveactivity_sleep_\(babyId)")
        result(nil)
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

        let data: [String: Any] = [
            "babyId": babyId,
            "activityType": "nursing",
            "startEpochSeconds": startEpochSeconds,
            "side": side,
            "isActive": true
        ]

        writeToAppGroup(key: "liveactivity_nursing_\(babyId)", data: data)
        result(nil)
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
        if var existingData = readFromAppGroup(key: key) {
            existingData["side"] = side
            writeToAppGroup(key: key, data: existingData)
        }

        result(nil)
    }

    private func handleStopNursing(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let babyId = args["babyId"] as? String else {
            result(FlutterError(code: "BAD_ARGS", message: "Missing arguments", details: nil))
            return
        }

        removeFromAppGroup(key: "liveactivity_nursing_\(babyId)")
        result(nil)
    }

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
