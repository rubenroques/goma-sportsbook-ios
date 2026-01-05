# ResendCodeView (ResendCodeCountdownView)

A countdown timer label for resend code functionality in verification flows.

## Overview

ResendCodeCountdownView displays a countdown timer showing when a user can request a new verification code. It formats the remaining time as "Resend Code in MM:SS" and automatically counts down. When the timer reaches zero, the user typically becomes eligible to resend the code. The component is used in SMS verification, email verification, and two-factor authentication flows.

## Component Relationships

### Used By (Parents)
- Verification screens
- PIN entry views
- Two-factor authentication forms

### Uses (Children)
- None (leaf component)

## Features

- Countdown timer with MM:SS format
- Automatic timer start on initialization
- Reset countdown functionality
- Localized countdown text
- Left-aligned label
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockResendCodeCountdownViewModel(startSeconds: 60)
let countdownView = ResendCodeCountdownView(viewModel: viewModel)

// Timer starts automatically on init
// Display shows: "Resend Code in 00:59"

// Reset the countdown
viewModel.resetCountdown()

// Start countdown manually after reset
viewModel.startCountdown()
```

## Data Model

```swift
protocol ResendCodeCountdownViewModelProtocol {
    var countdownTextPublisher: AnyPublisher<String, Never> { get }

    func startCountdown()
    func resetCountdown()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.textPrimary` - label text color
- `StyleProvider.fontWith(type: .regular, size: 14)` - label font

Layout constants:
- Label fills parent container
- Text alignment: left

Timer behavior:
- Updates every 1 second
- Format: "Resend Code in MM:SS"
- Stops at 00:00
- Timer invalidated on deinit

## Mock ViewModels

Available presets:
- `MockResendCodeCountdownViewModel(startSeconds: 59)` - Default 59 seconds
- `MockResendCodeCountdownViewModel(startSeconds: 60)` - 1 minute countdown
- `MockResendCodeCountdownViewModel(startSeconds: 5)` - Short 5 second countdown

Methods:
- `startCountdown()` - Starts/restarts the timer
- `resetCountdown()` - Resets to initial value and updates display
