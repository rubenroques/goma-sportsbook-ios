# CasinoGamePlayModeSelectorView

A full-screen game details overlay with play mode selection buttons.

## Overview

CasinoGamePlayModeSelectorView displays casino game details including thumbnail image, title, description, and configurable action buttons. It's designed for showing game information before launching, with different button configurations based on user state (logged out, logged in, insufficient funds). The component supports loading states and multiple button styles.

## Component Relationships

### Used By (Parents)
- None (typically presented as a modal overlay)

### Uses (Children)
- None (uses native UIButton components)

## Features

- Centered game thumbnail image (200x120pt with 12pt corner radius)
- Game title (up to 2 lines, bold 24pt white text)
- Optional game description (multi-line)
- Vertically stacked action buttons with configurable styles
- Button styles: filled, outlined, text
- Button types: primary, secondary, tertiary
- Button states: enabled, disabled, loading
- Loading overlay with activity indicator
- Scroll view for content overflow
- Clear background for overlay use
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockCasinoGamePlayModeSelectorViewModel.defaultMock
let selectorView = CasinoGamePlayModeSelectorView(viewModel: viewModel)

selectorView.onButtonTapped = { buttonId in
    switch buttonId {
    case "login":
        print("Navigate to login")
    case "practice":
        print("Start practice mode")
    case "play":
        print("Start real money play")
    default:
        break
    }
}
```

## Data Model

```swift
struct CasinoGamePlayModeSelectorGameData: Equatable, Hashable {
    let id: String
    let name: String
    let thumbnailURL: String?
    let backgroundURL: String?
    let provider: String?
    let volatility: String?
    let minStake: String
    let description: String?
}

struct CasinoGamePlayModeButton: Equatable, Hashable {
    let id: String
    let type: ButtonType       // primary, secondary, tertiary
    let title: String
    let state: ButtonState     // enabled, disabled, loading
    let style: ButtonStyle     // filled, outlined, text
}

struct CasinoGamePlayModeSelectorDisplayState: Equatable {
    let gameData: CasinoGamePlayModeSelectorGameData
    let buttons: [CasinoGamePlayModeButton]
    let isLoading: Bool
}

protocol CasinoGamePlayModeSelectorViewModelProtocol: AnyObject {
    var displayStatePublisher: AnyPublisher<CasinoGamePlayModeSelectorDisplayState, Never> { get }

    func buttonTapped(buttonId: String)
    func refreshGameData()
    func setLoading(_ loading: Bool)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - image placeholder background
- `StyleProvider.Color.highlightPrimary` - primary filled button, error background
- `StyleProvider.Color.highlightSecondary` - secondary filled button
- `StyleProvider.Color.buttonTextPrimary` - primary button text
- `StyleProvider.Color.textPrimary` - secondary button text, loading indicator
- `StyleProvider.Color.allWhite` - outlined button text/border
- `StyleProvider.fontWith(type: .bold, size: 24)` - game title font
- `StyleProvider.fontWith(type: .regular, size: 14)` - description font
- `StyleProvider.fontWith(type: .medium, size: 16)` - button font

Layout constants:
- Thumbnail size: 200x120pt
- Button height: 50pt
- Button spacing: 12pt
- Content padding: 24pt

## Mock ViewModels

Available presets:
- `.defaultMock` - logged-out user (LOGIN + PRACTICE buttons)
- `.loggedInMock` - logged-in user with funds (PLAY NOW + PRACTICE)
- `.insufficientFundsMock` - logged-in, no funds (DEPOSIT + PRACTICE)
- `.loadingMock` - loading state with disabled buttons
- `.disabledMock` - game under maintenance
- `.interactiveMock` - interactive demo for testing
