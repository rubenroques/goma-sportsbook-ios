//
//  SplashCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 24/07/2025.
//

import UIKit

class SplashCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    // MARK: - Private Properties
    
    private var splashViewController: SplashInformativeViewController?
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Coordinator Protocol
    
    func start() {
        let splashViewController = SplashInformativeViewController()
        self.splashViewController = splashViewController
        navigationController.setViewControllers([splashViewController], animated: false)
    }
    
    func finish() {
        childCoordinators.removeAll()
        splashViewController = nil
    }
}
