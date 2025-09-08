import UIKit
import Combine

final public class RecentlyPlayedGamesCellView: UIView {
    
    // MARK: - Constants
    private enum Constants {
        static let cellWidth: CGFloat = 210.0
        static let cellHeight: CGFloat = 56.0
        static let imageSize: CGFloat = 56.0
        static let cornerRadius: CGFloat = 12.0
        static let imageCornerRadius: CGFloat = 8.0
        static let contentPadding: CGFloat = 12.0
        static let contentSpacing: CGFloat = 2.0
    }
    
    // MARK: - UI Elements
    private let containerView = UIView()
    private let gameImageView = UIImageView()
    private let imageLoadingIndicator = UIActivityIndicatorView(style: .medium)
    private let imageFailureView = UIView()
    private let imageFailureLabel = UILabel()
    
    private let contentStackView = UIStackView()
    private let gameTitleLabel = UILabel()
    private let providerLabel = UILabel()
    
    // MARK: - Properties
    private var gameData: RecentlyPlayedGameData?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Callbacks
    public var onGameSelected: ((String) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init() {
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Configuration
    public func configure(with gameData: RecentlyPlayedGameData?) {
        self.gameData = gameData
        
        if let gameData = gameData {
            gameTitleLabel.text = gameData.name
            providerLabel.text = gameData.provider
            providerLabel.isHidden = gameData.provider == nil || gameData.provider?.isEmpty == true
            loadGameImage(from: gameData.imageURL)
        } else {
            renderPlaceholderState()
        }
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Container setup
        containerView.backgroundColor = StyleProvider.Color.backgroundGradient2
        containerView.layer.cornerRadius = Constants.cornerRadius
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        setupImageSection()
        setupContentSection()
        setupConstraints()
        setupGestures()
    }
    
    private func setupImageSection() {
        // Game image
        gameImageView.contentMode = .scaleAspectFill
        gameImageView.clipsToBounds = true
        gameImageView.backgroundColor = StyleProvider.Color.backgroundGradient2
        gameImageView.layer.cornerRadius = Constants.imageCornerRadius
        gameImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner] // Left corners only
        gameImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(gameImageView)
        
        // Loading indicator
        imageLoadingIndicator.hidesWhenStopped = true
        imageLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageLoadingIndicator)
        
        // Failure view
        imageFailureView.backgroundColor = StyleProvider.Color.backgroundPrimary
        imageFailureView.layer.cornerRadius = Constants.imageCornerRadius
        imageFailureView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        imageFailureView.isHidden = true
        imageFailureView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageFailureView)
        
        imageFailureLabel.text = "?"
        imageFailureLabel.font = StyleProvider.fontWith(type: .bold, size: 20)
        imageFailureLabel.textColor = StyleProvider.Color.textSecondary
        imageFailureLabel.textAlignment = .center
        imageFailureLabel.translatesAutoresizingMaskIntoConstraints = false
        imageFailureView.addSubview(imageFailureLabel)
    }
    
    private func setupContentSection() {
        // Content stack view
        contentStackView.axis = .vertical
        contentStackView.spacing = Constants.contentSpacing
        contentStackView.alignment = .leading
        contentStackView.distribution = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(contentStackView)
        
        // Game title
        gameTitleLabel.font = StyleProvider.fontWith(type: .bold, size: 12)
        gameTitleLabel.textColor = StyleProvider.Color.textPrimary
        gameTitleLabel.numberOfLines = 1
        gameTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(gameTitleLabel)
        
        // Provider label
        providerLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        providerLabel.textColor = StyleProvider.Color.textSecondary
        providerLabel.numberOfLines = 1
        providerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(providerLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Fixed cell size
            widthAnchor.constraint(equalToConstant: Constants.cellWidth),
            heightAnchor.constraint(equalToConstant: Constants.cellHeight),
            
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Game image
            gameImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            gameImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            gameImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            gameImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            
            // Loading indicator
            imageLoadingIndicator.centerXAnchor.constraint(equalTo: gameImageView.centerXAnchor),
            imageLoadingIndicator.centerYAnchor.constraint(equalTo: gameImageView.centerYAnchor),
            
            // Image failure view
            imageFailureView.topAnchor.constraint(equalTo: gameImageView.topAnchor),
            imageFailureView.leadingAnchor.constraint(equalTo: gameImageView.leadingAnchor),
            imageFailureView.trailingAnchor.constraint(equalTo: gameImageView.trailingAnchor),
            imageFailureView.bottomAnchor.constraint(equalTo: gameImageView.bottomAnchor),
            
            imageFailureLabel.centerXAnchor.constraint(equalTo: imageFailureView.centerXAnchor),
            imageFailureLabel.centerYAnchor.constraint(equalTo: imageFailureView.centerYAnchor),
            
            // Content stack view
            contentStackView.leadingAnchor.constraint(equalTo: gameImageView.trailingAnchor, constant: Constants.contentPadding),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.contentPadding),
            contentStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tapGesture)
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
        } else if let url = URL(string: imageSource) {
            // It's a URL - load from network
            showImageLoadingState()
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        self?.gameImageView.image = image
                        self?.showNormalState()
                    } else {
                        self?.showImageFailureState()
                    }
                }
            }.resume()
        } else {
            // Invalid image source
            showImageFailureState()
        }
    }
    
    // MARK: - Image States
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
    
    // MARK: - Rendering
    private func renderPlaceholderState() {
        gameTitleLabel.text = "Game Title"
        providerLabel.text = "Provider"
        gameImageView.image = nil
        showImageFailureState()
    }
    
    // MARK: - Actions
    @objc private func cellTapped() {
        guard let gameData = gameData else { return }
        onGameSelected(gameData.id)
    }
}
