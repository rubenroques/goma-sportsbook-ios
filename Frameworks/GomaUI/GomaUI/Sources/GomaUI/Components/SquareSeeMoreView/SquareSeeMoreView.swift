import UIKit
import SwiftUI

/// A simple "See More" card view that matches the size of CasinoGameImageView
/// Used as the last card in a casino game grid to navigate to full category
public final class SquareSeeMoreView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let cornerRadius: CGFloat = 16.0
        static let cardSize: CGFloat = 100.0
        static let iconSize: CGFloat = 24.0
        static let labelTopSpacing: CGFloat = 4.0
        static let labelFontSize: CGFloat = 12.0
    }

    // MARK: - Private Properties

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var seeMoreLabel: UILabel = Self.createSeeMoreLabel()
    private lazy var stackView: UIStackView = Self.createStackView()

    private var viewModel: SquareSeeMoreViewModelProtocol?

    // MARK: - Lifetime and Cycle

    public init(viewModel: SquareSeeMoreViewModelProtocol? = nil) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
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

    public func configure(with viewModel: SquareSeeMoreViewModelProtocol?) {
        self.viewModel = viewModel
    }

    // MARK: - Private Setup

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }

    @objc private func cardTapped() {
        viewModel?.seeMoreTapped()
    }
}

// MARK: - Subviews Initialization and Setup

extension SquareSeeMoreView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundCards
        view.clipsToBounds = true
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.textPrimary
        let config = UIImage.SymbolConfiguration(pointSize: Constants.iconSize, weight: .medium)
        imageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        return imageView
    }

    private static func createSeeMoreLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = LocalizationProvider.string("see_more")
        label.font = StyleProvider.fontWith(type: .medium, size: Constants.labelFontSize)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Constants.labelTopSpacing
        return stackView
    }

    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(seeMoreLabel)

        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container fills the view
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            // Stack view centered in container
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            // Icon size
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),

            // Fixed card size
            self.widthAnchor.constraint(equalToConstant: Constants.cardSize),
            self.heightAnchor.constraint(equalToConstant: Constants.cardSize)
        ])
    }
}

// MARK: - Preview Provider

#if DEBUG

@available(iOS 17.0, *)
#Preview("Square See More - Default") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let seeMoreView = SquareSeeMoreView(viewModel: MockSquareSeeMoreViewModel.default)
        seeMoreView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(seeMoreView)

        NSLayoutConstraint.activate([
            seeMoreView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            seeMoreView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Square See More - In Grid Context") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .top

        // Add a game image view for comparison
        let gameView = CasinoGameImageView(viewModel: MockCasinoGameImageViewModel.aviator)

        // Add the see more view
        let seeMoreView = SquareSeeMoreView(viewModel: MockSquareSeeMoreViewModel.interactive)

        stackView.addArrangedSubview(gameView)
        stackView.addArrangedSubview(seeMoreView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

#endif
