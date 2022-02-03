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

    // URL Scheme
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let scheme = url.scheme,
            scheme.localizedCaseInsensitiveCompare("sb.gg") == .orderedSame,
            let view = url.host {

            // URL query items
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }

            let urlSections = url.pathComponents

            if urlSections.contains("gamedetail") {
                if let gameDetailId = urlSections.last {
                    print("GAME DETAIL ID: \(gameDetailId)")
                    Env.urlSchemaManager.setRedirect(subject: ["gamedetail": gameDetailId])
                }
            }
            else if urlSections.contains("bet") {
                if let betId = urlSections.last {
                    print("BET ID: \(betId)")
                }
            }
            //redirect(to: view, with: parameters)
        }
        return true
    }

    // Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
            if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
                guard let url = userActivity.webpageURL else {
                    return false
                }

                //Ferching query parameters
                print("TAPPED APP URL: \(url)")
//                let queryParams = url.queryParams()
//                if let accessToken = queryParams["access_token"] as? String {
//                    //Do your actions here
//                }

            }
            return true
    }

}
