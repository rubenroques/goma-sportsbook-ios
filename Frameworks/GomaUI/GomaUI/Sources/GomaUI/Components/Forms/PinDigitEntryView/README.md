# PinDigitEntryView

A PIN code entry component with individual digit fields for secure input.

## Overview

PinDigitEntryView provides a series of individual digit boxes for entering PIN codes. It supports configurable digit counts (4, 6, 8, etc.), shows visual states for empty/focused/filled fields, and handles numeric keyboard input through a hidden text field. The component is commonly used for verification codes, security PINs, and two-factor authentication.

## Component Relationships

### Used By (Parents)
- Verification screens
- Security PIN entry forms
- Two-factor authentication views

### Uses (Children)
- `PinDigitField` (internal helper component)

## Features

- Configurable digit count (4, 6, 8, etc.)
- Individual digit display fields
- Hidden text field for keyboard input
- Empty/focused/filled visual states
- Number pad keyboard
- Tap anywhere to focus
- Pin completion callback
- Clear pin functionality
- Programmatic focus control
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockPinDigitEntryViewModel.defaultMock
let pinEntry = PinDigitEntryView(viewModel: viewModel)

// Handle PIN completion
pinEntry.onPinCompleted = { pin in
    verifyPin(pin)
}

// Clear the PIN
pinEntry.clearPin()

// Focus/unfocus
pinEntry.focusInput()
pinEntry.resignFocus()

// 6-digit PIN with partial input
let sixDigitVM = MockPinDigitEntryViewModel.sixDigitMock
let sixDigitEntry = PinDigitEntryView(viewModel: sixDigitVM)
```

## Data Model

```swift
struct PinDigitEntryData {
    let id: String
    let digitCount: Int       // Default: 4
    let currentPin: String    // Current entered digits
}

protocol PinDigitEntryViewModelProtocol {
    var data: PinDigitEntryData { get }
    var dataPublisher: AnyPublisher<PinDigitEntryData, Never> { get }
    var isPinComplete: CurrentValueSubject<Bool, Never> { get set }

    func configure(with data: PinDigitEntryData)
    func addDigit(_ digit: String)
    func removeLastDigit()
    func clearPin()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.textPrimary` - title label (preview)
- `StyleProvider.fontWith(type: .bold, size: 18)` - title font (preview)
- PinDigitField styling (internal):
  - Empty state: border only
  - Focused state: highlighted border
  - Filled state: background with digit text

Layout constants:
- Stack spacing: 12pt between digit fields
- Field height: 60pt
- Equal width distribution for all fields

Keyboard configuration:
- Type: `.numberPad`
- Hidden text field syncs with digit fields

Visual states per field:
- **Empty**: Border outline, no content
- **Focused**: Highlighted border, cursor indicator
- **Filled**: Solid background, digit displayed (or masked)

## Mock ViewModels

Available presets:
- `.defaultMock` - 4-digit PIN, empty
- `.sixDigitMock` - 6-digit PIN, partially filled with "123"
- `.eightDigitMock` - 8-digit PIN, empty
- `MockPinDigitEntryViewModel(data:)` - Custom configuration
