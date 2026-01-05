//
//  WalletWidgetView.swift
//  GomaUI
//

import UIKit
import Combine
import SwiftUI

final public class WalletWidgetView: UIView {
    
    // MARK: - Private Properties
    private let stackView = UIStackView()
    private let balanceContainer = UIView()
    private let balanceStackView = UIStackView()
    private let balanceLabel = UILabel()
    private let chevronImage = UIImageView()
    private let depositButton = UIButton(type: .system)

    private let viewModel: WalletWidgetViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Properties
    public var onDepositTapped: ((WidgetTypeIdentifier) -> Void) = { _ in }
    public var onBalanceTapped: ((WidgetTypeIdentifier) -> Void) = { _ in }

    // MARK: - Initialization
    public init(viewModel: WalletWidgetViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupSubviews() {
        setupStackView()
        setupBalanceContainer()
        setupDepositButton()

        stackView.addArrangedSubview(balanceContainer)
        stackView.addArrangedSubview(depositButton)

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    private func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .fill
    }

    private func setupBalanceContainer() {
        // Balance container (darker orange)
        balanceContainer.translatesAutoresizingMaskIntoConstraints = false
        balanceContainer.backgroundColor = StyleProvider.Color.highlightPrimaryContrast.withAlphaComponent(0.1)
        balanceContainer.layer.cornerRadius = 8
        balanceContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        // Add tap gesture to balance container
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(balanceTapped))
        balanceContainer.addGestureRecognizer(tapGesture)
        balanceContainer.isUserInteractionEnabled = true

        // Balance stack view
        balanceStackView.translatesAutoresizingMaskIntoConstraints = false
        balanceStackView.axis = .horizontal
        balanceStackView.spacing = 5
        balanceStackView.alignment = .center
        balanceStackView.isLayoutMarginsRelativeArrangement = true
        balanceStackView.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 6)

        // Balance label
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceLabel.textColor = StyleProvider.Color.allWhite
        balanceLabel.font = StyleProvider.fontWith(type: .semibold, size: 14)

        // Chevron image
        chevronImage.image = UIImage(systemName: "chevron.down")
        chevronImage.translatesAutoresizingMaskIntoConstraints = false
        chevronImage.tintColor = StyleProvider.Color.allWhite
        chevronImage.contentMode = .scaleAspectFit
        chevronImage.widthAnchor.constraint(equalToConstant: 12).isActive = true

        balanceStackView.addArrangedSubview(balanceLabel)
        balanceStackView.addArrangedSubview(chevronImage)
        balanceContainer.addSubview(balanceStackView)

        NSLayoutConstraint.activate([
            balanceStackView.leadingAnchor.constraint(equalTo: balanceContainer.leadingAnchor),
            balanceStackView.trailingAnchor.constraint(equalTo: balanceContainer.trailingAnchor),
            balanceStackView.topAnchor.constraint(equalTo: balanceContainer.topAnchor),
            balanceStackView.bottomAnchor.constraint(equalTo: balanceContainer.bottomAnchor)
        ])
    }

    private func setupDepositButton() {
        depositButton.translatesAutoresizingMaskIntoConstraints = false
        depositButton.backgroundColor = StyleProvider.Color.allWhite
        depositButton.setTitleColor(StyleProvider.Color.topBarGradient1, for: .normal)
        depositButton.titleLabel?.font = StyleProvider.fontWith(type: .bold, size: 14)
        depositButton.layer.cornerRadius = 8
        depositButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        depositButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)

        depositButton.addTarget(self, action: #selector(depositTapped), for: .touchUpInside)
    }

    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
    }

    // MARK: - Rendering
    private func render(state: WalletWidgetDisplayState) {
        balanceLabel.text = state.walletData.balance
        depositButton.setTitle(state.walletData.depositButtonTitle, for: .normal)
        depositButton.accessibilityIdentifier = state.walletData.id.rawValue
        balanceContainer.accessibilityIdentifier = state.walletData.id.rawValue
    }

    // MARK: - Action Handlers
    @objc private func depositTapped() {
        viewModel.deposit()
        if let idString = depositButton.accessibilityIdentifier,
           let id = WidgetTypeIdentifier(rawValue: idString) {
            onDepositTapped(id)
        }
    }

    @objc private func balanceTapped() {
        print("💰 WALLET_TAP: WalletWidgetView.balanceTapped() called")
        if let idString = balanceContainer.accessibilityIdentifier,
           let id = WidgetTypeIdentifier(rawValue: idString) {
            print("💰 WALLET_TAP: Calling onBalanceTapped callback with id: \(id)")
            onBalanceTapped(id)
        } else {
            print("💰 WALLET_TAP: ERROR - No accessibilityIdentifier on balanceContainer!")
        }
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("WalletWidgetView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "WalletWidgetView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Default balance
        let defaultViewModel = MockWalletWidgetViewModel(
            walletData: WalletWidgetData(
                id: .wallet,
                balance: "2,000.00",
                depositButtonTitle: "DEPOSIT"
            )
        )
        let defaultView = WalletWidgetView(viewModel: defaultViewModel)
        defaultView.translatesAutoresizingMaskIntoConstraints = false

        // High balance
        let highBalanceViewModel = MockWalletWidgetViewModel(
            walletData: WalletWidgetData(
                id: .wallet,
                balance: "50,250.75",
                depositButtonTitle: "DEPOSIT"
            )
        )
        let highBalanceView = WalletWidgetView(viewModel: highBalanceViewModel)
        highBalanceView.translatesAutoresizingMaskIntoConstraints = false

        // Low balance
        let lowBalanceViewModel = MockWalletWidgetViewModel(
            walletData: WalletWidgetData(
                id: .wallet,
                balance: "0.00",
                depositButtonTitle: "DEPOSIT"
            )
        )
        let lowBalanceView = WalletWidgetView(viewModel: lowBalanceViewModel)
        lowBalanceView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(defaultView)
        stackView.addArrangedSubview(highBalanceView)
        stackView.addArrangedSubview(lowBalanceView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}

#endif
