//
//  AppDelegate.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import UIKit
import Firebase
import FirebaseMessaging
import SwiftyBeaver

let swiftyBeaverLog = SwiftyBeaver.self


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    // TO-DO: Integrate fastlane
    var window: UIWindow?
    var bootstrap: Bootstrap!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let file = FileDestination()  // log to default swiftybeaver.log file
        let cloud = SBPlatformDestination(appID: "jxEpzL",
                                          appSecret: "Zgv4mfejLv3Es3fzlBacHja9yznw2ytr",
                                          encryptionKey: "7vxwxubvlRtgrtaAwybl5hdxstrns8Ik") // to cloud

        swiftyBeaverLog.addDestination(file)
        swiftyBeaverLog.addDestination(cloud)

        Logger.log("App Started")

        // Store device id
        if !UserDefaults.standard.isKeyPresentInUserDefaults(key: "device_id") {
            let deviceId = UIDevice.current.identifierForVendor?.uuidString
            Logger.log("Device ID: \(deviceId ?? "")")
            UserDefaults.standard.set(deviceId!, forKey: "device_id")
        }

        FirebaseConfiguration.shared.setLoggerLevel(.min)

        FirebaseApp.configure()

        Auth.auth().signInAnonymously { authResult, _ in
            guard let user = authResult?.user else { return }
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
            print("FirebaseCore Auth UID \(uid) [isAnonymous:\(isAnonymous)]")
        }

        // FCM
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()

        //
        self.window = UIWindow()

        self.bootstrap = Bootstrap(router: Router(window: self.window!))

        self.bootstrap.boot()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if !Env.userSessionStore.shouldRecordUserSession {
            Env.userSessionStore.logout()
        }
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM token: \(fcmToken ?? "[Token Error]")")
        Env.deviceFCMToken = fcmToken ?? ""
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Env.everyMatrixClient.reconnectSocket()
    }

    // Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
                guard let url = userActivity.webpageURL else {
                    return false
                }

                let urlSections = url.pathComponents

                if urlSections.contains("gamedetail") {
                    if let gameDetailId = urlSections.last {
                        Env.urlSchemaManager.setRedirect(subject: ["gamedetail": gameDetailId])
                    }
                }
                else if urlSections.contains("bet") {
                    if let betId = urlSections.last {
                        print("BET ID: \(betId)")
                        Env.urlSchemaManager.setRedirect(subject: ["bet": betId])
                    }
                }

            }
            return true
    }

}
