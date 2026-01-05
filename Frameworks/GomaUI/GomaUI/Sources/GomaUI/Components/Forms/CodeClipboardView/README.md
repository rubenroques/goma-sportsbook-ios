# CodeClipboardView

A copyable code display with clipboard functionality and visual feedback.

## Overview

CodeClipboardView displays a label on the left and a tappable code badge on the right. Tapping the code copies it to the clipboard and shows a "Copied" confirmation that automatically reverts after a delay. The component is commonly used for booking codes, referral codes, or any shareable text that users need to copy.

## Component Relationships

### Used By (Parents)
- None (standalone component for code display)

### Uses (Children)
- None (leaf component)

## Features

- Left label for code description
- Right tappable badge with code and copy icon
- Animated state transition on copy
- "Copied to clipboard" confirmation text
- 5-second auto-revert to default state
- Enable/disable state with alpha dimming
- 4pt corner radius on container
- Secondary background color
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockCodeClipboardViewModel.defaultMock()
let clipboardView = CodeClipboardView(viewModel: viewModel)

// Tapping automatically copies and shows confirmation
// Custom logic can be added via ViewModel's onCopyTapped()
```

## Data Model

```swift
enum CodeClipboardState: Equatable {
    case `default`
    case copied
}

struct CodeClipboardData: Equatable {
    let state: CodeClipboardState
    let code: String
    let labelText: String
    let isEnabled: Bool
}

protocol CodeClipboardViewModelProtocol {
    var dataPublisher: AnyPublisher<CodeClipboardData, Never> { get }
    var currentData: CodeClipboardData { get }

    func updateCode(_ code: String)
    func setCopied(_ isCopied: Bool)
    func setEnabled(_ isEnabled: Bool)
    func onCopyTapped()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - container background
- `StyleProvider.Color.backgroundGradient2` - copy button background
- `StyleProvider.Color.textPrimary` - left label text color
- `StyleProvider.Color.highlightPrimary` - code text, copy icon, and status text
- `StyleProvider.fontWith(type: .medium, size: 16)` - left label font
- `StyleProvider.fontWith(type: .bold, size: 18)` - code text font
- `StyleProvider.fontWith(type: .bold, size: 12)` - copied status font

Layout constants:
- Container corner radius: 4pt
- Badge corner radius: 12pt
- Badge padding: 12pt horizontal, 8pt vertical
- Icon size: 24pt
- Horizontal padding: 16pt

## Mock ViewModels

Available presets:
- `.defaultMock()` - default state with code "ABCD1E2"
- `.copiedMock()` - showing "Copied" state
- `.withCustomCodeMock()` - custom code "XYZ789"
- `.disabledMock()` - disabled/non-interactive state
