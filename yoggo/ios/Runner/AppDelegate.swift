import UIKit
import Flutter
import AppTrackingTransparency // add this

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  override func applicationDidBecomeActive(_ application: UIApplication) { // add this function
    if #available(iOS 14, *) {
      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
          switch status {
          case .authorized:
              // Tracking authorization dialog was shown
              // and we are authorized
              print("Authorized")
          case .denied:
              // Tracking authorization dialog was
              // shown and permission is denied
              print("Denied")
          case .notDetermined:
              // Tracking authorization dialog has not been shown
              print("Not Determined")
          case .restricted:
              print("Restricted")
          @unknown default:
              print("Unknown")
          }
      })
    } else {
        //you got permission to track, iOS 14 is not yet installed
    }
  }
}
