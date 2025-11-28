//
//  FirstDepositPromotionsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 01/07/2025.
//

import Foundation
import UIKit
import GomaUI

class FirstDepositPromotionsViewController: UIViewController {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let navigationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("welcome_to_betsson")
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.highlightPrimary
        label.textAlignment = .center
        return label
    }()
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close_circle_icon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let headerView: PromotionalHeaderView
    private let bonusCardsScrollView: PromotionalBonusCardsScrollView
    
    private let viewModel: FirstDepositPromotionsViewModelProtocol
    
    // MARK: - Navigation Closures
    // Called when user selects a bonus card - handled by coordinator
    var onBonusSelected: ((PromotionalBonusCardData) -> Void)?
    var onSkipRequested: (() -> Void)?
    var onCloseRequested: (() -> Void)?

    init(viewModel: FirstDepositPromotionsViewModelProtocol = MockFirstDepositPromotionsViewModel()) {
        self.viewModel = viewModel
        self.headerView = PromotionalHeaderView(viewModel: viewModel.headerViewModel)
        self.bonusCardsScrollView = PromotionalBonusCardsScrollView(viewModel: viewModel.bonusCardsViewModel)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        setupLayout()
        setupBindings()
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }

    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(navigationView)
        navigationView.addSubview(navigationTitleLabel)
        navigationView.addSubview(closeButton)
        containerView.addSubview(headerView)
        containerView.addSubview(bonusCardsScrollView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.9)
        ])

        // Navigation
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 40),

            navigationTitleLabel.centerXAnchor.constraint(equalTo: navigationView.centerXAnchor),
            navigationTitleLabel.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),

            closeButton.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        // Header
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: 10),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8)
        ])

        // Bonus cards scroll view
        bonusCardsScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bonusCardsScrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            bonusCardsScrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            bonusCardsScrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            bonusCardsScrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupBindings() {
        
        self.bonusCardsScrollView.onCardClaimBonus = { [weak self] cardBonus in
            self?.onBonusSelected?(cardBonus)
        }
        
        self.bonusCardsScrollView.onCardTermsTapped = { [weak self] cardBonus in
            // TODO: Handle terms and conditions display
        }
        
        // Setup close button action
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }

    @objc private func didTapClose() {
        onCloseRequested?()
    }
}
