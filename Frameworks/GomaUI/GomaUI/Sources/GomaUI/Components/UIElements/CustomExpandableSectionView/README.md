# CustomExpandableSectionView

A generic expandable section with header, icon, and content container.

## Overview

CustomExpandableSectionView provides a reusable collapsible section with a tappable header containing an optional leading icon, title, and toggle button. The content area is a UIStackView that can contain any custom views. The component handles expand/collapse animations and constraint switching automatically.

## Component Relationships

### Used By (Parents)
- `WalletDetailView` - expandable wallet sections

### Uses (Children)
- None (provides contentContainer for external content injection)

## Features

- Tappable header for expand/collapse
- Optional leading icon (system or asset)
- Customizable collapse/expand icons
- Toggle button with icon rotation
- Content container (UIStackView) for custom content
- Animated expand/collapse with constraint switching
- 8pt corner radius on container
- 40pt header height
- Tertiary background color
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockCustomExpandableSectionViewModel.defaultCollapsed
let sectionView = CustomExpandableSectionView(viewModel: viewModel)

// Add content to the expandable section
let contentLabel = UILabel()
contentLabel.text = "This is the expandable content"
sectionView.contentContainer.addArrangedSubview(contentLabel)
```

## Data Model

```swift
protocol CustomExpandableSectionViewModelProtocol: AnyObject {
    var title: String { get }
    var leadingIconName: String? { get }
    var collapsedIconName: String? { get }
    var expandedIconName: String? { get }
    var isExpandedPublisher: AnyPublisher<Bool, Never> { get }

    func toggleExpanded()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - container background
- `StyleProvider.Color.backgroundSecondary` - preview background
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.Color.textSecondary` - content text color in previews
- `StyleProvider.Color.highlightPrimary` - leading icon and toggle button tint
- `StyleProvider.fontWith(type: .bold, size: 12)` - title font
- `StyleProvider.fontWith(type: .regular, size: 13)` - content font in previews

Layout constants:
- Container corner radius: 8pt
- Header height: 40pt
- Leading icon size: 24pt
- Toggle button size: 40pt
- Content padding: 8pt horizontal
- Content bottom padding: 8pt (when expanded)
- Content stack spacing: 12pt

## Mock ViewModels

Available presets:
- `.defaultCollapsed` - "Account Overview" with person icon, collapsed
- `.defaultExpanded` - "Responsible Gaming" with shield icon, expanded
- `.custom(title:icon:collapsedIcon:expandedIcon:isExpanded:)` - custom configuration

Default icons:
- Leading: configurable per instance
- Collapsed: "chevron.down"
- Expanded: "chevron.up"
