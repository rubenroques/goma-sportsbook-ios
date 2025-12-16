//
//  DependenciesBootstrapper.swift
//  BetssonCameroonApp
//
//  Created to manage lazy initialization of external SDKs and dependencies
//  after the main UI is shown, improving startup performance.
//
//  Acts as a proxy/message queue for push notification events:
//  - Receives events from AppDelegate immediately
//  - Queues events if SDKs not initialized yet
//  - Forwards events to SDKs once ready
//

import UIKit
import Firebase
import XPush
import PhraseSDK
import FirebaseCore
import FirebaseAuth
import GomaPerformanceKit

/// Manages lazy initialization of external SDKs and third-party dependencies.
/// These dependencies are initialized after the main UI is shown to improve app startup time.
/// Acts as a proxy for push notification events, queuing them until SDKs are ready.
final class DependenciesBootstrapper {

    // MARK: - Singleton

    static let shared = DependenciesBootstrapper()

    // MARK: - Event Queue Types

    /// Events that can be queued before SDK initialization
    private enum PendingEvent {
        case launchOptions([UIApplication.LaunchOptionsKey: Any])
        case deviceToken(Data)
        case deviceTokenFailure(Error)
        case remoteNotification([AnyHashable: Any], completion: (UIBackgroundFetchResult) -> Void)
    }

    // MARK: - Properties

    private var isInitialized = false
    private var pendingEvents: [PendingEvent] = []
    private let eventQueue = DispatchQueue(label: "com.betsson.dependencies.events", qos: .userInitiated)

    // MARK: - Initialization

    private init() {
        
        
    }

    // MARK: - Public Proxy Methods (Called from AppDelegate)

    /// Handle app launch options (called immediately from AppDelegate)
    /// If SDKs not initialized yet, queues the event. Otherwise forwards immediately.
    func handleLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let launchOptions = launchOptions, !launchOptions.isEmpty else { return }

        eventQueue.async { [weak self] in
            guard let self = self else { return }

            if self.isInitialized {
                self.forwardLaunchOptions(launchOptions)
            } else {
                print("DependenciesBootstrapper - Queuing launch options")
                self.pendingEvents.append(.launchOptions(launchOptions))
            }
        }
    }

    /// Handle device token registration (called from AppDelegate)
    func handleDeviceTokenRegistration(_ deviceToken: Data) {
        eventQueue.async { [weak self] in
            guard let self = self else { return }

            if self.isInitialized {
                self.forwardDeviceToken(deviceToken)
            } else {
                print("DependenciesBootstrapper - Queuing device token")
                self.pendingEvents.append(.deviceToken(deviceToken))
            }
        }
    }

    /// Handle device token registration failure (called from AppDelegate)
    func handleDeviceTokenFailure(_ error: Error) {
        eventQueue.async { [weak self] in
            guard let self = self else { return }

            if self.isInitialized {
                self.forwardDeviceTokenFailure(error)
            } else {
                print("DependenciesBootstrapper - Queuing device token failure")
                self.pendingEvents.append(.deviceTokenFailure(error))
            }
        }
    }

    /// Handle remote notification (called from AppDelegate)
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any], completion: @escaping (UIBackgroundFetchResult) -> Void) {
        eventQueue.async { [weak self] in
            guard let self = self else {
                completion(.noData)
                return
            }

            if self.isInitialized {
                self.forwardRemoteNotification(userInfo, completion: completion)
            } else {
                print("DependenciesBootstrapper - Queuing remote notification")
                self.pendingEvents.append(.remoteNotification(userInfo, completion: completion))
            }
        }
    }

    // MARK: - Initialization

    /// Initialize all external dependencies asynchronously.
    /// This should be called after the main UI is shown.
    func initialize() {
        guard !isInitialized else {
            print("DependenciesBootstrapper - Already initialized, skipping")
            return
        }

        print("DependenciesBootstrapper - Starting lazy initialization")

        // Track external third-party SDK initialization
        PerformanceTracker.shared.start(
            feature: .externalDependencies,
            layer: .app,
            metadata: ["sdks": "Phrase,Firebase,XtremePush", "lazy": "true"]
        )

        initializePhraseSDK()
        initializeFirebase()
        initializeXtremePush(launchOptions: nil) // Will use queued launch options
        initializePushNotifications()

        // Mark as initialized BEFORE flushing to avoid re-queuing
        isInitialized = true

        // End external dependencies tracking
        PerformanceTracker.shared.end(
            feature: .externalDependencies,
            layer: .app,
            metadata: ["status": "complete", "lazy": "true"]
        )

        print("DependenciesBootstrapper - Lazy initialization complete")

        // Flush any events that were queued before initialization
        flushPendingEvents()
    }

    // MARK: - Private Methods

    private func initializePhraseSDK() {
        // External Localization tool (Phrase SDK)
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
                    print("DependenciesBootstrapper - PhraseSDK - Translations changed")
                    Phrase.shared.applyPendingUpdates()

                    print("DependenciesBootstrapper - PhraseSDK - updateTranslation")
                    let translation = localized("phrase.test")
                    print("DependenciesBootstrapper - PhraseSDK - NSLocalizedString via bundle proxy: ", translation)
                } else {
                    print("DependenciesBootstrapper - PhraseSDK - Translations remain unchanged")
                }
            } catch {
                print("DependenciesBootstrapper - PhraseSDK - An error occurred: \(error)")
            }
        }
    }

    private func initializeFirebase() {
        // Firebase Configuration
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()

        Auth.auth().signInAnonymously { authResult, _ in
            guard let user = authResult?.user else { return }
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
            print("DependenciesBootstrapper - FirebaseCore Auth UID \(uid) [isAnonymous: \(isAnonymous)]")
        }
    }

    private func initializeXtremePush(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // XtremePush Configuration
        XPush.setAppKey("tymCbccp6pas_HwOgwuDRMJZ6Nn0m7Gr")

        // Enable debug logs for development builds
        #if DEBUG
        XPush.setShouldShowDebugLogs(true)
        XPush.setSandboxModeEnabled(true)
        #endif

        // Initialize XtremePush with launch options (will be from queue if available)
        XPush.applicationDidFinishLaunching(options: launchOptions)
        XPush.startInappPoll()
    }

    private func initializePushNotifications() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                if granted {
                    print("DependenciesBootstrapper - Push notification authorization granted")
                } else if let error = error {
                    print("DependenciesBootstrapper - Push notification authorization error: \(error)")
                }
            }
        )

        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    // MARK: - Event Queue Management

    /// Flush all pending events that were queued before SDK initialization
    private func flushPendingEvents() {
        eventQueue.async { [weak self] in
            guard let self = self else { return }

            guard !self.pendingEvents.isEmpty else {
                print("DependenciesBootstrapper - No pending events to flush")
                return
            }

            print("DependenciesBootstrapper - Flushing \(self.pendingEvents.count) pending events")

            for event in self.pendingEvents {
                switch event {
                case .launchOptions(let options):
                    self.forwardLaunchOptions(options)

                case .deviceToken(let token):
                    self.forwardDeviceToken(token)

                case .deviceTokenFailure(let error):
                    self.forwardDeviceTokenFailure(error)

                case .remoteNotification(let userInfo, let completion):
                    self.forwardRemoteNotification(userInfo, completion: completion)
                }
            }

            self.pendingEvents.removeAll()
            print("DependenciesBootstrapper - All pending events flushed")
        }
    }

    // MARK: - Event Forwarding (to SDKs)

    /// Forward launch options to XtremePush
    private func forwardLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]) {
        print("DependenciesBootstrapper - Forwarding launch options to XtremePush")

        // Re-initialize XtremePush with actual launch options
        // Note: XtremePush was already initialized with nil options, this ensures
        // it receives the launch notification if app was launched by tapping notification
        if launchOptions[.remoteNotification] != nil {
            XPush.applicationDidFinishLaunching(options: launchOptions)
        }
    }

    /// Forward device token to XtremePush
    private func forwardDeviceToken(_ deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("DependenciesBootstrapper - Forwarding device token to XtremePush: \(token)")

        XPush.applicationDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }

    /// Forward device token failure to XtremePush
    private func forwardDeviceTokenFailure(_ error: Error) {
        print("DependenciesBootstrapper - Forwarding device token failure to XtremePush: \(error)")

        XPush.applicationDidFailToRegisterForRemoteNotificationsWithError(error as NSError)
    }

    /// Forward remote notification to appropriate handler
    private func forwardRemoteNotification(_ userInfo: [AnyHashable: Any], completion: @escaping (UIBackgroundFetchResult) -> Void) {
        print("DependenciesBootstrapper - Forwarding remote notification")

        // Forward to any SDKs that need to handle notifications
        // For now, just complete with noData as XtremePush handles most through system callbacks
        completion(.noData)
    }
}
