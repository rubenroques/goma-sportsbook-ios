# HighlightedTextView

A text view with support for multiple highlighted text ranges with customizable colors and styles.

## Overview

HighlightedTextView displays text with specific portions highlighted in different colors or styles. It supports multiple highlight types including bold highlights and underlined links, making it suitable for displaying text with emphasized elements, clickable terms, or formatted instructions.

## Component Relationships

### Used By (Parents)
- `StepInstructionView` - instruction text with highlights
- `TermsAcceptanceView` - terms text with highlighted links
- `TransactionVerificationView` - verification text with highlights

### Uses (Children)
- None (leaf component)

## Features

- Multiple text highlight ranges
- Two highlight types: bold highlights and underlined links
- Configurable text alignment (left, center, right)
- Customizable base font type and size
- Per-highlight color customization
- 4pt line spacing
- Reactive updates via Combine publisher
- Helper method to find text ranges
- Attributed string rendering

## Usage

```swift
let viewModel = MockHighlightedTextViewModel.defaultMock()
let highlightedView = HighlightedTextView(viewModel: viewModel)

// Create custom highlight data
let fullText = "Transfer $500.00 to John Smith"
let highlight = HighlightData(
    text: "$500.00",
    color: StyleProvider.Color.highlightPrimary,
    ranges: HighlightedTextView.findRanges(of: "$500.00", in: fullText)
)

let data = HighlightedTextData(
    fullText: fullText,
    highlights: [highlight],
    textAlignment: .left
)
viewModel.configure(with: data)
```

## Data Model

```swift
enum HighlightType {
    case highlight  // Bold, 14pt, no underline
    case link       // Regular, 12pt, underlined
}

struct HighlightData {
    let text: String
    let color: UIColor
    let ranges: [NSRange]
    let type: HighlightType
}

struct HighlightedTextData {
    let id: String
    let fullText: String
    let highlights: [HighlightData]
    let textAlignment: NSTextAlignment
    let baseFontType: StyleProvider.FontType
    let baseFontSize: CGFloat
}

protocol HighlightedTextViewModelProtocol {
    var data: HighlightedTextData { get }
    var dataPublisher: AnyPublisher<HighlightedTextData, Never> { get }

    func configure(with data: HighlightedTextData)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.textPrimary` - base text color
- `StyleProvider.fontWith(type:size:)` - configurable fonts

Layout constants:
- Line spacing: 4pt
- Background: clear
- Number of lines: unlimited (0)

Highlight type styling:
- `.highlight`: Bold font, 14pt, no underline
- `.link`: Regular font, 12pt, underlined

## Helper Methods

```swift
// Find all ranges of a substring in text
static func findRanges(of substring: String, in text: String) -> [NSRange]
```

## Mock ViewModels

Available presets:
- `.defaultMock()` - "USSD Push interaction" with phone number highlighted
- `.centeredMock()` - "24 hours" highlighted, center-aligned
- `.rightAlignedMock()` - "$1,250.00" highlighted, right-aligned
- `.multipleHighlightsMock()` - multiple highlights (amount, name, phone)
- `.linkMock()` - "Terms and Conditions" and "Privacy Policy" as underlined links
