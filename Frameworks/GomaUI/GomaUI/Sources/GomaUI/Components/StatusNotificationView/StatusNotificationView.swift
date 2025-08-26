import Foundation
import UIKit
import Combine
import SwiftUI

public enum StatusNotificationType {
    case success
    case error
    case warning
    
    var backgroundColor: UIColor {
        switch self {
        case .success:
            return StyleProvider.Color.alertSuccess
        case .error:
            return StyleProvider.Color.alertError
        case .warning:
            return StyleProvider.Color.alertWarning
        }
    }
    
    var iconImage: UIImage? {
        switch self {
        case .success:
            return UIImage(named: "checkmark.circle.fill")
        case .error:
            return UIImage(systemName: "xmark.circle.fill")
        case .warning:
            return UIImage(systemName: "exclamationmark.triangle.fill")
        }
    }
}

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
struct StatusNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            PreviewUIView {
                StatusNotificationView(viewModel: MockStatusNotificationViewModel.successMock)
            }
            .frame(height: 48)
            .previewDisplayName("Success")
            
            PreviewUIView {
                StatusNotificationView(viewModel: MockStatusNotificationViewModel.errorMock)
            }
            .frame(height: 48)
            .previewDisplayName("Error")
            
            PreviewUIView {
                StatusNotificationView(viewModel: MockStatusNotificationViewModel.warningMock)
            }
            .frame(height: 48)
            .previewDisplayName("Alert")
        }
        .padding()
        .frame(maxHeight: 250)
    }
}
#endif
