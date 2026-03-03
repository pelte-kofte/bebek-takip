import Flutter
import Security
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let iosRuntimeInfoChannelName = "com.nilico.baby/ios_runtime_info"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    LiveActivityHandler.shared.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: iosRuntimeInfoChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "getAppleSignInDiagnostics" else {
          result(FlutterMethodNotImplemented)
          return
        }
        result(self?.appleSignInDiagnostics())
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func appleSignInDiagnostics() -> [String: Any] {
    let entitlementValue = entitlementValue(for: "com.apple.developer.applesignin")
    let appGroupsValue = entitlementValue(for: "com.apple.security.application-groups")

    return [
      "bundleId": Bundle.main.bundleIdentifier ?? "",
      "buildMode": currentBuildMode(),
      "appleSignInEntitlement": entitlementValue,
      "appGroups": appGroupsValue,
    ]
  }

  private func entitlementValue(for key: String) -> Any {
    guard let task = SecTaskCreateFromSelf(nil) else {
      return NSNull()
    }

    var error: Unmanaged<CFError>?
    guard let value = SecTaskCopyValueForEntitlement(task, key as CFString, &error) else {
      if let error {
        NSLog("[AppDelegate] Entitlement lookup failed for %@: %@", key, error.takeRetainedValue() as Error as NSError)
      }
      return NSNull()
    }

    return value
  }

  private func currentBuildMode() -> String {
    #if DEBUG
      return "debug"
    #else
      return "release"
    #endif
  }
}
