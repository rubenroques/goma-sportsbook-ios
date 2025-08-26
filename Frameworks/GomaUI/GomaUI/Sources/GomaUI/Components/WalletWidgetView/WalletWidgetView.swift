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
    public var onDepositTapped: ((String) -> Void) = { _ in }
    public var onBalanceTapped: ((String) -> Void) = { _ in }

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
        depositButton.accessibilityIdentifier = state.walletData.id
        balanceContainer.accessibilityIdentifier = state.walletData.id
    }

    // MARK: - Action Handlers
    @objc private func depositTapped() {
        viewModel.deposit()
        if let id = depositButton.accessibilityIdentifier {
            onDepositTapped(id)
        }
    }

    @objc private func balanceTapped() {
        if let id = balanceContainer.accessibilityIdentifier {
            onBalanceTapped(id)
        }
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Wallet Widget") {
    PreviewUIView {
        let viewModel = MockWalletWidgetViewModel.defaultMock
        return WalletWidgetView(viewModel: viewModel)
    }
    .frame(width: 180, height: 50)
}

#endif
