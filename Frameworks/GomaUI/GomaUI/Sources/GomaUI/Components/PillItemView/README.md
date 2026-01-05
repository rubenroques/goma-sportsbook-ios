# PillItemView

A selectable pill/chip component with optional icon and expandable indicator for filter interfaces.

## Overview

PillItemView displays a rounded pill-shaped button that can contain a title, optional left icon, and optional expand indicator. It's used for category selection, filtering, and tab-like navigation. The component supports selection states with customizable styling, including full theming control via the dual-configuration pattern for selected/unselected appearances.

## Component Relationships

### Used By (Parents)
- `PillSelectorBarView`

### Uses (Children)
- None (leaf component)

## Features

- Title label with optional counter
- Optional left icon (SF Symbols or custom images)
- Optional expand indicator icon
- Selected/unselected visual states
- Full style customization via PillItemCustomization
- Pill types: informative, expansible, countable
- Tint color application toggle for icons
- Read-only mode support
- Tap gesture with callback
- Fully rounded corners (height/2)
- Reactive updates via Combine publishers
- Synchronous initial rendering

## Usage

```swift
let pillData = PillData(
    id: "football",
    title: "Football",
    leftIconName: "soccerball",
    type: .expansible,
    isSelected: true
)
let viewModel = MockPillItemViewModel(pillData: pillData)
let pillView = PillItemView(viewModel: viewModel)

// Handle selection
pillView.onPillSelected = {
    handlePillSelection()
}

// Custom styling
let customization = PillItemCustomization(
    selectedStyle: PillItemStyle(
        textColor: .white,
        backgroundColor: .systemBlue,
        borderColor: .systemBlue,
        borderWidth: 2.0
    ),
    unselectedStyle: PillItemStyle(
        textColor: .gray,
        backgroundColor: .lightGray,
        borderColor: .clear,
        borderWidth: 0.0
    )
)
pillView.setCustomization(customization)

// Using countable type with counter
let countablePill = PillData(
    id: "matches",
    title: "Matches",
    type: .countable(count: 42),
    isSelected: false
)
// Displays as "Matches (42)"
```

## Data Model

```swift
struct PillData: Equatable, Hashable {
    let id: String
    let title: String
    let leftIconName: String?
    let type: PillItemViewType
    let isSelected: Bool
    let shouldApplyTintColor: Bool

    enum PillItemViewType: Equatable, Hashable {
        case informative    // Simple pill, no extras
        case expansible     // Shows expand icon
        case countable(count: Int)  // Shows count in parentheses
    }
}

struct PillDisplayState: Equatable {
    let pillData: PillData
}

struct PillItemStyle: Equatable {
    let textColor: UIColor
    let backgroundColor: UIColor
    let borderColor: UIColor
    let borderWidth: CGFloat

    static func defaultSelected(isReadOnly: Bool) -> PillItemStyle
    static func defaultUnselected() -> PillItemStyle
}

struct PillItemCustomization: Equatable {
    let selectedStyle: PillItemStyle
    let unselectedStyle: PillItemStyle

    static var `default`: PillItemCustomization
    static func colors(...) -> PillItemCustomization
}

protocol PillItemViewModelProtocol {
    var currentDisplayState: PillDisplayState { get }
    var displayStatePublisher: AnyPublisher<PillDisplayState, Never> { get }
    var idPublisher: AnyPublisher<String, Never> { get }
    var titlePublisher: AnyPublisher<String, Never> { get }
    var leftIconNamePublisher: AnyPublisher<String?, Never> { get }
    var typePublisher: AnyPublisher<PillData.PillItemViewType, Never> { get }
    var isSelectedPublisher: AnyPublisher<Bool, Never> { get }
    var shouldApplyTintColorPublisher: AnyPublisher<Bool, Never> { get }
    var isReadOnly: Bool { get }

    func selectPill()
    func updateTitle(_ title: String)
    func updateLeftIcon(_ iconName: String?)
    func updateType(_ newType: PillData.PillItemViewType)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.pills` - default unselected/read-only background
- `StyleProvider.Color.highlightPrimary` - selected background, border, icon tint
- `StyleProvider.Color.buttonTextPrimary` - selected text color
- `StyleProvider.Color.textPrimary` - unselected/read-only text color
- `StyleProvider.fontWith(type: .semibold, size: 12)` - title font

Layout constants:
- Minimum height: 40pt
- Horizontal padding: 12pt
- Vertical padding: 10pt
- Icon size: 22pt x 22pt
- Icon spacing: 6pt
- Border width: 2pt (when visible)
- Corner radius: height / 2 (fully rounded)

Icon resolution:
1. First tries custom image (UIImage(named:))
2. Falls back to SF Symbol (UIImage(systemName:))

Read-only mode:
- Pills show their state but don't toggle on tap
- Selected style uses pills background instead of highlight

## Mock ViewModels

Available presets:
- `.footballPill` - "Football" with sportscourt.fill icon, expansible, selected
- `.popularPill` - "Popular" with flame.fill icon, informative, unselected
- `.allPill` - "All" with trophy.fill icon, expansible, unselected
- `MockPillItemViewModel(pillData:, isReadOnly:)` - Custom configuration
