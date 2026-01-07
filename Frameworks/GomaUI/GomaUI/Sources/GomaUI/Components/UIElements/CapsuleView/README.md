# CapsuleView

A versatile pill-shaped badge component with fully rounded corners for labels, status indicators, and tags.

## Overview

CapsuleView displays text or custom content inside a capsule-shaped container with automatic corner radius based on height. It supports customizable colors, fonts, padding, and can be configured via ViewModel or convenience initializer. Common uses include live badges, count badges, status indicators, and category tags.

## Component Relationships

### Used By (Parents)
- `MatchDateNavigationBar` - date selector pills
- `TicketSelectionView` - selection state badges

### Uses (Children)
- None (leaf component)

## Features

- Perfect capsule shape (corner radius = height / 2)
- Customizable text, background color, text color, and font
- Configurable horizontal and vertical padding
- Optional minimum height constraint
- Custom content view support (replaces text)
- Tap gesture handling
- Reactive updates via Combine publisher
- Convenience initializer for simple text capsules

## Usage

```swift
// ViewModel-based initialization
let viewModel = MockCapsuleViewModel.liveBadge
let capsuleView = CapsuleView(viewModel: viewModel)

capsuleView.onTapped = {
    print("Capsule tapped")
}

// Convenience initializer
let customCapsule = CapsuleView(
    text: "LIVE",
    backgroundColor: .systemRed,
    textColor: .white,
    font: UIFont.boldSystemFont(ofSize: 10),
    horizontalPadding: 12.0,
    verticalPadding: 4.0
)
```

## Data Model

```swift
struct CapsuleData: Equatable {
    let id: String
    let text: String?
    let backgroundColor: UIColor?
    let textColor: UIColor?
    let font: UIFont?
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let minimumHeight: CGFloat?
}

protocol CapsuleViewModelProtocol {
    var dataPublisher: AnyPublisher<CapsuleData, Never> { get }
    var data: CapsuleData { get }

    func configure(with data: CapsuleData)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightSecondary` - default background color
- `StyleProvider.Color.buttonTextPrimary` - default text color
- `StyleProvider.fontWith(type: .bold, size: 10)` - default font

## Mock ViewModels

Available presets:
- `.liveBadge` - red "LIVE" badge
- `.countBadge` - numeric count with minimum height
- `.tagStyle` - category tag with larger padding
- `.statusPending` - orange "Pending" status
- `.statusSuccess` - green "Completed" status
- `.statusError` - red "Failed" status
- `.promotionalNew` - purple "NEW" badge
- `.promotionalHot` - red "HOT" badge with emoji
- `.matchStatusLive` - match time indicator
- `.matchStatusHalfTime` - "Half Time" indicator
- `.marketCount` - market count badge
- `.custom(text:backgroundColor:textColor:...)` - fully customizable
