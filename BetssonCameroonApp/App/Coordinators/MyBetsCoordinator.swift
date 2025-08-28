//
//  MyBetsCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Claude on 28/08/2025.
//

import UIKit

class MyBetsCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Properties
    
    private let environment: Environment
    private var myBetsViewController: MyBetsViewController?
    
    // MARK: - Navigation Closures
    
    var onShowLogin: (() -> Void)?
    
    // MARK: - Public Properties
    
    var viewController: UIViewController? {
        return myBetsViewController
    }
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController, environment: Environment) {
        self.navigationController = navigationController
        self.environment = environment
    }
    
    // MARK: - Coordinator Protocol
    
    func start() {
        let viewModel: MyBetsViewModelProtocol = MockMyBetsViewModel()
        let viewController = MyBetsViewController(viewModel: viewModel)
        
        // Setup authentication navigation
        viewController.onLoginRequested = { [weak self] in
            self?.onShowLogin?()
        }
        
        self.myBetsViewController = viewController
        
        print("🎯 MyBetsCoordinator: Started MyBets screen")
    }
    
    func finish() {
        childCoordinators.removeAll()
        myBetsViewController = nil
    }
    
    // MARK: - Public Methods
    
    func refresh() {
        myBetsViewController?.refreshData()
        print("🎯 MyBetsCoordinator: Refreshed MyBets data")
    }
}