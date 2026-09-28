import UIKit
import Flutter
import UserNotifications
import bluedot_point_sdk_push

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Required for FlutterAppDelegate (and therefore the plugins it forwards to) to receive
    // UNUserNotificationCenter callbacks.
    UNUserNotificationCenter.current().delegate = self
    // Plugins are registered by SceneDelegate on the engine it creates.
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // PointSDK deliberately does not implement these two callbacks: Flutter forwards them to every
  // registered plugin with the same completion handler, so the app owns them and completes each
  // exactly once. That also leaves the presentation options to the app.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let handled = BluedotPointSdkPushPlugin.handleForegroundNotification(notification)
    completionHandler(handled ? [.banner, .list, .sound, .badge] : [.banner, .list])
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    BluedotPointSdkPushPlugin.handleNotificationResponse(response)
    completionHandler()
  }
}
