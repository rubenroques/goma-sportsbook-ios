import Foundation
import UIKit
import Combine
import SwiftUI

/// A button component that displays an icon and text with configurable layout (icon left or right)
public final class ButtonIconView: UIView {
    
    // MARK: - Properties
    private let viewModel: ButtonIconViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    // Container view
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    // Button
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(StyleProvider.Color.textPrimary, for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .regular, size: 14)
        return button
    }()
    
    // Stack view for content
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.isUserInteractionEnabled = false
        return stackView
    }()
    
    // Icon image view
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        imageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        return imageView
    }()
    
    // Title label
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Initialization
    public init(viewModel: ButtonIconViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        setupBindings()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(button)
        containerView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(titleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Button fills container
            button.topAnchor.constraint(equalTo: containerView.topAnchor),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Content stack view
            contentStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            contentStackView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 8),
            contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.render(data: data)
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        button.addTarget(self, action: #selector(handleButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Rendering
    private func render(data: ButtonIconData) {
        // Update title
        titleLabel.text = data.title
        
        // Update icon
        iconImageView.image = data.icon
        
        // Update layout
        updateLayout(for: data.layoutType)
        
        // Update enabled state
        alpha = data.isEnabled ? 1.0 : 0.5
        isUserInteractionEnabled = data.isEnabled
        button.isEnabled = data.isEnabled
    }
    
    private func updateLayout(for layoutType: ButtonIconLayoutType) {
        // Remove all arranged subviews
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        switch layoutType {
        case .iconLeft:
            // Icon on the left, title on the right
            contentStackView.addArrangedSubview(iconImageView)
            contentStackView.addArrangedSubview(titleLabel)
            
        case .iconRight:
            // Title on the left, icon on the right
            contentStackView.addArrangedSubview(titleLabel)
            contentStackView.addArrangedSubview(iconImageView)
        }
    }
    
    // MARK: - Actions
    @objc private func handleButtonTapped() {
        viewModel.onButtonTapped?()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Icon Left") {
    PreviewUIView {
        ButtonIconView(viewModel: MockButtonIconViewModel.bookingCodeMock())
    }
    .frame(height: 44)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Icon Right") {
    PreviewUIView {
        ButtonIconView(viewModel: MockButtonIconViewModel.clearBetslipMock())
    }
    .frame(height: 44)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Disabled") {
    PreviewUIView {
        ButtonIconView(viewModel: MockButtonIconViewModel.disabledMock())
    }
    .frame(height: 44)
    .padding()
}

#endif 
