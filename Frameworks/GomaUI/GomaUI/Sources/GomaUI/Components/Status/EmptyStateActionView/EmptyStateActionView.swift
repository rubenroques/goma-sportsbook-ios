import Foundation
import UIKit
import Combine
import SwiftUI

/// A view that displays an empty state with an image, title, and optional action button
public final class EmptyStateActionView: UIView {
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    // Image view
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        return imageView
    }()
    
    // Title label
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // Action button
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = StyleProvider.Color.highlightSecondary
        button.setTitleColor(StyleProvider.Color.buttonTextPrimary, for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .bold, size: 14)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(handleActionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private let viewModel: EmptyStateActionViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(viewModel: EmptyStateActionViewModelProtocol) {
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
        addSubview(containerView)
        
        containerView.addSubview(mainStackView)
        
        // Add image view
        mainStackView.addArrangedSubview(imageView)
        
        // Add title label
        mainStackView.addArrangedSubview(titleLabel)
        
        // Add action button
        mainStackView.addArrangedSubview(actionButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Main stack view
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            // Image view
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -16),
            
            // Action button
            actionButton.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -16),
            actionButton.heightAnchor.constraint(equalToConstant: 48),
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
    
    // MARK: - Rendering
    private func render(data: EmptyStateActionData) {
        // Update image
        if let customImage = UIImage(named: data.image ?? "") {
            imageView.image = customImage
        }
        else if let systemImage = UIImage(systemName: data.image ?? "") {
            imageView.image = systemImage
        }
        
        // Update title
        titleLabel.text = data.title
        
        // Update action button
        actionButton.setTitle(data.actionButtonTitle, for: .normal)
        
        // Show/hide action button based on state
        switch data.state {
        case .loggedOut:
            actionButton.isHidden = false
        case .loggedIn:
            actionButton.isHidden = true
        }
        
        // Update enabled state
        alpha = data.isEnabled ? 1.0 : 0.5
        isUserInteractionEnabled = data.isEnabled
        actionButton.isEnabled = data.isEnabled
    }
    
    // MARK: - Actions
    @objc private func handleActionButtonTapped() {
        viewModel.onActionButtonTapped?()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

#Preview("All States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "EmptyStateActionView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center

        // Vertical stack with all states
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Logged out state (with action button)
        let loggedOutView = EmptyStateActionView(viewModel: MockEmptyStateActionViewModel.loggedOutMock())
        loggedOutView.translatesAutoresizingMaskIntoConstraints = false

        // Logged in state (no action button)
        let loggedInView = EmptyStateActionView(viewModel: MockEmptyStateActionViewModel.loggedInMock())
        loggedInView.translatesAutoresizingMaskIntoConstraints = false

        // Disabled state
        let disabledView = EmptyStateActionView(viewModel: MockEmptyStateActionViewModel.disabledMock())
        disabledView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(loggedOutView)
        stackView.addArrangedSubview(loggedInView)
        stackView.addArrangedSubview(disabledView)

        // Add to view hierarchy
        vc.view.addSubview(titleLabel)
        vc.view.addSubview(stackView)

        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),

            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}

#endif 
