# TransactionVerificationView

A verification status view with icon, title, highlighted subtitle, and instructional image.

## Overview

TransactionVerificationView displays transaction verification status with a top icon (optionally spinning), title text, subtitle with highlighted text ranges, and a bottom instructional image. It is used in payment flows to show USSD push status, verification prompts, and confirmation screens. The top icon can animate with a spinning effect for loading states.

## Component Relationships

### Used By (Parents)
- Payment verification screens
- USSD push status screens
- Transaction confirmation flows

### Uses (Children)
- `HighlightedTextView` - for subtitle with highlighted text

## Features

- Top icon with optional spinning animation
- Bold title text (centered)
- Subtitle with highlighted text ranges
- Bottom instructional image
- Conditional icon visibility
- USSD push loading animation
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockTransactionVerificationViewModel.defaultMock
let verificationView = TransactionVerificationView(viewModel: viewModel)

// Simple prompt without highlights
let simpleView = TransactionVerificationView(
    viewModel: MockTransactionVerificationViewModel.simpleMock
)

// Update data dynamically
viewModel.configure(with: newData)
```

## Data Model

```swift
struct TransactionVerificationData {
    let id: String
    let title: String
    let subtitle: String
    let highlightText: String?
    let topImage: String?
    let bottomImage: String?
}

protocol TransactionVerificationViewModelProtocol {
    var data: TransactionVerificationData { get }
    var dataPublisher: AnyPublisher<TransactionVerificationData, Never> { get }
    var highlightedTextViewModel: HighlightedTextViewModelProtocol { get }

    func configure(with data: TransactionVerificationData)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundTertiary` - view background
- `StyleProvider.Color.highlightPrimary` - top icon tint, highlighted text
- `StyleProvider.Color.textPrimary` - title text color
- `StyleProvider.fontWith(type: .bold, size: 14)` - title font

Layout constants:
- Top icon to safe area: 20pt
- Top icon size: 40pt x 40pt
- Title to icon spacing: 24pt
- Title horizontal padding: 20pt
- Highlighted text to title spacing: 16pt
- Highlighted text horizontal padding: 20pt
- Bottom image to text spacing: 32pt
- Bottom image height: 200pt
- Bottom image horizontal padding: 20pt

Animation:
- Top icon spins for "ussd_push" state
- Rotation: 360 degrees, 1 second duration, infinite repeat

Image resolution:
1. Try bundle image with name
2. Fallback to SF Symbol
3. Hide if not found

## Mock ViewModels

Available presets:
- `.defaultMock` - USSD push with phone highlight and spinning icon
- `.simpleMock` - Simple prompt without highlight
- `.incompletePinMock` - Incomplete PIN entry state
- `.completePinMock` - Complete PIN entry state

Methods:
- `configure(with:)` - Update verification data and highlighted text
