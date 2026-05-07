import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)

      let controller = window?.rootViewController as! FlutterViewController
      let configChannel = FlutterMethodChannel(
          name: "io.bluedot.flutter_minimal_app/config",
          binaryMessenger: controller.binaryMessenger
      )
      configChannel.setMethodCallHandler { (call, result) in
          if call.method == "isPushEnabled" {
              let pushEnabled = Bundle.main.object(forInfoDictionaryKey: "PUSH_ENABLED") as? Bool ?? true
              result(pushEnabled)
          } else {
              result(FlutterMethodNotImplemented)
          }
      }

      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
