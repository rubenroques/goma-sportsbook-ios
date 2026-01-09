import UIKit
import Combine
import SwiftUI
import Kingfisher

final public class SingleButtonBannerView: UIView, TopBannerViewProtocol {
    // MARK: - Private Properties
    private let backgroundImageView = UIImageView()
    private let opacityLayer = UIView()
    private let messageLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private let contentContainer = UIView()

    private var cancellables = Set<AnyCancellable>()
    private var viewModel: any SingleButtonBannerViewModelProtocol

    // MARK: - Public Properties
    public var onButtonTapped: (() -> Void) = { }

    // MARK: - TopBannerProtocol Properties
    public var type: String {
        return "SingleButtonBannerView"
    }

    public var isVisible: Bool = true

    // MARK: - Initialization
    public init(viewModel: any SingleButtonBannerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
    
        self.configure(with: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupSubviews() {
        backgroundColor = StyleProvider.Color.backgroundPrimary
        clipsToBounds = true

        // Setup background image view
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundImageView)

        // Setup opacity layer
        opacityLayer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        opacityLayer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(opacityLayer)

        // Setup content container
        contentContainer.backgroundColor = UIColor.clear
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentContainer)

        // Setup message label
        messageLabel.font = StyleProvider.fontWith(type: .bold, size: 22)
        messageLabel.textColor = .white // StyleProvider.Color.textPrimary
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

            // Opacity layer - matches background image view
            opacityLayer.topAnchor.constraint(equalTo: backgroundImageView.topAnchor),
            opacityLayer.leadingAnchor.constraint(equalTo: backgroundImageView.leadingAnchor),
            opacityLayer.trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor),
            opacityLayer.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor),

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
            .dropFirst() // Skip initial emission since configure() already renders synchronously
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                print("[BANNER_DEBUG] 🟠 View.binding - displayState received")
                self?.render(state: displayState)
            }
            .store(in: &cancellables)

        // Removed redundant subscription - render() already handles visibility via isHidden
    }

    // MARK: - Rendering
    private func render(state: SingleButtonBannerDisplayState) {
        let bannerData = state.bannerData

        // Update background image
        if let imageURLString = bannerData.backgroundImageURL,
           let imageURL = URL(string: imageURLString) {
            backgroundImageView.kf.setImage(with: imageURL)
        } else {
            backgroundImageView.image = nil
        }

        // Update message label
        messageLabel.text = bannerData.messageText

        // Update button
        if let buttonConfig = bannerData.buttonConfig {
            actionButton.isHidden = false
            let currentTitle = actionButton.title(for: .normal) ?? ""
            print("[BANNER_DEBUG] 🔴 View.setButtonTitle - from '\(currentTitle)' to '\(buttonConfig.title)'")
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
    public func configure(with viewModel: any SingleButtonBannerViewModelProtocol) {
        print("[BANNER_DEBUG] 🔵 View.configure - start")

        // Add simplified call stack trace to find caller
        let caller = Thread.callStackSymbols.count > 1 ? Thread.callStackSymbols[1] : "unknown"
        print("[BANNER_DEBUG] 📍 Called from: \(caller)")

        // Clear existing subscriptions
        cancellables.removeAll()

        // Update the view model reference
        self.viewModel = viewModel

        // Get current state and render immediately (synchronous)
        render(state: viewModel.currentDisplayState)

        // Setup new bindings for future updates
        setupBindings()
    }

    public func clearContent() {
        // Log current state before clearing
        let currentTitle = actionButton.title(for: .normal) ?? "nil"
        print("[BANNER_DEBUG] 🧹 View.clearContent - clearing button from '\(currentTitle)'")

        // Clear existing subscriptions
        cancellables.removeAll()

        // Hide the entire view
        isHidden = true

        // Clear content
        backgroundImageView.image = nil
        messageLabel.text = ""
        actionButton.setTitle("", for: .normal)
        actionButton.isHidden = true

        // Clear callbacks
        onButtonTapped = { }
    }

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

#Preview("SingleButtonBannerView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "SingleButtonBannerView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Default Banner
        let defaultBanner = SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.defaultMock)
        defaultBanner.translatesAutoresizingMaskIntoConstraints = false

        // Banner without Button
        let noButtonBanner = SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.noButtonMock)
        noButtonBanner.translatesAutoresizingMaskIntoConstraints = false

        // Custom Styled Banner
        let customBanner = SingleButtonBannerView(viewModel: MockSingleButtonBannerViewModel.customStyledMock)
        customBanner.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(defaultBanner)
        stackView.addArrangedSubview(noButtonBanner)
        stackView.addArrangedSubview(customBanner)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),

            // Fixed heights for banners
            defaultBanner.heightAnchor.constraint(equalToConstant: 200),
            noButtonBanner.heightAnchor.constraint(equalToConstant: 200),
            customBanner.heightAnchor.constraint(equalToConstant: 200)
        ])

        return vc
    }
}

#endif
