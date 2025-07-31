# CasinoRecentlyPlayedCardView Component Specification

## Overview

**CasinoRecentlyPlayedCardView** is a specialized leaf component that displays recently played casino games in a horizontal/landscape card format. This component is distinct from the main `CasinoGameCardView` and is optimized for the "Recently Played" section.

## Visual Design

Based on the provided image showing "Gonzo's Quest" cards in the Recently Played section:
- **Horizontal/landscape orientation** (wider than tall)
- **Simplified layout** optimized for recently played context
- **Different proportions** compared to main game cards
- **Clean, minimal design** focusing on game identification

### Layout Structure
```
┌─────────────────────────────────────────────────┐
│  [Game Image]  │  Gonzo's Quest                 │
│                │  Netent                        │
│                │                                │
└─────────────────────────────────────────────────┘
```

### Design Elements
- **Game Image**: Square or landscape game artwork (left side)
- **Game Title**: Primary text (e.g., "Gonzo's Quest")
- **Provider Name**: Secondary text (e.g., "Netent")
- **Horizontal Layout**: Image left, text content right
- **Compact Size**: Optimized for recently played section

## Data Models

```swift
// MARK: - Data Models
public struct CasinoRecentlyPlayedCardData: Equatable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let provider: String
    public let imageURL: String?
    public let localImageName: String? // Fallback for bundled images
    public let lastPlayedDate: Date
    public let category: String
    
    public init(
        id: String,
        name: String,
        provider: String,
        imageURL: String? = nil,
        localImageName: String? = nil,
        lastPlayedDate: Date,
        category: String
    ) {
        self.id = id
        self.name = name
        self.provider = provider
        self.imageURL = imageURL
        self.localImageName = localImageName
        self.lastPlayedDate = lastPlayedDate
        self.category = category
    }
}

// MARK: - Display State
public struct CasinoRecentlyPlayedCardDisplayState: Equatable {
    public let cardData: CasinoRecentlyPlayedCardData
    public let isLoading: Bool
    public let imageLoadingFailed: Bool
    public let isSelected: Bool
    public let showLastPlayedInfo: Bool
    
    public init(
        cardData: CasinoRecentlyPlayedCardData,
        isLoading: Bool = false,
        imageLoadingFailed: Bool = false,
        isSelected: Bool = false,
        showLastPlayedInfo: Bool = false
    ) {
        self.cardData = cardData
        self.isLoading = isLoading
        self.imageLoadingFailed = imageLoadingFailed
        self.isSelected = isSelected
        self.showLastPlayedInfo = showLastPlayedInfo
    }
}
```

## ViewModelProtocol

```swift
public protocol CasinoRecentlyPlayedCardViewModelProtocol {
    // Main display state publisher
    var displayStatePublisher: AnyPublisher<CasinoRecentlyPlayedCardDisplayState, Never> { get }
    
    // Individual property publishers for fine-grained updates
    var gameNamePublisher: AnyPublisher<String, Never> { get }
    var providerNamePublisher: AnyPublisher<String, Never> { get }
    var imageURLPublisher: AnyPublisher<String?, Never> { get }
    var lastPlayedDatePublisher: AnyPublisher<Date, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var isSelectedPublisher: AnyPublisher<Bool, Never> { get }
    
    // User interaction methods
    func selectGame()
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
    static let cardWidth: CGFloat = 280.0  // Wider than tall
    static let cardHeight: CGFloat = 120.0 // Landscape orientation
    static let cornerRadius: CGFloat = 12.0
    static let shadowOpacity: Float = 0.1
    static let shadowRadius: CGFloat = 4.0
    static let shadowOffset = CGSize(width: 0, height: 2)
    
    // Image
    static let imageWidth: CGFloat = 100.0  // Square image
    static let imageHeight: CGFloat = 100.0
    static let imageCornerRadius: CGFloat = 8.0
    
    // Content padding
    static let contentPadding: CGFloat = 12.0
    static let imageToTextSpacing: CGFloat = 12.0
    static let titleToProviderSpacing: CGFloat = 6.0
    
    // Text area
    static let textAreaPadding: CGFloat = 8.0
}
```

### Styling
- **Card Background**: `StyleProvider.Color.backgroundColor`
- **Card Border**: `StyleProvider.Color.borderColor` (subtle)
- **Shadow Color**: `StyleProvider.Color.shadowColor`
- **Game Title**: 
  - Font: `StyleProvider.fontWith(type: .bold, size: 16)`
  - Color: `StyleProvider.Color.textPrimary`
- **Provider Name**: 
  - Font: `StyleProvider.fontWith(type: .regular, size: 14)`
  - Color: `StyleProvider.Color.textSecondary`

### UI Structure
```swift
final public class CasinoRecentlyPlayedCardView: UIView {
    // MARK: - UI Elements
    private let containerView = UIView()
    private let contentStackView = UIStackView()
    
    // Image section
    private let imageContainerView = UIView()
    private let gameImageView = UIImageView()
    private let imageLoadingIndicator = UIActivityIndicatorView(style: .medium)
    private let imageFailureView = UIView()
    private let imageFailureLabel = UILabel()
    
    // Text section
    private let textContainerView = UIView()
    private let textStackView = UIStackView()
    private let gameTitleLabel = UILabel()
    private let providerLabel = UILabel()
    
    // Overlay elements
    private let selectionOverlay = UIView()
    
    // MARK: - Properties
    private let viewModel: CasinoRecentlyPlayedCardViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Callbacks
    public var onGameSelected: ((String) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: CasinoRecentlyPlayedCardViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

### Layout Implementation
```swift
private func setupSubviews() {
    translatesAutoresizingMaskIntoConstraints = false
    
    // Container setup
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = StyleProvider.Color.backgroundColor
    containerView.layer.cornerRadius = Constants.cornerRadius
    containerView.layer.shadowColor = StyleProvider.Color.shadowColor.cgColor
    containerView.layer.shadowOpacity = Constants.shadowOpacity
    containerView.layer.shadowRadius = Constants.shadowRadius
    containerView.layer.shadowOffset = Constants.shadowOffset
    addSubview(containerView)
    
    // Content stack view (horizontal)
    contentStackView.axis = .horizontal
    contentStackView.spacing = Constants.imageToTextSpacing
    contentStackView.alignment = .center
    contentStackView.distribution = .fill
    contentStackView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(contentStackView)
    
    setupImageSection()
    setupTextSection()
    setupConstraints()
}

private func setupImageSection() {
    imageContainerView.translatesAutoresizingMaskIntoConstraints = false
    
    // Game image setup
    gameImageView.translatesAutoresizingMaskIntoConstraints = false
    gameImageView.contentMode = .scaleAspectFill
    gameImageView.clipsToBounds = true
    gameImageView.layer.cornerRadius = Constants.imageCornerRadius
    gameImageView.backgroundColor = StyleProvider.Color.imagePlaceholder
    
    // Loading indicator
    imageLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
    imageLoadingIndicator.hidesWhenStopped = true
    
    // Failure view
    imageFailureView.translatesAutoresizingMaskIntoConstraints = false
    imageFailureView.backgroundColor = StyleProvider.Color.imagePlaceholder
    imageFailureView.layer.cornerRadius = Constants.imageCornerRadius
    imageFailureView.isHidden = true
    
    imageFailureLabel.text = "?"
    imageFailureLabel.font = StyleProvider.fontWith(type: .bold, size: 24)
    imageFailureLabel.textColor = StyleProvider.Color.textTertiary
    imageFailureLabel.textAlignment = .center
    imageFailureLabel.translatesAutoresizingMaskIntoConstraints = false
    
    // Add to hierarchy
    imageContainerView.addSubview(gameImageView)
    imageContainerView.addSubview(imageLoadingIndicator)
    imageContainerView.addSubview(imageFailureView)
    imageFailureView.addSubview(imageFailureLabel)
    
    contentStackView.addArrangedSubview(imageContainerView)
    
    // Image constraints
    NSLayoutConstraint.activate([
        imageContainerView.widthAnchor.constraint(equalToConstant: Constants.imageWidth),
        imageContainerView.heightAnchor.constraint(equalToConstant: Constants.imageHeight),
        
        gameImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
        gameImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
        gameImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
        gameImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
        
        imageLoadingIndicator.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
        imageLoadingIndicator.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
        
        imageFailureView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
        imageFailureView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
        imageFailureView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
        imageFailureView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
        
        imageFailureLabel.centerXAnchor.constraint(equalTo: imageFailureView.centerXAnchor),
        imageFailureLabel.centerYAnchor.constraint(equalTo: imageFailureView.centerYAnchor)
    ])
}

private func setupTextSection() {
    textContainerView.translatesAutoresizingMaskIntoConstraints = false
    
    // Text stack view (vertical)
    textStackView.axis = .vertical
    textStackView.spacing = Constants.titleToProviderSpacing
    textStackView.alignment = .leading
    textStackView.distribution = .fill
    textStackView.translatesAutoresizingMaskIntoConstraints = false
    
    // Game title label
    gameTitleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
    gameTitleLabel.textColor = StyleProvider.Color.textPrimary
    gameTitleLabel.numberOfLines = 2
    gameTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    // Provider label
    providerLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
    providerLabel.textColor = StyleProvider.Color.textSecondary
    providerLabel.numberOfLines = 1
    providerLabel.translatesAutoresizingMaskIntoConstraints = false
    
    // Add to hierarchy
    textStackView.addArrangedSubview(gameTitleLabel)
    textStackView.addArrangedSubview(providerLabel)
    textContainerView.addSubview(textStackView)
    contentStackView.addArrangedSubview(textContainerView)
    
    // Text section constraints
    NSLayoutConstraint.activate([
        textStackView.topAnchor.constraint(greaterThanOrEqualTo: textContainerView.topAnchor, constant: Constants.textAreaPadding),
        textStackView.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),
        textStackView.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),
        textStackView.bottomAnchor.constraint(lessThanOrEqualTo: textContainerView.bottomAnchor, constant: -Constants.textAreaPadding),
        textStackView.centerYAnchor.constraint(equalTo: textContainerView.centerYAnchor)
    ])
}

private func setupConstraints() {
    NSLayoutConstraint.activate([
        // Container constraints
        containerView.topAnchor.constraint(equalTo: topAnchor),
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
        
        // Content stack view constraints
        contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.contentPadding),
        contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.contentPadding),
        contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.contentPadding),
        contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.contentPadding),
        
        // Fixed card size
        widthAnchor.constraint(equalToConstant: Constants.cardWidth),
        heightAnchor.constraint(equalToConstant: Constants.cardHeight)
    ])
}
```

## State Management

### Display States
1. **Normal State**: Game image and text displayed
2. **Loading State**: Image loading indicator visible
3. **Image Failed State**: Placeholder "?" shown for image
4. **Selected State**: Selection overlay visible

### Reactive Updates
```swift
private func setupBindings() {
    viewModel.displayStatePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] displayState in
            self?.render(displayState: displayState)
        }
        .store(in: &cancellables)
    
    // Individual property bindings
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
    
    viewModel.imageURLPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] imageURL in
            self?.loadGameImage(from: imageURL)
        }
        .store(in: &cancellables)
    
    viewModel.isSelectedPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] isSelected in
            self?.updateSelectionState(isSelected: isSelected)
        }
        .store(in: &cancellables)
}

private func render(displayState: CasinoRecentlyPlayedCardDisplayState) {
    if displayState.isLoading {
        showImageLoadingState()
    } else if displayState.imageLoadingFailed {
        showImageFailureState()
    } else {
        showNormalState()
    }
}
```

## Mock ViewModel

```swift
final public class MockCasinoRecentlyPlayedCardViewModel: CasinoRecentlyPlayedCardViewModelProtocol {
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<CasinoRecentlyPlayedCardDisplayState, Never>
    private var currentCardData: CasinoRecentlyPlayedCardData
    
    public var gameId: String { currentCardData.id }
    public var category: String { currentCardData.category }
    
    // MARK: - Initialization
    public init(cardData: CasinoRecentlyPlayedCardData, initialState: CasinoRecentlyPlayedCardDisplayState? = nil) {
        self.currentCardData = cardData
        
        let state = initialState ?? CasinoRecentlyPlayedCardDisplayState(cardData: cardData)
        self.displayStateSubject = CurrentValueSubject(state)
    }
    
    // MARK: - Publishers
    public var displayStatePublisher: AnyPublisher<CasinoRecentlyPlayedCardDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }
    
    public var gameNamePublisher: AnyPublisher<String, Never> {
        displayStatePublisher.map { $0.cardData.name }.eraseToAnyPublisher()
    }
    
    public var providerNamePublisher: AnyPublisher<String, Never> {
        displayStatePublisher.map { $0.cardData.provider }.eraseToAnyPublisher()
    }
    
    public var imageURLPublisher: AnyPublisher<String?, Never> {
        displayStatePublisher.map { $0.cardData.imageURL }.eraseToAnyPublisher()
    }
    
    public var lastPlayedDatePublisher: AnyPublisher<Date, Never> {
        displayStatePublisher.map { $0.cardData.lastPlayedDate }.eraseToAnyPublisher()
    }
    
    public var isLoadingPublisher: AnyPublisher<Bool, Never> {
        displayStatePublisher.map { $0.isLoading }.eraseToAnyPublisher()
    }
    
    public var isSelectedPublisher: AnyPublisher<Bool, Never> {
        displayStatePublisher.map { $0.isSelected }.eraseToAnyPublisher()
    }
    
    // MARK: - Actions
    public func selectGame() {
        let currentState = displayStateSubject.value
        let newState = CasinoRecentlyPlayedCardDisplayState(
            cardData: currentState.cardData,
            isLoading: currentState.isLoading,
            imageLoadingFailed: currentState.imageLoadingFailed,
            isSelected: !currentState.isSelected,
            showLastPlayedInfo: currentState.showLastPlayedInfo
        )
        displayStateSubject.send(newState)
    }
    
    public func imageLoadingFailed() {
        let currentState = displayStateSubject.value
        let newState = CasinoRecentlyPlayedCardDisplayState(
            cardData: currentState.cardData,
            isLoading: false,
            imageLoadingFailed: true,
            isSelected: currentState.isSelected,
            showLastPlayedInfo: currentState.showLastPlayedInfo
        )
        displayStateSubject.send(newState)
    }
    
    public func imageLoadingSucceeded() {
        let currentState = displayStateSubject.value
        let newState = CasinoRecentlyPlayedCardDisplayState(
            cardData: currentState.cardData,
            isLoading: false,
            imageLoadingFailed: false,
            isSelected: currentState.isSelected,
            showLastPlayedInfo: currentState.showLastPlayedInfo
        )
        displayStateSubject.send(newState)
    }
    
    // MARK: - Mock Factory Methods
    public static var gonzosQuest1: MockCasinoRecentlyPlayedCardViewModel {
        let cardData = CasinoRecentlyPlayedCardData(
            id: "gonzos-quest-1",
            name: "Gonzo's Quest",
            provider: "Netent",
            localImageName: "gonzos_quest_preview",
            lastPlayedDate: Date().addingTimeInterval(-1800), // 30 minutes ago
            category: "adventure"
        )
        return MockCasinoRecentlyPlayedCardViewModel(cardData: cardData)
    }
    
    public static var gonzosQuest2: MockCasinoRecentlyPlayedCardViewModel {
        let cardData = CasinoRecentlyPlayedCardData(
            id: "gonzos-quest-2",
            name: "Gonzo's Quest",
            provider: "Netent",
            localImageName: "gonzos_quest_preview",
            lastPlayedDate: Date().addingTimeInterval(-3600), // 1 hour ago
            category: "adventure"
        )
        return MockCasinoRecentlyPlayedCardViewModel(cardData: cardData)
    }
    
    public static var beastBelow: MockCasinoRecentlyPlayedCardViewModel {
        let cardData = CasinoRecentlyPlayedCardData(
            id: "beast-below-recent",
            name: "Beast Below",
            provider: "Hacksaw Gaming",
            localImageName: "beast_below_preview",
            lastPlayedDate: Date().addingTimeInterval(-7200), // 2 hours ago
            category: "action"
        )
        return MockCasinoRecentlyPlayedCardViewModel(cardData: cardData)
    }
    
    public static var aviator: MockCasinoRecentlyPlayedCardViewModel {
        let cardData = CasinoRecentlyPlayedCardData(
            id: "aviator-recent",
            name: "Aviator",
            provider: "Spribe",
            localImageName: "aviator_preview",
            lastPlayedDate: Date().addingTimeInterval(-10800), // 3 hours ago
            category: "crash"
        )
        return MockCasinoRecentlyPlayedCardViewModel(cardData: cardData)
    }
    
    // State examples
    public static var loadingCard: MockCasinoRecentlyPlayedCardViewModel {
        let cardData = CasinoRecentlyPlayedCardData(
            id: "loading-recent",
            name: "Loading Game",
            provider: "Provider",
            lastPlayedDate: Date(),
            category: "unknown"
        )
        
        let state = CasinoRecentlyPlayedCardDisplayState(
            cardData: cardData,
            isLoading: true
        )
        
        return MockCasinoRecentlyPlayedCardViewModel(cardData: cardData, initialState: state)
    }
    
    public static var imageFailedCard: MockCasinoRecentlyPlayedCardViewModel {
        let cardData = CasinoRecentlyPlayedCardData(
            id: "image-failed-recent",
            name: "Image Failed Game",
            provider: "Provider",
            lastPlayedDate: Date(),
            category: "unknown"
        )
        
        let state = CasinoRecentlyPlayedCardDisplayState(
            cardData: cardData,
            imageLoadingFailed: true
        )
        
        return MockCasinoRecentlyPlayedCardViewModel(cardData: cardData, initialState: state)
    }
}
```

## SwiftUI Previews

```swift
// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Recently Played Card - Gonzo's Quest 1") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let cardView = CasinoRecentlyPlayedCardView(viewModel: MockCasinoRecentlyPlayedCardViewModel.gonzosQuest1)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 280),
            cardView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Recently Played Card - Gonzo's Quest 2") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let cardView = CasinoRecentlyPlayedCardView(viewModel: MockCasinoRecentlyPlayedCardViewModel.gonzosQuest2)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 280),
            cardView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Recently Played Card - Beast Below") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let cardView = CasinoRecentlyPlayedCardView(viewModel: MockCasinoRecentlyPlayedCardViewModel.beastBelow)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 280),
            cardView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Recently Played Card - Aviator") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let cardView = CasinoRecentlyPlayedCardView(viewModel: MockCasinoRecentlyPlayedCardViewModel.aviator)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 280),
            cardView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Recently Played Card - Loading State") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let cardView = CasinoRecentlyPlayedCardView(viewModel: MockCasinoRecentlyPlayedCardViewModel.loadingCard)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 280),
            cardView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Recently Played Card - Image Failed") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundColor
        
        let cardView = CasinoRecentlyPlayedCardView(viewModel: MockCasinoRecentlyPlayedCardViewModel.imageFailedCard)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 280),
            cardView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        return vc
    }
}

#endif
```

## Demo Integration

### Demo View Controller
Create `CasinoRecentlyPlayedCardViewController.swift` in TestCase directory:

```swift
import UIKit
import Combine
import GomaUI

class CasinoRecentlyPlayedCardViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recently Played Cards"
        setupViews()
        createDemoCards()
    }
    
    private func setupViews() {
        view.backgroundColor = StyleProvider.Color.backgroundColor
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
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
        let mockViewModels = [
            MockCasinoRecentlyPlayedCardViewModel.gonzosQuest1,
            MockCasinoRecentlyPlayedCardViewModel.gonzosQuest2,
            MockCasinoRecentlyPlayedCardViewModel.beastBelow,
            MockCasinoRecentlyPlayedCardViewModel.aviator,
            MockCasinoRecentlyPlayedCardViewModel.loadingCard,
            MockCasinoRecentlyPlayedCardViewModel.imageFailedCard
        ]
        
        mockViewModels.forEach { mockViewModel in
            let cardView = CasinoRecentlyPlayedCardView(viewModel: mockViewModel)
            
            cardView.onGameSelected = { [weak self] gameId in
                self?.showAlert(title: "Game Selected", message: "Game ID: \(gameId)")
            }
            
            contentStackView.addArrangedSubview(cardView)
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
    title: "Casino Recently Played Card",
    description: "Horizontal card layout for recently played casino games with simplified design",
    viewController: CasinoRecentlyPlayedCardViewController.self,
    previewFactory: {
        let viewModel = MockCasinoRecentlyPlayedCardViewModel.gonzosQuest1
        return CasinoRecentlyPlayedCardView(viewModel: viewModel)
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
    
    // Update accessibility label based on card data
    viewModel.displayStatePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] displayState in
            let cardData = displayState.cardData
            let timeAgo = self?.formatTimeAgo(cardData.lastPlayedDate) ?? "recently"
            
            self?.accessibilityLabel = "\(cardData.name), by \(cardData.provider), played \(timeAgo)"
            
            if displayState.isLoading {
                self?.accessibilityLabel += ", loading"
            }
        }
        .store(in: &cancellables)
}

private func formatTimeAgo(_ date: Date) -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: date, relativeTo: Date())
}
```

## Performance Considerations

- **Horizontal Layout**: Optimized for landscape card orientation
- **Image Loading**: Async loading with proper failure handling
- **Memory Management**: Proper cleanup of image references
- **Compact Size**: Fixed size prevents layout issues
- **Simple Design**: Minimal complexity for fast rendering

## Implementation Files

```
CasinoRecentlyPlayedCardView/
├── CasinoRecentlyPlayedCardViewModelProtocol.swift
├── CasinoRecentlyPlayedCardView.swift
├── MockCasinoRecentlyPlayedCardViewModel.swift
└── Documentation/
    └── README.md
```

## Success Criteria

- [ ] Matches the horizontal/landscape card design from the image
- [ ] Game image displays correctly with loading and error states
- [ ] Game title and provider text display properly
- [ ] Card selection interaction works
- [ ] Proper sizing for recently played context
- [ ] Comprehensive preview states showing all scenarios
- [ ] Demo app integration working perfectly
- [ ] Accessibility support complete (VoiceOver, Dynamic Type)
- [ ] Performance optimized for horizontal layout
- [ ] Distinct from main CasinoGameCardView component