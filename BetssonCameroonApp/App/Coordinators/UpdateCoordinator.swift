//
//  UpdateCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 24/07/2025.
//

import UIKit

class UpdateCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Properties
    
    private let isRequired: Bool
    var onDismiss: (() -> Void)?
    
    // MARK: - Private Properties
    
    private var versionUpdateViewController: VersionUpdateViewController?
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController, isRequired: Bool) {
        self.navigationController = navigationController
        self.isRequired = isRequired
    }
    
    // MARK: - Coordinator Protocol
    
    func start() {
        let versionUpdateViewController = VersionUpdateViewController(updateRequired: isRequired)
        self.versionUpdateViewController = versionUpdateViewController
        navigationController.present(versionUpdateViewController, animated: true, completion: nil)
    }
    
    func finish() {
        childCoordinators.removeAll()
        
        if let versionUpdateViewController = versionUpdateViewController,
           navigationController.presentedViewController == versionUpdateViewController {
            navigationController.dismiss(animated: true, completion: nil)
        }
        
        versionUpdateViewController = nil
    }
}
