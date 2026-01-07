# OddsAcceptanceView

A checkbox component for odds change acceptance with label and clickable link.

## Overview

OddsAcceptanceView displays a checkbox with an acceptance label and a tappable "Learn More" link. It's used in betslip interfaces to let users accept odds changes during bet placement. The checkbox toggles between accepted/not accepted states, and the link text is tappable for more information.

## Component Relationships

### Used By (Parents)
- Betslip submission views
- Bet placement forms

### Uses (Children)
- None (leaf component)

## Features

- Checkbox with checkmark icon
- Acceptance label text
- Underlined clickable link text
- Accepted/not accepted visual states
- Enabled/disabled states (alpha 0.5)
- Checkbox toggle on tap
- Link detection with tap gesture
- ViewModel replacement support
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockOddsAcceptanceViewModel.notAcceptedMock()
let acceptanceView = OddsAcceptanceView(viewModel: viewModel)

// Toggle acceptance state programmatically
viewModel.updateState(.accepted)

// Custom label text
viewModel.updateLabelText("I accept changes to")
viewModel.updateLinkText("odds")

// Disable the component
viewModel.setEnabled(false)

// Handle link tap (done in ViewModel)
// viewModel.onLinkTapped() is called when link is tapped
```

## Data Model

```swift
enum OddsAcceptanceState: Equatable {
    case accepted
    case notAccepted
}

struct OddsAcceptanceData: Equatable {
    let state: OddsAcceptanceState
    let labelText: String      // Default: "Accept odds change"
    let linkText: String       // Default: "Learn more"
    let isEnabled: Bool
}

protocol OddsAcceptanceViewModelProtocol {
    var dataPublisher: AnyPublisher<OddsAcceptanceData, Never> { get }
    var currentData: OddsAcceptanceData { get }

    func updateState(_ state: OddsAcceptanceState)
    func updateLabelText(_ text: String)
    func updateLinkText(_ text: String)
    func setEnabled(_ isEnabled: Bool)
    func onCheckboxTapped()
    func onLinkTapped()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundBorder` - checkbox border (unchecked)
- `StyleProvider.Color.highlightPrimary` - checkbox background/border (checked)
- `StyleProvider.Color.allWhite` - checkmark icon color
- `StyleProvider.Color.textPrimary` - label and link text color
- `StyleProvider.fontWith(type: .regular, size: 14)` - label font (init)
- `StyleProvider.fontWith(type: .regular, size: 12)` - label font (render)

Layout constants:
- Stack spacing: 12pt
- Checkbox size: 24pt x 24pt
- Checkbox corner radius: 4pt
- Checkbox border width: 1pt
- Checkmark icon size: 12pt x 12pt

Visual states:
- **Accepted**: Primary highlight background, checkmark visible
- **Not Accepted**: Clear background, border only, no checkmark
- **Disabled**: Alpha 0.5, interactions disabled

Link detection:
- Uses NSLayoutManager for precise tap location
- Calculates character index from tap point
- Checks if tap falls within link text range

## Mock ViewModels

Available presets:
- `.acceptedMock()` - Checkbox checked state
- `.notAcceptedMock()` - Checkbox unchecked state
- `.disabledMock()` - Unchecked, disabled state
