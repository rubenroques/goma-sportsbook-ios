# CasinoGameCollectionViewCell Component Specification

## Overview

**CasinoGameCollectionViewCell** is a simple wrapper component that embeds a `CasinoGameCardView` within a `UICollectionViewCell`. This allows the reusable game card to be used in collection views while maintaining separation of concerns.

## Design Philosophy

This component follows the **composition over inheritance** principle:
- The cell doesn't duplicate game card logic
- It simply provides a UICollectionViewCell container
- All game-related logic remains in CasinoGameCardView
- The cell handles collection view-specific requirements (reuse, selection, etc.)

## Visual Design

The cell's appearance is entirely determined by the contained `CasinoGameCardView`. The cell itself provides:
- Proper margins/insets if needed
- Collection view selection handling
- Reuse preparation

### Layout Structure
```
┌─ UICollectionViewCell ──────────────────────┐
│ ┌─ CasinoGameCardView ───────────────────┐ │
│ │                                       │ │
│ │          [Game Card Content]          │ │
│ │                                       │ │
│ └───────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

## Data Models

The cell uses the same data models as `CasinoGameCardView`:

```swift
// Re-exported from CasinoGameCardView for convenience
public typealias CasinoGameCellData = CasinoGameCardData
public typealias CasinoGameCellDisplayState = CasinoGameCardDisplayState
```

## ViewModelProtocol

The cell uses the same view model protocol as the game card:

```swift
// The cell uses the game card's view model protocol directly
public typealias CasinoGameCollectionViewCellViewModelProtocol = CasinoGameCardViewModelProtocol
```

## UI Specifications

### Layout Constants
```swift
private enum Constants {
    static let cellMarginTop: CGFloat = 0.0
    static let cellMarginLeading: CGFloat = 0.0
    static let cellMarginTrailing: CGFloat = 0.0
    static let cellMarginBottom: CGFloat = 0.0
    
    // Standard cell size (matches game card size)
    static let cellWidth: CGFloat = 160.0
    static let cellHeight: CGFloat = 220.0
}
```

### UI Structure
```swift
final public class CasinoGameCollectionViewCell: UICollectionViewCell {
    // MARK: - Public Properties
    public static let reuseIdentifier = "CasinoGameCollectionViewCell"
    
    // MARK: - Private Properties
    private var gameCardView: CasinoGameCardView?
    private var currentViewModel: CasinoGameCardViewModelProtocol?
    
    // MARK: - Callbacks
    public var onGameSelected: ((String) -> Void) = { _ in }
    public var onFavoriteToggled: ((String, Bool) -> Void) = { _, _ in }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    // MARK: - UICollectionViewCell Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Remove existing game card view
        gameCardView?.removeFromSuperview()
        gameCardView = nil
        currentViewModel = nil
        
        // Reset callbacks
        onGameSelected = { _ in }
        onFavoriteToggled = { _, _ in }
    }
    
    // MARK: - Configuration
    public func configure(with viewModel: CasinoGameCardViewModelProtocol) {
        // Remove any existing card view
        gameCardView?.removeFromSuperview()
        
        // Create new game card view
        let cardView = CasinoGameCardView(viewModel: viewModel)
        
        // Set up callbacks
        cardView.onGameSelected = { [weak self] gameId in
            self?.onGameSelected(gameId)
        }
        
        cardView.onFavoriteToggled = { [weak self] gameId, isFavorite in
            self?.onFavoriteToggled(gameId, isFavorite)
        }
        
        // Add to content view
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.cellMarginTop),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.cellMarginLeading),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.cellMarginTrailing),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.cellMarginBottom)
        ])
        
        // Store references
        self.gameCardView = cardView
        self.currentViewModel = viewModel
    }
    
    // MARK: - Private Methods
    private func setupCell() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        // Disable selection highlighting (handled by game card)
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.clear
    }
}
```

## Collection View Integration Helper

### Size Calculation
```swift
extension CasinoGameCollectionViewCell {
    public static var standardSize: CGSize {
        return CGSize(
            width: Constants.cellWidth,
            height: Constants.cellHeight
        )
    }
    
    public static func sizeForContent() -> CGSize {
        return standardSize
    }
}
```

### Collection View Flow Layout Support
```swift
extension CasinoGameCollectionViewCell {
    public static func configureFlowLayout(_ layout: UICollectionViewFlowLayout) {
        layout.itemSize = standardSize
        layout.minimumInteritemSpacing = 12.0
        layout.minimumLineSpacing = 16.0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
```

## Mock Support

Since this cell is just a wrapper, it uses the same mock view models from `CasinoGameCardView`:

```swift
extension CasinoGameCollectionViewCell {
    // MARK: - Mock Configuration Helpers
    
    public static func configureMockCell(_ cell: CasinoGameCollectionViewCell, 
                                       with mockType: MockCasinoGameCardViewModel.MockType) {
        let mockViewModel: MockCasinoGameCardViewModel
        
        switch mockType {
        case .plinkGoal:
            mockViewModel = MockCasinoGameCardViewModel.plinkGoal
        case .beastBelow:
            mockViewModel = MockCasinoGameCardViewModel.beastBelow
        case .aviator:
            mockViewModel = MockCasinoGameCardViewModel.aviator
        case .dragonsFortune:
            mockViewModel = MockCasinoGameCardViewModel.dragonsFortuneMegaways
        case .jetX:
            mockViewModel = MockCasinoGameCardViewModel.jetX
        }
        
        cell.configure(with: mockViewModel)
    }
}

extension MockCasinoGameCardViewModel {
    public enum MockType: CaseIterable {
        case plinkGoal
        case beastBelow
        case aviator
        case dragonsFortune
        case jetX
    }
}
```

## Usage Examples

### In Collection View Controller
```swift
class CasinoGamesCollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var gameViewModels: [CasinoGameCardViewModelProtocol] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        // Register cell
        collectionView.register(
            CasinoGameCollectionViewCell.self,
            forCellWithReuseIdentifier: CasinoGameCollectionViewCell.reuseIdentifier
        )
        
        // Configure flow layout
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            CasinoGameCollectionViewCell.configureFlowLayout(flowLayout)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CasinoGamesCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CasinoGameCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! CasinoGameCollectionViewCell
        
        let viewModel = gameViewModels[indexPath.item]
        cell.configure(with: viewModel)
        
        // Set up callbacks
        cell.onGameSelected = { [weak self] gameId in
            self?.handleGameSelection(gameId)
        }
        
        cell.onFavoriteToggled = { [weak self] gameId, isFavorite in
            self?.handleFavoriteToggle(gameId, isFavorite: isFavorite)
        }
        
        return cell
    }
}
```

## SwiftUI Previews

```swift
// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Casino Game Collection Cell - Single Card") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        // Create a mini collection view for preview
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 160, height: 220)
        layout.minimumInteritemSpacing = 12
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Register cell
        collectionView.register(
            CasinoGameCollectionViewCell.self,
            forCellWithReuseIdentifier: CasinoGameCollectionViewCell.reuseIdentifier
        )
        
        // Simple data source for preview
        let mockViewModel = MockCasinoGameCardViewModel.plinkGoal
        
        // Set data source
        collectionView.dataSource = PreviewCollectionDataSource(mockViewModels: [mockViewModel])
        
        vc.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 252) // 220 + padding
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Game Collection Cell - Multiple Cards") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        // Create a collection view for preview
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 160, height: 220)
        layout.minimumInteritemSpacing = 12
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        
        // Register cell
        collectionView.register(
            CasinoGameCollectionViewCell.self,
            forCellWithReuseIdentifier: CasinoGameCollectionViewCell.reuseIdentifier
        )
        
        // Multiple mock view models
        let mockViewModels = [
            MockCasinoGameCardViewModel.plinkGoal,
            MockCasinoGameCardViewModel.beastBelow,
            MockCasinoGameCardViewModel.aviator
        ]
        
        // Set data source
        collectionView.dataSource = PreviewCollectionDataSource(mockViewModels: mockViewModels)
        
        vc.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 252) // 220 + padding
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Game Collection Cell - Different States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        // Create a collection view for preview
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 160, height: 220)
        layout.minimumInteritemSpacing = 12
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        
        // Register cell
        collectionView.register(
            CasinoGameCollectionViewCell.self,
            forCellWithReuseIdentifier: CasinoGameCollectionViewCell.reuseIdentifier
        )
        
        // Different states mock view models
        let mockViewModels = [
            MockCasinoGameCardViewModel.plinkGoal,
            MockCasinoGameCardViewModel.loadingGame,
            MockCasinoGameCardViewModel.imageFailedGame
        ]
        
        // Set data source
        collectionView.dataSource = PreviewCollectionDataSource(mockViewModels: mockViewModels)
        
        vc.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 252) // 220 + padding
        ])
        
        return vc
    }
}

// MARK: - Preview Helper Data Source
private class PreviewCollectionDataSource: NSObject, UICollectionViewDataSource {
    private let mockViewModels: [MockCasinoGameCardViewModel]
    
    init(mockViewModels: [MockCasinoGameCardViewModel]) {
        self.mockViewModels = mockViewModels
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mockViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CasinoGameCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! CasinoGameCollectionViewCell
        
        let viewModel = mockViewModels[indexPath.item]
        cell.configure(with: viewModel)
        
        return cell
    }
}

#endif
```

## Demo Integration

### Demo View Controller
Create `CasinoGameCollectionViewCellViewController.swift` in TestCase directory:

```swift
import UIKit
import Combine
import GomaUI

class CasinoGameCollectionViewCellViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var gameViewModels: [MockCasinoGameCardViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Casino Game Collection Cells"
        setupCollectionView()
        setupMockData()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        CasinoGameCollectionViewCell.configureFlowLayout(layout)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = StyleProvider.Color.backgroundColor
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register cell
        collectionView.register(
            CasinoGameCollectionViewCell.self,
            forCellWithReuseIdentifier: CasinoGameCollectionViewCell.reuseIdentifier
        )
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupMockData() {
        gameViewModels = [
            MockCasinoGameCardViewModel.plinkGoal,
            MockCasinoGameCardViewModel.beastBelow,
            MockCasinoGameCardViewModel.aviator,
            MockCasinoGameCardViewModel.dragonsFortuneMegaways,
            MockCasinoGameCardViewModel.jetX,
            MockCasinoGameCardViewModel.loadingGame,
            MockCasinoGameCardViewModel.imageFailedGame
        ]
    }
    
    private func handleGameSelection(_ gameId: String) {
        let alert = UIAlertController(
            title: "Game Selected",
            message: "Game ID: \(gameId)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func handleFavoriteToggle(_ gameId: String, isFavorite: Bool) {
        let alert = UIAlertController(
            title: "Favorite Toggled",
            message: "Game ID: \(gameId)\nFavorite: \(isFavorite)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension CasinoGameCollectionViewCellViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CasinoGameCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as! CasinoGameCollectionViewCell
        
        let viewModel = gameViewModels[indexPath.item]
        cell.configure(with: viewModel)
        
        cell.onGameSelected = { [weak self] gameId in
            self?.handleGameSelection(gameId)
        }
        
        cell.onFavoriteToggled = { [weak self] gameId, isFavorite in
            self?.handleFavoriteToggle(gameId, isFavorite: isFavorite)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CasinoGameCollectionViewCellViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Selection is handled by the game card view itself
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
```

### Gallery Integration
Add to `ComponentsTableViewController.swift`:

```swift
UIComponent(
    title: "Casino Game Collection Cell",
    description: "UICollectionViewCell wrapper for casino game cards with proper reuse handling",
    viewController: CasinoGameCollectionViewCellViewController.self,
    previewFactory: {
        // Create a mini collection view for preview
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 70, height: 90) // Scaled down for preview
        layout.minimumInteritemSpacing = 6
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a simple data source for preview
        let mockViewModels = [
            MockCasinoGameCardViewModel.plinkGoal,
            MockCasinoGameCardViewModel.beastBelow,
            MockCasinoGameCardViewModel.aviator
        ]
        
        // Simple preview implementation
        let previewController = CasinoGameCollectionViewPreviewController(
            collectionView: collectionView,
            mockViewModels: mockViewModels
        )
        
        // Size constraint for preview
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        return collectionView
    }
)
```

## Performance Considerations

### Cell Reuse Optimization
- **Proper Cleanup**: `prepareForReuse()` removes existing game card view
- **Callback Reset**: Prevents memory leaks from retained closures
- **Lightweight**: No heavy operations in cell configuration
- **Fast Creation**: Game card view created only when needed

### Memory Management
- **Weak References**: Used in callbacks to prevent retain cycles
- **View Cleanup**: Old views removed before adding new ones
- **ViewModel References**: Cleared on reuse to prevent memory leaks

## Testing Considerations

### Unit Tests
- Cell configuration with different view models
- Proper cleanup during reuse
- Callback forwarding functionality
- Size calculation methods

### UI Tests
- Collection view scrolling performance
- Cell selection handling
- Reuse behavior verification
- Memory usage under stress

## Implementation Files

```
CasinoGameCollectionViewCell/
├── CasinoGameCollectionViewCell.swift
└── Documentation/
    └── README.md
```

**Note**: This component doesn't need a separate ViewModelProtocol or MockViewModel since it directly reuses those from CasinoGameCardView.

## Success Criteria

- [ ] Proper cell reuse without visual glitches
- [ ] Callback forwarding works correctly
- [ ] Memory management is leak-free
- [ ] Size calculations are accurate
- [ ] Demo app integration shows smooth scrolling
- [ ] Performance is optimized for large collections
- [ ] Collection view integration is seamless

## Relationship with Other Components

### Dependencies
- **CasinoGameCardView**: The wrapped component
- **CasinoGameCardViewModelProtocol**: View model interface
- **MockCasinoGameCardViewModel**: For testing and demos

### Used By
- **CasinoCategoryScrollView**: For horizontal game scrolling
- Any collection view that displays casino games

This wrapper component maintains the separation of concerns while enabling the reusable game card to work within UICollectionView contexts.