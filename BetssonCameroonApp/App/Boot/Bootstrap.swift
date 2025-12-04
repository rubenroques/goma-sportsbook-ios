//
//  Bootstrap.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/09/2021.
//

import Foundation
import Combine
import UIKit
import GomaUI
import ServicesProvider
import PhraseSDK

class Bootstrap {

    private let window: UIWindow
    private var appStateManager: AppStateManager?
    var appCoordinator: AppCoordinator?

    init(window: UIWindow) {
        self.window = window
    }

    func boot() {
        // Create AppStateManager and AppCoordinator
        let appStateManager = AppStateManager(environment: Env)
        let appCoordinator = AppCoordinator(window: window, environment: Env, appStateManager: appStateManager)

        self.appStateManager = appStateManager
        self.appCoordinator = appCoordinator

        // Start the coordinator-based app flow
        appCoordinator.start()
    }

    /// Restarts the app with new language configuration
    /// Called when user changes language preference
    func restart() {
        print("[Bootstrap] Restarting app for language change to: \(LanguageManager.shared.currentLanguageCode)")

        // 1. Reconfigure Phrase SDK with new locale
        Phrase.shared.configuration.localeOverride = LanguageManager.shared.phraseLocaleString

        // 2. Update ServicesProvider language configuration
        Env.servicesProvider.setLanguage(LanguageManager.shared.currentLanguageCode)

        // 3. Disconnect existing services (sockets, subscriptions)
        Env.servicesProvider.disconnect()

        // 4. Cancel existing subscriptions in AppStateManager
        appStateManager?.cancelAllSubscriptions()

        // 5. Clear sports store to force reload with new language
        Env.sportsStore.reset()

        // 6. Create new AppStateManager and AppCoordinator
        let newAppStateManager = AppStateManager(environment: Env)
        let newAppCoordinator = AppCoordinator(window: window, environment: Env, appStateManager: newAppStateManager)

        self.appStateManager = newAppStateManager
        self.appCoordinator = newAppCoordinator

        // 7. Start fresh (shows splash, reconnects services with new language)
        newAppCoordinator.start()

        print("[Bootstrap] App restart complete")
    }

}
