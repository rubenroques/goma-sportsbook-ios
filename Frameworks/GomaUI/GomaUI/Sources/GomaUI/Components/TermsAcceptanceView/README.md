# TermsAcceptanceView

A checkbox with terms text containing tappable links for legal acceptance.

## Overview

TermsAcceptanceView displays a checkbox alongside legal acceptance text with highlighted, tappable links for Terms and Conditions, Privacy Policy, and optionally Cookies Policy. The checkbox toggles acceptance state with visual feedback. Tapping highlighted terms triggers navigation callbacks. The component includes an error state for validation with a "Required field" message.

## Component Relationships

### Used By (Parents)
- Registration screens
- Account creation flows
- Consent forms

### Uses (Children)
- `HighlightedTextView` (for text with tappable links)

## Features

- Checkbox with check/uncheck animation
- Tappable highlighted links for terms documents
- Terms, Privacy, and Cookies link callbacks
- Error state with validation message
- Acceptance state tracking
- Hit-testing on specific text ranges
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockTermsAcceptanceViewModel.defaultMock
let termsView = TermsAcceptanceView(viewModel: viewModel)

// Handle checkbox toggle
termsView.onCheckboxToggled = { isAccepted in
    updateRegistrationState(accepted: isAccepted)
}

// Handle link taps
termsView.onTermsLinkTapped = { openTermsPage() }
termsView.onPrivacyLinkTapped = { openPrivacyPage() }
termsView.onCookiesLinkTapped = { openCookiesPage() }

// Show validation error
termsView.showError(true)

// Toggle acceptance programmatically
viewModel.toggleAcceptance()
```

## Data Model

```swift
struct TermsAcceptanceData {
    let id: String
    let fullText: String           // Complete legal text
    let termsText: String          // "Terms and Conditions" to highlight
    let privacyText: String        // "Privacy Policy" to highlight
    let cookiesText: String?       // Optional "Cookies" to highlight
    let isAccepted: Bool
}

protocol TermsAcceptanceViewModelProtocol {
    var data: TermsAcceptanceData { get }
    var dataPublisher: AnyPublisher<TermsAcceptanceData, Never> { get }
    var highlightedTextViewModel: HighlightedTextViewModelProtocol { get }

    func configure(with data: TermsAcceptanceData)
    func toggleAcceptance()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - checked state, link highlights
- `StyleProvider.Color.textSecondary` - unchecked border color
- `StyleProvider.Color.allWhite` - checkmark icon color
- `StyleProvider.fontWith(type: .regular, size: 12)` - error label, text

Layout constants:
- Checkbox size: 24pt x 24pt
- Checkbox corner radius: 4pt
- Checkbox border width: 2pt
- Checkmark size: 16pt
- Checkbox to text spacing: 12pt
- Error label left margin: 40pt
- Error label top spacing: 4pt

Checkbox states:
- Unchecked: clear background, gray border, hidden checkmark
- Checked: orange background, orange border, white checkmark

Icons:
- Bundle "check_icon" or SF Symbol "checkmark"

## Mock ViewModels

Available presets:
- `.defaultMock` - Full legal text with Terms and Privacy links
- `.acceptedMock` - Same text, pre-accepted
- `.shortTextMock` - Short text "I accept the Terms and Privacy Policy"

Methods:
- `configure(with:)` - Update terms data
- `toggleAcceptance()` - Toggle acceptance state
