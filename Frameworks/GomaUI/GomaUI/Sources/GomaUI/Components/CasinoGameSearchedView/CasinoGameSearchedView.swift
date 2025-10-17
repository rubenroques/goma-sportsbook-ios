import UIKit
import Combine

final public class CasinoGameSearchedView: UIView {
    
    // MARK: - Constants
    private enum Constants {
        static let height: CGFloat = 56.0
        static let imageSize: CGFloat = 56.0
        static let cornerRadius: CGFloat = 16.0
        static let imageCornerRadius: CGFloat = 12.0
        static let padding: CGFloat = 16.0
        static let spacing: CGFloat = 4.0
    }
    
    // MARK: - UI Elements
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var gameImageView: UIImageView = Self.createGameImageView()
    private lazy var imageLoadingIndicator: UIActivityIndicatorView = Self.createImageLoadingIndicator()
    private lazy var imageFailureView: UIView = Self.createImageFailureView()
    private lazy var imageFailureLabel: UILabel = Self.createImageFailureLabel()
    
    private lazy var contentStackView: UIStackView = Self.createContentStackView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var providerLabel: UILabel = Self.createProviderLabel()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: CasinoGameSearchedViewModelProtocol?
    
    // MARK: - Callbacks
    public var onGameSelected: (() -> Void)?
    
    // MARK: - Init
    public init(viewModel: CasinoGameSearchedViewModelProtocol? = nil) {
        super.init(frame: .zero)
        setupSubviews()
        configure(with: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public API
    public func configure(with viewModel: CasinoGameSearchedViewModelProtocol?) {
        self.cancellables.removeAll()
        self.viewModel = viewModel
        
        if let viewModel = viewModel {
            bind(to: viewModel)
        } else {
            renderPlaceholderState()
        }
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.gameImageView)
        self.containerView.addSubview(self.imageLoadingIndicator)
        self.containerView.addSubview(self.imageFailureView)
        self.imageFailureView.addSubview(self.imageFailureLabel)
        
        self.containerView.addSubview(self.contentStackView)
        self.contentStackView.addArrangedSubview(self.titleLabel)
        self.contentStackView.addArrangedSubview(self.providerLabel)
        
        self.containerView.addSubview(self.iconImageView)
        
        self.initConstraints()
        self.setupGestures()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: Constants.height),
            
            gameImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            gameImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            gameImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            gameImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            
            imageLoadingIndicator.centerXAnchor.constraint(equalTo: gameImageView.centerXAnchor),
            imageLoadingIndicator.centerYAnchor.constraint(equalTo: gameImageView.centerYAnchor),
            
            imageFailureView.leadingAnchor.constraint(equalTo: gameImageView.leadingAnchor),
            imageFailureView.trailingAnchor.constraint(equalTo: gameImageView.trailingAnchor),
            imageFailureView.topAnchor.constraint(equalTo: gameImageView.topAnchor),
            imageFailureView.bottomAnchor.constraint(equalTo: gameImageView.bottomAnchor),
            
            imageFailureLabel.centerXAnchor.constraint(equalTo: imageFailureView.centerXAnchor),
            imageFailureLabel.centerYAnchor.constraint(equalTo: imageFailureView.centerYAnchor),
            
            contentStackView.leadingAnchor.constraint(equalTo: gameImageView.trailingAnchor, constant: Constants.padding),
            contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: iconImageView.leadingAnchor, constant: -Constants.padding),
            contentStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            iconImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.padding),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor)
        ])
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapContainer))
        addGestureRecognizer(tap)
    }
}

// MARK: - Subviews Initialization and Setup
extension CasinoGameSearchedView {
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        view.layer.cornerRadius = Constants.cornerRadius
        view.clipsToBounds = true
        return view
    }
    
    private static func createGameImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    private static func createImageLoadingIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }
    
    private static func createImageFailureView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        return view
    }
    
    private static func createImageFailureLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "?"
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
        label.textColor = StyleProvider.Color.textSecondary
        return label
    }
    
    private static func createContentStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = Constants.spacing
        return stack
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 18)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 1
        return label
    }
    
    private static func createProviderLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textSecondary
        label.numberOfLines = 1
        return label
    }
    
    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let customImage = UIImage(named: "play_game_icon") {
            imageView.image = customImage
        }
        else if let systemImage = UIImage(systemName: "chevron.right") {
            imageView.image = systemImage
            imageView.tintColor = StyleProvider.Color.highlightPrimary
        }
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    // MARK: - Bindings
    private func bind(to viewModel: CasinoGameSearchedViewModelProtocol) {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.titleLabel.text = data.title
                self?.providerLabel.text = data.provider
                self?.providerLabel.isHidden = data.provider == nil || data.provider?.isEmpty == true
                self?.loadGameImage(from: data.imageURL)
            }
            .store(in: &cancellables)
        
        viewModel.displayStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if state.isLoading { self?.showImageLoadingState() }
                if state.imageLoadingFailed { self?.showImageFailureState() }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Image Loading
    private func loadGameImage(from imageSource: String?) {
        guard let imageSource = imageSource else {
            showImageFailureState()
            viewModel?.imageLoadingFailed()
            return
        }
        
        if let bundleImage = UIImage(named: imageSource, in: Bundle.module, with: nil) {
            gameImageView.image = bundleImage
            showNormalState()
            viewModel?.imageLoadingSucceeded()
        } else if let url = URL(string: imageSource) {
            showImageLoadingState()
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
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
            showImageFailureState()
            viewModel?.imageLoadingFailed()
        }
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
    
    private func renderPlaceholderState() {
        titleLabel.text = "Gonzo’s Quest"
        providerLabel.text = "Netent"
        showImageFailureState()
    }
    
    // MARK: - Actions
    @objc private func didTapContainer() {
        onGameSelected?()
        viewModel?.didSelect()
    }
}

// MARK: - Preview Provider
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("CasinoGameSearchedView - States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor
        
        let searchedView = CasinoGameSearchedView(viewModel: MockCasinoGameSearchedViewModel.normal)
        searchedView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(searchedView)
        
        NSLayoutConstraint.activate([
            searchedView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            searchedView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            searchedView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}
#endif


