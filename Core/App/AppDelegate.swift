//
//  AppDelegate.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import UIKit
import Firebase
import FirebaseMessaging
import SwiftUI
import ServicesProvider
import IQKeyboardManagerSwift
import PhraseSDK
import AdyenActions
import OptimoveSDK
import Adjust

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    var bootstrap: Bootstrap!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Logger.log("App Started")

        //
        // External Localization tool
        #if DEBUG
        let phraseConfiguration = PhraseConfiguration()
        phraseConfiguration.debugMode = true
        phraseConfiguration.localeOverride = "fr-FR"
        Phrase.shared.configuration = phraseConfiguration
        Phrase.shared.setup(distributionID: "8dff53ee102cd6a5c31935d4d5938c3f", environmentSecret: "GuBCndN-seQgps-CuyMlx6AXkzsiyGuJMIFicqpvMoc")
        #else
        let phraseConfiguration = PhraseConfiguration()
        phraseConfiguration.localeOverride = "fr-FR"
        Phrase.shared.configuration = phraseConfiguration
        Phrase.shared.setup(distributionID: "8dff53ee102cd6a5c31935d4d5938c3f", environmentSecret: "UmPDmeEDM8dGvFdKu9-x_bJxI0-8eaJX5CDeq88Eepk")
        #endif

        do {
            try Phrase.shared.updateTranslation { updatedResult in
                print("PhraseSDK updateTranslation \(dump(updatedResult))")

                let translation = localized("phrase.test")
                print("PhraseSDK NSLocalizedString via bundle proxy: ", translation)
            }
        }
        catch {
            print("PhraseSDK updateTranslation crashed error \(error)")
        }
        
        //
        //
        // Disable autolayout errors/warnings console logs
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

        //
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 24.0
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true

        let disabledClasses = [BetslipViewController.self, PreSubmissionBetslipViewController.self]
        IQKeyboardManager.shared.disabledToolbarClasses = disabledClasses
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = disabledClasses

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
            print("FirebaseCore Auth UID \(uid) [isAnonymous: \(isAnonymous)]")
        }

        // FCM
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        let optimoveCredentials = "WzEsIjEzMGRjNGIwNTZiYzRhNmQ5NWI0ZWJjODczNGJlYmJhIiwibW9iaWxlLWNvbmZpZ3VyYXRpb24uMS4wLjAiXQ=="
        let optimobileCredentials = "WzEsImV1LWNlbnRyYWwtMiIsImJkYzg1MTk5LTk4ODEtNGRhMy05NmYzLWI3ZGZkOWM3NzI0NCIsImpDNFMzODF4SDhCU2JSeS94aVlsQ25ubUVsT2ZTTEUxYUdhSyJd"

        // Optimove
        let config = OptimoveConfigBuilder(optimoveCredentials: optimoveCredentials, optimobileCredentials: optimobileCredentials)
            .setPushOpenedHandler(pushOpenedHandlerBlock: { (notification: PushNotification) -> Void in
                //- Inspect notification data and do work.
                
                var route: Route?
                let application = UIApplication.shared

                var routeId: String = ""
                if let routeIdValue = notification.data["routeId"] as? String {
                    print("ROUTE ID AS STRING")
                    routeId = routeIdValue
                }
                else if let routeIdValue = notification.data["routeId"] as? Double {
                    print("ROUTE ID AS DOUBLE")
                    routeId = String(routeIdValue)
                }          
                
                let routeLabel = notification.data["routeLabel"] as? String ?? ""
                let routeType = notification.data["routeType"] as? String ?? ""

                switch (routeType, routeLabel) {
                case ("event", _):
                    route = .event(id: routeId)
                case ("competition", _):
                    route = .competition(id: routeId)
                case ("contact-settings", _):
                    route = .contactSettings
                case ("betswipe", _):
                    route = .betSwipe
                case ("deposit", _):
                    route = .deposit
                case ("bonus", _):
                    route = .bonus
                case ("documents", _):
                    route = .documents
                case ("customer-support", _):
                    route = .customerSupport
                case ("favorites", _):
                    route = .favorites
                case ("promotions", _):
                    route = .promotions
                default:
                    ()
                }

                if let route = route {
                    self.openPushNotificationRoute(route)
                }
            })
            .build()
        
        Optimove.initialize(with: config)

        application.registerForRemoteNotifications()
        
        // Adjust
        // Sandbox ENV = ADJEnvironmentSandbox
        let appToken = "u9xpbb9chxj4"
        let environment = ADJEnvironmentProduction
        let adjustConfig = ADJConfig(appToken: appToken, environment: environment)
        
        adjustConfig?.logLevel = ADJLogLevelVerbose
        
        Adjust.appDidLaunch(adjustConfig)
        
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
        Env.deviceFirebaseCloudMessagingToken = fcmToken ?? ""
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Env.servicesProvider.reconnectIfNeeded()
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
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            
            if (urlSections.contains("competitions") || urlSections.contains("live")) && urlSections.count > 6 {
                if let gameDetailId = urlSections.last {
                    self.openSharedRoute(Route.event(id: gameDetailId), onApplication: application)
                    
                }
            }
            else if urlSections.contains("competitions") && urlSections.count <= 6 {
                if let competitionDetailId = urlSections.last {
                    self.openSharedRoute(Route.competition(id: competitionDetailId), onApplication: application)
                }
            }
            else if urlSections.contains("bet") {
                if let ticketId = urlSections.last {

                    self.openSharedRoute(Route.ticket(id: ticketId), onApplication: application)

                }
            }
            else if urlSections.contains("contact-settings") {
                self.openSharedRoute(Route.contactSettings, onApplication: application)
            }
            else if urlSections.contains("bonus") {
                self.openSharedRoute(Route.bonus, onApplication: application)
            }
            else if urlSections.contains("documents") {
                self.openSharedRoute(Route.documents, onApplication: application)
            }
            else if urlSections.contains("support") {
                self.openSharedRoute(Route.customerSupport, onApplication: application)
            }
            else if urlSections.contains("favoris") {
                self.openSharedRoute(Route.favorites, onApplication: application)
            }
            else if urlSections.contains("promotions") {
                self.openSharedRoute(Route.promotions, onApplication: application)
            }
            // Deposit does not exists in an url section
            else if url.absoluteString.contains("deposit") {
                self.openSharedRoute(Route.deposit, onApplication: application)
            }
            else if url.absoluteString.contains("register") {
                let queryItems = urlComponents?.queryItems
                if let code = urlComponents?.queryItems?.first(where: {
                    $0.name == "referralCode"
                })?.value {
                    self.openSharedRoute(Route.referral(code: code), onApplication: application)
                }
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map {
            data in String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        Optimove.shared.pushRegister(deviceToken)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            // userInfo["aps"]["content-available"] will be set to 1
            // userInfo["custom"]["a"] will contain any additional data sent with the push
            let userInfo = userInfo
            
            completionHandler(UIBackgroundFetchResult.noData)
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

            self.bootstrap.router.configureStartingRoute(route)
        }
        else if application.applicationState == .background {
            
            self.bootstrap.router.configureStartingRoute(route)
        }

    }

    private func openSharedRoute(_ route: Route, onApplication application: UIApplication) {

        self.bootstrap.router.openPushNotificationRoute(route)
    }
    
    private func openPushNotificationRoute(_ route: Route) {
        self.bootstrap.router.openPushNotificationRoute(route)
    }

}
