# OutcomeItemView

An individual betting outcome item displaying title, odds value, and selection state with animated odds changes.

## Overview

OutcomeItemView represents a single betting outcome (e.g., "Home 1.85" or "Over 2.5 1.95"). It displays the outcome name/title and its odds value, supporting selection states, odds change animations with directional indicators, and multiple display states including loading, locked, and boosted. The component handles tap and long-press gestures and provides haptic feedback on selection.

## Component Relationships

### Used By (Parents)
- `CompactOutcomesLineView`
- `MarketOutcomesLineView`

### Uses (Children)
- None (leaf component)

## Features

- Title label (outcome name)
- Value label (odds value)
- Selected/unselected visual states
- Odds change animations (up/down arrows with colored backgrounds)
- Loading state with activity indicator
- Locked state with lock icon
- Unavailable state (shows "-")
- Boosted state with boost icon
- Position-based corner rounding for grid layouts
- Tap gesture for selection toggle
- Long press gesture with callback
- Haptic feedback on selection
- Configurable font sizes via OutcomeItemConfiguration
- Reactive updates via Combine publishers
- Synchronous initial rendering for snapshot tests

## Usage

```swift
let viewModel = MockOutcomeItemViewModel.homeOutcome
let outcomeView = OutcomeItemView(viewModel: viewModel)

// Position-based corners for multi-line layouts
outcomeView.setPosition(.multiTopLeft)

// Custom configuration
let config = OutcomeItemConfiguration(
    titleFontSize: 10.0,
    titleFontType: .regular,
    valueFontSize: 14.0,
    valueFontType: .bold
)
outcomeView.setCustomization(config)

// Long press callback
outcomeView.onLongPress = {
    showMarketDetails()
}

// Reconfigure for cell reuse
outcomeView.configure(with: newViewModel)
```

## Data Model

```swift
enum OutcomeDisplayState: Hashable {
    case loading
    case locked
    case unavailable
    case normal(isSelected: Bool, isBoosted: Bool)
}

enum OddsChangeDirection {
    case up
    case down
    case none
}

struct OutcomeItemData: Equatable, Hashable {
    let id: String
    let bettingOfferId: String?
    let title: String
    let value: String
    let oddsChangeDirection: OddsChangeDirection
    let displayState: OutcomeDisplayState
    let previousValue: String?
    let changeTimestamp: Date?
}

enum OutcomePosition {
    case single           // All corners rounded
    case singleFirst      // Left corners rounded
    case singleLast       // Right corners rounded
    case multiTopLeft     // Top-left corner
    case multiTopRight    // Top-right corner
    case multiBottomLeft  // Bottom-left corner
    case multiBottomRight // Bottom-right corner
    case middle           // No corners rounded
}

struct OutcomeItemConfiguration: Equatable {
    let titleFontSize: CGFloat
    let titleFontType: StyleProvider.FontType
    let valueFontSize: CGFloat
    let valueFontType: StyleProvider.FontType

    static let `default`: OutcomeItemConfiguration
    static let compact: OutcomeItemConfiguration
}

protocol OutcomeItemViewModelProtocol {
    var currentOutcomeData: OutcomeItemData { get }
    var outcomeDataSubject: CurrentValueSubject<OutcomeItemData, Never> { get }
    var oddsChangeEventPublisher: AnyPublisher<OutcomeItemOddsChangeEvent, Never> { get }
    var selectionDidChangePublisher: AnyPublisher<OutcomeSelectionChangeEvent, Never> { get }
    var titlePublisher: AnyPublisher<String, Never> { get }
    var valuePublisher: AnyPublisher<String, Never> { get }
    var isSelectedPublisher: AnyPublisher<Bool, Never> { get }
    var isDisabledPublisher: AnyPublisher<Bool, Never> { get }
    var displayStatePublisher: AnyPublisher<OutcomeDisplayState, Never> { get }

    func userDidTapOutcome()
    func setSelected(_ selected: Bool)
    func setDisabled(_ disabled: Bool)
    func setDisplayState(_ state: OutcomeDisplayState)
    func updateValue(_ newValue: String)
    func updateValue(_ newValue: String, changeDirection: OddsChangeDirection)
    func clearOddsChangeIndicator()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - base view background
- `StyleProvider.Color.backgroundOdds` - normal/loading/locked state background
- `StyleProvider.Color.backgroundDisabledOdds` - unavailable state background
- `StyleProvider.Color.highlightPrimary` - selected state background, loading indicator, boost icon
- `StyleProvider.Color.allWhite` - selected state text/icon colors
- `StyleProvider.Color.textOdds` - normal state text color
- `StyleProvider.Color.textDisabledOdds` - unavailable state text color
- `StyleProvider.Color.textPrimary` - title/value text color
- `StyleProvider.Color.iconSecondary` - lock icon color
- `StyleProvider.Color.myTicketsWon` - odds up border color
- `StyleProvider.Color.myTicketsWonFaded` - odds up background color
- `StyleProvider.Color.myTicketsLost` - odds down border color
- `StyleProvider.Color.myTicketsLostFaded` - odds down background color
- `StyleProvider.fontWith(type: .regular, size: 12)` - default title font
- `StyleProvider.fontWith(type: .bold, size: 16)` - default value font

Layout constants:
- Corner radius: 4.5pt
- Title top padding: 6pt
- Horizontal padding: 2pt
- Title height: 14pt
- Change indicator size: 12pt
- Border width: 1pt (during animation)
- Lock icon size: 16pt x 16pt
- Boost icon size: 10pt x 10pt

Odds change animation:
- Up/down arrow indicators appear
- Background color changes (green/red faded)
- Border animates to solid color
- Auto-hides after 3 seconds

## Mock ViewModels

Available presets:
- `.homeOutcome` - Home team, selected, value 1.85
- `.drawOutcome` - Draw, unselected, value 3.55
- `.awayOutcome` - Away team, unselected, value 4.20
- `.overOutcomeUp` - Over 2.5, odds going up
- `.underOutcomeDown` - Under 2.5, odds going down
- `.disabledOutcome` - Unavailable state
- `.loadingOutcome` - Loading state
- `.lockedOutcome` - Locked state
- `.unavailableOutcome` - Shows "-"
- `.boostedOutcome` - Boosted, unselected
- `.boostedOutcomeSelected` - Boosted and selected
- `.customOutcome(...)` - Factory with full customization
