import UIKit
import Combine
import SwiftUI

final public class CasinoGameCardView: UIView {
    
    // MARK: - Constants
    private enum Constants {
        static let cardWidth: CGFloat = 164.0
        static let cardHeight: CGFloat = 272.0
        static let cornerRadius: CGFloat = 8.0
        
        // Image
        static let imageHeight: CGFloat = 164.0
        
        // Content padding
        static let contentPadding: CGFloat = 11.0
        static let titleToRatingSpacing: CGFloat = 4.0
        
        // Rating capsule (based on Figma specs)
        static let ratingCapsuleCornerRadius: CGFloat = 12.0
        static let ratingCapsuleHorizontalPadding: CGFloat = 7.0
        static let ratingCapsuleVerticalPadding: CGFloat = 5.0
        static let thunderboltSize: CGFloat = 15.0
        static let thunderboltSpacing: CGFloat = 2.0
    }
    
    // MARK: - UI Elements
    private let containerView = UIView()
    private let imageContainerView = UIView()
    private let gameImageView = UIImageView()
    private let imageLoadingIndicator = UIActivityIndicatorView(style: .medium)
    private let imageFailureView = UIView()
    private let imageFailureLabel = UILabel()
    
    private let contentStackView = UIStackView()
    private let gameTitleLabel = UILabel()
    private let providerLabel = UILabel()
    private let minStakeLabel = UILabel()
    private let ratingCapsuleView = UIView()
    private let starsStackView = UIStackView()
    
    // Thunderbolt views (created dynamically)
    private var thunderboltImageViews: [UIImageView] = []
    
    // MARK: - Properties
    private var viewModel: CasinoGameCardViewModelProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Callbacks
    public var onGameSelected: ((String) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: CasinoGameCardViewModelProtocol? = nil) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        configure(with: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Configuration
    public func configure(with viewModel: CasinoGameCardViewModelProtocol?) {
        // Clear existing bindings
        cancellables.removeAll()
        self.viewModel = viewModel
        
        if let viewModel = viewModel {
            setupBindings(with: viewModel)
        } else {
            renderPlaceholderState()
        }
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Container setup
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = StyleProvider.Color.backgroundTertiary
        containerView.layer.cornerRadius = Constants.cornerRadius
        containerView.layer.shadowColor = StyleProvider.Color.shadow.cgColor
        containerView.clipsToBounds = true
        
        addSubview(containerView)
        
        setupImageSection()
        setupContentSection()
        setupConstraints()
        setupGestures()
    }
    
    private func setupImageSection() {
        // Image container
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageContainerView)
        
        // Game image
        gameImageView.translatesAutoresizingMaskIntoConstraints = false
        gameImageView.contentMode = .scaleAspectFill
        gameImageView.clipsToBounds = true
        gameImageView.backgroundColor = StyleProvider.Color.backgroundCards
        imageContainerView.addSubview(gameImageView)
        
        // Loading indicator
        imageLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        imageLoadingIndicator.hidesWhenStopped = true
        imageContainerView.addSubview(imageLoadingIndicator)
        
        // Failure view
        imageFailureView.translatesAutoresizingMaskIntoConstraints = false
        imageFailureView.backgroundColor = StyleProvider.Color.backgroundCards
        imageFailureView.isHidden = true
        imageContainerView.addSubview(imageFailureView)
        
        imageFailureLabel.text = "?"
        imageFailureLabel.font = StyleProvider.fontWith(type: .bold, size: 24)
        imageFailureLabel.textColor = StyleProvider.Color.textDisablePrimary
        imageFailureLabel.textAlignment = .center
        imageFailureLabel.translatesAutoresizingMaskIntoConstraints = false
        imageFailureView.addSubview(imageFailureLabel)
    }
    
    private func setupContentSection() {
        // Content stack view
        contentStackView.axis = .vertical
        contentStackView.spacing = Constants.titleToRatingSpacing
        contentStackView.alignment = .leading
        contentStackView.distribution = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(contentStackView)
        
        // Game title
        gameTitleLabel.font = StyleProvider.fontWith(type: .bold, size: 14)
        gameTitleLabel.textColor = StyleProvider.Color.textPrimary
        gameTitleLabel.numberOfLines = 2
        gameTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(gameTitleLabel)
        
        // Provider label
        providerLabel.font = StyleProvider.fontWith(type: .semibold, size: 12)
        providerLabel.textColor = StyleProvider.Color.textSecondary
        providerLabel.numberOfLines = 1
        providerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(providerLabel)
        
        // Min stake label
        minStakeLabel.font = StyleProvider.fontWith(type: .semibold, size: 12)
        minStakeLabel.textColor = StyleProvider.Color.textSecondary
        minStakeLabel.numberOfLines = 1
        minStakeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(minStakeLabel)
        
        // Rating capsule setup
        ratingCapsuleView.backgroundColor = StyleProvider.Color.backgroundPrimary
        ratingCapsuleView.layer.cornerRadius = Constants.ratingCapsuleCornerRadius
        ratingCapsuleView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(ratingCapsuleView)
        
        // Thunderbolts container (inside capsule)
        starsStackView.axis = .horizontal
        starsStackView.spacing = Constants.thunderboltSpacing
        starsStackView.alignment = .center
        starsStackView.translatesAutoresizingMaskIntoConstraints = false
        ratingCapsuleView.addSubview(starsStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Fixed card size
            widthAnchor.constraint(equalToConstant: Constants.cardWidth),
            heightAnchor.constraint(equalToConstant: Constants.cardHeight),
            
            // Image container
            imageContainerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageContainerView.heightAnchor.constraint(equalToConstant: Constants.imageHeight),
            
            // Game image
            gameImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            gameImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            gameImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            gameImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            
            // Loading indicator
            imageLoadingIndicator.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            imageLoadingIndicator.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            
            // Image failure view
            imageFailureView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            imageFailureView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            imageFailureView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            imageFailureView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            
            imageFailureLabel.centerXAnchor.constraint(equalTo: imageFailureView.centerXAnchor),
            imageFailureLabel.centerYAnchor.constraint(equalTo: imageFailureView.centerYAnchor),
            
            // Content stack view
            contentStackView.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: Constants.contentPadding),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.contentPadding),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.contentPadding),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -Constants.contentPadding),
            
            // Rating capsule constraints
            ratingCapsuleView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            ratingCapsuleView.heightAnchor.constraint(equalToConstant: Constants.thunderboltSize + 2 * Constants.ratingCapsuleVerticalPadding),
            
            // Thunderbolts stack inside capsule
            starsStackView.centerXAnchor.constraint(equalTo: ratingCapsuleView.centerXAnchor),
            starsStackView.centerYAnchor.constraint(equalTo: ratingCapsuleView.centerYAnchor),
            starsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: ratingCapsuleView.leadingAnchor, constant: Constants.ratingCapsuleHorizontalPadding),
            starsStackView.trailingAnchor.constraint(lessThanOrEqualTo: ratingCapsuleView.trailingAnchor, constant: -Constants.ratingCapsuleHorizontalPadding)
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Bindings
    private func setupBindings(with viewModel: CasinoGameCardViewModelProtocol) {
        // Main display state
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(displayState: displayState)
            }
            .store(in: &cancellables)
        
        // Game name
        viewModel.gameNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.gameTitleLabel.text = name
            }
            .store(in: &cancellables)
        
        // Provider name
        viewModel.providerNamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] provider in
                self?.providerLabel.text = provider
                self?.providerLabel.isHidden = provider == nil || provider?.isEmpty == true
            }
            .store(in: &cancellables)
        
        // Min stake
        viewModel.minStakePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] minStake in
                self?.minStakeLabel.text = LocalizationProvider.string("min_stake") + ":" + minStake
            }
            .store(in: &cancellables)
        
        // Rating
        viewModel.ratingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rating in
                self?.updateStarRating(rating)
            }
            .store(in: &cancellables)
        
        // Icon URL
        viewModel.iconURLPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] iconURL in
                self?.loadGameImage(from: iconURL)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    private func render(displayState: CasinoGameCardDisplayState) {
        if displayState.isLoading {
            showImageLoadingState()
        } else if displayState.imageLoadingFailed {
            showImageFailureState()
        } else {
            showNormalState()
        }
    }
    
    private func renderPlaceholderState() {
        gameTitleLabel.text = LocalizationProvider.string("loading")
        providerLabel.text = LocalizationProvider.string("provider")
        minStakeLabel.text = LocalizationProvider.string("min_stake")
        gameImageView.image = nil
        updateStarRating(0.0)
        showImageFailureState() // Show placeholder state with "?"
    }
    
    private func showImageLoadingState() {
        imageLoadingIndicator.startAnimating()
        gameImageView.isHidden = true
        imageFailureView.isHidden = true
    }
    
    private func showImageFailureState() {
        imageLoadingIndicator.stopAnimating()
        gameImageView.isHidden = true
        imageFailureView.isHidden = false
    }
    
    private func showNormalState() {
        imageLoadingIndicator.stopAnimating()
        gameImageView.isHidden = false
        imageFailureView.isHidden = true
    }
    
    // MARK: - Thunderbolt Rating
    private func updateStarRating(_ rating: Double) {
        // Clear existing thunderbolts
        thunderboltImageViews.forEach { $0.removeFromSuperview() }
        thunderboltImageViews.removeAll()
        
        // Round rating to nearest integer (no half-thunderbolts)
        let activeCount = Int(round(rating))
        
        // Create 5 thunderbolt views
        for i in 0..<5 {
            let thunderboltImageView = UIImageView()
            thunderboltImageView.contentMode = .scaleAspectFit
            thunderboltImageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                thunderboltImageView.widthAnchor.constraint(equalToConstant: Constants.thunderboltSize),
                thunderboltImageView.heightAnchor.constraint(equalToConstant: Constants.thunderboltSize)
            ])
            
            // Determine thunderbolt state based on rounded rating
            let isActive = i < activeCount
            let imageName = isActive ? "thunderbolt_active" : "thunderbolt_inactive"
            thunderboltImageView.image = UIImage(named: imageName, in: Bundle.module, with: nil)
            
            starsStackView.addArrangedSubview(thunderboltImageView)
            thunderboltImageViews.append(thunderboltImageView)
        }
    }
    
    // MARK: - Image Loading
    private func loadGameImage(from imageSource: String?) {
        guard let imageSource = imageSource else {
            showImageFailureState()
            return
        }
        
        // Check if it's a bundle image name or URL
        if let bundleImage = UIImage(named: imageSource, in: Bundle.module, with: nil) {
            // It's a bundle image
            gameImageView.image = bundleImage
            showNormalState()
            viewModel?.imageLoadingSucceeded()
        } else if let url = URL(string: imageSource) {
            // It's a URL - load from network
            showImageLoadingState()
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        self?.gameImageView.image = image
                        self?.showNormalState()
                        self?.viewModel?.imageLoadingSucceeded()
                    } else {
                        self?.showImageFailureState()
                        self?.viewModel?.imageLoadingFailed()
                    }
                }
            }.resume()
        } else {
            // Invalid image source
            showImageFailureState()
            viewModel?.imageLoadingFailed()
        }
    }
    
    // MARK: - Actions
    @objc private func cardTapped() {
        guard let viewModel = viewModel else { return }
        onGameSelected(viewModel.gameId)
    }
}

// MARK: - Preview Provider
#if DEBUG

#Preview("Casino Game Card - Placeholder") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor
        
        let gameCardView = CasinoGameCardView() // No viewModel - placeholder state
        gameCardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(gameCardView)
        
        NSLayoutConstraint.activate([
            gameCardView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            gameCardView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
}

#endif
