import UIKit
import SwiftUI

public final class ShareChannelButtonView: UIView {

    // MARK: - Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconContainerView: UIView = Self.createIconContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var stackView: UIStackView = Self.createStackView()

    private var channel: ShareChannel?
    private var onTapCallback: (() -> Void)?

    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupWithTheme()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setupWithTheme()
    }

    private func commonInit() {
        setupSubviews()
        setupActions()
    }

    private func setupWithTheme() {
        backgroundColor = .clear
        iconImageView.tintColor = StyleProvider.Color.allWhite
        titleLabel.textColor = StyleProvider.Color.textPrimary
    }

    // MARK: - Public Methods
    public func configure(with channel: ShareChannel, onTap: @escaping () -> Void) {
        self.channel = channel
        self.onTapCallback = onTap

        titleLabel.text = channel.title

        // Try to load image from bundle first, fallback to system image
        if let bundleImage = UIImage(named: channel.iconName) {
            iconImageView.image = bundleImage.withRenderingMode(.alwaysTemplate)
        } else if let systemImage = UIImage(systemName: channel.iconName) {
            iconImageView.image = systemImage
        }

        // Set background color
        iconContainerView.backgroundColor = channel.type.backgroundColor

        // Update interaction state
        isUserInteractionEnabled = channel.isAvailable
        alpha = channel.isAvailable ? 1.0 : 0.5
    }
}

// MARK: - Subviews Initialization and Setup
extension ShareChannelButtonView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }

    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(stackView)

        iconContainerView.addSubview(iconImageView)

        stackView.addArrangedSubview(iconContainerView)
        stackView.addArrangedSubview(titleLabel)

        initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Stack view
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // Icon container (circular, 44pt for tap target)
            iconContainerView.widthAnchor.constraint(equalToConstant: 44),
            iconContainerView.heightAnchor.constraint(equalToConstant: 44),

            // Icon image (24pt inside container)
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        guard let channel = channel, channel.isAvailable else { return }

        // Add tap feedback animation
        UIView.animate(withDuration: 0.1, animations: {
            self.iconContainerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.iconContainerView.transform = CGAffineTransform.identity
            }
        }

        onTapCallback?()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Twitter") {
    PreviewUIViewController {
        let vc = UIViewController()
        let button = ShareChannelButtonView()
        button.configure(with: ShareChannel(type: .twitter)) {
            print("Twitter tapped")
        }
        button.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 70)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("WhatsApp") {
    PreviewUIViewController {
        let vc = UIViewController()
        let button = ShareChannelButtonView()
        button.configure(with: ShareChannel(type: .whatsApp)) {
            print("WhatsApp tapped")
        }
        button.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 70)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Disabled") {
    PreviewUIViewController {
        let vc = UIViewController()
        let button = ShareChannelButtonView()
        button.configure(with: ShareChannel(type: .facebook, isAvailable: false)) {
            print("Facebook tapped")
        }
        button.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 70)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("All Channels") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let channels = ShareChannel.allChannels()
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        channels.prefix(5).forEach { channel in
            let button = ShareChannelButtonView()
            button.configure(with: channel) {
                print("\(channel.title) tapped")
            }
            stackView.addArrangedSubview(button)
        }

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 70)
        ])

        return vc
    }
}

#endif
