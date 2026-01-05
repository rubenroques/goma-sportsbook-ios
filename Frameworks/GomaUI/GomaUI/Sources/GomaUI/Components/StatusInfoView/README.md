# StatusInfoView

A status display with icon, title, and message for confirmation screens.

## Overview

StatusInfoView displays a centered status message with a large icon, bold title, and descriptive message text. It is typically used for confirmation screens, success states, or informational displays after completing an action (e.g., password changed successfully). The component supports both custom named images and SF Symbols for the icon.

## Component Relationships

### Used By (Parents)
- Confirmation screens
- Success/error result screens
- Information displays

### Uses (Children)
- None (leaf component)

## Features

- Large centered icon (100pt x 100pt)
- Bold title with multiline support
- Regular message with multiline support
- Custom or SF Symbol icons
- Centered text alignment
- Background color theming

## Usage

```swift
let statusInfo = StatusInfo(
    icon: "checkmark.circle.fill",
    title: "Password Changed Successfully",
    message: "Your password has been updated. You can now log in with your new password."
)
let viewModel = MockStatusInfoViewModel(statusInfo: statusInfo)
let statusView = StatusInfoView(viewModel: viewModel)

// Custom icon from bundle
let customStatusInfo = StatusInfo(
    icon: "success_icon",  // Bundle asset name
    title: "Success!",
    message: "Your request has been processed."
)
```

## Data Model

```swift
struct StatusInfo {
    let id: String
    let icon: String       // Bundle image name or SF Symbol name
    let title: String
    let message: String
}

protocol StatusInfoViewModelProtocol {
    var statusInfo: StatusInfo { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - view background

Layout constants:
- Icon size: 100pt x 100pt
- Icon top padding: 16pt
- Title top margin: 50pt (from icon)
- Title horizontal padding: 16pt
- Message top margin: 14pt (from title)
- Message horizontal padding: 16pt
- Message bottom padding: 16pt

Typography:
- Title: Bold, 22pt, centered, 2 lines max
- Message: Regular, 16pt, centered, unlimited lines

Icon handling:
- Tries custom named image first
- Falls back to SF Symbol
- Content mode: scaleAspectFit

## Mock ViewModels

Available presets:
- `.successMock` - "Password Changed Successfully" with checkmark icon

Parameters:
- `statusInfo: StatusInfo` - The status information to display
