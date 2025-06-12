import UIKit
import Combine
import SwiftUI

final public class SingleButtonBannerView: UIView, TopBannerViewProtocol {
    // MARK: - Private Properties
    private let backgroundImageView = UIImageView()
    private let messageLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private let contentContainer = UIView()

    private var cancellables = Set<AnyCancellable>()
    private let viewModel: SingleButtonBannerViewModelProtocol

    // MARK: - Public Properties
    public var onButtonTapped: (() -> Void) = { }

    // MARK: - TopBannerProtocol Properties
    public var type: String {
        return "SingleButtonBannerView"
    }

    public var isVisible: Bool = true

    // MARK: - Initialization
    public init(viewModel: SingleButtonBannerViewModelProtocol) {
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
        backgroundColor = StyleProvider.Color.backgroundColor
        clipsToBounds = true

        // Setup background image view
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundImageView)

        // Setup content container
        contentContainer.backgroundColor = UIColor.clear
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentContainer)

        // Setup message label
        messageLabel.font = StyleProvider.fontWith(type: .bold, size: 22)
        messageLabel.textColor = StyleProvider.Color.textPrimary
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(messageLabel)

        // Setup action button
        actionButton.titleLabel?.font = StyleProvider.fontWith(type: .medium, size: 16)
        actionButton.backgroundColor = StyleProvider.Color.buttonBackgroundSecondary
        actionButton.setTitleColor(StyleProvider.Color.buttonTextSecondary, for: .normal)
        actionButton.layer.cornerRadius = 8
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        contentContainer.addSubview(actionButton)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background image view - full width and height
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Content container - with padding
            contentContainer.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),

            // Message label - top left area
            messageLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentContainer.trailingAnchor),

            // Action button - bottom left
            actionButton.topAnchor.constraint(greaterThanOrEqualTo: messageLabel.bottomAnchor, constant: 16),
            actionButton.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            actionButton.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            actionButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
        
        viewModel.displayStatePublisher
            .map(\.bannerData.isVisible)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isVisible in
                self?.isVisible = isVisible
            }
            .store(in: &self.cancellables)
    }

    // MARK: - Rendering
    private func render(state: SingleButtonBannerDisplayState) {
        let bannerData = state.bannerData

        // Update background image
        backgroundImageView.image = bannerData.backgroundImage

        // Update message label
        messageLabel.text = bannerData.messageText

        // Update button
        if let buttonConfig = bannerData.buttonConfig {
            actionButton.isHidden = false
            actionButton.setTitle(buttonConfig.title, for: .normal)
            actionButton.isEnabled = state.isButtonEnabled

            // Apply custom styling if provided
            if let backgroundColor = buttonConfig.backgroundColor {
                actionButton.backgroundColor = backgroundColor
            }
            if let textColor = buttonConfig.textColor {
                actionButton.setTitleColor(textColor, for: .normal)
            }
            if let cornerRadius = buttonConfig.cornerRadius {
                actionButton.layer.cornerRadius = cornerRadius
            }
        } else {
            actionButton.isHidden = true
        }

        // Update banner visibility
        isHidden = !bannerData.isVisible
    }

    // MARK: - Actions
    @objc private func buttonTapped() {
        viewModel.buttonTapped()
        onButtonTapped()
    }

    // MARK: - Public Methods
    public func updateButtonEnabled(_ enabled: Bool) {
        actionButton.isEnabled = enabled
    }

    // MARK: - TopBannerViewProtocol Methods
    public func bannerDidBecomeVisible() {
        // Called when banner becomes visible in slider
        // Can be used for analytics, animations, etc.
    }

    public func bannerDidBecomeHidden() {
        // Called when banner is no longer visible in slider
        // Can be used for cleanup, pausing animations, etc.
    }
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Default Banner") {
    PreviewUIView {
        SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.defaultMock)
    }
    .frame(height: 200)
}

@available(iOS 17.0, *)
#Preview("Banner without Button") {
    PreviewUIView {
        SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.noButtonMock)
    }
    .frame(height: 200)
}

@available(iOS 17.0, *)
#Preview("Custom Styled Banner") {
    PreviewUIView {
        SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.customStyledMock)
    }
    .frame(height: 200)
}

#endif
