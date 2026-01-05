# MarketGroupTabItemView

An individual market group tab item with title, optional icons, badge, and selection underline.

## Overview

MarketGroupTabItemView displays a single tab item within a market group selector. It supports prefix and suffix icons, a badge counter, and an animated underline indicator for the selected state. The component uses a pluggable image resolver for icon loading and supports customizable background colors for idle and selected states.

## Component Relationships

### Used By (Parents)
- `MarketGroupSelectorTabView` - horizontal tab collection

### Uses (Children)
- None (leaf component)

## Features

- Centered title label with prefix/suffix icon support
- Optional badge counter (circular, primary highlight color)
- Selection underline indicator (2pt height)
- Two visual states: idle and selected
- Animated state transitions (0.2s duration)
- Haptic feedback on tap
- Pluggable image resolver for icons
- Customizable idle/selected background colors
- Icon tinting based on selection state
- Intrinsic content size for self-sizing

## Usage

```swift
let tabData = MarketGroupTabItemData(
    id: "popular",
    title: "Popular",
    visualState: .idle,
    suffixIconTypeName: "popular",
    badgeCount: 12
)
let viewModel = MockMarketGroupTabItemViewModel(tabItemData: tabData)
let tabView = MarketGroupTabItemView(
    viewModel: viewModel,
    imageResolver: DefaultMarketGroupTabImageResolver(),
    idleBackgroundColor: .systemGray6,
    selectedBackgroundColor: .systemBlue
)

// Listen for taps
viewModel.onTapPublisher
    .sink { tappedId in
        print("Tab tapped: \(tappedId)")
    }
    .store(in: &cancellables)

// Update state programmatically
viewModel.setSelected(true)
viewModel.updateBadgeCount(5)
```

## Data Model

```swift
enum MarketGroupTabItemVisualState: Equatable {
    case idle       // Normal unselected state
    case selected   // Tab is currently selected
}

struct MarketGroupTabItemData: Equatable, Hashable {
    let id: String
    let title: String
    let visualState: MarketGroupTabItemVisualState
    let prefixIconTypeName: String?
    let suffixIconTypeName: String?
    let badgeCount: Int?
}

protocol MarketGroupTabImageResolver {
    func tabIcon(for tabType: String) -> UIImage?
}

protocol MarketGroupTabItemViewModelProtocol {
    var titlePublisher: AnyPublisher<String, Never> { get }
    var idPublisher: AnyPublisher<String, Never> { get }
    var prefixIconTypePublisher: AnyPublisher<String?, Never> { get }
    var suffixIconTypePublisher: AnyPublisher<String?, Never> { get }
    var badgeCountPublisher: AnyPublisher<Int?, Never> { get }
    var visualStatePublisher: AnyPublisher<MarketGroupTabItemVisualState, Never> { get }
    var currentVisualState: MarketGroupTabItemVisualState { get }
    var onTapPublisher: AnyPublisher<String, Never> { get }

    func setVisualState(_ state: MarketGroupTabItemVisualState)
    func updateTitle(_ title: String)
    func updatePrefixIconType(_ iconType: String?)
    func updateSuffixIconType(_ iconType: String?)
    func updateBadgeCount(_ count: Int?)
    func updateTabItemData(_ tabItemData: MarketGroupTabItemData)
    func setSelected(_ selected: Bool)
    func setEnabled(_ enabled: Bool)
    func handleTap()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - default background
- `StyleProvider.Color.textPrimary` - idle text/icon color
- `StyleProvider.Color.highlightPrimary` - selected text/icon color, underline, badge background
- `StyleProvider.Color.buttonTextPrimary` - badge text color
- `StyleProvider.fontWith(type: .regular, size: 14)` - idle title font
- `StyleProvider.fontWith(type: .medium, size: 14)` - selected title font
- `StyleProvider.fontWith(type: .bold, size: 10)` - badge font

Layout constants:
- Horizontal padding: 16pt
- Vertical padding: 2pt
- Underline height: 2pt
- Minimum height: 42pt
- Stack spacing: 4pt
- Icon size: 14pt
- Badge size: 16pt (circular)
- Animation duration: 0.2s

## Mock ViewModels

Available presets:
- `.oneXTwoTab` - "1x2" selected
- `.doubleChanceTab` - "Double Chance" idle
- `.overUnderTab` - "Over/Under" idle
- `.anotherMarketTab` - "Another market" idle
- `.allTab` - "All" selected (market category)
- `.betBuilderTab` - "BetBuilder" with icon and badge (14)
- `.popularTab` - "Popular" with icon and badge (12)
- `.setsTab` - "Sets" with badge only (16)
- `.prefixOnlyTab` - "Live" with prefix flame icon
- `.suffixOnlyTab` - "Popular" with suffix gamecontroller icon
- `.bothIconsTab` - "VIP" with both icons and badge
- `.customTab(id:title:selected:prefixIconTypeName:suffixIconTypeName:badgeCount:)` - fully customizable
