//
//  AppDelegate.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import UIKit
import Firebase
import XPush
import SwiftUI
import ServicesProvider
import IQKeyboardManagerSwift
import PhraseSDK
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var bootstrap: Bootstrap!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        print("App Started")

        // Register Settings.bundle defaults (makes iOS Settings app recognize our settings)
        SettingsBundleHelper.registerDefaultsFromSettingsBundle()
        SettingsBundleHelper.updateSettingsBundleValues()

        // External Localization tool
        #if DEBUG
        let phraseConfiguration = PhraseConfiguration()
        phraseConfiguration.debugMode = false
        Phrase.shared.configuration = phraseConfiguration
        Phrase.shared.setup(distributionID: "6d295e019be829c18ca3c20fa1acddf1", environmentSecret: "uO7ZSRelqmnwrbB1sjl6SrAMHKSwGhtKDD-xcGWnmxY")
        #else
        let phraseConfiguration = PhraseConfiguration()
        Phrase.shared.configuration = phraseConfiguration
        Phrase.shared.setup(distributionID: "6d295e019be829c18ca3c20fa1acddf1", environmentSecret: "rExUgxvoqyX6AQJ9UBiK2DN9t02tsF_P-i0HEXvc-yg")
        #endif

        Task {
            do {
                let updated = try await Phrase.shared.updateTranslation()
                if updated {
                    print("PhraseSDK - Translations changed")
                    Phrase.shared.applyPendingUpdates()

                    print("PhraseSDK - updateTranslation")
                    let translation = localized("phrase.test")
                    print("PhraseSDK - NSLocalizedString via bundle proxy: ", translation)
                } else {
                    print("PhraseSDK - Translations remain unchanged")
                }
            } catch {
                print("PhraseSDK - An error occurred: \(error)")
            }
        }

        //
        //
        // Disable autolayout errors/warnings console logs
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

        //
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 24.0
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true

//        let disabledClasses = [BetslipViewController.self, PreSubmissionBetslipViewController.self]
//        IQKeyboardManager.shared.disabledToolbarClasses = disabledClasses
//        IQKeyboardManager.shared.disabledDistanceHandlingClasses = disabledClasses

        // Store device id
        if !UserDefaults.standard.isKeyPresentInUserDefaults(key: "device_id") {
            let deviceId = UIDevice.current.identifierForVendor?.uuidString
            print("Device ID: \(deviceId ?? "")")
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
        
        // XtremePush Configuration
        // TODO: Replace with actual app key from client
        XPush.setAppKey("tymCbccp6pas_HwOgwuDRMJZ6Nn0m7Gr")
        
        // Enable debug logs for development builds
        #if DEBUG
        XPush.setShouldShowDebugLogs(true)
        XPush.setSandboxModeEnabled(true)
        #endif
        
        // Initialize XtremePush
        XPush.applicationDidFinishLaunching(options: launchOptions)

        XPush.startInappPoll()
        
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()

        // App Init
        //
        self.window = UIWindow()

        self.bootstrap = Bootstrap(window: self.window!)
        self.bootstrap.boot()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if !Env.userSessionStore.shouldRecordUserSession {
            Env.userSessionStore.logout()
        }
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

            if urlSections.contains("register") {
                self.openSharedRoute(Route.register, onApplication: application)
            }
            else if urlSections.contains("login") {
                self.openSharedRoute(Route.login, onApplication: application)
            }
            else if urlSections.contains("live") {
                self.openSharedRoute(Route.liveGames, onApplication: application)
            }
            else if urlSections.contains("mybets") {
                self.openSharedRoute(Route.myBets, onApplication: application)
            }
            else if urlSections.contains("search") && urlSections.contains("sports") {
                self.openSharedRoute(Route.sportsSearch, onApplication: application)
            }
            else if urlSections.contains("virtuals") && urlSections.contains("casino") {
                self.openSharedRoute(Route.casinoVirtuals, onApplication: application)
            }
            else if urlSections.contains("game") && urlSections.contains("casino"),
                        let gameId = urlSections.last {
                self.openSharedRoute(Route.casinoGame(gameId: gameId), onApplication: application)
            }
            else if urlSections.contains("search") && urlSections.contains("casino") {
                self.openSharedRoute(Route.casinoSearch, onApplication: application)
            }
            else if urlSections.contains("sports") {
                self.openSharedRoute(Route.sportsHome, onApplication: application)
            }
            else if urlSections.contains("casino") {
                self.openSharedRoute(Route.casinoHome, onApplication: application)
            }
            // Deposit does not exists in an url section
            else if urlSections.contains("deposit") {
                self.openSharedRoute(Route.deposit, onApplication: application)
            }
            
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")

        // Send device token to XtremePush
        XPush.applicationDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
        XPush.applicationDidFailToRegisterForRemoteNotificationsWithError(error as NSError)
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

        if routeLabel == "chat_message" {
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
            route = .casinoGame(gameId: routeLabel)
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
            // This should be sent to AppCoordinator
            // self.bootstrap.router.openedNotificationRouteWhileActive(route)
        }
        else if application.applicationState == .inactive {
            // This should be sent to AppCoordinator
            // self.bootstrap.router.configureStartingRoute(route)
        }
        else if application.applicationState == .background {
            // This should be sent to AppCoordinator
            // self.bootstrap.router.configureStartingRoute(route)
        }

    }

    private func openSharedRoute(_ route: Route, onApplication application: UIApplication) {
        self.bootstrap.appCoordinator?.openSharedRoute(route)
    }

    private func openPushNotificationRoute(_ route: Route) {
        // self.bootstrap.router.openPushNotificationRoute(route)
        self.bootstrap.appCoordinator?.openSharedRoute(route)
    }

}
