# CashoutSubmissionInfoView

A status notification bar displaying cashout submission results with icon and action button.

## Overview

CashoutSubmissionInfoView shows feedback after a cashout operation, displaying either success or error state with appropriate icon, message, and action button. The component uses distinct background colors and icons for each state, with visibility control for showing/hiding the notification.

## Component Relationships

### Used By (Parents)
- None (standalone notification component)

### Uses (Children)
- `ButtonView` - action button (OK/Retry)

## Features

- Success and error visual states
- State-appropriate icon (checkmark or warning)
- Customizable message text
- Visibility toggle for show/hide
- Integrated action button with state-specific label
- Fixed 56pt height with 12pt corner radius
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockCashoutSubmissionInfoViewModel.successMock()
let infoView = CashoutSubmissionInfoView(viewModel: viewModel)

viewModel.onButtonTap = {
    print("User acknowledged")
}
```

## Data Model

```swift
enum CashoutSubmissionState: Equatable {
    case success
    case error
}

struct CashoutSubmissionInfoData: Equatable {
    let state: CashoutSubmissionState
    let message: String
    let isVisible: Bool
}

protocol CashoutSubmissionInfoViewModelProtocol {
    var dataPublisher: AnyPublisher<CashoutSubmissionInfoData, Never> { get }
    var buttonViewModel: ButtonViewModelProtocol { get }

    func handleButtonTap()
    func setVisible(_ isVisible: Bool)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightSecondary` - success state background
- `StyleProvider.Color.highlightPrimary` - error state background
- `StyleProvider.fontWith(type: .regular, size: 14)` - message font
- White text color for messages

Icons:
- Success: "success_circle_icon" or SF Symbol "checkmark.circle.fill"
- Error: "alert_icon" or SF Symbol "exclamationmark.triangle.fill"

## Mock ViewModels

Available presets:
- `.successMock()` - "Cashout Successful" with OK button
- `.errorMock()` - "Cashout Failed" with Retry button
- `.customMock(state:message:isVisible:)` - custom configuration
