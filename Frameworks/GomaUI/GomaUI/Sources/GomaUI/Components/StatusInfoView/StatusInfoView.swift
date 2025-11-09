import Foundation
import UIKit
import SwiftUI


public class StatusInfoView: UIView {
    private let viewModel: StatusInfoViewModelProtocol

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationProvider.string("title")
        label.font = StyleProvider.fontWith(type: .bold, size: 24)
        label.numberOfLines = 0
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationProvider.string("message")
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        label.numberOfLines = 0
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()

    public init(viewModel: StatusInfoViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = StyleProvider.Color.backgroundTertiary

        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 100),
            iconView.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    private func configure() {
        
        if let iconImage = UIImage(named: viewModel.statusInfo.icon) {
            iconView.image = iconImage
        }
        else {
            iconView.image = UIImage(systemName: viewModel.statusInfo.icon)
        }
        
        titleLabel.text = viewModel.statusInfo.title
        
        messageLabel.text = viewModel.statusInfo.message
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("All States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "StatusInfoView"
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

        // Success state
        let successView = StatusInfoView(viewModel: MockStatusInfoViewModel.successMock)
        successView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(successView)

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
