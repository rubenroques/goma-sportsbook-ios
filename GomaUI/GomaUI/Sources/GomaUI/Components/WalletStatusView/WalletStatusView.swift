//
//  WalletStatusView.swift
//  GomaUI
//
//  Created by Claude on 04/07/2025.
//

import UIKit
import Combine
import SwiftUI

final public class WalletStatusView: UIView {
    
    // MARK: - Private Properties
    private let viewModel: WalletStatusViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // UI Components
    private lazy var containerStackView = Self.createContainerStackView()
    private lazy var totalBalanceRow = Self.createBalanceRow(withIcon: true)
    private lazy var firstSeparatorLine = Self.createSeparatorLine()
    private lazy var currentBalanceRow = Self.createBalanceRow(withIcon: false)
    private lazy var bonusBalanceRow = Self.createBalanceRow(withIcon: false)
    private lazy var cashbackBalanceRow = Self.createBalanceRow(withIcon: false)
    private lazy var secondSeparatorLine = Self.createSeparatorLine()
    private lazy var withdrawableRow = Self.createBalanceRow(withIcon: false)
    private var depositButton: ButtonView
    private var withdrawButton: ButtonView
    
    // MARK: - Initialization
    public init(viewModel: WalletStatusViewModelProtocol) {
        self.viewModel = viewModel
        self.depositButton = ButtonView(viewModel: viewModel.depositButtonViewModel)
        self.withdrawButton = ButtonView(viewModel: viewModel.withdrawButtonViewModel)
        
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
        applyTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        backgroundColor = StyleProvider.Color.backgroundTertiary
        layer.cornerRadius = 8
        
        addSubview(containerStackView)
        
        // Add all rows to stack view
        containerStackView.addArrangedSubview(totalBalanceRow)
        containerStackView.addArrangedSubview(firstSeparatorLine)
        containerStackView.addArrangedSubview(currentBalanceRow)
        containerStackView.addArrangedSubview(bonusBalanceRow)
        containerStackView.addArrangedSubview(cashbackBalanceRow)
        containerStackView.addArrangedSubview(secondSeparatorLine)
        containerStackView.addArrangedSubview(withdrawableRow)
        
        // Add spacing before buttons
        let buttonSpacingView = UIView()
        buttonSpacingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonSpacingView.heightAnchor.constraint(equalToConstant: 2)
        ])
        containerStackView.addArrangedSubview(buttonSpacingView)
        
        containerStackView.addArrangedSubview(depositButton)
        containerStackView.addArrangedSubview(withdrawButton)
        
        // Set custom button heights and font sizes
        depositButton.setCustomHeight(40)
        depositButton.setCustomFontSize(15)
        withdrawButton.setCustomHeight(40)
        withdrawButton.setCustomFontSize(15)
        
        setupConstraints()
        setupLabels()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    private func setupLabels() {
        // Total Balance - has icon in left container
        if let leftContainer = totalBalanceRow.arrangedSubviews.first as? UIStackView {
            if let iconImageView = leftContainer.arrangedSubviews.first as? UIImageView {
                iconImageView.image = UIImage(named: "banknote_cash_icon", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                iconImageView.tintColor = StyleProvider.Color.highlightPrimary
            }
            if let label = leftContainer.arrangedSubviews.last as? UILabel {
                label.text = "Total Balance"
            }
        }
        
        // Other balance labels - check for left container or direct label
        if let leftContainer = currentBalanceRow.arrangedSubviews.first as? UIStackView,
           let label = leftContainer.arrangedSubviews.first as? UILabel {
            label.text = "Current Balance"
        } else if let label = currentBalanceRow.arrangedSubviews.first as? UILabel {
            label.text = "Current Balance"
        }
        
        if let leftContainer = bonusBalanceRow.arrangedSubviews.first as? UIStackView,
           let label = leftContainer.arrangedSubviews.first as? UILabel {
            label.text = "Bonus"
        } else if let label = bonusBalanceRow.arrangedSubviews.first as? UILabel {
            label.text = "Bonus"
        }
        
        if let leftContainer = cashbackBalanceRow.arrangedSubviews.first as? UIStackView,
           let label = leftContainer.arrangedSubviews.first as? UILabel {
            label.text = "Cashback balance"
        } else if let label = cashbackBalanceRow.arrangedSubviews.first as? UILabel {
            label.text = "Cashback balance"
        }
        
        if let leftContainer = withdrawableRow.arrangedSubviews.first as? UIStackView,
           let label = leftContainer.arrangedSubviews.first as? UILabel {
            label.text = "Withdrawable"
        } else if let label = withdrawableRow.arrangedSubviews.first as? UILabel {
            label.text = "Withdrawable"
        }
    }
    
    private func setupBindings() {
        // Total Balance
        viewModel.totalBalancePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let valueLabel = self?.totalBalanceRow.arrangedSubviews.last as? UILabel {
                    valueLabel.text = value
                }
            }
            .store(in: &cancellables)
        
        // Current Balance
        viewModel.currentBalancePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let valueLabel = self?.currentBalanceRow.arrangedSubviews.last as? UILabel {
                    valueLabel.text = value
                }
            }
            .store(in: &cancellables)
        
        // Bonus Balance
        viewModel.bonusBalancePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let valueLabel = self?.bonusBalanceRow.arrangedSubviews.last as? UILabel {
                    valueLabel.text = value
                }
            }
            .store(in: &cancellables)
        
        // Cashback Balance
        viewModel.cashbackBalancePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let valueLabel = self?.cashbackBalanceRow.arrangedSubviews.last as? UILabel {
                    valueLabel.text = value
                }
            }
            .store(in: &cancellables)
        
        // Withdrawable Amount
        viewModel.withdrawableAmountPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let valueLabel = self?.withdrawableRow.arrangedSubviews.last as? UILabel {
                    valueLabel.text = value
                }
            }
            .store(in: &cancellables)
    }
    
    private func applyTheme() {
        backgroundColor = StyleProvider.Color.backgroundTertiary
    }
}

// MARK: - UI Elements Factory
extension WalletStatusView {
    
    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }
    
    private static func createBalanceRow(withIcon: Bool) -> UIStackView {
        let rowStack = UIStackView()
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        rowStack.axis = .horizontal
        rowStack.distribution = .equalSpacing
        rowStack.alignment = .center
        
        // Left side container
        let leftContainer = UIStackView()
        leftContainer.axis = .horizontal
        leftContainer.spacing = 3
        leftContainer.alignment = .center
        
        if withIcon {
            let iconImageView = UIImageView()
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            iconImageView.contentMode = .scaleAspectFit
            NSLayoutConstraint.activate([
                iconImageView.widthAnchor.constraint(equalToConstant: 24),
                iconImageView.heightAnchor.constraint(equalToConstant: 24)
            ])
            leftContainer.addArrangedSubview(iconImageView)
        }
        
        let titleLabel = UILabel()
        titleLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        leftContainer.addArrangedSubview(titleLabel)
        
        // Value label
        let valueLabel = UILabel()
        valueLabel.font = StyleProvider.fontWith(type: .bold, size: 14)
        valueLabel.textColor = StyleProvider.Color.highlightPrimary
        valueLabel.textAlignment = .right
        
        rowStack.addArrangedSubview(leftContainer)
        rowStack.addArrangedSubview(valueLabel)
        
        return rowStack
    }
    
    private static func createSeparatorLine() -> UIView {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = StyleProvider.Color.separatorLine
        NSLayoutConstraint.activate([
            line.heightAnchor.constraint(equalToConstant: 1)
        ])
        return line
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Default Wallet Status") {
    PreviewUIViewController {
        let vc = UIViewController()
        
        let walletView = WalletStatusView(viewModel: MockWalletStatusViewModel.defaultMock)
        walletView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(walletView)
        
        NSLayoutConstraint.activate([
            walletView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            walletView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            walletView.widthAnchor.constraint(equalToConstant: 350),
            walletView.heightAnchor.constraint(lessThanOrEqualToConstant: 340)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("All Balance States") {
    PreviewUIViewController {
        let vc = UIViewController()
        
        // Stack view for multiple states
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Default state
        let defaultWallet = WalletStatusView(viewModel: MockWalletStatusViewModel.defaultMock)
        defaultWallet.translatesAutoresizingMaskIntoConstraints = false
        
        // Empty balance state
        let emptyWallet = WalletStatusView(viewModel: MockWalletStatusViewModel.emptyBalanceMock)
        emptyWallet.translatesAutoresizingMaskIntoConstraints = false
        
        // High balance state
        let highBalanceWallet = WalletStatusView(viewModel: MockWalletStatusViewModel.highBalanceMock)
        highBalanceWallet.translatesAutoresizingMaskIntoConstraints = false
        
        // Create labels
        let createLabel: (String) -> UILabel = { text in
            let label = UILabel()
            label.text = text
            label.font = StyleProvider.fontWith(type: .medium, size: 14)
            label.textColor = StyleProvider.Color.textSecondary
            label.textAlignment = .center
            return label
        }
        
        // Add to stack
        stackView.addArrangedSubview(createLabel("Default Balance"))
        stackView.addArrangedSubview(defaultWallet)
        stackView.addArrangedSubview(createLabel("Empty Balance"))
        stackView.addArrangedSubview(emptyWallet)
        stackView.addArrangedSubview(createLabel("High Balance"))
        stackView.addArrangedSubview(highBalanceWallet)
        
        // Scroll view for content
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        vc.view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            defaultWallet.widthAnchor.constraint(equalToConstant: 350),
            emptyWallet.widthAnchor.constraint(equalToConstant: 350),
            highBalanceWallet.widthAnchor.constraint(equalToConstant: 350)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Dialog Overlay") {
    PreviewUIViewController {
        let vc = UIViewController()
        
        // Background content
        let backgroundLabel = UILabel()
        backgroundLabel.text = "Background Content"
        backgroundLabel.font = StyleProvider.fontWith(type: .bold, size: 24)
        backgroundLabel.textColor = StyleProvider.Color.textSecondary
        backgroundLabel.textAlignment = .center
        backgroundLabel.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(backgroundLabel)
        
        // Overlay
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        // Wallet view
        let walletView = WalletStatusView(viewModel: MockWalletStatusViewModel.highBalanceMock)
        walletView.translatesAutoresizingMaskIntoConstraints = false
        
        overlayView.addSubview(walletView)
        vc.view.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            backgroundLabel.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            backgroundLabel.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            
            overlayView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
            
            walletView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            walletView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            walletView.widthAnchor.constraint(equalToConstant: 350)
        ])
        
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        return vc
    }
}

#endif
