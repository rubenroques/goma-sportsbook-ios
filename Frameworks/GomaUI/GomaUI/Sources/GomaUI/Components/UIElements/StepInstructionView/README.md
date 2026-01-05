# StepInstructionView

A numbered step instruction with highlighted keywords for guiding users through processes.

## Overview

StepInstructionView displays a numbered step indicator circle alongside instruction text with highlighted keywords. It uses HighlightedTextView to render text with colored keywords (e.g., button names, important terms) for emphasis. The component is used in onboarding flows, payment instructions, and multi-step processes where clear guidance is needed.

## Component Relationships

### Used By (Parents)
- Payment instruction screens
- Onboarding flows
- Help/tutorial sections

### Uses (Children)
- `HighlightedTextView` (for instruction text with highlights)

## Features

- Numbered step indicator circle (32pt)
- Highlighted text with auto-detected keyword ranges
- Customizable indicator and text colors
- Left-aligned instruction text
- Flexible width layout
- Reactive updates via Combine publishers

## Usage

```swift
let data = StepInstructionData(
    stepNumber: 1,
    instructionText: "On the mobile money menu, select Pay Bill, then select the Betsson option.",
    highlightedWords: ["Pay Bill", "Betsson"]
)
let viewModel = MockStepInstructionViewModel(data: data)
let stepView = StepInstructionView(viewModel: viewModel)

// Custom indicator colors
let customData = StepInstructionData(
    stepNumber: 2,
    instructionText: "Click the Confirm Payment button below.",
    highlightedWords: ["Confirm Payment"],
    indicatorColor: StyleProvider.Color.highlightSecondary,
    numberTextColor: StyleProvider.Color.textPrimary
)
let customView = StepInstructionView(viewModel: MockStepInstructionViewModel(data: customData))
```

## Data Model

```swift
struct StepInstructionData {
    let id: String
    let stepNumber: Int
    let instructionText: String
    let highlightedWords: [String]
    let indicatorColor: UIColor?     // nil = highlightPrimary
    let numberTextColor: UIColor?    // nil = buttonTextPrimary
}

protocol StepInstructionViewModelProtocol {
    var data: StepInstructionData { get }
    var dataPublisher: AnyPublisher<StepInstructionData, Never> { get }
    var highlightedTextViewModel: HighlightedTextViewModelProtocol { get }

    func configure(with data: StepInstructionData)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - default indicator background, highlight color
- `StyleProvider.Color.buttonTextPrimary` - default step number text color
- `StyleProvider.fontWith(type: .bold, size: 16)` - step number font

Layout constants:
- Indicator size: 32pt x 32pt
- Indicator corner radius: 16pt (circular)
- Indicator leading: 16pt
- Text leading from indicator: 8pt
- Text trailing: 16pt
- Vertical padding: 8pt

Highlighted text:
- Handled by HighlightedTextView child component
- Keywords automatically colorized in highlightPrimary
- Left-aligned text

## Mock ViewModels

Available presets:
- `.defaultMock` - Mobile money step with "x" placeholder highlighted
- `.customColorMock` - Step 2 with custom colors and "Confirm Payment" highlighted
- `.multipleHighlightsMock` - Step 3 with two highlighted phrases

Methods:
- `configure(with:)` - Update step data reactively
