# CopyableCodeView

A simple code display component with tap-to-copy functionality and visual feedback.

## Overview

CopyableCodeView displays a label on the left and a tappable code badge on the right. Tapping the code copies it to the clipboard and shows a "Copied" confirmation with haptic feedback that automatically reverts after 2 seconds. This component is useful for displaying booking codes, promo codes, referral codes, or any shareable text.

## Component Relationships

### Used By (Parents)
- None (standalone component for code display)

### Uses (Children)
- None (leaf component)

## Features

- Left label for code description
- Right tappable badge with code and copy icon
- System copy icon (doc.on.doc.fill)
- Haptic feedback on copy
- Cross-dissolve animation to "Copied" state
- 2-second auto-revert to default state
- 4pt corner radius on container
- 12pt corner radius on badge
- Secondary background color
- Gradient background on badge

## Usage

```swift
let viewModel = MockCopyableCodeViewModel.bookingCodeMock
let codeView = CopyableCodeView(viewModel: viewModel)

// Copy action is handled internally via viewModel.onCopyTapped()
// Real implementation should copy to UIPasteboard.general.string
```

## Data Model

```swift
protocol CopyableCodeViewModelProtocol {
    var code: String { get }
    var label: String { get }
    var copiedMessage: String { get }

    func onCopyTapped()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - container background
- `StyleProvider.Color.backgroundGradient2` - badge background
- `StyleProvider.Color.backgroundTertiary` - preview background
- `StyleProvider.Color.textPrimary` - label text color
- `StyleProvider.Color.highlightPrimary` - code text, copy icon, and status text
- `StyleProvider.fontWith(type: .semibold, size: 13)` - label font
- `StyleProvider.fontWith(type: .bold, size: 18)` - code text font
- `StyleProvider.fontWith(type: .bold, size: 14)` - copied status font

Layout constants:
- Container corner radius: 4pt
- Badge corner radius: 12pt
- Badge height: 44pt
- Icon size: 24pt
- Horizontal padding: 16pt
- Badge padding: 12pt

## Mock ViewModels

Available presets:
- `.bookingCodeMock` - "ABCD1E2" with "Copy Booking Code" label
- `.promoCodeMock` - "SUMMER2025" with "Copy Promo Code" label
- `.longCodeMock` - "ABCD1E2F3G4H5J6K7" with "Copy Transaction ID" label
- `.referralCodeMock` - "REF-XYZ789" with "Copy Referral Code" label
