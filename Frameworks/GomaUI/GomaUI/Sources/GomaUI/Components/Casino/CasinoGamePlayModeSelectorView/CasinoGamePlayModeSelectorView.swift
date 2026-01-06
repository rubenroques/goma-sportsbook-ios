import UIKit
import Combine
import SwiftUI

/// A reusable component for displaying casino game details with configurable play mode buttons
final public class CasinoGamePlayModeSelectorView: UIView {
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let gameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = StyleProvider.Color.backgroundPrimary
        return imageView
    }()
    
    private let gameTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let gameDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Hidden Components (temporarily disabled)
    // The detailsContainerView, volatility, and minStake components are hidden per product decision

//    private let detailsContainerView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .clear // StyleProvider.Color.backgroundSecondary
//        view.layer.cornerRadius = 8
//        return view
//    }()
//
//    private let volatilityLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = StyleProvider.fontWith(type: .medium, size: 12)
//        label.textColor = .white // StyleProvider.Color.textPrimary
//        label.text = LocalizationProvider.string("volatility") + ":"
//        return label
//    }()
//
//    private let volatilityCapsuleView: UIView = {
//        let view = UIView()
//        view.backgroundColor = StyleProvider.Color.backgroundPrimary
//        view.layer.cornerRadius = 12 // Same as CasinoGameCardView ratingCapsuleCornerRadius
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    private let volatilityStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.spacing = 2.0 // Same spacing as CasinoGameCardView thunderbolts
//        stackView.alignment = .center
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
//
//    private let minStakeLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = StyleProvider.fontWith(type: .medium, size: 12)
//        label.textColor = .white // StyleProvider.Color.textPrimary
//        label.text = LocalizationProvider.string("min_stake") + ":"
//        return label
//    }()
//
//    private let minStakeValueLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = StyleProvider.fontWith(type: .semibold, size: 12)
//        label.textColor = .white //StyleProvider.Color.textSecondary
//        return label
//    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let loadingIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = StyleProvider.Color.textPrimary
        return indicator
    }()
    
    // MARK: - Properties
    
    private let viewModel: CasinoGamePlayModeSelectorViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentButtons: [UIButton] = []
    
    // Volatility thunderbolt views (created dynamically like CasinoGameCardView)
    // Hidden per product decision
    // private var volatilityThunderboltImageViews: [UIImageView] = []
    
    // MARK: - Public Callbacks
    
    /// Callback fired when a button is tapped
    public var onButtonTapped: ((String) -> Void) = { _ in }
    
    /// Callback fired when refresh is requested
    public var onRefreshRequested: (() -> Void) = { }
    
    // MARK: - Initialization
    
    public init(viewModel: CasinoGamePlayModeSelectorViewModelProtocol) {
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
        backgroundColor = .clear
        
        // Add scroll view
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add main components to content view
        contentView.addSubview(gameImageView)
        contentView.addSubview(gameTitleLabel)
        contentView.addSubview(gameDescriptionLabel)
        // contentView.addSubview(detailsContainerView) // Hidden per product decision
        contentView.addSubview(buttonsStackView)
        contentView.addSubview(loadingIndicatorView)

        // Hidden per product decision
        // Add details to container
        // detailsContainerView.addSubview(volatilityLabel)
        // detailsContainerView.addSubview(volatilityCapsuleView)
        // detailsContainerView.addSubview(minStakeLabel)
        // detailsContainerView.addSubview(minStakeValueLabel)

        // Setup volatility capsule content (simple approach like CasinoGameCardView)
        // volatilityCapsuleView.addSubview(volatilityStackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view fills the view
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Content view setup
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Game image
            gameImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            gameImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            gameImageView.widthAnchor.constraint(equalToConstant: 200),
            gameImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Game title
            gameTitleLabel.topAnchor.constraint(equalTo: gameImageView.bottomAnchor, constant: 24),
            gameTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            gameTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Game description
            gameDescriptionLabel.topAnchor.constraint(equalTo: gameTitleLabel.bottomAnchor, constant: 12),
            gameDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            gameDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            // Hidden per product decision: Details container with volatility and min stake
//            // Details container
//            detailsContainerView.topAnchor.constraint(equalTo: gameDescriptionLabel.bottomAnchor, constant: 24),
//            detailsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
//            detailsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
//            detailsContainerView.heightAnchor.constraint(equalToConstant: 60),
//
//            // Volatility labels
//            volatilityLabel.leadingAnchor.constraint(equalTo: detailsContainerView.leadingAnchor, constant: 16),
//            volatilityLabel.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: 12),
//
//            volatilityCapsuleView.leadingAnchor.constraint(equalTo: volatilityLabel.trailingAnchor, constant: 8),
//            volatilityCapsuleView.centerYAnchor.constraint(equalTo: volatilityLabel.centerYAnchor),
//            volatilityCapsuleView.heightAnchor.constraint(equalToConstant: 15.0 + 2 * 5.0), // thunderbolt size + vertical padding
//
//            // Volatility stack view inside capsule (same pattern as CasinoGameCardView)
//            volatilityStackView.centerXAnchor.constraint(equalTo: volatilityCapsuleView.centerXAnchor),
//            volatilityStackView.centerYAnchor.constraint(equalTo: volatilityCapsuleView.centerYAnchor),
//            volatilityStackView.leadingAnchor.constraint(greaterThanOrEqualTo: volatilityCapsuleView.leadingAnchor, constant: 7.0), // horizontal padding
//            volatilityStackView.trailingAnchor.constraint(lessThanOrEqualTo: volatilityCapsuleView.trailingAnchor, constant: -7.0),
//
//            // Min stake labels
//            minStakeLabel.trailingAnchor.constraint(equalTo: minStakeValueLabel.leadingAnchor, constant: -4),
//            minStakeLabel.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: 12),
//
//            minStakeValueLabel.trailingAnchor.constraint(equalTo: detailsContainerView.trailingAnchor, constant: -16),
//            minStakeValueLabel.centerYAnchor.constraint(equalTo: minStakeLabel.centerYAnchor),

            // Buttons stack view (now connects to gameDescriptionLabel since detailsContainer is hidden)
            buttonsStackView.topAnchor.constraint(equalTo: gameDescriptionLabel.bottomAnchor, constant: 32),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // Loading indicator
            loadingIndicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    
    private func render(state: CasinoGamePlayModeSelectorDisplayState) {
        // Show/hide loading indicator
        if state.isLoading {
            loadingIndicatorView.startAnimating()
            contentView.alpha = 0.5
        } else {
            loadingIndicatorView.stopAnimating()
            contentView.alpha = 1.0
        }
        
        // Update game data
        updateGameData(state.gameData)
        
        // Update buttons
        updateButtons(state.buttons)
    }
    
    private func updateGameData(_ gameData: CasinoGamePlayModeSelectorGameData) {
        gameTitleLabel.text = gameData.name
        gameDescriptionLabel.text = gameData.description
        // Hidden per product decision
        // updateVolatilityCapsule(gameData.volatility)
        // minStakeValueLabel.text = gameData.minStake
        
        // Load game thumbnail image if available
        if let thumbnailURLString = gameData.thumbnailURL, let thumbnailURL = URL(string: thumbnailURLString) {
            loadImage(from: thumbnailURL)
        } else {
            gameImageView.image = UIImage(systemName: "photo")
        }
        
        // Show/hide description based on content
        gameDescriptionLabel.isHidden = gameData.description?.isEmpty ?? true
    }
    
    private func updateButtons(_ buttons: [CasinoGamePlayModeButton]) {
        // Remove existing buttons
        currentButtons.forEach { $0.removeFromSuperview() }
        currentButtons.removeAll()
        
        // Add new buttons
        for button in buttons {
            let uiButton = createButton(from: button)
            buttonsStackView.addArrangedSubview(uiButton)
            currentButtons.append(uiButton)
        }
    }
    
    // MARK: - Volatility Capsule (Hidden per product decision)

//    private func updateVolatilityCapsule(_ volatility: String?) {
//        // Clear existing thunderbolts
//        volatilityThunderboltImageViews.forEach { $0.removeFromSuperview() }
//        volatilityThunderboltImageViews.removeAll()
//
//        // Map volatility to thunderbolt count
//        let thunderboltCount = mapVolatilityToThunderboltCount(volatility)
//
//        // Create thunderbolt views (similar to CasinoGameCardView)
//        for i in 0..<5 {
//            let thunderboltImageView = UIImageView()
//            thunderboltImageView.contentMode = .scaleAspectFit
//            thunderboltImageView.translatesAutoresizingMaskIntoConstraints = false
//
//            NSLayoutConstraint.activate([
//                thunderboltImageView.widthAnchor.constraint(equalToConstant: 15.0), // Same size as CasinoGameCardView
//                thunderboltImageView.heightAnchor.constraint(equalToConstant: 15.0)
//            ])
//
//            // Determine thunderbolt state
//            let isActive = i < thunderboltCount
//            let imageName = isActive ? "thunderbolt_active" : "thunderbolt_inactive"
//            thunderboltImageView.image = UIImage(named: imageName, in: Bundle.module, with: nil)
//
//            volatilityStackView.addArrangedSubview(thunderboltImageView)
//            volatilityThunderboltImageViews.append(thunderboltImageView)
//        }
//    }
//
//    private func mapVolatilityToThunderboltCount(_ volatility: String?) -> Int {
//        guard let volatility = volatility?.lowercased() else { return 0 }
//
//        switch volatility {
//        case "low":
//            return 2
//        case "medium":
//            return 3
//        case "high":
//            return 4
//        default:
//            return 0 // N/A or unknown values show no thunderbolts
//        }
//    }
    
    private func createButton(from buttonData: CasinoGamePlayModeButton) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = StyleProvider.fontWith(type: .medium, size: 16)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Configure title
        button.setTitle(buttonData.title, for: .normal)
        
        // Configure style
        configureButtonStyle(button, style: buttonData.style, type: buttonData.type)
        
        // Configure state
        configureButtonState(button, state: buttonData.state)
        
        // Add action
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.accessibilityIdentifier = buttonData.id
        
        return button
    }
    
    private func configureButtonStyle(_ button: UIButton, style: CasinoGamePlayModeButton.ButtonStyle, type: CasinoGamePlayModeButton.ButtonType) {
        switch (style, type) {
        case (.filled, .primary):
            button.backgroundColor = StyleProvider.Color.highlightPrimary
            button.setTitleColor(StyleProvider.Color.buttonTextPrimary, for: .normal)
            button.layer.borderWidth = 0
            
        case (.filled, .secondary), (.filled, .tertiary):
            button.backgroundColor = StyleProvider.Color.highlightSecondary
            button.setTitleColor(StyleProvider.Color.textPrimary, for: .normal)
            button.layer.borderWidth = 0
            
        case (.outlined, _):
            button.backgroundColor = UIColor.clear
            button.setTitleColor(StyleProvider.Color.allWhite, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = StyleProvider.Color.allWhite.cgColor
            
        case (.text, _):
            button.backgroundColor = UIColor.clear
            button.setTitleColor(StyleProvider.Color.highlightPrimary, for: .normal)
            button.layer.borderWidth = 0
        }
    }
    
    private func configureButtonState(_ button: UIButton, state: CasinoGamePlayModeButton.ButtonState) {
        switch state {
        case .enabled:
            button.isEnabled = true
            button.alpha = 1.0
            
        case .disabled:
            button.isEnabled = false
            button.alpha = 0.6
            
        case .loading:
            button.isEnabled = false
            // Add loading indicator to button if needed
        }
    }
    
    private func loadImage(from url: URL) {
        // Simple image loading - in production you'd use a proper image loading library
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.gameImageView.image = image
            }
        }.resume()
    }
    
    // MARK: - Actions
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let buttonId = sender.accessibilityIdentifier else { return }
        viewModel.buttonTapped(buttonId: buttonId)
        onButtonTapped(buttonId)
    }
    
    // MARK: - Public Methods
    
    /// Manually configure the view with a new ViewModel (useful for cell reuse)
    public func configure(with viewModel: CasinoGamePlayModeSelectorViewModelProtocol?) {
        // Clear existing bindings
        cancellables.removeAll()
        
        guard let viewModel = viewModel else { return }
        
        // Setup new bindings
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(state: displayState)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Preview Provider

#if DEBUG

#Preview("Default State") {
    PreviewUIView {
        CasinoGamePlayModeSelectorView(viewModel: MockCasinoGamePlayModeSelectorViewModel.defaultMock)
    }
    .frame(height: 600)
}

#Preview("Loading State") {
    PreviewUIView {
        CasinoGamePlayModeSelectorView(viewModel: MockCasinoGamePlayModeSelectorViewModel.loadingMock)
    }
    .frame(height: 600)
}

#Preview("Logged In User") {
    PreviewUIView {
        CasinoGamePlayModeSelectorView(viewModel: MockCasinoGamePlayModeSelectorViewModel.loggedInMock)
    }
    .frame(height: 600)
}

#endif
