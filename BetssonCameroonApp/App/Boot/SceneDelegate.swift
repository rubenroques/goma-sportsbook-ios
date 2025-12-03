//
//  SceneDelegate.swift
//  BetssonCameroonApp
//

import UIKit
import GomaPerformanceKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var bootstrap: Bootstrap!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Track scene connection as part of app boot
        PerformanceTracker.shared.start(
            feature: .appBoot,
            layer: .app,
            metadata: ["phase": "scene_delegate_boot"]
        )

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        self.bootstrap = Bootstrap(window: window)
        self.bootstrap.boot()

        // End scene boot tracking
        PerformanceTracker.shared.end(
            feature: .appBoot,
            layer: .app,
            metadata: ["phase": "scene_delegate_boot", "status": "complete"]
        )

        // Handle universal links passed at launch
        if let userActivity = connectionOptions.userActivities.first {
            handleUserActivity(userActivity)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        Env.servicesProvider.reconnectIfNeeded()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }

    // MARK: - Universal Links

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        handleUserActivity(userActivity)
    }

    // MARK: - Private Helpers

    private func handleUserActivity(_ userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return
        }

        let urlSections = url.pathComponents

        if urlSections.contains("register") {
            openSharedRoute(.register)
        } else if urlSections.contains("login") {
            openSharedRoute(.login)
        } else if urlSections.contains("live") {
            openSharedRoute(.liveGames)
        } else if urlSections.contains("mybets") {
            openSharedRoute(.myBets)
        } else if urlSections.contains("search") && urlSections.contains("sports") {
            openSharedRoute(.sportsSearch)
        } else if urlSections.contains("virtuals") && urlSections.contains("casino") {
            openSharedRoute(.casinoVirtuals)
        } else if urlSections.contains("game") && urlSections.contains("casino"),
                  let gameId = urlSections.last {
            openSharedRoute(.casinoGame(gameId: gameId))
        } else if urlSections.contains("search") && urlSections.contains("casino") {
            openSharedRoute(.casinoSearch)
        } else if urlSections.contains("sports") {
            openSharedRoute(.sportsHome)
        } else if urlSections.contains("casino") {
            openSharedRoute(.casinoHome)
        } else if urlSections.contains("deposit") {
            openSharedRoute(.deposit)
        }
    }

    private func openSharedRoute(_ route: Route) {
        bootstrap.appCoordinator?.openSharedRoute(route)
    }
}
