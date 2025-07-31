# CasinoCategoryScrollView Component Specification

## Overview

**CasinoCategoryScrollView** is a container component that displays a horizontal scrolling collection of casino games for a specific category. It combines a category header with a horizontally scrolling collection view containing game cards.

## Visual Design

Based on Figma design showing category sections with:
- Category header (using CasinoCategoryHeaderView)
- Horizontal scrolling list of games (using CasinoGameCollectionViewCell)

### Layout Structure
```
┌─────────────────────────────────────────────────────────────┐
│ [Category Header: "New Games"               "All 41 >"]     │
├─────────────────────────────────────────────────────────────┤
│ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐         │
│ │ Game  │ │ Game  │ │ Game  │ │ Game  │ │ Game  │  ──→    │
│ │ Card  │ │ Card  │ │ Card  │ │ Card  │ │ Card  │         │
│ │   1   │ │   2   │ │   3   │ │   4   │ │   5   │         │
│ └───────┘ └───────┘ └───────┘ └───────┘ └───────┘         │
└─────────────────────────────────────────────────────────────┘
```

### Design Elements
- **Full-width container**: Spans entire parent width
- **Integrated header**: Uses CasinoCategoryHeaderView component
- **Horizontal scroll**: Smooth collection view scrolling
- **Consistent spacing**: Proper margins and game card spacing
- **Loading states**: Placeholder cards during data loading

## Data Models

```swift
// MARK: - Data Models
public struct CasinoCategoryScrollData: Equatable, Hashable, Identifiable {
    public let id: String
    public let categoryName: String
    public let totalGameCount: Int
    public let displayedGames: [CasinoGameCardData]
    public let showViewAllButton: Bool
    public let maxDisplayedItems: Int
    
    public init(
        id: String,
        categoryName: String,
        totalGameCount: Int,
        displayedGames: [CasinoGameCardData],
        showViewAllButton: Bool = true,
        maxDisplayedItems: Int = 10
    ) {
        self.id = id
        self.categoryName = categoryName
        self.totalGameCount = totalGameCount
        self.displayedGames = displayedGames
        self.showViewAllButton = showViewAllButton
        self.maxDisplayedItems = maxDisplayedItems
    }
}

// MARK: - Display State
public struct CasinoCategoryScrollDisplayState: Equatable {
    public let categoryData: CasinoCategoryScrollData
    public let isLoading: Bool
    public let isLoadingMore: Bool
    public let hasError: Bool
    public let errorMessage: String?
    
    public init(
        categoryData: CasinoCategoryScrollData,
        isLoading: Bool = false,
        isLoadingMore: Bool = false,
        hasError: Bool = false,
        errorMessage: String? = nil
    ) {
        self.categoryData = categoryData
        self.isLoading = isLoading
        self.isLoadingMore = isLoadingMore
        self.hasError = hasError
        self.errorMessage = errorMessage
    }
}
```

## ViewModelProtocol

```swift
public protocol CasinoCategoryScrollViewModelProtocol {
    // Main display state publisher
    var displayStatePublisher: AnyPublisher<CasinoCategoryScrollDisplayState, Never> { get }
    
    // Individual property publishers for fine-grained updates
    var categoryNamePublisher: AnyPublisher<String, Never> { get }
    var gameCountPublisher: AnyPublisher<Int, Never> { get }
    var gamesPublisher: AnyPublisher<[CasinoGameCardData], Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var hasErrorPublisher: AnyPublisher<Bool, Never> { get }
    
    // User interaction methods
    func viewAllGamesTapped()
    func gameSelected(_ gameId: String)
    func favoriteToggled(_ gameId: String, isFavorite: Bool)
    func loadMoreGames()
    func retryLoading()
    
    // Read-only properties
    var categoryId: String { get }
    var maxDisplayedItems: Int { get }
}
```

## UI Specifications

### Layout Constants
```swift
private enum Constants {
    static let headerHeight: CGFloat = 56.0
    static let collectionViewHeight: CGFloat = 240.0 // 220 + margins
    static let totalHeight: CGFloat = headerHeight + collectionViewHeight
    
    // Collection view layout
    static let itemSize = CGSize(width: 160, height: 220)
    static let minimumLineSpacing: CGFloat = 12.0
    static let minimumInteritemSpacing: CGFloat = 12.0
    static let sectionInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    
    // Loading placeholders
    static let loadingItemCount: Int = 3
    static let loadMoreThreshold: Int = 3 // Load more when 3 items from end
}
```

### UI Structure
```swift
final public class CasinoCategoryScrollView: UIView {
    // MARK: - UI Elements
    private let containerStackView = UIStackView()
    private let categoryHeaderView: CasinoCategoryHeaderView
    private let collectionView: UICollectionView
    private let loadingView = UIView()
    private let errorView = UIView()
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let viewModel: CasinoCategoryScrollViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var gameCardViewModels: [CasinoGameCardViewModelProtocol] = []
    
    // MARK: - Callbacks
    public var onViewAllTapped: ((String) -> Void) = { _ in }
    public var onGameSelected: ((String) -> Void) = { _ in }
    public var onFavoriteToggled: ((String, Bool) -> Void) = { _, _ in }
    
    // MARK: - Initialization
    public init(viewModel: CasinoCategoryScrollViewModelProtocol) {
        self.viewModel = viewModel
        
        // Create header view model (bridged from main view model)
        let headerViewModel = CasinoCategoryScrollHeaderBridge(categoryScrollViewModel: viewModel)
        self.categoryHeaderView = CasinoCategoryHeaderView(viewModel: headerViewModel)
        
        // Create collection view with flow layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = Constants.itemSize
        layout.minimumLineSpacing = Constants.minimumLineSpacing
        layout.minimumInteritemSpacing = Constants.minimumInteritemSpacing
        layout.sectionInset = Constants.sectionInsets
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: .zero)
        
        setupSubviews()
        setupBindings()
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

### Collection View Setup
```swift
private func setupCollectionView() {
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = UIColor.clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.delegate = self
    collectionView.dataSource = self
    
    // Register cells
    collectionView.register(
        CasinoGameCollectionViewCell.self,
        forCellWithReuseIdentifier: CasinoGameCollectionViewCell.reuseIdentifier
    )
    
    // Register loading cell if needed
    collectionView.register(
        CasinoGameLoadingCollectionViewCell.self,
        forCellWithReuseIdentifier: CasinoGameLoadingCollectionViewCell.reuseIdentifier
    )
}

private func setupSubviews() {
    translatesAutoresizingMaskIntoConstraints = false
    
    // Container stack view
    containerStackView.axis = .vertical
    containerStackView.spacing = 0
    containerStackView.distribution = .fill
    containerStackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(containerStackView)
    
    // Add header
    containerStackView.addArrangedSubview(categoryHeaderView)
    
    // Add collection view
    containerStackView.addArrangedSubview(collectionView)
    
    // Setup constraints
    NSLayoutConstraint.activate([
        containerStackView.topAnchor.constraint(equalTo: topAnchor),
        containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
        containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        
        // Fixed heights
        categoryHeaderView.heightAnchor.constraint(equalToConstant: Constants.headerHeight),
        collectionView.heightAnchor.constraint(equalToConstant: Constants.collectionViewHeight),
        
        // Total component height
        heightAnchor.constraint(equalToConstant: Constants.totalHeight)
    ])
    
    setupErrorView()
    setupLoadingView()
}
```

### Loading and Error States
```swift
private func setupLoadingView() {
    loadingView.translatesAutoresizingMaskIntoConstraints = false
    loadingView.backgroundColor = UIColor.clear
    loadingView.isHidden = true
    
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
    loadingIndicator.startAnimating()
    
    let loadingLabel = UILabel()
    loadingLabel.text = "Loading games..."
    loadingLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
    loadingLabel.textColor = StyleProvider.Color.textSecondary
    loadingLabel.textAlignment = .center
    loadingLabel.translatesAutoresizingMaskIntoConstraints = false
    
    let loadingStackView = UIStackView(arrangedSubviews: [loadingIndicator, loadingLabel])
    loadingStackView.axis = .vertical
    loadingStackView.spacing = 8
    loadingStackView.alignment = .center
    loadingStackView.translatesAutoresizingMaskIntoConstraints = false
    
    loadingView.addSubview(loadingStackView)
    containerStackView.insertArrangedSubview(loadingView, at: 1) // After header, before collection
    
    NSLayoutConstraint.activate([
        loadingStackView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
        loadingStackView.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor),
        loadingView.heightAnchor.constraint(equalToConstant: Constants.collectionViewHeight)
    ])
}

private func setupErrorView() {
    errorView.translatesAutoresizingMaskIntoConstraints = false
    errorView.backgroundColor = UIColor.clear
    errorView.isHidden = true
    
    errorLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
    errorLabel.textColor = StyleProvider.Color.textSecondary
    errorLabel.textAlignment = .center
    errorLabel.numberOfLines = 0
    errorLabel.translatesAutoresizingMaskIntoConstraints = false
    
    retryButton.setTitle("Retry", for: .normal)
    retryButton.setTitleColor(StyleProvider.Color.primaryColor, for: .normal)
    retryButton.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 14)
    retryButton.translatesAutoresizingMaskIntoConstraints = false
    retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    
    let errorStackView = UIStackView(arrangedSubviews: [errorLabel, retryButton])
    errorStackView.axis = .vertical
    errorStackView.spacing = 12
    errorStackView.alignment = .center
    errorStackView.translatesAutoresizingMaskIntoConstraints = false
    
    errorView.addSubview(errorStackView)
    containerStackView.insertArrangedSubview(errorView, at: 1) // After header, before collection
    
    NSLayoutConstraint.activate([
        errorStackView.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
        errorStackView.centerYAnchor.constraint(equalTo: errorView.centerYAnchor),
        errorStackView.leadingAnchor.constraint(greaterThanOrEqualTo: errorView.leadingAnchor, constant: 16),
        errorStackView.trailingAnchor.constraint(lessThanOrEqualTo: errorView.trailingAnchor, constant: -16),
        errorView.heightAnchor.constraint(equalToConstant: Constants.collectionViewHeight)
    ])
}
```

## State Management

### Display States
1. **Loading State**: Loading indicator shown, collection view hidden
2. **Content State**: Games displayed in collection view
3. **Error State**: Error message and retry button shown
4. **Empty State**: No games available message
5. **Loading More State**: Additional loading indicator at end of collection

### Reactive Updates
```swift
private func setupBindings() {
    // Header callbacks
    categoryHeaderView.onViewAllTapped = { [weak self] categoryId in
        self?.viewModel.viewAllGamesTapped()
        self?.onViewAllTapped(categoryId)
    }
    
    // Main display state
    viewModel.displayStatePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] displayState in
            self?.render(displayState: displayState)
        }
        .store(in: &cancellables)
    
    // Games list updates
    viewModel.gamesPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] games in
            self?.updateGameViewModels(games)
            self?.collectionView.reloadData()
        }
        .store(in: &cancellables)
}

private func render(displayState: CasinoCategoryScrollDisplayState) {
    if displayState.isLoading && displayState.categoryData.displayedGames.isEmpty {
        // Initial loading state
        showLoadingState()
    } else if displayState.hasError && displayState.categoryData.displayedGames.isEmpty {
        // Error state with no data
        showErrorState(message: displayState.errorMessage)
    } else {
        // Content state
        showContentState()
    }
}

private func showLoadingState() {
    loadingView.isHidden = false
    collectionView.isHidden = true
    errorView.isHidden = true
}

private func showErrorState(message: String?) {
    errorLabel.text = message ?? "Failed to load games"
    errorView.isHidden = false
    collectionView.isHidden = true
    loadingView.isHidden = true
}

private func showContentState() {
    collectionView.isHidden = false
    loadingView.isHidden = true
    errorView.isHidden = true
}
```

## Collection View Implementation

### Data Source
```swift
extension CasinoCategoryScrollView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameCardViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CasinoGameCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! CasinoGameCollectionViewCell
        
        let gameViewModel = gameCardViewModels[indexPath.item]
        cell.configure(with: gameViewModel)
        
        // Set up callbacks
        cell.onGameSelected = { [weak self] gameId in
            self?.viewModel.gameSelected(gameId)
            self?.onGameSelected(gameId)
        }
        
        cell.onFavoriteToggled = { [weak self] gameId, isFavorite in
            self?.viewModel.favoriteToggled(gameId, isFavorite: isFavorite)
            self?.onFavoriteToggled(gameId, isFavorite)
        }
        
        return cell
    }
}

extension CasinoCategoryScrollView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Load more when approaching end
        let threshold = gameCardViewModels.count - Constants.loadMoreThreshold
        if indexPath.item >= threshold {
            viewModel.loadMoreGames()
        }
    }
}
```

## Header Bridge Component

Since the category header needs to be integrated, we need a bridge:

```swift
private class CasinoCategoryScrollHeaderBridge: CasinoCategoryHeaderViewModelProtocol {
    private let categoryScrollViewModel: CasinoCategoryScrollViewModelProtocol
    
    init(categoryScrollViewModel: CasinoCategoryScrollViewModelProtocol) {
        self.categoryScrollViewModel = categoryScrollViewModel
    }
    
    var displayStatePublisher: AnyPublisher<CasinoCategoryHeaderDisplayState, Never> {
        categoryScrollViewModel.displayStatePublisher
            .map { scrollState in
                let headerData = CasinoCategoryHeaderData(
                    id: scrollState.categoryData.id,
                    categoryName: scrollState.categoryData.categoryName,
                    gameCount: scrollState.categoryData.totalGameCount,
                    showAllButton: scrollState.categoryData.showViewAllButton
                )
                return CasinoCategoryHeaderDisplayState(
                    headerData: headerData,
                    isLoading: scrollState.isLoading
                )
            }
            .eraseToAnyPublisher()
    }
    
    // Bridge other publishers similarly...
    var categoryNamePublisher: AnyPublisher<String, Never> {
        categoryScrollViewModel.categoryNamePublisher
    }
    
    var gameCountPublisher: AnyPublisher<Int, Never> {
        categoryScrollViewModel.gameCountPublisher
    }
    
    // ... other bridged methods
    
    func viewAllTapped() {
        categoryScrollViewModel.viewAllGamesTapped()
    }
}
```

## Mock ViewModel

```swift
final public class MockCasinoCategoryScrollViewModel: CasinoCategoryScrollViewModelProtocol {
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<CasinoCategoryScrollDisplayState, Never>
    private var currentCategoryData: CasinoCategoryScrollData
    
    public var categoryId: String { currentCategoryData.id }
    public var maxDisplayedItems: Int { currentCategoryData.maxDisplayedItems }
    
    // MARK: - Initialization
    public init(categoryData: CasinoCategoryScrollData, initialState: CasinoCategoryScrollDisplayState? = nil) {
        self.currentCategoryData = categoryData
        
        let state = initialState ?? CasinoCategoryScrollDisplayState(categoryData: categoryData)
        self.displayStateSubject = CurrentValueSubject(state)
    }
    
    // MARK: - Mock Factory Methods
    public static var newGames: MockCasinoCategoryScrollViewModel {
        let games = [
            MockCasinoGameCardViewModel.plinkGoal.gameData,
            MockCasinoGameCardViewModel.beastBelow.gameData,
            MockCasinoGameCardViewModel.jetX.gameData,
            MockCasinoGameCardViewModel.aviator.gameData
        ]
        
        let categoryData = CasinoCategoryScrollData(
            id: "new-games",
            categoryName: "New Games",
            totalGameCount: 41,
            displayedGames: games
        )
        
        return MockCasinoCategoryScrollViewModel(categoryData: categoryData)
    }
    
    public static var liveGames: MockCasinoCategoryScrollViewModel {
        let games = [
            MockCasinoGameCardViewModel.aviator.gameData,
            MockCasinoGameCardViewModel.dragonsFortuneMegaways.gameData
        ]
        
        let categoryData = CasinoCategoryScrollData(
            id: "live-games",
            categoryName: "Live Games",
            totalGameCount: 24,
            displayedGames: games
        )
        
        return MockCasinoCategoryScrollViewModel(categoryData: categoryData)
    }
    
    public static var crashGames: MockCasinoCategoryScrollViewModel {
        let games = [
            MockCasinoGameCardViewModel.aviator.gameData,
            MockCasinoGameCardViewModel.jetX.gameData
        ]
        
        let categoryData = CasinoCategoryScrollData(
            id: "crash-games",
            categoryName: "Crash Games",
            totalGameCount: 8,
            displayedGames: games
        )
        
        return MockCasinoCategoryScrollViewModel(categoryData: categoryData)
    }
    
    public static var trending: MockCasinoCategoryScrollViewModel {
        let games = [
            MockCasinoGameCardViewModel.dragonsFortuneMegaways.gameData,
            MockCasinoGameCardViewModel.beastBelow.gameData,
            MockCasinoGameCardViewModel.plinkGoal.gameData
        ]
        
        let categoryData = CasinoCategoryScrollData(
            id: "trending",
            categoryName: "Trending",
            totalGameCount: 15,
            displayedGames: games
        )
        
        return MockCasinoCategoryScrollViewModel(categoryData: categoryData)
    }
    
    // State examples
    public static var loadingCategory: MockCasinoCategoryScrollViewModel {
        let categoryData = CasinoCategoryScrollData(
            id: "loading-category",
            categoryName: "Loading Category",
            totalGameCount: 0,
            displayedGames: []
        )
        
        let state = CasinoCategoryScrollDisplayState(
            categoryData: categoryData,
            isLoading: true
        )
        
        return MockCasinoCategoryScrollViewModel(categoryData: categoryData, initialState: state)
    }
    
    public static var errorCategory: MockCasinoCategoryScrollViewModel {
        let categoryData = CasinoCategoryScrollData(
            id: "error-category",
            categoryName: "Error Category",
            totalGameCount: 0,
            displayedGames: []
        )
        
        let state = CasinoCategoryScrollDisplayState(
            categoryData: categoryData,
            hasError: true,
            errorMessage: "Failed to load category games"
        )
        
        return MockCasinoCategoryScrollViewModel(categoryData: categoryData, initialState: state)
    }
}
```

## SwiftUI Previews

```swift
// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Casino Category Scroll - New Games") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let categoryScrollView = CasinoCategoryScrollView(viewModel: MockCasinoCategoryScrollViewModel.newGames)
        categoryScrollView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(categoryScrollView)
        
        NSLayoutConstraint.activate([
            categoryScrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            categoryScrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 296) // headerHeight + collectionViewHeight
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Category Scroll - Live Games") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let categoryScrollView = CasinoCategoryScrollView(viewModel: MockCasinoCategoryScrollViewModel.liveGames)
        categoryScrollView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(categoryScrollView)
        
        NSLayoutConstraint.activate([
            categoryScrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            categoryScrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 296)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Category Scroll - Crash Games") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let categoryScrollView = CasinoCategoryScrollView(viewModel: MockCasinoCategoryScrollViewModel.crashGames)
        categoryScrollView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(categoryScrollView)
        
        NSLayoutConstraint.activate([
            categoryScrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            categoryScrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 296)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Category Scroll - Trending") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let categoryScrollView = CasinoCategoryScrollView(viewModel: MockCasinoCategoryScrollViewModel.trending)
        categoryScrollView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(categoryScrollView)
        
        NSLayoutConstraint.activate([
            categoryScrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            categoryScrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 296)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Category Scroll - Loading State") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let categoryScrollView = CasinoCategoryScrollView(viewModel: MockCasinoCategoryScrollViewModel.loadingCategory)
        categoryScrollView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(categoryScrollView)
        
        NSLayoutConstraint.activate([
            categoryScrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            categoryScrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 296)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Category Scroll - Error State") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let categoryScrollView = CasinoCategoryScrollView(viewModel: MockCasinoCategoryScrollViewModel.errorCategory)
        categoryScrollView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(categoryScrollView)
        
        NSLayoutConstraint.activate([
            categoryScrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            categoryScrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 296)
        ])
        
        return vc
    }
}

#endif
```

## Demo Integration

### Demo View Controller
Create `CasinoCategoryScrollViewController.swift` in TestCase directory:

```swift
import UIKit
import Combine
import GomaUI

class CasinoCategoryScrollViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Casino Category Scroll"
        setupViews()
        createDemoCategories()
    }
    
    private func setupViews() {
        view.backgroundColor = StyleProvider.Color.backgroundColor
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        
        scrollView.addSubview(contentStackView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func createDemoCategories() {
        let categoryViewModels = [
            MockCasinoCategoryScrollViewModel.newGames,
            MockCasinoCategoryScrollViewModel.liveGames,
            MockCasinoCategoryScrollViewModel.crashGames,
            MockCasinoCategoryScrollViewModel.trending
        ]
        
        categoryViewModels.forEach { mockViewModel in
            let categoryScrollView = CasinoCategoryScrollView(viewModel: mockViewModel)
            
            categoryScrollView.onViewAllTapped = { [weak self] categoryId in
                self?.showAlert(title: "View All", message: "Category: \(categoryId)")
            }
            
            categoryScrollView.onGameSelected = { [weak self] gameId in
                self?.showAlert(title: "Game Selected", message: "Game: \(gameId)")
            }
            
            categoryScrollView.onFavoriteToggled = { [weak self] gameId, isFavorite in
                self?.showAlert(title: "Favorite Toggled", message: "Game: \(gameId), Favorite: \(isFavorite)")
            }
            
            contentStackView.addArrangedSubview(categoryScrollView)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
```

### Gallery Integration
Add to `ComponentsTableViewController.swift`:

```swift
UIComponent(
    title: "Casino Category Scroll",
    description: "Horizontal scrolling collection of casino games with category header",
    viewController: CasinoCategoryScrollViewController.self,
    previewFactory: {
        let viewModel = MockCasinoCategoryScrollViewModel.newGames
        return CasinoCategoryScrollView(viewModel: viewModel)
    }
)
```

## Performance Considerations

- **Lazy Loading**: Games loaded as user scrolls
- **Cell Reuse**: Proper UICollectionViewCell reuse
- **Image Caching**: Efficient image loading and caching
- **Memory Management**: Proper cleanup of view models and subscriptions
- **Smooth Scrolling**: Optimized layout calculations

## Implementation Files

```
CasinoCategoryScrollView/
├── CasinoCategoryScrollViewModelProtocol.swift
├── CasinoCategoryScrollView.swift
├── MockCasinoCategoryScrollViewModel.swift
└── Documentation/
    └── README.md
```

## Success Criteria

- [ ] Smooth horizontal scrolling performance
- [ ] Proper integration with category header
- [ ] Loading and error states handled gracefully
- [ ] Game selection and favorite toggling work correctly
- [ ] "View All" functionality works
- [ ] Demo app shows multiple categories stacked vertically
- [ ] Memory usage optimized for large game lists
- [ ] Collection view cell reuse working properly