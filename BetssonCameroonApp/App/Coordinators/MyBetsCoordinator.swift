//
//  MyBetsCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Claude on 28/08/2025.
//

import UIKit
import ServicesProvider

class MyBetsCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Properties
    
    private let environment: Environment
    private var myBetsViewController: MyBetsViewController?
    
    // MARK: - Navigation Closures
    
    var onShowLogin: (() -> Void)?
    var onNavigateToBetDetail: ((MyBet) -> Void)?
    
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
        // Create real ViewModel with ServicesProvider
        let servicesProvider = environment.servicesProvider
        let viewModel: MyBetsViewModelProtocol = MyBetsViewModel(servicesProvider: servicesProvider)
        let viewController = MyBetsViewController(viewModel: viewModel)
        
        // Setup authentication navigation
        viewController.onLoginRequested = { [weak self] in
            self?.onShowLogin?()
        }
        
        // Setup bet detail navigation
        if let concreteViewModel = viewModel as? MyBetsViewModel {
            concreteViewModel.onNavigateToBetDetail = { [weak self] bet in
                self?.onNavigateToBetDetail?(bet)
            }
        }
        
        self.myBetsViewController = viewController
        
        print("🎯 MyBetsCoordinator: Started MyBets screen with real ViewModel")
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