//
//  MaintenanceCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 24/07/2025.
//

import UIKit

class MaintenanceCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Properties
    
    private let message: String
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController, message: String) {
        self.navigationController = navigationController
        self.message = message
    }
    
    // MARK: - Coordinator Protocol
    
    func start() {
        let maintenanceViewController = MaintenanceViewController()
        
        // Set the maintenance message if the view controller supports it
        // (Note: Would need to modify MaintenanceViewController to accept message parameter)
        
        // Present as full screen root (not modal)
        navigationController.setViewControllers([maintenanceViewController], animated: false)
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}