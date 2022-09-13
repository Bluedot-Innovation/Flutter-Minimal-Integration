import UIKit
import Flutter
import AppCenter
import AppCenterCrashes
import AppCenterAnalytics

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let appSecret = "APPCENTER_SECRET_IOS"
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      AppCenter.start(withAppSecret: appSecret, services: [Analytics.self, Crashes.self])
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
