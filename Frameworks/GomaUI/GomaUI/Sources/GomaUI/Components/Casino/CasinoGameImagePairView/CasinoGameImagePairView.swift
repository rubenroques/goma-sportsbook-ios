import UIKit
import SwiftUI

/// A vertical container that displays two casino game images stacked vertically
/// The top game is required, the bottom game is optional (for odd-numbered game lists)
public final class CasinoGameImagePairView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let verticalSpacing: CGFloat = 8.0
    }

    // MARK: - Private Properties

    private lazy var stackView: UIStackView = Self.createStackView()
    private lazy var topGameView: CasinoGameImageView = Self.createGameImageView()
    private lazy var bottomGameView: CasinoGameImageView = Self.createGameImageView()

    private var viewModel: CasinoGameImagePairViewModelProtocol?

    // MARK: - Callbacks

    public var onGameSelected: ((String) -> Void) = { _ in }

    // MARK: - Lifetime and Cycle

    public init(viewModel: CasinoGameImagePairViewModelProtocol? = nil) {
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
    }

    // MARK: - Public Configuration

    public func configure(with viewModel: CasinoGameImagePairViewModelProtocol?) {
        self.viewModel = viewModel

        if let viewModel = viewModel {
            // Configure top game (always present)
            topGameView.configure(with: viewModel.topGameViewModel)

            // Configure bottom game (optional) - never hide, just show empty placeholder
            bottomGameView.configure(with: viewModel.bottomGameViewModel)
            // Keep bottomGameView visible to maintain consistent 2-row height
            bottomGameView.alpha = (viewModel.bottomGameViewModel == nil) ? 0.0 : 1.0

            // Set up game selection callbacks on child ViewModels
            if let topVM = viewModel.topGameViewModel as? MockCasinoGameImageViewModel {
                topVM.onGameSelected = { [weak self] gameId in
                    self?.onGameSelected(gameId)
                }
            }
            if let bottomVM = viewModel.bottomGameViewModel as? MockCasinoGameImageViewModel {
                bottomVM.onGameSelected = { [weak self] gameId in
                    self?.onGameSelected(gameId)
                }
            }
        } else {
            topGameView.configure(with: nil)
            bottomGameView.configure(with: nil)
            bottomGameView.alpha = 1.0  // Show placeholder state
        }
    }

    /// Prepare the view for reuse in a collection/table view cell
    public func prepareForReuse() {
        topGameView.prepareForReuse()
        bottomGameView.prepareForReuse()
        bottomGameView.alpha = 1.0  // Reset alpha for reuse
        viewModel = nil
        onGameSelected = { _ in }
    }
}

// MARK: - Subviews Initialization and Setup

extension CasinoGameImagePairView {

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Constants.verticalSpacing
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }

    private static func createGameImageView() -> CasinoGameImageView {
        let view = CasinoGameImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(stackView)
        stackView.addArrangedSubview(topGameView)
        stackView.addArrangedSubview(bottomGameView)

        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Stack view fills the container
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            // Note: CasinoGameImageView sets its own size (100x100)
        ])
    }
}

// MARK: - Preview Provider

#if DEBUG

@available(iOS 17.0, *)
#Preview("Casino Game Image Pair - Full") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let pairView = CasinoGameImagePairView(viewModel: MockCasinoGameImagePairViewModel.fullPair)
        pairView.onGameSelected = { gameId in
            print("Game selected: \(gameId)")
        }
        pairView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(pairView)

        NSLayoutConstraint.activate([
            pairView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            pairView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Game Image Pair - Top Only") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let pairView = CasinoGameImagePairView(viewModel: MockCasinoGameImagePairViewModel.topOnly)
        pairView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(pairView)

        NSLayoutConstraint.activate([
            pairView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            pairView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Game Image Pair - No Images") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let pairView = CasinoGameImagePairView(viewModel: MockCasinoGameImagePairViewModel.noImages)
        pairView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(pairView)

        NSLayoutConstraint.activate([
            pairView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            pairView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

#endif
