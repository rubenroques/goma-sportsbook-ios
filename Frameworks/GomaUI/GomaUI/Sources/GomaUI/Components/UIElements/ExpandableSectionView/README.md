# ExpandableSectionView

An expandable section with header title and plus/minus toggle button.

## Overview

ExpandableSectionView provides a collapsible section with a title header and a circular toggle button showing plus (collapsed) or minus (expanded) icons. The content area is exposed as a UIStackView for adding custom views. The component supports both header tap and button tap for toggling the expanded state.

## Component Relationships

### Used By (Parents)
- None (standalone expandable container)

### Uses (Children)
- None (provides contentContainer for external content injection)

## Features

- Tappable header for expand/collapse
- Title label (semibold 16pt)
- Plus/minus toggle button with primary highlight tint
- Custom expand/collapse icons support (asset or SF Symbol)
- Content container (UIStackView) for custom content
- 56pt header height
- 8pt corner radius on container
- Tertiary background color
- Constraint-based expand/collapse (animation commented out)
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockExpandableSectionViewModel.defaultMock
let sectionView = ExpandableSectionView(viewModel: viewModel)

// Add content to the expandable section
let contentLabel = UILabel()
contentLabel.text = "This content appears when expanded"
contentLabel.numberOfLines = 0
sectionView.contentContainer.addArrangedSubview(contentLabel)
```

## Data Model

```swift
protocol ExpandableSectionViewModelProtocol {
    var title: String { get }
    var isExpandedPublisher: AnyPublisher<Bool, Never> { get }

    func toggleExpanded()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - container background
- `StyleProvider.Color.backgroundPrimary` - preview background
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.Color.textSecondary` - content text color in previews
- `StyleProvider.Color.highlightPrimary` - toggle button tint
- `StyleProvider.fontWith(type: .semibold, size: 16)` - title font
- `StyleProvider.fontWith(type: .regular, size: 14)` - content font in previews
- `StyleProvider.fontWith(type: .regular, size: 13)` - smaller content font

Layout constants:
- Container corner radius: 8pt
- Header height: 56pt
- Title padding: 16pt leading
- Toggle button background size: 32pt
- Toggle button touch target: 44pt
- Content padding: 16pt horizontal, 12pt top, 16pt bottom
- Content stack spacing: 12pt

## Mock ViewModels

Available presets:
- `.defaultMock` - "Information" title, collapsed
- `.expandedMock` - "Details" title, expanded
- `.customMock(title:isExpanded:)` - custom configuration

Icons:
- Collapsed: plus icon (custom "expand_icon" or SF Symbol "plus")
- Expanded: minus icon (custom "collapse_icon" or SF Symbol "minus")
