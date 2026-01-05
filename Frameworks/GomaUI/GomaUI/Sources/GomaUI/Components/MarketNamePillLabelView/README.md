# MarketNamePillLabelView

A pill-shaped label for displaying market names with trailing fading line.

## Overview

MarketNamePillLabelView displays a market name in a compact pill-shaped container with a rounded border and a trailing horizontal fading line. The component supports multiple visual styles (standard, highlighted, disabled, custom) and can be interactive with tap gestures. It's designed for market identification in betting interfaces.

## Component Relationships

### Used By (Parents)
- `MarketInfoLineView` - market name display

### Uses (Children)
- `FadingView` - trailing fading line effect

## Features

- Pill-shaped border container (fully rounded)
- Trailing fading line (20pt width)
- Four visual styles: standard, highlighted, disabled, custom
- Interactive mode with tap gesture and animation
- Subtle shadow effect for interactive state
- Scale animation on tap (0.95x)
- Center-aligned text
- Dynamic style updates via Combine publisher

## Usage

```swift
let viewModel = MockMarketNamePillLabelViewModel.standardPill
let pillView = MarketNamePillLabelView(viewModel: viewModel)

pillView.onInteraction = {
    print("Pill tapped")
}

// Update style dynamically
let newData = MarketNamePillData(
    text: "Over/Under 2.5",
    style: .highlighted,
    isInteractive: true
)
viewModel.updatePillData(newData)
```

## Data Model

```swift
enum MarketNamePillStyle: Equatable, Hashable {
    case standard
    case highlighted
    case disabled
    case custom(borderColor: UIColor, textColor: UIColor, backgroundColor: UIColor?)
}

struct MarketNamePillData: Equatable, Hashable {
    let text: String
    let style: MarketNamePillStyle
    let isInteractive: Bool
}

struct MarketNamePillDisplayState: Equatable {
    let pillData: MarketNamePillData
}

protocol MarketNamePillLabelViewModelProtocol {
    var displayStatePublisher: AnyPublisher<MarketNamePillDisplayState, Never> { get }

    func updatePillData(_ data: MarketNamePillData)
    func updateDisplayState(_ state: MarketNamePillDisplayState)
    func handleInteraction()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - standard/highlighted border, text, line
- `StyleProvider.Color.separatorLineSecondary` - disabled border and line (50% alpha)
- `StyleProvider.Color.textSecondary` - disabled text (50% alpha)
- `StyleProvider.Color.shadow` - interactive hover shadow
- `StyleProvider.fontWith(type: .medium, size: 10)` - text font

Layout constants:
- Border width: 1.2pt
- Border corner radius: fully rounded (height / 2)
- Text padding: 6pt horizontal, 2pt vertical
- Fading line width: 20pt
- Fading line height: 1.2pt
- Shadow offset: (0, 1)
- Shadow radius: 2pt
- Shadow opacity: 0.1 (interactive only)

Style configurations:
- **Standard**: primary highlight border/text, clear background
- **Highlighted**: primary highlight border/text, 10% alpha background
- **Disabled**: 50% alpha secondary colors
- **Custom**: fully configurable colors

## Mock ViewModels

Available presets:
- `.standardPill` - "1X2" standard style
- `.highlightedPill` - "Over/Under" highlighted style
- `.disabledPill` - "Handicap" disabled style
- `.interactivePill` - "Both Teams to Score" interactive
- `.customStyledPill` - "Custom Market" purple custom style
- `.pillWithoutLine` - "No Line" standard
- `.longTextPill` - "Very Long Market Name" standard
- `.shortTextPill` - "FT" highlighted
- `.winDrawWinMarket` - "1X2" highlighted interactive
- `.overUnderMarket` - "Over/Under 2.5" standard interactive
- `.handicapMarket` - "Asian Handicap" standard interactive
- `.bothTeamsToScoreMarket` - "BTTS" standard interactive
