# ToasterView

A toast notification banner with icon and message for displaying brief feedback.

## Overview

ToasterView displays a temporary notification banner with an optional leading icon and title text. It features a rounded container with drop shadow for visual prominence. The component supports customizable background color, text color, icon color, and corner radius. It is used to show confirmation messages, success feedback, or brief alerts.

## Component Relationships

### Used By (Parents)
- Toast presentation managers
- Feedback notification systems
- Confirmation displays

### Uses (Children)
- None (leaf component)

## Features

- Rounded container with drop shadow
- Optional leading icon (bundle or SF Symbol)
- Title text label
- Customizable background color
- Customizable text and icon colors
- Configurable corner radius
- Horizontal icon + text layout
- Reactive updates via Combine publishers

## Usage

```swift
let data = ToasterData(
    title: "Booking Code Loaded",
    icon: "checkmark",
    backgroundColor: .white,
    titleColor: StyleProvider.Color.textPrimary,
    iconColor: .systemGreen,
    cornerRadius: 14
)
let viewModel = MockToasterViewModel(data: data)
let toaster = ToasterView(viewModel: viewModel)

// Success toast
let successData = ToasterData(
    title: "Bet Placed Successfully",
    icon: "checkmark.circle.fill",
    backgroundColor: StyleProvider.Color.backgroundTertiary,
    iconColor: .systemGreen
)
let successToast = ToasterView(viewModel: MockToasterViewModel(data: successData))

// Error toast
let errorData = ToasterData(
    title: "Something went wrong",
    icon: "exclamationmark.triangle.fill",
    backgroundColor: StyleProvider.Color.backgroundTertiary,
    iconColor: .systemRed
)
let errorToast = ToasterView(viewModel: MockToasterViewModel(data: errorData))

// Update toast dynamically
viewModel.update(newData)
```

## Data Model

```swift
struct ToasterData: Equatable {
    let title: String
    let icon: String?
    let backgroundColor: UIColor
    let titleColor: UIColor
    let iconColor: UIColor
    let cornerRadius: CGFloat
}

protocol ToasterViewModelProtocol {
    var dataPublisher: AnyPublisher<ToasterData, Never> { get }
    var currentData: ToasterData { get }
}
```

## Styling

Default StyleProvider properties:
- `StyleProvider.Color.backgroundTertiary` - default background
- `StyleProvider.Color.textPrimary` - default title color
- `StyleProvider.Color.highlightPrimary` - default icon color
- `StyleProvider.fontWith(type: .regular, size: 16)` - title font

Layout constants:
- Container corner radius: 12pt (customizable)
- Stack horizontal padding: 16pt
- Stack vertical padding: 20pt
- Icon to title spacing: 12pt
- Icon size: 20pt x 20pt
- Title lines: 1

Shadow properties:
- Color: black
- Opacity: 0.15
- Offset: (0, 4)
- Radius: 8pt

Icon resolution:
1. Try bundle image with name
2. Fallback to SF Symbol
3. Hide if neither found

## Mock ViewModels

Default initialization:
```swift
MockToasterViewModel()
// Creates: "Booking Code Loaded" with checkmark icon
```

Custom initialization:
```swift
MockToasterViewModel(data: ToasterData)
```

Methods:
- `update(_:)` - Update toast data reactively
