# AdaptiveTabBarView

A dynamic tab bar supporting multiple tab bar configurations with animated transitions between them.

## Overview

`AdaptiveTabBarView` is a highly flexible and ViewModel-driven tab bar solution that enables switching between different tab bar layouts (e.g., Sports vs Casino) with rich animated transitions. It maintains navigation history for proper back navigation and supports multiple background modes including blur effects.

### Key Features

- **ViewModel-Driven**: All UI state (tab structures, active tabs, appearances) is managed by a ViewModel, making the view itself a passive renderer
- **Dynamic Content**: Supports multiple distinct tab bars (e.g., for different sections of an app like "Home," "Casino," "Live Events") and allows switching between them
- **Five Animation Types**: horizontalFlip, verticalCube, slideLeftToRight, modernMorphSlide, none
- **Three Background Modes**: solid, blur, transparent
- **Reactive Updates**: Via Combine publishers for state management
- **Navigation History**: Tracking for back navigation direction
- **Fixed 52pt Height**: Consistent sizing

## Component Relationships

### Used By (Parents)
- None (standalone component, typically used as main app tab bar)

### Uses (Children)
- None (internally uses AdaptiveTabBarItemView for tab items)

## Usage

### Basic Implementation

```swift
let viewModel = MockAdaptiveTabBarViewModel.defaultMock
let tabBarView = AdaptiveTabBarView(viewModel: viewModel)

// Configure animation type
tabBarView.animationType = .slideLeftToRight

// Configure background mode
tabBarView.backgroundMode = .blur

// Handle tab selection
tabBarView.onTabSelected = { tabItem in
    print("Selected: \(tabItem.title)")
}
```

### Integration in UIViewController

```swift
class MyViewController: UIViewController {
    let tabBarViewModel = MyCustomTabBarViewModel()
    var adaptiveTabBar: AdaptiveTabBarView!

    override func viewDidLoad() {
        super.viewDidLoad()

        adaptiveTabBar = AdaptiveTabBarView(viewModel: tabBarViewModel)
        adaptiveTabBar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(adaptiveTabBar)

        NSLayoutConstraint.activate([
            adaptiveTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            adaptiveTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            adaptiveTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        adaptiveTabBar.onTabSelected = { [weak self] selectedTabItem in
            print("Tab selected: \(selectedTabItem.title)")
        }
    }
}
```

## Architecture

The component uses a ViewModel-driven architecture with clear separation of concerns.

### Core Principles

1. **ViewModel as Single Source of Truth**: The ViewModel manages all state including tab structures, active tabs, selected items, and appearance details.

2. **Reactive Updates via Display State**: The ViewModel exposes a `displayStatePublisher` that emits comprehensive `AdaptiveTabBarDisplayState` objects. The View subscribes and updates its entire UI based on the received state.

3. **Dumb View Components**: The UIViews render the data provided and forward user interactions to the ViewModel without holding significant business logic.

4. **Unidirectional Data Flow**: User actions → ViewModel → Updated State → View Re-render

### Data Flow

```
User Taps Tab Item
       ↓
AdaptiveTabBarItemView.onTap
       ↓
AdaptiveTabBarView → viewModel.selectTab()
       ↓
ViewModel Updates Internal State
       ↓
ViewModel Constructs AdaptiveTabBarDisplayState
       ↓
displayStatePublisher.send()
       ↓
AdaptiveTabBarView.render(state:)
       ↓
UI Update: StackViews & ItemViews
```

## Data Structures

### Display State Structures

```swift
// Complete state for rendering
public struct AdaptiveTabBarDisplayState: Equatable {
    public let tabBars: [TabBarDisplayData]
    public let activeTabBarID: TabBarIdentifier
}

// Single tab bar description
public struct TabBarDisplayData: Equatable, Hashable {
    public let id: TabBarIdentifier
    public let items: [TabItemDisplayData]
}

// Single tab item description
public struct TabItemDisplayData: Equatable, Hashable {
    public let identifier: String
    public let title: String
    public let icon: UIImage?
    public let isActive: Bool
    public let switchToTabBar: TabBarIdentifier?
}
```

### Configuration Enums

```swift
public enum TabBarIdentifier: String, Hashable {
    case home, casino, live, promotions, profile
}

public enum TabBarAnimationType {
    case horizontalFlip      // 3D horizontal flip
    case verticalCube        // 3D cube rotation
    case slideLeftToRight    // Direction-aware slide
    case modernMorphSlide    // Blur + scale + slide
    case none                // Instant switch
}

public enum TabBarBackgroundMode {
    case solid       // StyleProvider.Color.backgroundPrimary
    case blur        // UIBlurEffect with .systemUltraThinMaterial
    case transparent // Clear background
}
```

### Internal ViewModel Structures

```swift
// Underlying data model for a tab bar
public struct TabBar: Hashable {
    public var id: TabBarIdentifier
    public var tabs: [TabItem]
    public var selectedTabItemIdentifier: String
}

// Underlying data model for a tab item
public struct TabItem: Equatable, Hashable {
    public let identifier: String
    public let title: String
    public let icon: UIImage?
    public let switchToTabBar: TabBarIdentifier?
}
```

## ViewModel Protocol

```swift
public protocol AdaptiveTabBarViewModelProtocol {
    /// Publisher for the current display state
    var displayStatePublisher: AnyPublisher<AdaptiveTabBarDisplayState, Never> { get }

    /// Handles tab selection
    func selectTab(itemID: String, inTabBarID: TabBarIdentifier)
}
```

### ViewModel Responsibilities

1. **State Management**: Maintain internal source of truth for all tab bar data
2. **Logic Execution**: Determine selections and tab bar switches based on `switchToTabBar` property
3. **Display State Construction**: Transform internal models into `AdaptiveTabBarDisplayState`
4. **Publishing Updates**: Emit new state through `displayStatePublisher` on any change

### Custom ViewModel Example

```swift
class MyCustomTabBarViewModel: AdaptiveTabBarViewModelProtocol {
    private let displayStateSubject: CurrentValueSubject<AdaptiveTabBarDisplayState, Never>
    var displayStatePublisher: AnyPublisher<AdaptiveTabBarDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }

    private var internalTabBars: [TabBar]
    private var internalActiveTabBarID: TabBarIdentifier

    func selectTab(itemID: String, inTabBarID: TabBarIdentifier) {
        // 1. Find the TabBar and TabItem
        // 2. Update selected item
        // 3. Handle potential switch to another tab bar
        // 4. Publish the new display state
    }
}
```

## View Components

### AdaptiveTabBarView

**Inherits from**: `UIView`

**Key Responsibilities**:
- Initializes with `AdaptiveTabBarViewModelProtocol`
- Subscribes to `displayStatePublisher`
- Manages `stackViewMap: [TabBarIdentifier: UIStackView]` for tab bar StackViews
- Renders by clearing and re-populating StackViews with `AdaptiveTabBarItemView` instances
- Controls visibility based on `activeTabBarID`
- Provides `onTabSelected` callback

### AdaptiveTabBarItemView

**Inherits from**: `UIView`

**UI Elements**:
- `iconImageView: UIImageView`
- `titleLabel: UILabel`
- `containerStackView: UIStackView` (vertical arrangement)

**Key Responsibilities**:
- Displays icon and title
- Configured via `configure(with: TabItemDisplayData)`
- Updates appearance based on `isActive` state
- Handles tap gestures via `onTap` closure

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - solid background color
- `StyleProvider.Color.highlightPrimary` - active tab item color
- `StyleProvider.Color.iconSecondary` - inactive tab item color
- `StyleProvider.fontWith(type: .semibold, size: 12)` - tab item title font

Active state:
- Title/icon colors: `highlightPrimary`
- Alpha: 1.0

Inactive state:
- Title/icon colors: `highlightSecondary`
- Alpha: 0.3

## Testing

### ViewModel Testing

Focus on testing the ViewModel's logic:

1. **Initialization**: Test correct initial `AdaptiveTabBarDisplayState` emission
2. **selectTab scenarios**:
   - Selecting item in active tab bar
   - Selecting item in inactive tab bar (should activate it)
   - Selecting item with `switchToTabBar` to different tab bar
   - Selecting item with `switchToTabBar` to same tab bar
3. **Structural updates**: If supporting dynamic tab bar changes

### SwiftUI Previews

```swift
#Preview("Default Tabs") {
    PreviewUIView {
        AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.defaultMock)
    }
    .frame(height: 52)
}

#Preview("Complex Mock") {
    PreviewUIView {
        AdaptiveTabBarView(viewModel: MockAdaptiveTabBarViewModel.complexAndCrazyMock)
    }
    .frame(height: 52)
}
```

## Mock ViewModels

Available presets:
- `.defaultMock` - home and casino tab bars with Sports, Live, My Bets, Search, Casino tabs
- `.complexAndCrazyMock` - complex configuration for testing edge cases

## Requirements

- iOS 17.0+
- Swift 5.7+
- GomaUI Framework

## Related Components

- **QuickLinksTabBar**: Horizontal quick access tab bar
- **StyleProvider**: Provides theming and styling
