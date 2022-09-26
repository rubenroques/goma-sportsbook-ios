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
import SwiftUI

let swiftyBeaverLog = SwiftyBeaver.self

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    // TO-DO: Integrate fastlane
    var window: UIWindow?
    var bootstrap: Bootstrap!

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let file = FileDestination()  // log to default swiftybeaver.log file
        let cloud = SBPlatformDestination(appID: "jxEpzL",
                                          appSecret: "Zgv4mfejLv3Es3fzlBacHja9yznw2ytr",
                                          encryptionKey: "7vxwxubvlRtgrtaAwybl5hdxstrns8Ik") // to cloud

        swiftyBeaverLog.addDestination(file)
        swiftyBeaverLog.addDestination(cloud)

        
         
        // This is used to disable temporarly auto layout Unsatisfiable constraints logs
        // This should be deleted, unsatisfiable constraints must be fixed
        #if XCODE_ACTION_install
            // Is archiving
        #else
            // UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        #endif
        
        
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
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            guard let url = userActivity.webpageURL else {
                return false
            }

            let urlSections = url.pathComponents
            if urlSections.contains("gamedetail") {
                if let gameDetailId = urlSections.last {
                    self.openRoute(Route.event(id: gameDetailId), onApplication: application)
                }
            }
            else if urlSections.contains("bet") {
                if let ticketId = urlSections.last {
                    self.openRoute(Route.ticket(id: ticketId), onApplication: application)
                }
            }
        }
        return true
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let userInfo = notification.request.content.userInfo

        // Print message ID.
        let gcmMessageIDKey = "gcm.message_id"
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        var routeId: String = ""
        if let routeIdValue = userInfo["routeId"] as? String {
            routeId = routeIdValue
        }
        else if let routeIdValue = userInfo["routeId"] as? Int {
            routeId = String(routeIdValue)
        }
        
        let routeLabel = userInfo["routeLabel"] as? String ?? ""

        let chatroomOnForegroundID = Env.gomaSocialClient.chatroomOnForeground()

        if routeLabel == "chat_message" && routeId == chatroomOnForegroundID {
            completionHandler([])
        }
        else {
            if #available(iOS 14.0, *) {
                completionHandler([.banner])
            }
            else {
                completionHandler([.alert])
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo

        // Print message ID.
        let gcmMessageIDKey = "gcm.message_id"
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        var route: Route?
        let application = UIApplication.shared

        let routeId = userInfo["routeId"] as? String ?? ""
        let routeLabel = userInfo["routeLabel"] as? String ?? ""
        let routeType = userInfo["routeType"] as? String ?? ""

        switch (routeLabel, routeType) {
        case ("pending", "bet"):
            route = .openBet(id: routeId)
        case ("resolved", "bet"):
            route = .resolvedBet(id: routeId)
        case (_, "event"):
            route = .event(id: routeId)
        case (_, "chat"):
            if routeId.isNotEmpty {
                route = .chatMessage(id: routeId)
            }
            else {
                route = .chatNotifications
            }
        default:
            ()
        }

        if let route = route {
            self.openRoute(route, onApplication: application)
        }

        completionHandler()
    }

    private func openRoute(_ route: Route, onApplication application: UIApplication) {

        if application.applicationState == .active {
            self.bootstrap.router.openedNotificationRouteWhileActive(route)
        }
        else if application.applicationState == .inactive {
            if Env.everyMatrixClient.serviceStatusPublisher.value == .connected {
                self.bootstrap.router.openedNotificationRouteWhileActive(route)
            }
            else {
                self.bootstrap.router.configureStartingRoute(route)
            }
        }
        else if application.applicationState == .background {
            self.bootstrap.router.configureStartingRoute(route)
        }

    }

}
