//
//  BetSuccessViewController.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import UIKit
import GomaUI

class BetSuccessViewController: UIViewController {
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

    private let betPlacedRow: ActionRowView = ActionRowView()
    private let openDetailsRow: ActionRowView = ActionRowView()
    private let shareRow: ActionRowView = ActionRowView()

    private let shareLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let viewModel: BetSuccessViewModelProtocol

    // MARK: - Navigation Closures
    // Called when success flow completes - handled by coordinator
    var onContinueRequested: (() -> Void)?
    var onOpenDetails: (() -> Void)?
    var onShareBetslip: (() -> Void)?

    init(viewModel: BetSuccessViewModelProtocol) {
        self.viewModel = viewModel
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
        setupActionRows()
        setupLayout()
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }

    private func setupActionRows() {
        // 1. Green "Bet Placed" row - non-tappable
        let betPlacedItem = ActionRowItem(
            icon: "checkmark.circle.fill",
            title: localized("bet_placed"),
            type: .action,
            action: .custom,
            isTappable: false
        )
        betPlacedRow.customBackgroundColor = StyleProvider.Color.alertSuccess
        betPlacedRow.configure(with: betPlacedItem) { _ in }
        betPlacedRow.translatesAutoresizingMaskIntoConstraints = false

        // 2. "Open Betslip Details" row - tappable with chevron
        let openDetailsItem = ActionRowItem(
            icon: "",
            title: localized("open_betslip_details"),
            type: .navigation,
            action: .custom,
            trailingIcon: "chevron.right"
        )
        openDetailsRow.configure(with: openDetailsItem) { [weak self] _ in
            self?.onOpenDetails?()
        }
        openDetailsRow.translatesAutoresizingMaskIntoConstraints = false

        // 3. "Share your Betslip" row - tappable with share icon
        let shareItem = ActionRowItem(
            icon: "",
            title: localized("share_your_betslip"),
            type: .action,
            action: .custom,
            trailingIcon: "share_icon"
        )
        shareRow.configure(with: shareItem) { [weak self] _ in
            self?.onShareBetslip?()
        }
        shareRow.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(closeButton)

        let infoStack = UIStackView(arrangedSubviews: [betPlacedRow, openDetailsRow, shareRow])
        infoStack.axis = .vertical
        infoStack.spacing = 10
        infoStack.alignment = .fill
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(infoStack)

        // Add loading indicator to share row
        shareRow.addSubview(shareLoadingIndicator)

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
            infoStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),

            // Position loading indicator on the right side of share row
            shareLoadingIndicator.trailingAnchor.constraint(equalTo: shareRow.trailingAnchor, constant: -16),
            shareLoadingIndicator.centerYAnchor.constraint(equalTo: shareRow.centerYAnchor)
        ])
    }

    // MARK: - Public Methods

    /// Shows or hides loading state on the share row
    public func setShareLoading(_ isLoading: Bool) {
        shareRow.isUserInteractionEnabled = !isLoading
        shareRow.alpha = isLoading ? 0.6 : 1.0

        if isLoading {
            shareLoadingIndicator.startAnimating()
        } else {
            shareLoadingIndicator.stopAnimating()
        }
    }

    // MARK: - Private Methods

    @objc private func didTapClose() {
        onContinueRequested?()
    }
} 
