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
import GomaPerformanceKit
import GomaLogger

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var allowsLandscape = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Configure performance tracking
        #if DEBUG
        let consoleDestination = ConsolePerformanceDestination()
        consoleDestination.logLevel = ConsolePerformanceDestination.LogLevel.verbose
        PerformanceTracker.shared.addDestination(consoleDestination)
        #endif

        // Configure device context for performance tracking
        PerformanceTracker.shared.configure(
            deviceContext: DeviceContext.current(networkType: "Unknown")
        )

        PerformanceTracker.shared.enable()
        
        print("App Started")

        // Track overall app boot time (app-specific initialization only)
        PerformanceTracker.shared.start(
            feature: .appBoot,
            layer: .app,
            metadata: ["phase": "app_delegate_boot"]
        )

        // Register Settings.bundle defaults (makes iOS Settings app recognize our settings)
        SettingsBundleHelper.registerDefaultsFromSettingsBundle()
        SettingsBundleHelper.updateSettingsBundleValues()

        // Disable autolayout errors/warnings console logs
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

        //
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 24.0
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true

        // Store device id
        if !UserDefaults.standard.isKeyPresentInUserDefaults(key: "device_id") {
            let deviceId = UIDevice.current.identifierForVendor?.uuidString
            print("Device ID: \(deviceId ?? "")")
            UserDefaults.standard.set(deviceId!, forKey: "device_id")
        }

        // Track external third-party SDK initialization
        PerformanceTracker.shared.start(
            feature: .externalDependencies,
            layer: .app,
            metadata: ["sdks": "Phrase,Firebase,XtremePush"]
        )

        // External Localization tool (Phrase SDK)
        // Set locale override based on user preference (like BetssonFrance pattern)
        let phraseConfiguration = PhraseConfiguration()
        phraseConfiguration.localeOverride = LanguageManager.shared.phraseLocaleString

        #if DEBUG
        phraseConfiguration.debugMode = false
        Phrase.shared.configuration = phraseConfiguration
        Phrase.shared.setup(distributionID: "6d295e019be829c18ca3c20fa1acddf1", environmentSecret: "uO7ZSRelqmnwrbB1sjl6SrAMHKSwGhtKDD-xcGWnmxY")
        #else
        Phrase.shared.configuration = phraseConfiguration
        Phrase.shared.setup(distributionID: "6d295e019be829c18ca3c20fa1acddf1", environmentSecret: "rExUgxvoqyX6AQJ9UBiK2DN9t02tsF_P-i0HEXvc-yg")
        #endif

        #if LOCAL_DEBUGR
            print("🔍 [LOCAL] test local-only code in debug")
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

        // Firebase Configuration
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

        // End external dependencies tracking
        PerformanceTracker.shared.end(
            feature: .externalDependencies,
            layer: .app,
            metadata: ["status": "complete"]
        )

        // End app boot tracking (window/bootstrap initialization moved to SceneDelegate)
        PerformanceTracker.shared.end(
            feature: .appBoot,
            layer: .app,
            metadata: ["phase": "app_delegate_boot", "status": "complete"]
        )

        // GomaLogger options
        GomaLogger.disableCategories("LIVE_SCORE", "TALL_CARD", "SPORT_DEBUG", "ODDS_FLOW")

        // Orientation notification observers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLandscapeRequest),
            name: .landscapeOrientationRequested,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePortraitRequest),
            name: .portraitOrientationRequested,
            object: nil
        )

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if !Env.userSessionStore.shouldRecordUserSession {
            Env.userSessionStore.logout()
        }
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // MARK: - Orientation Support

    @objc private func handleLandscapeRequest() {
        allowsLandscape = true
    }

    @objc private func handlePortraitRequest() {
        allowsLandscape = false
    }

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return allowsLandscape ? .allButUpsideDown : .portrait
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

    private var sceneDelegate: SceneDelegate? {
        UIApplication.shared.connectedScenes
            .compactMap { $0.delegate as? SceneDelegate }
            .first
    }

    private func openRoute(_ route: Route, onApplication application: UIApplication) {
        sceneDelegate?.bootstrap.appCoordinator?.openSharedRoute(route)
    }

    private func openPushNotificationRoute(_ route: Route) {
        sceneDelegate?.bootstrap.appCoordinator?.openSharedRoute(route)
    }

}
