//
//  DepositBonusSuccessViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 02/07/2025.
//

import Foundation
import UIKit
import GomaUI

class DepositBonusSuccessViewController: UIViewController {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close_circle_icon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let statusNotificationView: StatusNotificationView
    private let infoRowViews: [InfoRowView]

    private let viewModel: DepositBonusSuccessViewModelProtocol
    
    // MARK: - Navigation Closures
    // Called when success flow completes - handled by coordinator
    var onContinueRequested: (() -> Void)?

    init(viewModel: DepositBonusSuccessViewModelProtocol) {
        self.viewModel = viewModel
        self.statusNotificationView = StatusNotificationView(viewModel: viewModel.statusNotificationViewModel)
        self.infoRowViews = viewModel.infoRowViewModels.map { InfoRowView(viewModel: $0) }
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
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }

    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(closeButton)
        
        let infoStack = UIStackView(arrangedSubviews: [statusNotificationView] + infoRowViews)
        infoStack.axis = .vertical
        infoStack.spacing = 10
        infoStack.alignment = .fill
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(infoStack)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.7),

            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),

            infoStack.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 12),
            infoStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            infoStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            infoStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }

    @objc private func didTapClose() {
        onContinueRequested?()
    }
}
