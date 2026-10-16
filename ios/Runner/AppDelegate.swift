import Flutter
import UIKit
import flutter_local_notifications
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
     if let key = Bundle.main.object(forInfoDictionaryKey: "MAPS_API_KEY") as? String, !key.isEmpty {
      GMSServices.provideAPIKey(key)
    }
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
    GeneratedPluginRegistrant.register(with: registry)
    }
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as?
      UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
