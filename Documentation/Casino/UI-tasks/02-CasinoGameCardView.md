# CasinoGameCardView Component Specification

## Overview

**CasinoGameCardView** is a fundamental leaf component that displays individual casino games. This is the most important component as it's reused across multiple contexts (recently played, category scrolls, search results, etc.).

## Visual Design

Based on Figma design showing individual game cards with:
- Game artwork/image
- Game title (e.g., "PlinkGoal")
- Provider name (e.g., "Gaming Corps")
- Star rating display (e.g., 3/5 stars)
- Min stake information (e.g., "Min Stake: XAF 1")

### Layout Structure
```
┌─────────────────────────────────────────┐
│                                         │
│          [Game Image]                   │
│                                         │
│─────────────────────────────────────────│
│ Game Title                              │
│ Provider Name                           │
│ ⭐⭐⭐☆☆ Min Stake: XAF 1             │
└─────────────────────────────────────────┘
```

### Design Measurements
- **Card Width**: 160pt (fixed for consistency)
- **Card Height**: 220pt (fixed for consistency)
- **Image Aspect Ratio**: 16:9 or square depending on provider
- **Corner Radius**: 12pt
- **Shadow**: Subtle drop shadow for elevation

## Data Models

```swift
// MARK: - Data Models
public struct CasinoGameCardData: Equatable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let provider: String
    public let imageURL: String?
    public let localImageName: String? // Fallback for bundled images
    public let rating: Double // 0.0 to 5.0
    public let minStake: String
    public let currency: String
    public let isNew: Bool
    public let isFavorite: Bool
    public let category: String
    public let playableInDemo: Bool
    
    public init(
        id: String,
        name: String,
        provider: String,
        imageURL: String? = nil,
        localImageName: String? = nil,
        rating: Double,
        minStake: String,
        currency: String = "XAF",
        isNew: Bool = false,
        isFavorite: Bool = false,
        category: String,
        playableInDemo: Bool = true
    ) {
        self.id = id
        self.name = name
        self.provider = provider
        self.imageURL = imageURL
        self.localImageName = localImageName
        self.rating = max(0.0, min(5.0, rating))
        self.minStake = minStake
        self.currency = currency
        self.isNew = isNew
        self.isFavorite = isFavorite
        self.category = category
        self.playableInDemo = playableInDemo
    }
}

// MARK: - Display State
public struct CasinoGameCardDisplayState: Equatable {
    public let gameData: CasinoGameCardData
    public let isLoading: Bool
    public let imageLoadingFailed: Bool
    public let isSelected: Bool
    public let showNewBadge: Bool
    public let showFavoriteIcon: Bool
    
    public init(
        gameData: CasinoGameCardData,
        isLoading: Bool = false,
        imageLoadingFailed: Bool = false,
        isSelected: Bool = false,
        showNewBadge: Bool = false,
        showFavoriteIcon: Bool = false
    ) {
        self.gameData = gameData
        self.isLoading = isLoading
        self.imageLoadingFailed = imageLoadingFailed
        self.isSelected = isSelected
        self.showNewBadge = showNewBadge
        self.showFavoriteIcon = showFavoriteIcon
    }
}
```

## ViewModelProtocol

```swift
public protocol CasinoGameCardViewModelProtocol {
    // Main display state publisher
    var displayStatePublisher: AnyPublisher<CasinoGameCardDisplayState, Never> { get }
    
    // Individual property publishers for fine-grained updates
    var gameNamePublisher: AnyPublisher<String, Never> { get }
    var providerNamePublisher: AnyPublisher<String, Never> { get }
    var imageURLPublisher: AnyPublisher<String?, Never> { get }
    var ratingPublisher: AnyPublisher<Double, Never> { get }
    var minStakePublisher: AnyPublisher<String, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var isSelectedPublisher: AnyPublisher<Bool, Never> { get }
    var showNewBadgePublisher: AnyPublisher<Bool, Never> { get }
    var showFavoriteIconPublisher: AnyPublisher<Bool, Never> { get }
    
    // User interaction methods
    func selectGame()
    func toggleFavorite()
    func imageLoadingFailed()
    func imageLoadingSucceeded()
    
    // Read-only properties
    var gameId: String { get }
    var category: String { get }
}
```

## UI Specifications

### Layout Constants
```swift
private enum Constants {
    static let cardWidth: CGFloat = 160.0
    static let cardHeight: CGFloat = 220.0
    static let cornerRadius: CGFloat = 12.0
    static let shadowOpacity: Float = 0.1
    static let shadowRadius: CGFloat = 4.0
    static let shadowOffset = CGSize(width: 0, height: 2)
    
    // Image
    static let imageHeight: CGFloat = 120.0
    static let imageCornerRadius: CGFloat = 8.0
    
    // Content padding
    static let contentPadding: CGFloat = 12.0
    static let titleToProviderSpacing: CGFloat = 4.0
    static let providerToRatingSpacing: CGFloat = 8.0
    
    // Stars
    static let starSize: CGFloat = 16.0
    static let starSpacing: CGFloat = 2.0
    
    // Badge
    static let badgeSize: CGFloat = 20.0
    static let badgeTopRightOffset: CGFloat = 8.0
    
    // Favorite icon
    static let favoriteIconSize: CGFloat = 24.0
}
```

### Styling
- **Card Background**: `StyleProvider.Color.backgroundColor`
- **Card Border**: `StyleProvider.Color.borderColor` (subtle)
- **Shadow Color**: `StyleProvider.Color.shadowColor`
- **Game Title**: 
  - Font: `StyleProvider.fontWith(type: .bold, size: 14)`
  - Color: `StyleProvider.Color.textPrimary`
- **Provider Name**: 
  - Font: `StyleProvider.fontWith(type: .regular, size: 12)`
  - Color: `StyleProvider.Color.textSecondary`
- **Min Stake**: 
  - Font: `StyleProvider.fontWith(type: .regular, size: 11)`
  - Color: `StyleProvider.Color.textSecondary`
- **Stars**: Golden color `#FFD700` for filled, light gray for empty
- **New Badge**: `StyleProvider.Color.primaryColor` background
- **Favorite Icon**: `StyleProvider.Color.primaryColor` when active

### UI Structure
```swift
final public class CasinoGameCardView: UIView {
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
    private let bottomStackView = UIStackView()
    private let starsStackView = UIStackView()
    private let minStakeLabel = UILabel()
    
    // Overlay elements
    private let newBadgeView = UIView()
    private let newBadgeLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private let selectionOverlay = UIView()
    
    // Star views (created dynamically)
    private var starImageViews: [UIImageView] = []
    
    // MARK: - Properties
    public var onGameSelected: ((String) -> Void) = { _ in }
    public var onFavoriteToggled: ((String, Bool) -> Void) = { _, _ in }
}
```

### Image Loading Strategy
```swift
private func loadGameImage(from urlString: String?) {
    guard let urlString = urlString,
          let url = URL(string: urlString) else {
        showImageFailureState()
        return
    }
    
    // Show loading state
    imageLoadingIndicator.startAnimating()
    gameImageView.isHidden = true
    
    // Use URLSession or image loading library
    // Implementation will depend on project's image loading strategy
    loadImageAsync(from: url) { [weak self] result in
        DispatchQueue.main.async {
            self?.imageLoadingIndicator.stopAnimating()
            
            switch result {
            case .success(let image):
                self?.gameImageView.image = image
                self?.gameImageView.isHidden = false
                self?.hideImageFailureState()
                self?.viewModel.imageLoadingSucceeded()
                
            case .failure:
                self?.showImageFailureState()
                self?.viewModel.imageLoadingFailed()
            }
        }
    }
}

private func showImageFailureState() {
    gameImageView.isHidden = true
    imageFailureView.isHidden = false
    imageFailureLabel.text = "No Image"
}
```

### Star Rating Display
```swift
private func updateStarRating(_ rating: Double) {
    // Clear existing stars
    starImageViews.forEach { $0.removeFromSuperview() }
    starImageViews.removeAll()
    
    // Create 5 star views
    for i in 0..<5 {
        let starImageView = UIImageView()
        starImageView.contentMode = .scaleAspectFit
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            starImageView.widthAnchor.constraint(equalToConstant: Constants.starSize),
            starImageView.heightAnchor.constraint(equalToConstant: Constants.starSize)
        ])
        
        // Determine star state based on rating
        let starValue = Double(i) + 1.0
        if rating >= starValue {
            // Full star
            starImageView.image = UIImage(systemName: "star.fill")
            starImageView.tintColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Gold
        } else if rating >= starValue - 0.5 {
            // Half star
            starImageView.image = UIImage(systemName: "star.leadinghalf.filled")
            starImageView.tintColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Gold
        } else {
            // Empty star
            starImageView.image = UIImage(systemName: "star")
            starImageView.tintColor = StyleProvider.Color.textTertiary
        }
        
        starsStackView.addArrangedSubview(starImageView)
        starImageViews.append(starImageView)
    }
}
```

## State Management

### Display States
1. **Normal State**: All content visible, no loading
2. **Loading State**: Image loading indicator visible
3. **Image Failed State**: Placeholder shown for image
4. **Selected State**: Selection overlay visible
5. **New Game State**: "NEW" badge visible
6. **Favorite State**: Favorite heart icon filled

### Reactive Updates
```swift
private func setupBindings() {
    viewModel.displayStatePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] displayState in
            self?.render(displayState: displayState)
        }
        .store(in: &cancellables)
    
    // Individual property bindings for performance
    viewModel.gameNamePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] name in
            self?.gameTitleLabel.text = name
        }
        .store(in: &cancellables)
    
    viewModel.providerNamePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] provider in
            self?.providerLabel.text = provider
        }
        .store(in: &cancellables)
    
    viewModel.ratingPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] rating in
            self?.updateStarRating(rating)
        }
        .store(in: &cancellables)
    
    viewModel.minStakePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] minStake in
            self?.minStakeLabel.text = "Min Stake: \(minStake)"
        }
        .store(in: &cancellables)
}
```

## Mock ViewModel

```swift
final public class MockCasinoGameCardViewModel: CasinoGameCardViewModelProtocol {
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<CasinoGameCardDisplayState, Never>
    private var currentGameData: CasinoGameCardData
    
    public var gameId: String { currentGameData.id }
    public var category: String { currentGameData.category }
    
    // MARK: - Initialization
    public init(gameData: CasinoGameCardData, initialState: CasinoGameCardDisplayState? = nil) {
        self.currentGameData = gameData
        
        let state = initialState ?? CasinoGameCardDisplayState(
            gameData: gameData,
            showNewBadge: gameData.isNew,
            showFavoriteIcon: gameData.isFavorite
        )
        
        self.displayStateSubject = CurrentValueSubject(state)
    }
    
    // MARK: - Mock Factory Methods
    public static var plinkGoal: MockCasinoGameCardViewModel {
        let gameData = CasinoGameCardData(
            id: "plink-goal",
            name: "PlinkGoal",
            provider: "Gaming Corps",
            localImageName: "plink_goal_preview", // Bundled fallback image
            rating: 3.0,
            minStake: "1",
            currency: "XAF",
            isNew: true,
            category: "new-games"
        )
        return MockCasinoGameCardViewModel(gameData: gameData)
    }
    
    public static var beastBelow: MockCasinoGameCardViewModel {
        let gameData = CasinoGameCardData(
            id: "beast-below",
            name: "Beast Below",
            provider: "Hacksaw Gaming",
            localImageName: "beast_below_preview",
            rating: 4.5,
            minStake: "1",
            currency: "XAF",
            isNew: true,
            isFavorite: true,
            category: "new-games"
        )
        return MockCasinoGameCardViewModel(gameData: gameData)
    }
    
    public static var aviator: MockCasinoGameCardViewModel {
        let gameData = CasinoGameCardData(
            id: "aviator",
            name: "Aviator",
            provider: "Spribe",
            localImageName: "aviator_preview",
            rating: 4.0,
            minStake: "1",
            currency: "XAF",
            category: "crash-games"
        )
        return MockCasinoGameCardViewModel(gameData: gameData)
    }
    
    public static var dragonsFortuneMegaways: MockCasinoGameCardViewModel {
        let gameData = CasinoGameCardData(
            id: "dragons-fortune-megaways",
            name: "Dragon's Fortune Megaways",
            provider: "Nolimit City",
            localImageName: "dragons_fortune_preview",
            rating: 4.5,
            minStake: "1",
            currency: "XAF",
            category: "trending"
        )
        return MockCasinoGameCardViewModel(gameData: gameData)
    }
    
    public static var jetX: MockCasinoGameCardViewModel {
        let gameData = CasinoGameCardData(
            id: "jetx",
            name: "JetX",
            provider: "SmartSoft Gaming",
            localImageName: "jetx_preview",
            rating: 3.5,
            minStake: "1",
            currency: "XAF",
            category: "crash-games"
        )
        return MockCasinoGameCardViewModel(gameData: gameData)
    }
    
    // Loading state examples
    public static var loadingGame: MockCasinoGameCardViewModel {
        let gameData = CasinoGameCardData(
            id: "loading-game",
            name: "Loading Game",
            provider: "Provider",
            rating: 0.0,
            minStake: "1",
            category: "new-games"
        )
        let state = CasinoGameCardDisplayState(
            gameData: gameData,
            isLoading: true
        )
        return MockCasinoGameCardViewModel(gameData: gameData, initialState: state)
    }
    
    public static var imageFailedGame: MockCasinoGameCardViewModel {
        let gameData = CasinoGameCardData(
            id: "image-failed-game",
            name: "Image Failed Game",
            provider: "Provider",
            rating: 2.5,
            minStake: "1",
            category: "new-games"
        )
        let state = CasinoGameCardDisplayState(
            gameData: gameData,
            imageLoadingFailed: true
        )
        return MockCasinoGameCardViewModel(gameData: gameData, initialState: state)
    }
}
```

## SwiftUI Previews

```swift
// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Casino Game Card - PlinkGoal") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let gameCardView = CasinoGameCardView(viewModel: MockCasinoGameCardViewModel.plinkGoal)
        gameCardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(gameCardView)
        
        NSLayoutConstraint.activate([
            gameCardView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            gameCardView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            gameCardView.widthAnchor.constraint(equalToConstant: 160),
            gameCardView.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Game Card - Beast Below") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let gameCardView = CasinoGameCardView(viewModel: MockCasinoGameCardViewModel.beastBelow)
        gameCardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(gameCardView)
        
        NSLayoutConstraint.activate([
            gameCardView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            gameCardView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            gameCardView.widthAnchor.constraint(equalToConstant: 160),
            gameCardView.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Game Card - Aviator") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let gameCardView = CasinoGameCardView(viewModel: MockCasinoGameCardViewModel.aviator)
        gameCardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(gameCardView)
        
        NSLayoutConstraint.activate([
            gameCardView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            gameCardView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            gameCardView.widthAnchor.constraint(equalToConstant: 160),
            gameCardView.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Game Card - Dragon's Fortune") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let gameCardView = CasinoGameCardView(viewModel: MockCasinoGameCardViewModel.dragonsFortuneMegaways)
        gameCardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(gameCardView)
        
        NSLayoutConstraint.activate([
            gameCardView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            gameCardView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            gameCardView.widthAnchor.constraint(equalToConstant: 160),
            gameCardView.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Game Card - Loading State") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let gameCardView = CasinoGameCardView(viewModel: MockCasinoGameCardViewModel.loadingGame)
        gameCardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(gameCardView)
        
        NSLayoutConstraint.activate([
            gameCardView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            gameCardView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            gameCardView.widthAnchor.constraint(equalToConstant: 160),
            gameCardView.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Game Card - Image Failed") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let gameCardView = CasinoGameCardView(viewModel: MockCasinoGameCardViewModel.imageFailedGame)
        gameCardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(gameCardView)
        
        NSLayoutConstraint.activate([
            gameCardView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            gameCardView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            gameCardView.widthAnchor.constraint(equalToConstant: 160),
            gameCardView.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        return vc
    }
}

#endif
```

## Demo Integration

### Demo View Controller
Create `CasinoGameCardViewController.swift` in TestCase directory:

```swift
import UIKit
import Combine
import GomaUI

class CasinoGameCardViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Casino Game Cards"
        setupViews()
        createDemoCards()
    }
    
    private func setupViews() {
        view.backgroundColor = StyleProvider.Color.backgroundColor
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.alignment = .center
        
        scrollView.addSubview(contentStackView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func createDemoCards() {
        // Single cards section
        addSectionHeader("Individual Cards")
        let singleCardsStack = createHorizontalStack()
        
        [MockCasinoGameCardViewModel.plinkGoal,
         MockCasinoGameCardViewModel.beastBelow,
         MockCasinoGameCardViewModel.aviator].forEach { mockViewModel in
            let cardView = CasinoGameCardView(viewModel: mockViewModel)
            cardView.onGameSelected = { gameId in
                self.showAlert(title: "Game Selected", message: "Game ID: \(gameId)")
            }
            cardView.onFavoriteToggled = { gameId, isFavorite in
                self.showAlert(title: "Favorite Toggled", message: "Game ID: \(gameId), Favorite: \(isFavorite)")
            }
            singleCardsStack.addArrangedSubview(cardView)
        }
        contentStackView.addArrangedSubview(singleCardsStack)
        
        // State examples section
        addSectionHeader("Different States")
        let statesStack = createHorizontalStack()
        
        [MockCasinoGameCardViewModel.loadingGame,
         MockCasinoGameCardViewModel.imageFailedGame,
         MockCasinoGameCardViewModel.dragonsFortuneNegaways].forEach { mockViewModel in
            let cardView = CasinoGameCardView(viewModel: mockViewModel)
            statesStack.addArrangedSubview(cardView)
        }
        contentStackView.addArrangedSubview(statesStack)
    }
    
    private func addSectionHeader(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        contentStackView.addArrangedSubview(label)
    }
    
    private func createHorizontalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
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
    title: "Casino Game Card",
    description: "Individual casino game display with image, rating, and game details",
    viewController: CasinoGameCardViewController.self,
    previewFactory: {
        let viewModel = MockCasinoGameCardViewModel.plinkGoal
        return CasinoGameCardView(viewModel: viewModel)
    }
)
```

## Accessibility

### VoiceOver Support
```swift
private func setupAccessibility() {
    // Make the entire card a single accessible element
    isAccessibilityElement = true
    accessibilityTraits = .button
    
    // Update accessibility label based on game data
    viewModel.displayStatePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] displayState in
            let gameData = displayState.gameData
            let rating = "\(gameData.rating) out of 5 stars"
            let stake = "Minimum stake \(gameData.minStake) \(gameData.currency)"
            
            self?.accessibilityLabel = "\(gameData.name), by \(gameData.provider), \(rating), \(stake)"
            
            if displayState.showNewBadge {
                self?.accessibilityLabel += ", New game"
            }
            
            if displayState.showFavoriteIcon {
                self?.accessibilityLabel += ", Favorite"
            }
        }
        .store(in: &cancellables)
}
```

### Dynamic Type Support
```swift
private func setupDynamicType() {
    // Observe content size category changes
    NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.updateFontsForCurrentContentSize()
        }
        .store(in: &cancellables)
}

private func updateFontsForCurrentContentSize() {
    gameTitleLabel.font = StyleProvider.fontWith(type: .bold, size: 14)
    providerLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
    minStakeLabel.font = StyleProvider.fontWith(type: .regular, size: 11)
}
```

## Performance Considerations

- **Image Loading**: Async loading with proper cancellation
- **Memory Management**: Proper cleanup of image references
- **Reuse**: Designed for UICollectionView reuse
- **Layout Optimization**: Minimal constraint changes during updates
- **Star Rating**: Efficient star view creation and updates

## Testing Considerations

### Unit Tests
- Star rating calculation and display
- Image loading state transitions
- Accessibility label generation
- Favorite state toggling
- Mock view model state changes

### UI Tests
- Card tap interactions
- Favorite button functionality
- Image placeholder display
- Rating star visibility
- Text truncation handling

## Implementation Files

```
CasinoGameCardView/
├── CasinoGameCardViewModelProtocol.swift
├── CasinoGameCardView.swift
├── MockCasinoGameCardViewModel.swift
└── Documentation/
    └── README.md
```

## Success Criteria

- [ ] Matches Figma design exactly
- [ ] Smooth image loading with proper fallbacks
- [ ] Accurate star rating display (including half stars)
- [ ] Proper favorite state handling
- [ ] Comprehensive preview states showing all scenarios
- [ ] Demo app integration working perfectly
- [ ] Accessibility support complete (VoiceOver, Dynamic Type)
- [ ] Performance optimized for collection view usage
- [ ] Proper memory management in image loading