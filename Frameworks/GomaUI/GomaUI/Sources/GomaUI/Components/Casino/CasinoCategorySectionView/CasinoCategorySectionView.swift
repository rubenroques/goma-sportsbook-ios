import UIKit
import Combine
import SwiftUI

final public class CasinoCategorySectionView: UIView {
    
    // MARK: - Constants
    private enum Constants {
        static let verticalPadding: CGFloat = 12.0
        static let horizontalPadding: CGFloat = 16.0
        static let cellSpacing: CGFloat = 12.0
        static let categoryBarHeight: CGFloat = 48.0
        static let collectionHeight: CGFloat = 266.0 // CasinoGameCardView and wrapper cell height
    }
    
    // MARK: - UI Elements
    private let categoryBarView = CasinoCategoryBarView()
    private let collectionView: UICollectionView
    
    // MARK: - Properties
    private var viewModel: CasinoCategorySectionViewModelProtocol?
    private var cancellables = Set<AnyCancellable>()
    private var gameCardViewModels: [CasinoGameCardViewModelProtocol] = []
    
    // MARK: - Callbacks
    public var onGameSelected: ((String) -> Void) = { _ in }
    public var onCategoryButtonTapped: ((String) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: CasinoCategorySectionViewModelProtocol? = nil) {
        // Create collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 164, height: Constants.collectionHeight) // CasinoGameCardView size
        layout.minimumInteritemSpacing = Constants.cellSpacing
        layout.minimumLineSpacing = Constants.cellSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: Constants.horizontalPadding,
            bottom: 0,
            right: Constants.horizontalPadding
        )
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        setupSubviews()
        configure(with: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Configuration
    public func configure(with viewModel: CasinoCategorySectionViewModelProtocol?) {
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
        backgroundColor = StyleProvider.Color.backgroundTertiary
        
        setupCategoryBar()
        setupCollectionView()
        setupConstraints()
    }
    
    private func setupCategoryBar() {
        // Category bar setup
        categoryBarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(categoryBarView)
    }
    
    private func setupCollectionView() {
        // Collection view setup
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Register cell
        collectionView.register(CasinoGameCardCollectionViewCell.self, forCellWithReuseIdentifier: "GameCardCell")
        
        // Set delegates
        collectionView.dataSource = self
        collectionView.delegate = self
        
        addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            categoryBarView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            categoryBarView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            categoryBarView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            categoryBarView.heightAnchor.constraint(equalToConstant: Constants.categoryBarHeight),
            
            collectionView.topAnchor.constraint(equalTo: categoryBarView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            
            // Collection view height
            collectionView.heightAnchor.constraint(equalToConstant: Constants.collectionHeight)
        ])
    }
    
    // MARK: - Bindings
    private func setupBindings(with viewModel: CasinoCategorySectionViewModelProtocol) {
        // Configure category bar with its child ViewModel
        categoryBarView.configure(with: viewModel.categoryBarViewModel)
        
        // Setup category bar callback
        categoryBarView.onButtonTapped = { [weak self] categoryId in
            self?.onCategoryButtonTapped(categoryId)
            self?.viewModel?.categoryButtonTapped()
        }
        
        // Game card ViewModels
        viewModel.gameCardViewModelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gameCardViewModels in
                self?.gameCardViewModels = gameCardViewModels
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    private func renderPlaceholderState() {
        categoryBarView.configure(with: nil)
        gameCardViewModels = []
        collectionView.reloadData()
    }
}

// MARK: - Collection View Data Source
extension CasinoCategorySectionView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameCardViewModels.isEmpty ? 3 : gameCardViewModels.count // Show 3 placeholder cells when empty
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCardCell", for: indexPath) as! CasinoGameCardCollectionViewCell
        
        if gameCardViewModels.isEmpty {
            // Configure placeholder cell
            cell.configure(with: nil)
        } else {
            // Configure with actual game card ViewModel
            let gameCardViewModel = gameCardViewModels[indexPath.item]
            cell.configure(with: gameCardViewModel)
        }
        
        // Set callback
        cell.onGameSelected = { [weak self] gameId in
            self?.onGameSelected(gameId)
            self?.viewModel?.gameSelected(gameId)
        }
        
        return cell
    }
}

// MARK: - Collection View Delegate
extension CasinoCategorySectionView: UICollectionViewDelegate {
    // Additional delegate methods can be added here if needed
}

// MARK: - Preview Provider
#if DEBUG

#Preview("Casino Category Section - Placeholder") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor
        
        let categorySectionView = CasinoCategorySectionView() // No viewModel - placeholder state
        categorySectionView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(categorySectionView)
        
        NSLayoutConstraint.activate([
            categorySectionView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            categorySectionView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            categorySectionView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        return vc
    }
}

#endif
