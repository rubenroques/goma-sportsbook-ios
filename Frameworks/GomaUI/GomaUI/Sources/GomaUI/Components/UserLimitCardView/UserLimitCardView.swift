//
//  UserLimitCardView.swift
//  GomaUI
//
//  Created by Claude on 11/11/2025.
//

import UIKit
import SwiftUI

public final class UserLimitCardView: UIView {
    
    // MARK: - UI Components
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createHorizontalStackView()
    private lazy var infoStackView: UIStackView = Self.createVerticalStackView()
    private lazy var typeLabel: UILabel = Self.createTypeLabel()
    private lazy var valueLabel: UILabel = Self.createValueLabel()
    private let actionButton: ButtonView
    
    // MARK: - Properties
    public let viewModel: UserLimitCardViewModelProtocol
    public var onActionTapped: ((String) -> Void)?
    
    // MARK: - Initialization
    public init(viewModel: UserLimitCardViewModelProtocol) {
        self.viewModel = viewModel
        self.actionButton = ButtonView(viewModel: viewModel.actionButtonViewModel)
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func commonInit() {
        configureAppearance()
        setupHierarchy()
        setupConstraints()
        configureTexts()
        setupButtonCallback()
    }
    
    private func configureAppearance() {
        backgroundColor = .clear
        containerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        containerView.layer.masksToBounds = true
    }
    
    private func setupHierarchy() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(infoStackView)
        stackView.addArrangedSubview(actionButton)
        
        infoStackView.addArrangedSubview(typeLabel)
        infoStackView.addArrangedSubview(valueLabel)
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            actionButton.heightAnchor.constraint(equalToConstant: 35),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)

        ])
        
    }
    
    private func configureTexts() {
        typeLabel.text = viewModel.typeText
        valueLabel.text = viewModel.valueText
    }
    
    private func setupButtonCallback() {
        actionButton.onButtonTapped = { [weak self] in
            guard let self else { return }
            self.onActionTapped?(self.viewModel.limitId)
        }
    }
    
}

// MARK: - Factory Methods
private extension UserLimitCardView {
    static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func createHorizontalStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }
    
    static func createVerticalStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        return stack
    }
    
    static func createTypeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        return label
    }
    
    static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        return label
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("User Limit Card") {
    PreviewUIViewController {
        let viewModel = MockUserLimitCardViewModel.removalMock()
        let cardView = UserLimitCardView(viewModel: viewModel)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.onActionTapped = { limitId in
            print("Remove tapped for \(limitId)")
        }
        
        let container = UIViewController()
        container.view.backgroundColor = StyleProvider.Color.backgroundSecondary
        container.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: container.view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: container.view.trailingAnchor, constant: -20),
            cardView.topAnchor.constraint(equalTo: container.view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ])

        return container
    }
}
#endif
