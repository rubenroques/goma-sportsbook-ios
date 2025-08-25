//
//  BetslipViewController.swift
//  Demo
//
//  Created by Claude on 09/07/2025.
//

import Foundation
import UIKit
import GomaUI

class BetslipDemoViewController: UIViewController {
    
    private let betslipView: BetslipViewController
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        // Create a mock view model for demo purposes
        let mockViewModel = MockBetslipViewModel.defaultMock()
        self.betslipView = BetslipViewController(viewModel: mockViewModel)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray4
        setupBetslipView()
    }
    
    private func setupBetslipView() {
        // Add the betslip view as a child view controller
        addChild(betslipView)
        view.addSubview(betslipView.view)
        betslipView.didMove(toParent: self)
        
        // Set up constraints
        betslipView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            betslipView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            betslipView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            betslipView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            betslipView.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
} 