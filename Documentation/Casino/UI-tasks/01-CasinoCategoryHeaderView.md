# CasinoCategoryHeaderView Component Specification

## Overview

**CasinoCategoryHeaderView** is a leaf component that displays casino category section headers with an optional "View All" action button.

## Visual Design

Based on Figma design: Shows "New Games" with orange "All 41 >" button on the right.

### Layout Structure
```
┌─────────────────────────────────────────────────┐
│ Category Name                      All X > │
│ [Bold Text]                       [Button]  │
└─────────────────────────────────────────────────┘
```

### Design Elements
- **Category Title**: Left-aligned, bold typography
- **Count Button**: Right-aligned, orange background, shows count and arrow
- **Full Width**: Spans container width
- **Consistent Height**: Fixed height for visual consistency

## Data Models

```swift
// MARK: - Data Models
public struct CasinoCategoryHeaderData: Equatable, Hashable, Identifiable {
    public let id: String
    public let categoryName: String
    public let gameCount: Int
    public let showAllButton: Bool
    
    public init(
        id: String,
        categoryName: String,
        gameCount: Int,
        showAllButton: Bool = true
    ) {
        self.id = id
        self.categoryName = categoryName
        self.gameCount = gameCount
        self.showAllButton = showAllButton
    }
}

// MARK: - Display State
public struct CasinoCategoryHeaderDisplayState: Equatable {
    public let headerData: CasinoCategoryHeaderData
    public let isLoading: Bool
    
    public init(
        headerData: CasinoCategoryHeaderData,
        isLoading: Bool = false
    ) {
        self.headerData = headerData
        self.isLoading = isLoading
    }
}
```

## ViewModelProtocol

```swift
public protocol CasinoCategoryHeaderViewModelProtocol {
    // Publishers for reactive updates
    var displayStatePublisher: AnyPublisher<CasinoCategoryHeaderDisplayState, Never> { get }
    
    // Individual property publishers for fine-grained updates
    var categoryNamePublisher: AnyPublisher<String, Never> { get }
    var gameCountPublisher: AnyPublisher<Int, Never> { get }
    var showAllButtonPublisher: AnyPublisher<Bool, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    
    // User interaction methods
    func viewAllTapped()
    func updateGameCount(_ count: Int)
}
```

## UI Specifications

### Layout Constants
```swift
private enum Constants {
    static let height: CGFloat = 56.0
    static let horizontalPadding: CGFloat = 16.0
    static let verticalPadding: CGFloat = 12.0
    static let buttonCornerRadius: CGFloat = 16.0
    static let buttonHorizontalPadding: CGFloat = 12.0
    static let buttonMinWidth: CGFloat = 60.0
}
```

### Styling
- **Background**: `StyleProvider.Color.backgroundColor`
- **Category Text**: 
  - Font: `StyleProvider.fontWith(type: .bold, size: 18)`
  - Color: `StyleProvider.Color.textPrimary`
- **Button**:
  - Background: `StyleProvider.Color.primaryColor` (orange)
  - Text Color: `StyleProvider.Color.contrastTextColor` (white)
  - Font: `StyleProvider.fontWith(type: .semibold, size: 14)`

### UI Structure
```swift
final public class CasinoCategoryHeaderView: UIView {
    // MARK: - UI Elements
    private let containerView = UIView()
    private let categoryLabel = UILabel()
    private let viewAllButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Properties
    public var onViewAllTapped: ((String) -> Void) = { _ in }
}
```

### Constraints Layout
```swift
private func setupConstraints() {
    NSLayoutConstraint.activate([
        // Container constraints
        containerView.topAnchor.constraint(equalTo: topAnchor),
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
        containerView.heightAnchor.constraint(equalToConstant: Constants.height),
        
        // Category label constraints
        categoryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.horizontalPadding),
        categoryLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        
        // View all button constraints
        viewAllButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.horizontalPadding),
        viewAllButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        viewAllButton.leadingAnchor.constraint(greaterThanOrEqualTo: categoryLabel.trailingAnchor, constant: 16),
        viewAllButton.heightAnchor.constraint(equalToConstant: 32),
        viewAllButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.buttonMinWidth),
        
        // Loading indicator constraints
        loadingIndicator.centerXAnchor.constraint(equalTo: viewAllButton.centerXAnchor),
        loadingIndicator.centerYAnchor.constraint(equalTo: viewAllButton.centerYAnchor)
    ])
}
```

## State Management

### Display States
1. **Normal State**: Category name and count button visible
2. **Loading State**: Loading indicator replaces button
3. **Hidden Button State**: Only category name visible (when showAllButton = false)

### Reactive Updates
```swift
private func setupBindings() {
    // Category name updates
    viewModel.categoryNamePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] categoryName in
            self?.categoryLabel.text = categoryName
        }
        .store(in: &cancellables)
    
    // Game count updates
    viewModel.gameCountPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] count in
            self?.updateButtonTitle(count: count)
        }
        .store(in: &cancellables)
    
    // Button visibility updates
    viewModel.showAllButtonPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] showButton in
            self?.viewAllButton.isHidden = !showButton
        }
        .store(in: &cancellables)
    
    // Loading state updates
    viewModel.isLoadingPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] isLoading in
            self?.updateLoadingState(isLoading: isLoading)
        }
        .store(in: &cancellables)
}
```

## Mock ViewModel

```swift
final public class MockCasinoCategoryHeaderViewModel: CasinoCategoryHeaderViewModelProtocol {
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<CasinoCategoryHeaderDisplayState, Never>
    
    // MARK: - Initialization
    public init(headerData: CasinoCategoryHeaderData, isLoading: Bool = false) {
        let initialState = CasinoCategoryHeaderDisplayState(
            headerData: headerData,
            isLoading: isLoading
        )
        self.displayStateSubject = CurrentValueSubject(initialState)
    }
    
    // MARK: - Mock Factory Methods
    public static var newGames: MockCasinoCategoryHeaderViewModel {
        let headerData = CasinoCategoryHeaderData(
            id: "new-games",
            categoryName: "New Games",
            gameCount: 41,
            showAllButton: true
        )
        return MockCasinoCategoryHeaderViewModel(headerData: headerData)
    }
    
    public static var liveGames: MockCasinoCategoryHeaderViewModel {
        let headerData = CasinoCategoryHeaderData(
            id: "live-games",
            categoryName: "Live Games",
            gameCount: 24,
            showAllButton: true
        )
        return MockCasinoCategoryHeaderViewModel(headerData: headerData)
    }
    
    public static var crashGames: MockCasinoCategoryHeaderViewModel {
        let headerData = CasinoCategoryHeaderData(
            id: "crash-games",
            categoryName: "Crash Games",
            gameCount: 8,
            showAllButton: true
        )
        return MockCasinoCategoryHeaderViewModel(headerData: headerData)
    }
    
    public static var trending: MockCasinoCategoryHeaderViewModel {
        let headerData = CasinoCategoryHeaderData(
            id: "trending",
            categoryName: "Trending",
            gameCount: 15,
            showAllButton: true
        )
        return MockCasinoCategoryHeaderViewModel(headerData: headerData)
    }
    
    public static var noButton: MockCasinoCategoryHeaderViewModel {
        let headerData = CasinoCategoryHeaderData(
            id: "featured",
            categoryName: "Featured Games",
            gameCount: 0,
            showAllButton: false
        )
        return MockCasinoCategoryHeaderViewModel(headerData: headerData)
    }
}
```

## SwiftUI Previews

```swift
// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Casino Category Header - New Games") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let headerView = CasinoCategoryHeaderView(viewModel: MockCasinoCategoryHeaderViewModel.newGames)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Category Header - Live Games") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let headerView = CasinoCategoryHeaderView(viewModel: MockCasinoCategoryHeaderViewModel.liveGames)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Category Header - No Button") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let headerView = CasinoCategoryHeaderView(viewModel: MockCasinoCategoryHeaderViewModel.noButton)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        return vc
    }
}

#endif
```

## Demo Integration

### Demo View Controller
Create `CasinoCategoryHeaderViewController.swift` in TestCase directory:

```swift
import UIKit
import Combine
import GomaUI

class CasinoCategoryHeaderViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Casino Category Header"
        setupViews()
        createDemoHeaders()
    }
    
    private func setupViews() {
        view.backgroundColor = StyleProvider.Color.backgroundColor
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func createDemoHeaders() {
        let examples = [
            MockCasinoCategoryHeaderViewModel.newGames,
            MockCasinoCategoryHeaderViewModel.liveGames,
            MockCasinoCategoryHeaderViewModel.crashGames,
            MockCasinoCategoryHeaderViewModel.trending,
            MockCasinoCategoryHeaderViewModel.noButton
        ]
        
        examples.forEach { mockViewModel in
            let headerView = CasinoCategoryHeaderView(viewModel: mockViewModel)
            headerView.onViewAllTapped = { categoryId in
                self.showAlert(title: "View All Tapped", message: "Category: \(categoryId)")
            }
            stackView.addArrangedSubview(headerView)
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
    title: "Casino Category Header",
    description: "Section headers for casino game categories with optional view all button",
    viewController: CasinoCategoryHeaderViewController.self,
    previewFactory: {
        let viewModel = MockCasinoCategoryHeaderViewModel.newGames
        return CasinoCategoryHeaderView(viewModel: viewModel)
    }
)
```

## Accessibility

### VoiceOver Support
- Category name should be readable
- Button should announce action and count
- Loading state should be announced

```swift
private func setupAccessibility() {
    containerView.isAccessibilityElement = false
    categoryLabel.isAccessibilityElement = true
    viewAllButton.isAccessibilityElement = true
    
    categoryLabel.accessibilityTraits = .header
    viewAllButton.accessibilityTraits = .button
    
    // Update accessibility in binding
    viewModel.gameCountPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] count in
            self?.viewAllButton.accessibilityLabel = "View all \(count) games"
        }
        .store(in: &cancellables)
}
```

## Performance Considerations

- **Lightweight**: No heavy computations or network calls
- **Reusable**: Single instance can be reused with different view models
- **Memory Efficient**: Proper cleanup of Combine subscriptions
- **Fast Updates**: Minimal layout passes during state changes

## Testing Considerations

### Unit Tests
- Button title formatting with different counts
- Loading state transitions
- Accessibility label generation
- View model state changes

### UI Tests
- Button tap interactions
- Visual appearance verification
- Different screen sizes and orientations
- Dynamic type support

## Implementation Files

```
CasinoCategoryHeaderView/
├── CasinoCategoryHeaderViewModelProtocol.swift
├── CasinoCategoryHeaderView.swift
├── MockCasinoCategoryHeaderViewModel.swift
└── Documentation/
    └── README.md
```

## Success Criteria

- [ ] Matches Figma design exactly
- [ ] Smooth button interactions
- [ ] Proper loading state handling
- [ ] Comprehensive preview states
- [ ] Demo app integration working
- [ ] Accessibility support complete
- [ ] Performance optimized for scrolling contexts