# ButtonIconView

A button component with configurable icon position (left or right of title).

## Overview

ButtonIconView displays a tappable button with an icon and text label. The icon can be positioned on either side of the text, making it suitable for various action buttons like "Add Booking Code" or "Clear Betslip" with trailing icons.

## Component Relationships

### Used By (Parents)
- `TicketBetInfoView` - action buttons within bet ticket info

### Uses (Children)
- None (leaf component)

## Features

- Configurable icon position: left or right of title
- Custom or SF Symbol icon support
- Customizable icon tint color
- Optional background color and corner radius
- Enabled/disabled state with alpha dimming
- Reactive updates via Combine publisher
- 16x16pt icon size with 8pt spacing from title

## Usage

```swift
let viewModel = MockButtonIconViewModel.bookingCodeMock()
let buttonView = ButtonIconView(viewModel: viewModel)

viewModel.onButtonTapped = {
    print("Button tapped")
}
```

## Data Model

```swift
enum ButtonIconLayoutType: Equatable {
    case iconLeft
    case iconRight
}

struct ButtonIconData: Equatable {
    let title: String
    let icon: String?
    let layoutType: ButtonIconLayoutType
    let isEnabled: Bool
    let backgroundColor: UIColor?
    let cornerRadius: CGFloat?
    let iconColor: UIColor?
}

protocol ButtonIconViewModelProtocol {
    var dataPublisher: AnyPublisher<ButtonIconData, Never> { get }
    var currentData: ButtonIconData { get }

    func updateTitle(_ title: String)
    func updateIcon(_ icon: String?)
    func updateLayoutType(_ layoutType: ButtonIconLayoutType)
    func setEnabled(_ isEnabled: Bool)
    func updateBackgroundColor(_ color: UIColor?)
    func updateCornerRadius(_ radius: CGFloat?)
    func updateIconColor(_ color: UIColor?)

    var onButtonTapped: (() -> Void)? { get set }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.Color.highlightPrimary` - default icon tint color
- `StyleProvider.fontWith(type: .regular, size: 14)` - title font

## Mock ViewModels

Available presets:
- `.bookingCodeMock()` - "Add Booking Code" with barcode icon (left)
- `.clearBetslipMock()` - "Clear Betslip" with trash icon (right)
- `.disabledMock()` - disabled state example
