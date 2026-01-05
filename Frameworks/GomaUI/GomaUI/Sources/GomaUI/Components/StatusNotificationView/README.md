# StatusNotificationView

A compact notification banner with icon and message for success, error, or warning states.

## Overview

StatusNotificationView displays a horizontal notification bar with an icon and message. It supports three notification types (success, error, warning) with appropriate background colors and default icons. The component is used for inline feedback messages, toast-style notifications, and status indicators throughout the app.

## Component Relationships

### Used By (Parents)
- Transaction screens
- Form validation displays
- Action feedback areas

### Uses (Children)
- None (leaf component)

## Features

- Three notification types: success, error, warning
- Type-specific background colors
- Type-specific default icons
- Custom icon override support
- Multiline message support
- Bold white text for visibility
- Rounded corners (4pt)
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockStatusNotificationViewModel.successMock
let notificationView = StatusNotificationView(viewModel: viewModel)

// Error notification
let errorVM = MockStatusNotificationViewModel.errorMock
let errorView = StatusNotificationView(viewModel: errorVM)

// Warning notification
let warningVM = MockStatusNotificationViewModel.warningMock
let warningView = StatusNotificationView(viewModel: warningVM)

// Custom notification
let customData = StatusNotificationData(
    type: .success,
    message: "Your bet has been placed!",
    icon: "custom_success_icon"  // Optional custom icon
)
viewModel.configure(with: customData)
```

## Data Model

```swift
enum StatusNotificationType {
    case success
    case error
    case warning

    var backgroundColor: UIColor
    var iconImage: UIImage?
}

struct StatusNotificationData {
    let id: String
    let type: StatusNotificationType
    let message: String
    let icon: String?  // Optional custom icon override
}

protocol StatusNotificationViewModelProtocol {
    var data: StatusNotificationData { get }
    var dataPublisher: AnyPublisher<StatusNotificationData, Never> { get }

    func configure(with data: StatusNotificationData)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.alertSuccess` - success background
- `StyleProvider.Color.alertError` - error background
- `StyleProvider.Color.alertWarning` - warning background
- `StyleProvider.Color.buttonTextPrimary` - message text color
- `StyleProvider.Color.allWhite` - icon tint color
- `StyleProvider.fontWith(type: .bold, size: 16)` - message font

Layout constants:
- Corner radius: 4pt
- Vertical padding: 12pt
- Horizontal padding: 16pt
- Icon size: 24pt
- Icon to message spacing: 8pt

Default icons (when not overridden):
- Success: "checkmark.circle.fill" (bundle or SF Symbol)
- Error: SF Symbol "xmark.circle.fill"
- Warning: SF Symbol "exclamationmark.triangle.fill"

## Mock ViewModels

Available presets:
- `.successMock` - "Deposit Successful" with success styling
- `.errorMock` - "Transaction Failed" with error styling
- `.warningMock` - "Low Balance Warning" with warning styling

Methods:
- `configure(with:)` - Update notification data reactively
