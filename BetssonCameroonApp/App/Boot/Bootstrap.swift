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

class Bootstrap {

    private let window: UIWindow
    private var appCoordinator: AppCoordinator?
    private var appStateManager: AppStateManager?

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

}
