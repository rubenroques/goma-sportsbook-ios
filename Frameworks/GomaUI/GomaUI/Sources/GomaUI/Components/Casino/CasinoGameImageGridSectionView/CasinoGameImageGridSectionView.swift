import UIKit
import Combine
import SwiftUI

/// A section view displaying casino games in a 2-row horizontal scrolling grid
/// Uses CasinoCategoryBarView for the header and CasinoGameImagePairView for game columns
public final class CasinoGameImageGridSectionView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let categoryBarHeight: CGFloat = 48.0
        static let verticalSpacing: CGFloat = 8.0
        static let horizontalSpacing: CGFloat = 12.0
        static let horizontalPadding: CGFloat = 16.0
        static let topSpacingBelowBar: CGFloat = 14.0
        static let bottomPadding: CGFloat = 8.0

        // Use CasinoGameImageView's card size as the source of truth
        static var cardSize: CGFloat { CasinoGameImageView.Constants.cardSize }

        // Collection height = 2 cards + spacing between them
        static var collectionHeight: CGFloat {
            return (cardSize * 2) + verticalSpacing
        }
    }

    // MARK: - Private Properties

    private lazy var categoryBarView: CasinoCategoryBarView = Self.createCategoryBarView()
    private lazy var collectionView: UICollectionView = Self.createCollectionView()

    private var viewModel: CasinoGameImageGridSectionViewModelProtocol?
    private var cancellables = Set<AnyCancellable>()
    private var gamePairViewModels: [CasinoGameImagePairViewModelProtocol] = []

    // MARK: - Callbacks

    public var onGameSelected: ((String) -> Void) = { _ in }
    public var onCategoryButtonTapped: ((String) -> Void) = { _ in }

    // MARK: - Lifetime and Cycle

    public init(viewModel: CasinoGameImageGridSectionViewModelProtocol? = nil) {
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

    public func configure(with viewModel: CasinoGameImageGridSectionViewModelProtocol?) {
        cancellables.removeAll()
        self.viewModel = viewModel

        if let viewModel = viewModel {
            setupBindings(with: viewModel)
        } else {
            renderPlaceholderState()
        }
    }

    // MARK: - Bindings

    private func setupBindings(with viewModel: CasinoGameImageGridSectionViewModelProtocol) {
        // Configure category bar
        categoryBarView.configure(with: viewModel.categoryBarViewModel)

        // Category bar button callback - only use the view's callback, not the ViewModel
        // The ViewModel already wires its own callback in its init
        categoryBarView.onButtonTapped = { [weak self] categoryId in
            self?.onCategoryButtonTapped(categoryId)
        }

        // Game pair ViewModels
        viewModel.gamePairViewModelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pairViewModels in
                self?.gamePairViewModels = pairViewModels
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)

        // Initial data
        gamePairViewModels = viewModel.gamePairViewModels
        collectionView.reloadData()
    }

    // MARK: - Rendering

    private func renderPlaceholderState() {
        categoryBarView.configure(with: nil)
        gamePairViewModels = []
        collectionView.reloadData()
    }
}

// MARK: - Subviews Initialization and Setup

extension CasinoGameImageGridSectionView {

    private static func createCategoryBarView() -> CasinoCategoryBarView {
        let view = CasinoCategoryBarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(
            width: Constants.cardSize,
            height: Constants.collectionHeight
        )
        layout.minimumInteritemSpacing = Constants.horizontalSpacing
        layout.minimumLineSpacing = Constants.horizontalSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: Constants.horizontalPadding,
            bottom: 0,
            right: Constants.horizontalPadding
        )

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(
            CasinoGameImagePairCollectionViewCell.self,
            forCellWithReuseIdentifier: "GamePairCell"
        )
        return collectionView
    }

    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = StyleProvider.Color.backgroundTertiary

        self.addSubview(categoryBarView)
        self.addSubview(collectionView)

        collectionView.dataSource = self
        collectionView.delegate = self

        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Category bar at top
            categoryBarView.topAnchor.constraint(equalTo: self.topAnchor),
            categoryBarView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            categoryBarView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            categoryBarView.heightAnchor.constraint(equalToConstant: Constants.categoryBarHeight),

            // Collection view below category bar
            collectionView.topAnchor.constraint(
                equalTo: categoryBarView.bottomAnchor,
                constant: Constants.topSpacingBelowBar
            ),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(
                equalTo: self.bottomAnchor,
                constant: -Constants.bottomPadding
            ),
            collectionView.heightAnchor.constraint(equalToConstant: Constants.collectionHeight)
        ])
    }
}

// MARK: - UICollectionViewDataSource

extension CasinoGameImageGridSectionView: UICollectionViewDataSource {

    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        // Show placeholder cells when empty
        return gamePairViewModels.isEmpty ? 3 : gamePairViewModels.count
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GamePairCell",
            for: indexPath
        ) as! CasinoGameImagePairCollectionViewCell

        if gamePairViewModels.isEmpty {
            // Placeholder cell
            cell.configure(with: nil)
        } else {
            let pairVM = gamePairViewModels[indexPath.item]
            cell.configure(with: pairVM)
        }

        // Forward game selection callback
        cell.onGameSelected = { [weak self] gameId in
            self?.onGameSelected(gameId)
            self?.viewModel?.gameSelected(gameId)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CasinoGameImageGridSectionView: UICollectionViewDelegate {
    // Additional delegate methods can be added here if needed
}

// MARK: - Preview Provider

#if DEBUG

#Preview("Casino Game Image Grid - Lite Games") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let mockVM = MockCasinoGameImageGridSectionViewModel.liteGamesSection
        mockVM.onGameSelected = { gameId in
            print("Game selected: \(gameId)")
        }
        mockVM.onCategoryButtonTapped = {
            print("Category button tapped")
        }

        let sectionView = CasinoGameImageGridSectionView(viewModel: mockVM)
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(sectionView)

        NSLayoutConstraint.activate([
            sectionView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            sectionView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            sectionView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        return vc
    }
}

#Preview("Casino Game Image Grid - Odd Games") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let sectionView = CasinoGameImageGridSectionView(
            viewModel: MockCasinoGameImageGridSectionViewModel.oddGamesSection
        )
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(sectionView)

        NSLayoutConstraint.activate([
            sectionView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            sectionView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            sectionView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        return vc
    }
}

#Preview("Casino Game Image Grid - Placeholder") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let sectionView = CasinoGameImageGridSectionView()
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(sectionView)

        NSLayoutConstraint.activate([
            sectionView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            sectionView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            sectionView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])

        return vc
    }
}

#endif
