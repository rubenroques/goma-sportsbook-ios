import UIKit
import SwiftUI

/// A simple image-only card view for displaying casino games
/// Used in the compact 2-row grid layout for casino game sections
public final class CasinoGameImageView: UIView {

    // MARK: - Constants

    public enum Constants {
        public static let cardSize: CGFloat = 100.0
        static let cornerRadius: CGFloat = 16.0
    }

    // MARK: - Private Properties

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var gameImageView: UIImageView = Self.createGameImageView()
    private lazy var loadingIndicator: UIActivityIndicatorView = Self.createLoadingIndicator()
    private lazy var failureView: UIView = Self.createFailureView()
    private lazy var failureLabel: UILabel = Self.createFailureLabel()

    private var viewModel: CasinoGameImageViewModelProtocol?
    private var currentImageTask: URLSessionDataTask?

    // MARK: - Lifetime and Cycle

    public init(viewModel: CasinoGameImageViewModelProtocol? = nil) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
        self.configure(with: viewModel)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    private func commonInit() {
        self.setupSubviews()
        self.setupGestures()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = Constants.cornerRadius
    }

    // MARK: - Public Configuration

    public func configure(with viewModel: CasinoGameImageViewModelProtocol?) {
        // Cancel any pending image load task
        currentImageTask?.cancel()
        currentImageTask = nil

        self.viewModel = viewModel

        if let viewModel = viewModel {
            loadGameImage(from: viewModel.iconURL)
        } else {
            showFailureState()
        }
    }

    /// Prepare the view for reuse in a collection/table view cell
    public func prepareForReuse() {
        currentImageTask?.cancel()
        currentImageTask = nil
        gameImageView.image = nil
        viewModel = nil
        showFailureState()
    }

    // MARK: - Private Setup

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }

    @objc private func cardTapped() {
        viewModel?.gameSelected()
    }

    // MARK: - State Rendering

    private func showLoadingState() {
        loadingIndicator.startAnimating()
        gameImageView.isHidden = true
        failureView.isHidden = true
    }

    private func showFailureState() {
        loadingIndicator.stopAnimating()
        gameImageView.isHidden = true
        failureView.isHidden = false
    }

    private func showLoadedState() {
        loadingIndicator.stopAnimating()
        gameImageView.isHidden = false
        failureView.isHidden = true
    }

    // MARK: - Image Loading

    private func loadGameImage(from imageSource: String?) {
        // Clear previous image before loading new one
        gameImageView.image = nil

        guard let imageSource = imageSource else {
            showFailureState()
            return
        }

        // Check if it's a bundle image name
        if let bundleImage = UIImage(named: imageSource, in: Bundle.module, with: nil) {
            gameImageView.image = bundleImage
            showLoadedState()
        } else if let url = URL(string: imageSource) {
            // It's a URL - load from network
            showLoadingState()

            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                DispatchQueue.main.async {
                    // Check if task was cancelled
                    guard error == nil || (error as? URLError)?.code != .cancelled else {
                        return
                    }

                    if let data = data, let image = UIImage(data: data) {
                        self?.gameImageView.image = image
                        self?.showLoadedState()
                    } else {
                        self?.showFailureState()
                    }
                }
            }
            currentImageTask = task
            task.resume()
        } else {
            showFailureState()
        }
    }
}

// MARK: - Subviews Initialization and Setup

extension CasinoGameImageView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundCards
        view.clipsToBounds = true
        return view
    }

    private static func createGameImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = StyleProvider.Color.backgroundCards
        return imageView
    }

    private static func createLoadingIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = StyleProvider.Color.textSecondary
        return indicator
    }

    private static func createFailureView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundCards
        view.isHidden = true
        return view
    }

    private static func createFailureLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "?"
        label.font = StyleProvider.fontWith(type: .bold, size: 32)
        label.textColor = StyleProvider.Color.textDisablePrimary
        label.textAlignment = .center
        return label
    }

    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(containerView)
        containerView.addSubview(gameImageView)
        containerView.addSubview(loadingIndicator)
        containerView.addSubview(failureView)
        failureView.addSubview(failureLabel)

        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container fills the view
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            // Game image fills container
            gameImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            gameImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            gameImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            gameImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // Loading indicator centered
            loadingIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            // Failure view fills container
            failureView.topAnchor.constraint(equalTo: containerView.topAnchor),
            failureView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            failureView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            failureView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // Failure label centered
            failureLabel.centerXAnchor.constraint(equalTo: failureView.centerXAnchor),
            failureLabel.centerYAnchor.constraint(equalTo: failureView.centerYAnchor),

            // Fixed card size
            self.widthAnchor.constraint(equalToConstant: Constants.cardSize),
            self.heightAnchor.constraint(equalToConstant: Constants.cardSize)
        ])
    }
}

// MARK: - Preview Provider

#if DEBUG

#Preview("Casino Game Image - With Image") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.backgroundTestColor

        let gameImageView = CasinoGameImageView(viewModel: MockCasinoGameImageViewModel.aviator)
        gameImageView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(gameImageView)

        NSLayoutConstraint.activate([
            gameImageView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            gameImageView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

#Preview("Casino Game Image - No Image") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.backgroundTestColor

        let gameImageView = CasinoGameImageView(viewModel: MockCasinoGameImageViewModel.noImage)
        gameImageView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(gameImageView)

        NSLayoutConstraint.activate([
            gameImageView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            gameImageView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

#Preview("Casino Game Image - Placeholder") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.backgroundTestColor

        let gameImageView = CasinoGameImageView()
        gameImageView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(gameImageView)

        NSLayoutConstraint.activate([
            gameImageView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            gameImageView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

#endif
