# QuickLinksTabBar

A horizontal tab bar displaying quick access links with icons and titles.

## Overview

`QuickLinksTabBarView` displays a horizontal row of quick access links (e.g., Aviator, Virtual, Slots, Crash, Promos) with icons and titles. Each item is equally distributed across the available width. The component is used for quick navigation to popular features or categories, typically placed below the main header or navigation bar.

### Key Features

- **ViewModel-Driven**: All UI state (link items) is managed by a ViewModel
- **Simple Structure**: Straightforward horizontal layout of identical items
- **Type-Safe Actions**: Enum-based approach for item types
- **Flexible Content**: Easily customizable with different sets of quick links
- **Lightweight Design**: Fixed height of 48pt and minimal complexity
- **Callback-Based Interaction**: Simple callback mechanism for handling user taps
- **Reactive Updates**: Via Combine publishers for dynamic content changes

### When to Use

Unlike the more complex `AdaptiveTabBarView`, `QuickLinksTabBar` is not designed for primary app navigation or maintaining selected states. It's ideal for:

- Providing access to frequently used features at the top of a screen
- Creating category shortcuts in a browsing interface
- Building a compact navigation row for related sections
- Implementing feature highlights or promotional links

## Component Relationships

### Used By (Parents)
- Home screens
- Main navigation areas

### Uses (Children)
- `QuickLinkTabBarItemView` (internal helper)

## Usage

### Basic Implementation

```swift
let viewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
let quickLinksBar = QuickLinksTabBarView(viewModel: viewModel)

// Handle quick link selection
quickLinksBar.onQuickLinkSelected = { linkType in
    switch linkType {
    case .aviator: navigateToAviator()
    case .virtual: navigateToVirtual()
    case .slots: navigateToSlots()
    default: break
    }
}

// Update theme if needed
quickLinksBar.updateTheme()

// Change links dynamically
viewModel.updateQuickLinks(newLinks)
```

### Integration in UIViewController

```swift
class MyViewController: UIViewController {
    let quickLinksViewModel = MyQuickLinksViewModel()
    var quickLinksTabBar: QuickLinksTabBarView!

    override func viewDidLoad() {
        super.viewDidLoad()

        quickLinksTabBar = QuickLinksTabBarView(viewModel: quickLinksViewModel)
        quickLinksTabBar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(quickLinksTabBar)

        NSLayoutConstraint.activate([
            quickLinksTabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            quickLinksTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quickLinksTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            // Height (48pt) is set internally by the component
        ])

        quickLinksTabBar.onQuickLinkSelected = { [weak self] linkType in
            self?.handleQuickLinkSelection(linkType)
        }
    }

    private func handleQuickLinkSelection(_ linkType: QuickLinkType) {
        switch linkType {
        case .aviator: navigateToAviator()
        case .slots: showSlots()
        case .crash: openCrashGame()
        case .promos: showPromotions()
        default: break
        }
    }
}
```

## Architecture

The component uses a simple ViewModel-driven architecture.

### Core Principles

1. **ViewModel as Single Source of Truth**: Provides the collection of quick link items
2. **Reactive Updates via Publisher**: Emits `[QuickLinkItem]` through `quickLinksPublisher`
3. **Dumb View Components**: Render data and forward user interactions
4. **Type-Safe Link Identifiers**: All links identified by `QuickLinkType` enum

### Data Flow

```
ViewModel Initializes/Updates
       ↓
quickLinksPublisher.send()
       ↓
QuickLinksTabBarView subscribes
       ↓
render(quickLinks:) → UI Update

User Taps Quick Link
       ↓
QuickLinkTabBarItemView.onTap
       ↓
QuickLinksTabBarView
       ↓
didTapQuickLink → ViewModel
onQuickLinkSelected → App Code
```

## Data Structures

### QuickLinkType

```swift
public enum QuickLinkType: String, Hashable {
    // Gaming
    case aviator, virtual, slots, crash, promos, lite
    // Sports
    case sports, live, football, basketball, tennis, golf
    // Account
    case deposit, withdraw, help, settings, favourites
    // Filter
    case mainFilter
}
```

### QuickLinkItem

```swift
public struct QuickLinkItem: Equatable, Hashable {
    public let type: QuickLinkType
    public let title: String
    public let icon: UIImage?
}
```

### ViewModel Protocol

```swift
public protocol QuickLinksTabBarViewModelProtocol {
    /// Publisher for the current quick links to be displayed
    var quickLinksPublisher: AnyPublisher<[QuickLinkItem], Never> { get }

    /// Optional callback for tab selection
    var onTabSelected: ((String) -> Void) { get set }

    /// Handles when a quick link is tapped
    func didTapQuickLink(type: QuickLinkType)
}
```

### Custom ViewModel Example

```swift
class MyQuickLinksViewModel: QuickLinksTabBarViewModelProtocol {
    private let quickLinksSubject: CurrentValueSubject<[QuickLinkItem], Never>

    var quickLinksPublisher: AnyPublisher<[QuickLinkItem], Never> {
        return quickLinksSubject.eraseToAnyPublisher()
    }

    init() {
        let defaultLinks = [
            QuickLinkItem(type: .aviator, title: "Aviator", icon: UIImage(systemName: "airplane")),
            QuickLinkItem(type: .slots, title: "Slots", icon: UIImage(systemName: "square.grid.3x3")),
            QuickLinkItem(type: .crash, title: "Crash", icon: UIImage(systemName: "chart.line.uptrend.xyaxis")),
            QuickLinkItem(type: .promos, title: "Promos", icon: UIImage(systemName: "gift"))
        ]
        self.quickLinksSubject = CurrentValueSubject(defaultLinks)
    }

    func didTapQuickLink(type: QuickLinkType) {
        print("Quick link tapped: \(type)")
    }

    func updateQuickLinks(_ newLinks: [QuickLinkItem]) {
        quickLinksSubject.send(newLinks)
    }
}
```

## View Components

### QuickLinksTabBarView

**Inherits from**: `UIView`

**Properties**:
- `stackView: UIStackView` - Horizontal stack for items
- `viewModel: QuickLinksTabBarViewModelProtocol` - Data provider
- `onQuickLinkSelected: ((QuickLinkType) -> Void)` - Selection callback

**Key Methods**:
- `setupSubviews()` - Configures appearance, sets fixed height (48pt)
- `setupBindings()` - Subscribes to `quickLinksPublisher`
- `render(quickLinks:)` - Clears and recreates item views

### QuickLinkTabBarItemView

**Inherits from**: `UIView`

**UI Elements**:
- `iconImageView: UIImageView` - Item icon
- `titleLabel: UILabel` - Item title
- `containerStackView: UIStackView` - Vertical arrangement

**Key Methods**:
- `configure(with: QuickLinkItem)` - Sets content
- `handleTap()` - Executes `onTap` closure

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - bar background

Layout constants:
- Fixed height: 48pt
- Stack spacing: 2pt
- Vertical padding: 2pt
- Distribution: fillEqually

Item styling:
- Handled by QuickLinkTabBarItemView
- Icons from bundle or SF Symbols

## Testing

### ViewModel Testing

Focus on:
1. **Initialization**: Test correct initial links emission
2. **Tap Handling**: Test `didTapQuickLink(type:)` behavior
3. **Dynamic Updates**: Test `updateQuickLinks(_:)` emissions

### SwiftUI Previews

```swift
#Preview("Gaming Quick Links") {
    PreviewUIView {
        QuickLinksTabBarView(viewModel: MockQuickLinksTabBarViewModel.gamingMockViewModel)
    }
    .frame(height: 48)
}

#Preview("Sports Quick Links") {
    PreviewUIView {
        QuickLinksTabBarView(viewModel: MockQuickLinksTabBarViewModel.sportsMockViewModel)
    }
    .frame(height: 48)
}
```

## Mock ViewModels

Available presets:
- `.gamingMockViewModel` - Aviator, Virtual, Slots, Crash, Promos (bundle icons)
- `.sportsMockViewModel` - Football, Basketball, Tennis, Golf (SF Symbols)
- `.accountMockViewModel` - Deposit, Withdraw, Help, Settings (SF Symbols)

Icon sources:
- Gaming: Bundle assets (aviator_quick_link_icon, etc.)
- Sports: SF Symbols (soccerball, basketball, tennisball, figure.golf)
- Account: SF Symbols (arrow.down.circle, arrow.up.circle, etc.)

## Requirements

- iOS 17.0+
- Swift 5.7+
- GomaUI Framework

## Related Components

- **AdaptiveTabBarView**: Complex tab bar for primary app navigation with selection states
- **StyleProvider**: Provides theming and styling
