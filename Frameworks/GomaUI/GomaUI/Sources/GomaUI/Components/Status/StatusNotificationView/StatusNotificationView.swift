import Foundation
import UIKit
import Combine
import SwiftUI


public final class StatusNotificationView: UIView {
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.allWhite
        return imageView
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Properties
    private let viewModel: StatusNotificationViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(viewModel: StatusNotificationViewModelProtocol = MockStatusNotificationViewModel.successMock) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MockStatusNotificationViewModel.successMock
        super.init(coder: coder)
        setupViews()
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        backgroundColor = .clear
        
        addSubview(containerView)
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(messageLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Stack view
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            messageLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            messageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.configure(with: data)
            }
            .store(in: &cancellables)
    }
    
    private func configure(with data: StatusNotificationData) {
        messageLabel.text = data.message
        containerView.backgroundColor = data.type.backgroundColor
        
        if let icon = data.icon {
            iconImageView.image = UIImage(named: icon)?.withTintColor(StyleProvider.Color.allWhite)
        }
        else {
            iconImageView.image = data.type.iconImage
        }
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview(LocalizationProvider.string("success")) {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockStatusNotificationViewModel.successMock
        let notificationView = StatusNotificationView(viewModel: mockViewModel)
        notificationView.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(notificationView)

        NSLayoutConstraint.activate([
            notificationView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            notificationView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            notificationView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview(LocalizationProvider.string("omega_error_fail")) {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockStatusNotificationViewModel.errorMock
        let notificationView = StatusNotificationView(viewModel: mockViewModel)
        notificationView.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(notificationView)

        NSLayoutConstraint.activate([
            notificationView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            notificationView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            notificationView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Warning") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockStatusNotificationViewModel.warningMock
        let notificationView = StatusNotificationView(viewModel: mockViewModel)
        notificationView.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(notificationView)

        NSLayoutConstraint.activate([
            notificationView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            notificationView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            notificationView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("All States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let successView = StatusNotificationView(viewModel: MockStatusNotificationViewModel.successMock)
        successView.translatesAutoresizingMaskIntoConstraints = false

        let errorView = StatusNotificationView(viewModel: MockStatusNotificationViewModel.errorMock)
        errorView.translatesAutoresizingMaskIntoConstraints = false

        let warningView = StatusNotificationView(viewModel: MockStatusNotificationViewModel.warningMock)
        warningView.translatesAutoresizingMaskIntoConstraints = false

        vc.view.addSubview(successView)
        vc.view.addSubview(errorView)
        vc.view.addSubview(warningView)

        NSLayoutConstraint.activate([
            // Success view (top)
            successView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            successView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            successView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),

            // Error view (middle)
            errorView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            errorView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            errorView.topAnchor.constraint(equalTo: successView.bottomAnchor, constant: 16),

            // Warning view (bottom)
            warningView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            warningView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            warningView.topAnchor.constraint(equalTo: errorView.bottomAnchor, constant: 16)
        ])

        return vc
    }
}

#endif
