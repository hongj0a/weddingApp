import Flutter
import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
    
      // 푸시 알림 권한 요청
      UNUserNotificationCenter.current().delegate = self
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
          if let error = error {
              print("알림 권한 요청 실패: \(error.localizedDescription)")
          } else {
              print("알림 권한 상태: \(granted ? "허용됨" : "거부됨")")
          }
      }

      application.registerForRemoteNotifications()
      GeneratedPluginRegistrant.register(with: self)

      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
      }
  }
