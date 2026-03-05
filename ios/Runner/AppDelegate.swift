import Flutter
import os
import Security
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let iosRuntimeInfoChannelName = "com.nilico.baby/ios_runtime_info"
  private let nativeLoggerChannelName = "native_logger"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    LiveActivityHandler.shared.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let diagnosticsChannel = FlutterMethodChannel(
        name: iosRuntimeInfoChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      diagnosticsChannel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "getAppleSignInDiagnostics" else {
          result(FlutterMethodNotImplemented)
          return
        }
        result(self?.appleSignInDiagnostics())
      }

      let loggerChannel = FlutterMethodChannel(
        name: nativeLoggerChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      loggerChannel.setMethodCallHandler { call, result in
        guard let message = call.arguments as? String else {
          result(
            FlutterError(
              code: "invalid-args",
              message: "native_logger expects String argument.",
              details: nil
            ))
          return
        }

        let subsystem = Bundle.main.bundleIdentifier ?? "Nilico"
        let category = "AppleAuthService"
        let fallbackLog = OSLog(subsystem: subsystem, category: category)

        switch call.method {
        case "log":
          if #available(iOS 14.0, *) {
            let logger = Logger(subsystem: subsystem, category: category)
            logger.log("\(message, privacy: .public)")
          } else {
            os_log("%{public}@", log: fallbackLog, type: .info, message)
          }
          result(nil)
        case "error":
          if #available(iOS 14.0, *) {
            let logger = Logger(subsystem: subsystem, category: category)
            logger.error("\(message, privacy: .public)")
          } else {
            os_log("%{public}@", log: fallbackLog, type: .error, message)
          }
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func appleSignInDiagnostics() -> [String: Any] {
    let appleEntitlementValue = entitlementValue(for: "com.apple.developer.applesignin")
    let appGroupsValue = entitlementValue(for: "com.apple.security.application-groups")

    return [
      "bundleId": Bundle.main.bundleIdentifier ?? "",
      "buildMode": currentBuildMode(),
      "appleSignInEntitlement": appleEntitlementValue,
      "appGroups": appGroupsValue,
    ]
  }

  private func entitlementValue(for key: String) -> Any {
    #if DEBUG
      guard let task = SecTaskCreateFromSelf(nil) else {
        print("[AppDelegate] SecTaskCreateFromSelf returned nil for key: \(key)")
        return NSNull()
      }
      let value = SecTaskCopyValueForEntitlement(task, key as CFString, nil)
      print("[AppDelegate] entitlement \(key): \(String(describing: value))")
      return value ?? NSNull()
    #else
      return NSNull()
    #endif
  }

  private func currentBuildMode() -> String {
    #if DEBUG
      return "debug"
    #else
      return "release"
    #endif
  }
}
