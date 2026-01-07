//
//  PendingWithdrawView.swift
//  GomaUI
//
//  Created by André on 17/11/2025.
//

import Combine
import UIKit

public final class PendingWithdrawView: UIView {
    
    // MARK: - UI Components
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var contentStackView: UIStackView = Self.createContentStackView()
    private lazy var headerStackView: UIStackView = Self.createHeaderStackView()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var statusBadgeView: UIView = Self.createStatusBadgeView()
    private lazy var statusLabel: UILabel = Self.createStatusLabel()
    private lazy var amountStackView: UIStackView = Self.createAmountStackView()
    private lazy var amountTitleLabel: UILabel = Self.createAmountTitleLabel()
    private lazy var amountValueLabel: UILabel = Self.createAmountValueLabel()
    private lazy var transactionStackView: UIStackView = Self.createTransactionStackView()
    private lazy var transactionTitleLabel: UILabel = Self.createTransactionTitleLabel()
    private lazy var transactionValueStackView: UIStackView = Self.createTransactionValueStackView()
    private lazy var transactionValueLabel: UILabel = Self.createTransactionValueLabel()
    private lazy var copyIconButton: UIButton = Self.createCopyButton()
    
    // MARK: - Properties
    public let viewModel: PendingWithdrawViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(viewModel: PendingWithdrawViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        commonInit()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func commonInit() {
        backgroundColor = .clear
        setupSubviews()
        setupActions()
        render(state: viewModel.currentDisplayState)
    }
    
    private func setupActions() {
        copyIconButton.addTarget(self, action: #selector(handleCopyButtonTap), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state: state)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    private func render(state: PendingWithdrawViewDisplayState) {
        dateLabel.text = state.dateText
        statusLabel.text = state.statusText
        amountTitleLabel.text = state.amountTitleText
        amountValueLabel.text = state.amountValueText
        transactionTitleLabel.text = state.transactionIdTitleText
        transactionValueLabel.text = state.transactionIdValueText
        
        if let iconName = state.copyIconName,
           let image = Self.iconImage(named: iconName) {
            copyIconButton.isHidden = false
            copyIconButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            copyIconButton.imageView?.contentMode = .scaleAspectFit
        } else {
            copyIconButton.setImage(nil, for: .normal)
            copyIconButton.isHidden = true
        }
        
        applyStatusStyle(state.statusStyle)
    }
    
    private func applyStatusStyle(_ style: PendingWithdrawStatusStyle) {
        statusLabel.textColor = style.textColor
        statusBadgeView.backgroundColor = style.backgroundColor
        if let borderColor = style.borderColor {
            statusBadgeView.layer.borderWidth = 1
            statusBadgeView.layer.borderColor = borderColor.cgColor
        } else {
            statusBadgeView.layer.borderWidth = 0
            statusBadgeView.layer.borderColor = nil
        }
    }
    
    // MARK: - Actions
    @objc
    private func handleCopyButtonTap() {
        viewModel.handleCopyTransactionID()
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = false
        
        statusBadgeView.layer.cornerRadius = 12
        statusBadgeView.layer.masksToBounds = true
    }
}

// MARK: - Factory Methods
private extension PendingWithdrawView {
    static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return view
    }
    
    static func createContentStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }
    
    static func createHeaderStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }
    
    static func createAmountStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }
    
    static func createTransactionStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }
    
    static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }
    
    static func createStatusBadgeView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.myTicketsWonFaded
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.directionalLayoutMargins = LayoutConstants.statusBadgeInsets
        return view
    }
    
    static func createStatusLabel() -> UILabel {
        let label = UILabel()
        label.font = StyleProvider.fontWith(type: .semibold, size: 12)
        label.textColor = StyleProvider.Color.buttonActiveHoverPrimary
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }
    
    static func createAmountTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        return label
    }
    
    static func createAmountValueLabel() -> UILabel {
        let label = UILabel()
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }
    
    static func createTransactionTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        return label
    }
    
    static func createTransactionValueStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }
    
    static func createTransactionValueLabel() -> UILabel {
        let label = UILabel()
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        label.textAlignment = .left
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }
    
    static func createCopyButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.tintColor = StyleProvider.Color.highlightPrimary
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return button
    }
    
    static func iconImage(named name: String) -> UIImage? {
        if let bundleImage = UIImage(
            named: name
        ) {
            return bundleImage
        }
        return UIImage(systemName: name)
    }
    
    enum LayoutConstants {
        static let statusBadgeInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
        static let statusBadgeHeight: CGFloat = 24
    }
    
    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(contentStackView)
        
        headerStackView.addArrangedSubview(dateLabel)
        headerStackView.addArrangedSubview(UIView())
        headerStackView.addArrangedSubview(statusBadgeView)
        statusBadgeView.addSubview(statusLabel)
        
        amountStackView.addArrangedSubview(amountTitleLabel)
        amountStackView.addArrangedSubview(UIView())
        amountStackView.addArrangedSubview(amountValueLabel)
        
        transactionValueStackView.addArrangedSubview(copyIconButton)
        transactionValueStackView.addArrangedSubview(transactionValueLabel)
        transactionValueStackView.setContentHuggingPriority(.required, for: .horizontal)
        transactionValueStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        transactionStackView.addArrangedSubview(transactionTitleLabel)
        transactionStackView.addArrangedSubview(UIView())
        transactionStackView.addArrangedSubview(transactionValueStackView)
        
        contentStackView.addArrangedSubview(headerStackView)
        contentStackView.addArrangedSubview(amountStackView)
        contentStackView.addArrangedSubview(transactionStackView)
        
        initConstraints()

    }
    
    private func initConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        transactionValueStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            copyIconButton.widthAnchor.constraint(equalToConstant: 24),
            copyIconButton.heightAnchor.constraint(equalToConstant: 24),
            
            statusBadgeView.heightAnchor.constraint(equalToConstant: LayoutConstants.statusBadgeHeight),
            statusLabel.leadingAnchor.constraint(equalTo: statusBadgeView.layoutMarginsGuide.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadgeView.layoutMarginsGuide.trailingAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: statusBadgeView.centerYAnchor)
        ])
    }
}

public struct PendingWithdrawStatusStyle {
    public let textColor: UIColor
    public let backgroundColor: UIColor
    public let borderColor: UIColor?
    
    public init(
        textColor: UIColor = StyleProvider.Color.buttonActiveHoverPrimary,
        backgroundColor: UIColor = StyleProvider.Color.myTicketsWonFaded,
        borderColor: UIColor? = StyleProvider.Color.buttonActiveHoverPrimary
    ) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

#Preview("Pending Withdraw View") {
    PreviewUIViewController {
        let container = UIViewController()
        container.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        let viewModel = MockPendingWithdrawViewModel()
        let pendingView = PendingWithdrawView(viewModel: viewModel)
        pendingView.translatesAutoresizingMaskIntoConstraints = false
        
        container.view.addSubview(pendingView)
        
        NSLayoutConstraint.activate([
            pendingView.leadingAnchor.constraint(equalTo: container.view.leadingAnchor, constant: 20),
            pendingView.trailingAnchor.constraint(equalTo: container.view.trailingAnchor, constant: -20),
            pendingView.topAnchor.constraint(equalTo: container.view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ])
        
        return container
    }
}
#endif

