# CustomNavigationView

A custom navigation bar with logo and close button for modal presentations.

## Overview

CustomNavigationView provides a branded navigation header typically used for modal flows. It displays a logo image on the left and a close button on the right, with customizable colors and icons. The component is commonly used in registration flows, payment screens, or any modal presentation requiring branded navigation.

## Component Relationships

### Used By (Parents)
- None (standalone navigation component)

### Uses (Children)
- None (leaf component)

## Features

- Left-aligned logo image
- Right-aligned close button with circular icon
- Customizable background color
- Customizable close button background color
- Customizable close icon tint color
- Custom close icon support
- Fixed 80pt height
- Close action callback
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockCustomNavigationViewModel.defaultMock
let navigationView = CustomNavigationView(viewModel: viewModel)

navigationView.onCloseTapped = {
    print("Close button tapped")
    // Dismiss modal
}
```

## Data Model

```swift
struct CustomNavigationData {
    let id: String
    let logoImage: String?
    let closeIcon: String?
    let backgroundColor: UIColor?
    let closeButtonBackgroundColor: UIColor?
    let closeIconTintColor: UIColor?
}

protocol CustomNavigationViewModelProtocol {
    var data: CustomNavigationData { get }
    var dataPublisher: AnyPublisher<CustomNavigationData, Never> { get }

    func configure(with data: CustomNavigationData)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - default background color
- `StyleProvider.Color.allWhite` - default close icon tint

Layout constants:
- Container height: 80pt
- Logo padding: 20pt leading
- Logo height: 40pt
- Logo max width: 150pt
- Close button padding: 20pt trailing
- Close button size: 40pt
- Close button corner radius: 20pt

## Mock ViewModels

Available presets:
- `.defaultMock` - Betsson logo with default primary highlight background
- `.blueMock` - Betsson logo with blue background, white close icon

Custom configuration:
```swift
let customData = CustomNavigationData(
    logoImage: "custom_logo",
    closeIcon: "custom_close_icon",
    backgroundColor: .systemGreen,
    closeButtonBackgroundColor: .white,
    closeIconTintColor: .systemGreen
)
let viewModel = MockCustomNavigationViewModel(data: customData)
```
