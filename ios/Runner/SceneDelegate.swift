import Flutter
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  var engine: FlutterEngine?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let engine = FlutterEngine(name: "io.bluedot.flutterMinIntegrationApp")
    engine.run()
    GeneratedPluginRegistrant.register(with: engine)
    self.engine = engine

    // Expose the PUSH_ENABLED Info.plist flag to Dart. This used to be wired up in
    // AppDelegate, but under the UIScene lifecycle the engine — and therefore the
    // plugin registry and this channel — is created here instead.
    let configChannel = FlutterMethodChannel(
      name: "io.bluedot.flutter_minimal_app/config",
      binaryMessenger: engine.binaryMessenger
    )
    configChannel.setMethodCallHandler { (call, result) in
      if call.method == "isPushEnabled" {
        let pushEnabled = Bundle.main.object(forInfoDictionaryKey: "PUSH_ENABLED") as? Bool ?? false
        result(pushEnabled)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    let controller = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = controller
    window.makeKeyAndVisible()
    self.window = window
  }
}
