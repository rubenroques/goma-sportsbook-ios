# SingleButtonBannerView

A promotional banner with background image, message text, and optional call-to-action button.

## Overview

SingleButtonBannerView displays a promotional banner with a full-bleed background image, multiline message text, and an optional action button. It supports custom button styling (colors, corner radius), enabled/disabled states, and visibility control. The component conforms to TopBannerViewProtocol for integration with banner slider systems. It uses Kingfisher for async image loading.

## Component Relationships

### Used By (Parents)
- `TopBannerSliderView`
- Home screens
- Promotional sections

### Uses (Children)
- None (leaf component)

## Features

- Full-bleed background image (async loading via Kingfisher)
- Multiline message text with bold styling
- Optional action button with custom styling
- Button enabled/disabled states
- Banner visibility control
- TopBannerViewProtocol conformance
- Button tap callback
- Cell reuse support (clearContent, configure)
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockSingleButtonBannerViewModel.defaultMock
let banner = SingleButtonBannerView(viewModel: viewModel)

// Handle button tap
banner.onButtonTapped = {
    navigateToPromotion()
}

// Reconfigure for cell reuse
banner.configure(with: newViewModel)

// Clear content for reuse
banner.clearContent()

// Update button enabled state
banner.updateButtonEnabled(false)
```

## Data Model

```swift
struct SingleButtonBannerData: Equatable, Hashable, TopBannerProtocol {
    let type: String
    let isVisible: Bool
    let backgroundImageURL: String?
    let messageText: String
    let buttonConfig: ButtonConfig?
}

struct ButtonConfig: Equatable, Hashable {
    let title: String
    let backgroundColor: UIColor?
    let textColor: UIColor?
    let cornerRadius: CGFloat?
}

struct SingleButtonBannerDisplayState: Equatable {
    let bannerData: SingleButtonBannerData
    let isButtonEnabled: Bool
}

protocol SingleButtonBannerViewModelProtocol {
    associatedtype ActionType

    var currentDisplayState: SingleButtonBannerDisplayState { get }
    var displayStatePublisher: AnyPublisher<SingleButtonBannerDisplayState, Never> { get }
    var onButtonAction: ((ActionType) -> Void)? { get set }

    func buttonTapped()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - view background
- `StyleProvider.Color.buttonBackgroundSecondary` - default button background
- `StyleProvider.Color.buttonTextSecondary` - default button text color
- `StyleProvider.fontWith(type: .bold, size: 22)` - message label font
- `StyleProvider.fontWith(type: .medium, size: 16)` - button title font

Layout constants:
- Content padding: 20pt all sides
- Message to button spacing: 16pt (minimum)
- Button corner radius: 8pt (default)
- Button padding: 12pt vertical, 24pt horizontal
- Button min height: 44pt

Message styling:
- White text color (for image overlay)
- Multiline support
- Left aligned

## Mock ViewModels

Available presets:
- `.emptyState` - Hidden empty banner
- `.defaultMock` - Welcome banner with blue button
- `.noButtonMock` - Message-only banner (no button)
- `.customStyledMock` - Green button with custom styling
- `.disabledMock` - Banner with disabled button
- `.hiddenMock` - Hidden banner state
