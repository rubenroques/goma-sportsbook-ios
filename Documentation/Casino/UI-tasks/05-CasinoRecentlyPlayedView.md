# CasinoRecentlyPlayedView Component Specification

## Overview

**CasinoRecentlyPlayedView** is a container component that displays the "Recently Played" section at the top of the casino screen. It shows a simple header title and a horizontal collection of recently played games using specialized `CasinoRecentlyPlayedCardView` components.

## Visual Design

Based on Figma design showing:
- "Recently Played" header text (left-aligned, no button)
- Two recently played game cards (in the example: "Gonzo's Quest" games)
- Simple horizontal layout without scrolling (limited number of items)

### Layout Structure
```
┌─────────────────────────────────────────────────────────────────────┐
│ Recently Played                                                     │
├─────────────────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────┐ ┌─────────────────────────────┐     │
│ │ [Image] Gonzo's Quest       │ │ [Image] Gonzo's Quest       │     │
│ │         Netent              │ │         Netent              │     │
│ └─────────────────────────────┘ └─────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────┘
```

### Design Elements
- **Simple Header**: Just "Recently Played" text, no action button
- **Horizontal Layout**: Stack view with `CasinoRecentlyPlayedCardView` components
- **Limited Items**: Maximum 2-3 recently played games
- **No Scrolling**: All items visible without horizontal scrolling
- **Horizontal Cards**: Uses landscape-oriented recently played cards
- **Empty State**: Placeholder when no recently played games

## Data Models

```swift
// MARK: - Data Models
public struct CasinoRecentlyPlayedData: Equatable, Hashable {
    public let recentlyPlayedGames: [CasinoRecentlyPlayedCardData]
    public let maxDisplayItems: Int
    
    public init(
        recentlyPlayedGames: [CasinoRecentlyPlayedCardData],
        maxDisplayItems: Int = 2
    ) {
        self.recentlyPlayedGames = recentlyPlayedGames
        self.maxDisplayItems = maxDisplayItems
    }
    
    // Helper computed property for sorted games by last played date
    public var sortedRecentlyPlayedGames: [CasinoRecentlyPlayedCardData] {
        return recentlyPlayedGames.sorted { game1, game2 in
            return game1.lastPlayedDate > game2.lastPlayedDate // Most recently played first
        }
    }
}

// MARK: - Display State
public struct CasinoRecentlyPlayedDisplayState: Equatable {
    public let recentlyPlayedData: CasinoRecentlyPlayedData
    public let isLoading: Bool
    public let hasError: Bool
    public let errorMessage: String?
    public let isEmpty: Bool
    
    public init(
        recentlyPlayedData: CasinoRecentlyPlayedData,
        isLoading: Bool = false,
        hasError: Bool = false,
        errorMessage: String? = nil
    ) {
        self.recentlyPlayedData = recentlyPlayedData
        self.isLoading = isLoading
        self.hasError = hasError
        self.errorMessage = errorMessage
        self.isEmpty = recentlyPlayedData.recentlyPlayedGames.isEmpty
    }
}
```

## ViewModelProtocol

```swift
public protocol CasinoRecentlyPlayedViewModelProtocol {
    // Main display state publisher
    var displayStatePublisher: AnyPublisher<CasinoRecentlyPlayedDisplayState, Never> { get }
    
    // Individual property publishers for fine-grained updates
    var recentlyPlayedGamesPublisher: AnyPublisher<[CasinoRecentlyPlayedCardData], Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var hasErrorPublisher: AnyPublisher<Bool, Never> { get }
    var isEmptyPublisher: AnyPublisher<Bool, Never> { get }
    
    // User interaction methods
    func gameSelected(_ gameId: String)
    func refreshRecentlyPlayed()
    func clearRecentlyPlayed()
    
    // Read-only properties
    var maxDisplayItems: Int { get }
}
```

## UI Specifications

### Layout Constants
```swift
private enum Constants {
    static let headerHeight: CGFloat = 40.0
    static let gameCardSpacing: CGFloat = 12.0
    static let horizontalPadding: CGFloat = 16.0
    static let verticalPadding: CGFloat = 8.0
    static let recentlyPlayedCardSize = CGSize(width: 280, height: 120) // Horizontal cards
    
    // Total height calculation
    static let totalHeight: CGFloat = headerHeight + verticalPadding + recentlyPlayedCardSize.height + verticalPadding
    
    // Empty state
    static let emptyStateHeight: CGFloat = 100.0
    static let emptyStateMessageHeight: CGFloat = 60.0
}
```

### Styling
- **Header Text**: 
  - Font: `StyleProvider.fontWith(type: .bold, size: 18)`
  - Color: `StyleProvider.Color.textPrimary`
- **Empty State Text**: 
  - Font: `StyleProvider.fontWith(type: .regular, size: 14)`
  - Color: `StyleProvider.Color.textSecondary`
- **Background**: `StyleProvider.Color.backgroundColor`

### UI Structure
```swift
final public class CasinoRecentlyPlayedView: UIView {
    // MARK: - UI Elements
    private let containerStackView = UIStackView()
    private let headerLabel = UILabel()
    private let gamesStackView = UIStackView()
    private let emptyStateView = UIView()
    private let emptyStateLabel = UILabel()
    private let loadingView = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let errorView = UIView()
    private let errorLabel = UILabel()
    
    // MARK: - Properties
    private let viewModel: CasinoRecentlyPlayedViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var recentlyPlayedCardViews: [CasinoRecentlyPlayedCardView] = []
    
    // MARK: - Callbacks
    public var onGameSelected: ((String) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: CasinoRecentlyPlayedViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

### Layout Setup
```swift
private func setupSubviews() {
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = StyleProvider.Color.backgroundColor
    
    // Container stack view
    containerStackView.axis = .vertical
    containerStackView.spacing = Constants.verticalPadding
    containerStackView.distribution = .fill
    containerStackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(containerStackView)
    
    // Header setup
    setupHeader()
    
    // Games stack view setup
    setupGamesStackView()
    
    // Empty state setup
    setupEmptyState()
    
    // Loading state setup
    setupLoadingState()
    
    // Error state setup
    setupErrorState()
    
    // Constraints
    NSLayoutConstraint.activate([
        containerStackView.topAnchor.constraint(equalTo: topAnchor),
        containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
        containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
        containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
}

private func setupHeader() {
    headerLabel.text = "Recently Played"
    headerLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
    headerLabel.textColor = StyleProvider.Color.textPrimary
    headerLabel.translatesAutoresizingMaskIntoConstraints = false
    
    containerStackView.addArrangedSubview(headerLabel)
    
    NSLayoutConstraint.activate([
        headerLabel.heightAnchor.constraint(equalToConstant: Constants.headerHeight)
    ])
}

private func setupGamesStackView() {
    gamesStackView.axis = .horizontal
    gamesStackView.spacing = Constants.gameCardSpacing
    gamesStackView.distribution = .fillEqually
    gamesStackView.alignment = .top
    gamesStackView.translatesAutoresizingMaskIntoConstraints = false
    
    containerStackView.addArrangedSubview(gamesStackView)
    
    NSLayoutConstraint.activate([
        gamesStackView.heightAnchor.constraint(equalToConstant: Constants.gameCardSize.height)
    ])
}

private func setupEmptyState() {
    emptyStateView.translatesAutoresizingMaskIntoConstraints = false
    emptyStateView.isHidden = true
    
    emptyStateLabel.text = "No recently played games\nStart playing to see your recent games here"
    emptyStateLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
    emptyStateLabel.textColor = StyleProvider.Color.textSecondary
    emptyStateLabel.textAlignment = .center
    emptyStateLabel.numberOfLines = 0
    emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
    
    emptyStateView.addSubview(emptyStateLabel)
    containerStackView.addArrangedSubview(emptyStateView)
    
    NSLayoutConstraint.activate([
        emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
        emptyStateLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
        emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: emptyStateView.leadingAnchor, constant: 16),
        emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: emptyStateView.trailingAnchor, constant: -16),
        emptyStateView.heightAnchor.constraint(equalToConstant: Constants.emptyStateHeight)
    ])
}

private func setupLoadingState() {
    loadingView.translatesAutoresizingMaskIntoConstraints = false
    loadingView.isHidden = true
    
    loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
    loadingIndicator.hidesWhenStopped = true
    
    loadingView.addSubview(loadingIndicator)
    containerStackView.addArrangedSubview(loadingView)
    
    NSLayoutConstraint.activate([
        loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
        loadingIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor),
        loadingView.heightAnchor.constraint(equalToConstant: Constants.recentlyPlayedCardSize.height)
    ])
}

private func setupErrorState() {
    errorView.translatesAutoresizingMaskIntoConstraints = false
    errorView.isHidden = true
    
    errorLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
    errorLabel.textColor = StyleProvider.Color.textSecondary
    errorLabel.textAlignment = .center
    errorLabel.numberOfLines = 0
    errorLabel.translatesAutoresizingMaskIntoConstraints = false
    
    errorView.addSubview(errorLabel)
    containerStackView.addArrangedSubview(errorView)
    
    NSLayoutConstraint.activate([
        errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
        errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor),
        errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: errorView.leadingAnchor, constant: 16),
        errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: errorView.trailingAnchor, constant: -16),
        errorView.heightAnchor.constraint(equalToConstant: Constants.recentlyPlayedCardSize.height)
    ])
}
```

## State Management

### Display States
1. **Loading State**: Loading indicator shown
2. **Content State**: Recently played games displayed
3. **Empty State**: No recently played games message
4. **Error State**: Error message shown

### Reactive Updates
```swift
private func setupBindings() {
    viewModel.displayStatePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] displayState in
            self?.render(displayState: displayState)
        }
        .store(in: &cancellables)
    
    viewModel.recentlyPlayedGamesPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] games in
            self?.updateGameCards(games)
        }
        .store(in: &cancellables)
}

private func render(displayState: CasinoRecentlyPlayedDisplayState) {
    // Hide all state views first
    gamesStackView.isHidden = true
    emptyStateView.isHidden = true
    loadingView.isHidden = true
    errorView.isHidden = true
    
    if displayState.isLoading {
        loadingView.isHidden = false
        loadingIndicator.startAnimating()
    } else if displayState.hasError {
        errorView.isHidden = false
        errorLabel.text = displayState.errorMessage ?? "Failed to load recently played games"
    } else if displayState.isEmpty {
        emptyStateView.isHidden = false
    } else {
        gamesStackView.isHidden = false
        loadingIndicator.stopAnimating()
    }
}

private func updateGameCards(_ games: [CasinoRecentlyPlayedCardData]) {
    // Remove existing game card views
    recentlyPlayedCardViews.forEach { $0.removeFromSuperview() }
    recentlyPlayedCardViews.removeAll()
    
    // Limit to max display items
    let displayGames = Array(games.prefix(viewModel.maxDisplayItems))
    
    // Create new recently played card views
    displayGames.forEach { cardData in
        let mockViewModel = MockCasinoRecentlyPlayedCardViewModel(cardData: cardData)
        let recentlyPlayedCardView = CasinoRecentlyPlayedCardView(viewModel: mockViewModel)
        
        // Set up callbacks
        recentlyPlayedCardView.onGameSelected = { [weak self] gameId in
            self?.viewModel.gameSelected(gameId)
            self?.onGameSelected(gameId)
        }
        
        // Set fixed size
        recentlyPlayedCardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recentlyPlayedCardView.widthAnchor.constraint(equalToConstant: Constants.recentlyPlayedCardSize.width),
            recentlyPlayedCardView.heightAnchor.constraint(equalToConstant: Constants.recentlyPlayedCardSize.height)
        ])
        
        gamesStackView.addArrangedSubview(recentlyPlayedCardView)
        recentlyPlayedCardViews.append(recentlyPlayedCardView)
    }
    
    // Add spacer views if needed to maintain layout
    let emptySlots = viewModel.maxDisplayItems - displayGames.count
    for _ in 0..<emptySlots {
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.backgroundColor = UIColor.clear
        
        NSLayoutConstraint.activate([
            spacerView.widthAnchor.constraint(equalToConstant: Constants.recentlyPlayedCardSize.width),
            spacerView.heightAnchor.constraint(equalToConstant: Constants.recentlyPlayedCardSize.height)
        ])
        
        gamesStackView.addArrangedSubview(spacerView)
    }
}
```

## Mock ViewModel

```swift
final public class MockCasinoRecentlyPlayedViewModel: CasinoRecentlyPlayedViewModelProtocol {
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<CasinoRecentlyPlayedDisplayState, Never>
    private var currentRecentlyPlayedData: CasinoRecentlyPlayedData
    
    public var maxDisplayItems: Int { currentRecentlyPlayedData.maxDisplayItems }
    
    // MARK: - Initialization
    public init(recentlyPlayedData: CasinoRecentlyPlayedData, initialState: CasinoRecentlyPlayedDisplayState? = nil) {
        self.currentRecentlyPlayedData = recentlyPlayedData
        
        let state = initialState ?? CasinoRecentlyPlayedDisplayState(recentlyPlayedData: recentlyPlayedData)
        self.displayStateSubject = CurrentValueSubject(state)
    }
    
    // MARK: - Publishers
    public var displayStatePublisher: AnyPublisher<CasinoRecentlyPlayedDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }
    
    public var recentlyPlayedGamesPublisher: AnyPublisher<[CasinoRecentlyPlayedCardData], Never> {
        displayStatePublisher
            .map { $0.recentlyPlayedData.sortedRecentlyPlayedGames }
            .eraseToAnyPublisher()
    }
    
    public var isLoadingPublisher: AnyPublisher<Bool, Never> {
        displayStatePublisher.map { $0.isLoading }.eraseToAnyPublisher()
    }
    
    public var hasErrorPublisher: AnyPublisher<Bool, Never> {
        displayStatePublisher.map { $0.hasError }.eraseToAnyPublisher()
    }
    
    public var isEmptyPublisher: AnyPublisher<Bool, Never> {
        displayStatePublisher.map { $0.isEmpty }.eraseToAnyPublisher()
    }
    
    // MARK: - Actions
    public func gameSelected(_ gameId: String) {
        print("MockCasinoRecentlyPlayedViewModel: Game selected: \(gameId)")
    }
    
    
    public func refreshRecentlyPlayed() {
        let currentState = displayStateSubject.value
        let newState = CasinoRecentlyPlayedDisplayState(
            recentlyPlayedData: currentRecentlyPlayedData,
            isLoading: true
        )
        displayStateSubject.send(newState)
        
        // Simulate refresh delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let refreshedState = CasinoRecentlyPlayedDisplayState(
                recentlyPlayedData: self.currentRecentlyPlayedData
            )
            self.displayStateSubject.send(refreshedState)
        }
    }
    
    public func clearRecentlyPlayed() {
        let emptyData = CasinoRecentlyPlayedData(
            recentlyPlayedGames: [],
            maxDisplayItems: currentRecentlyPlayedData.maxDisplayItems
        )
        currentRecentlyPlayedData = emptyData
        
        let newState = CasinoRecentlyPlayedDisplayState(recentlyPlayedData: emptyData)
        displayStateSubject.send(newState)
    }
    
    // MARK: - Mock Factory Methods
    public static var withTwoGames: MockCasinoRecentlyPlayedViewModel {
        let cards = [
            MockCasinoRecentlyPlayedCardViewModel.gonzosQuest1.cardData,
            MockCasinoRecentlyPlayedCardViewModel.gonzosQuest2.cardData
        ]
        
        let recentlyPlayedData = CasinoRecentlyPlayedData(
            recentlyPlayedGames: cards,
            maxDisplayItems: 2
        )
        
        return MockCasinoRecentlyPlayedViewModel(recentlyPlayedData: recentlyPlayedData)
    }
    
    public static var withTwoGamesAlternative: MockCasinoRecentlyPlayedViewModel {
        let cards = [
            MockCasinoRecentlyPlayedCardViewModel.beastBelow.cardData,
            MockCasinoRecentlyPlayedCardViewModel.aviator.cardData
        ]
        
        let recentlyPlayedData = CasinoRecentlyPlayedData(
            recentlyPlayedGames: cards,
            maxDisplayItems: 2
        )
        
        return MockCasinoRecentlyPlayedViewModel(recentlyPlayedData: recentlyPlayedData)
    }
    
    public static var empty: MockCasinoRecentlyPlayedViewModel {
        let recentlyPlayedData = CasinoRecentlyPlayedData(
            recentlyPlayedGames: [],
            maxDisplayItems: 2
        )
        
        return MockCasinoRecentlyPlayedViewModel(recentlyPlayedData: recentlyPlayedData)
    }
    
    public static var loading: MockCasinoRecentlyPlayedViewModel {
        let recentlyPlayedData = CasinoRecentlyPlayedData(
            recentlyPlayedGames: [],
            maxDisplayItems: 2
        )
        
        let state = CasinoRecentlyPlayedDisplayState(
            recentlyPlayedData: recentlyPlayedData,
            isLoading: true
        )
        
        return MockCasinoRecentlyPlayedViewModel(recentlyPlayedData: recentlyPlayedData, initialState: state)
    }
    
    public static var error: MockCasinoRecentlyPlayedViewModel {
        let recentlyPlayedData = CasinoRecentlyPlayedData(
            recentlyPlayedGames: [],
            maxDisplayItems: 2
        )
        
        let state = CasinoRecentlyPlayedDisplayState(
            recentlyPlayedData: recentlyPlayedData,
            hasError: true,
            errorMessage: "Failed to load recently played games"
        )
        
        return MockCasinoRecentlyPlayedViewModel(recentlyPlayedData: recentlyPlayedData, initialState: state)
    }
}
```

## SwiftUI Previews

```swift
// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Casino Recently Played - Two Games") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let recentlyPlayedView = CasinoRecentlyPlayedView(viewModel: MockCasinoRecentlyPlayedViewModel.withTwoGames)
        recentlyPlayedView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(recentlyPlayedView)
        
        NSLayoutConstraint.activate([
            recentlyPlayedView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            recentlyPlayedView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            recentlyPlayedView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            recentlyPlayedView.heightAnchor.constraint(equalToConstant: 200) // Adjust based on content
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Recently Played - Alternative Games") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let recentlyPlayedView = CasinoRecentlyPlayedView(viewModel: MockCasinoRecentlyPlayedViewModel.withTwoGamesAlternative)
        recentlyPlayedView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(recentlyPlayedView)
        
        NSLayoutConstraint.activate([
            recentlyPlayedView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            recentlyPlayedView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            recentlyPlayedView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            recentlyPlayedView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Recently Played - Empty State") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let recentlyPlayedView = CasinoRecentlyPlayedView(viewModel: MockCasinoRecentlyPlayedViewModel.empty)
        recentlyPlayedView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(recentlyPlayedView)
        
        NSLayoutConstraint.activate([
            recentlyPlayedView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            recentlyPlayedView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            recentlyPlayedView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            recentlyPlayedView.heightAnchor.constraint(equalToConstant: 160) // Shorter for empty state
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Recently Played - Loading State") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let recentlyPlayedView = CasinoRecentlyPlayedView(viewModel: MockCasinoRecentlyPlayedViewModel.loading)
        recentlyPlayedView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(recentlyPlayedView)
        
        NSLayoutConstraint.activate([
            recentlyPlayedView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            recentlyPlayedView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            recentlyPlayedView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            recentlyPlayedView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Casino Recently Played - Error State") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let recentlyPlayedView = CasinoRecentlyPlayedView(viewModel: MockCasinoRecentlyPlayedViewModel.error)
        recentlyPlayedView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(recentlyPlayedView)
        
        NSLayoutConstraint.activate([
            recentlyPlayedView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            recentlyPlayedView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            recentlyPlayedView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            recentlyPlayedView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        return vc
    }
}

#endif
```

## Demo Integration

### Demo View Controller
Create `CasinoRecentlyPlayedViewController.swift` in TestCase directory:

```swift
import UIKit
import Combine
import GomaUI

class CasinoRecentlyPlayedViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recently Played Casino Games"
        setupViews()
        createDemoSections()
        setupToolbar()
    }
    
    private func setupViews() {
        view.backgroundColor = StyleProvider.Color.backgroundColor
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        
        scrollView.addSubview(contentStackView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func createDemoSections() {
        let sections = [
            ("Two Games", MockCasinoRecentlyPlayedViewModel.withTwoGames),
            ("Three Games", MockCasinoRecentlyPlayedViewModel.withThreeGames),
            ("Empty State", MockCasinoRecentlyPlayedViewModel.empty),
            ("Loading State", MockCasinoRecentlyPlayedViewModel.loading),
            ("Error State", MockCasinoRecentlyPlayedViewModel.error)
        ]
        
        sections.forEach { title, mockViewModel in
            // Add section title
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
            titleLabel.textColor = StyleProvider.Color.textPrimary
            contentStackView.addArrangedSubview(titleLabel)
            
            // Add recently played view
            let recentlyPlayedView = CasinoRecentlyPlayedView(viewModel: mockViewModel)
            
            recentlyPlayedView.onGameSelected = { [weak self] gameId in
                self?.showAlert(title: "Game Selected", message: "Game: \(gameId)")
            }
            
            recentlyPlayedView.onFavoriteToggled = { [weak self] gameId, isFavorite in
                self?.showAlert(title: "Favorite Toggled", message: "Game: \(gameId), Favorite: \(isFavorite)")
            }
            
            contentStackView.addArrangedSubview(recentlyPlayedView)
        }
    }
    
    private func setupToolbar() {
        // Add refresh button to test refresh functionality
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshTapped)
        )
    }
    
    @objc private func refreshTapped() {
        // Refresh the first section for demo purposes
        if let firstRecentlyPlayedView = contentStackView.arrangedSubviews.compactMap({ $0 as? CasinoRecentlyPlayedView }).first {
            // Would call refresh on the view model if this was a real implementation
            showAlert(title: "Refresh", message: "Refresh functionality would be implemented in a real scenario")
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
    title: "Casino Recently Played",
    description: "Section showing recently played casino games with header and horizontal layout",
    viewController: CasinoRecentlyPlayedViewController.self,
    previewFactory: {
        let viewModel = MockCasinoRecentlyPlayedViewModel.withTwoGames
        return CasinoRecentlyPlayedView(viewModel: viewModel)
    }
)
```

## Accessibility

### VoiceOver Support
```swift
private func setupAccessibility() {
    // Header accessibility
    headerLabel.accessibilityTraits = .header
    
    // Empty state accessibility
    emptyStateView.isAccessibilityElement = true
    emptyStateView.accessibilityLabel = "Recently played games section is empty"
    emptyStateView.accessibilityHint = "Start playing games to see them appear here"
    
    // Loading state accessibility
    loadingView.isAccessibilityElement = true
    loadingView.accessibilityLabel = "Loading recently played games"
    
    // Error state accessibility
    errorView.isAccessibilityElement = true
    errorView.accessibilityTraits = .staticText
}
```

## Performance Considerations

- **Limited Items**: Maximum 2 games prevents performance issues
- **No Scrolling**: Fixed layout eliminates scroll performance concerns
- **Efficient Updates**: Individual recently played card updates without full reload
- **Memory Management**: Proper cleanup of recently played card views
- **Fast Loading**: Simple layout with minimal complexity
- **Horizontal Cards**: Optimized landscape card layout

## Implementation Files

```
CasinoRecentlyPlayedView/
├── CasinoRecentlyPlayedViewModelProtocol.swift
├── CasinoRecentlyPlayedView.swift
├── MockCasinoRecentlyPlayedViewModel.swift
└── Documentation/
    └── README.md
```

## Success Criteria

- [ ] Displays recently played games using `CasinoRecentlyPlayedCardView` components
- [ ] Shows appropriate empty state when no games
- [ ] Loading and error states handled gracefully
- [ ] Game selection callbacks work correctly
- [ ] Proper date-based sorting of games (most recent first)
- [ ] Demo app shows all different states
- [ ] Accessibility support complete
- [ ] Memory usage optimized for small number of items (max 2)
- [ ] Integration with recently played card components working properly
- [ ] Horizontal landscape card layout displays correctly