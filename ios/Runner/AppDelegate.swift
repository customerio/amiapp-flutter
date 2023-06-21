import UIKit
import Flutter
import CioMessagingPushFCM
import CioTracking
import FirebaseMessaging
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        FirebaseApp.configure()
        
        var modifiedLaunchOptions = launchOptions
        
        if let remoteNotification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any],
           let cioMap = remoteNotification["CIO"] as? [String: Any],
           let pushMap = cioMap["push"] as? [String: Any],
           let deepLinkURL = pushMap["link"] as? String {
            if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? String {
                UIPasteboard.general.string = url
            }
            if let url = URL(string: deepLinkURL) {
                let path = url.path
                let flutterViewController = window?.rootViewController as! FlutterViewController
                // Sets path for Flutter router
                flutterViewController.setInitialRoute(path)
            }
            modifiedLaunchOptions![UIApplication.LaunchOptionsKey.url] = NSURL(string: deepLinkURL)
        }

        // Set FCM messaging delegate
        Messaging.messaging().delegate = self

        let center  = UNUserNotificationCenter.current()
        center.delegate = self
        
        // Register for push notification
        UIApplication.shared.registerForRemoteNotifications()

        return super.application(application, didFinishLaunchingWithOptions: modifiedLaunchOptions)
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown);
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        MessagingPush.shared.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let handled = MessagingPush.shared.userNotificationCenter(center, didReceive: response,
                                                                  withCompletionHandler: completionHandler)
        
        // If the Customer.io SDK does not handle the push, it's up to you to handle it and call the
        // completion handler. If the SDK did handle it, it called the completion handler for you.
        if !handled {
            completionHandler()
        }
    }
    
    // OPTIONAL: If you want your push UI to show even with the app in the foreground, override this function and call
    // the completion handler.
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .badge, .sound])
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        MessagingPush.shared.messaging(messaging, didReceiveRegistrationToken: fcmToken)
    }
}
