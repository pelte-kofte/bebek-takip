import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register Live Activity MethodChannel
    if let controller = window?.rootViewController as? FlutterViewController {
        LiveActivityHandler.shared.register(with: controller)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
