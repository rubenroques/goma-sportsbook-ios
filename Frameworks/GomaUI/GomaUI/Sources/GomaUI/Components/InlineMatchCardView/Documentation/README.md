# InlineMatchCardView

A compact inline match card component that replaces TallOddsMatchCardView with a more streamlined layout for event display.

## Overview

`InlineMatchCardView` is a composite component that assembles:
- **CompactMatchHeaderView** - Date/time or LIVE badge + icons
- **Participant labels** - Home and away team/player names
- **InlineScoreView** - Compact live scores (hidden for pre-live)
- **CompactOutcomesLineView** - 2-3 outcome buttons

## Architecture

### Files
```
InlineMatchCardView/
├── InlineMatchCardView.swift              # Main composite view
├── InlineMatchCardViewModelProtocol.swift # Protocol + data models
├── MockInlineMatchCardViewModel.swift     # Mock implementation
└── Documentation/
    └── README.md
```

### Component Structure
```
InlineMatchCardView
├── containerStackView (vertical)
│   ├── CompactMatchHeaderView
│   │   ├── Left: Date/time OR LIVE badge
│   │   └── Right: Icons + market count
│   │
│   └── contentStackView (horizontal)
│       ├── participantsContainer (left)
│       │   ├── participantsStackView
│       │   │   ├── homeParticipantLabel
│       │   │   └── awayParticipantLabel
│       │   └── InlineScoreView (hidden when pre-live)
│       │
│       └── CompactOutcomesLineView (right)
│           ├── OutcomeItemView (1)
│           ├── OutcomeItemView (X) - optional
│           └── OutcomeItemView (2)
```

## Usage

### Basic Usage

```swift
// Pre-live football
let preLiveCard = InlineMatchCardView(
    viewModel: MockInlineMatchCardViewModel.preLiveFootball
)

// Live tennis with scores
let liveCard = InlineMatchCardView(
    viewModel: MockInlineMatchCardViewModel.liveTennis
)
```

### Handle Callbacks

```swift
cardView.onCardTapped = { [weak self] in
    self?.coordinator?.showMatchDetails(matchId: matchId)
}

cardView.onOutcomeSelected = { [weak self] outcomeId in
    self?.coordinator?.addToBetslip(outcomeId: outcomeId)
}

cardView.onOutcomeDeselected = { [weak self] outcomeId in
    self?.coordinator?.removeFromBetslip(outcomeId: outcomeId)
}

cardView.onMoreMarketsTapped = { [weak self] in
    self?.coordinator?.showMoreMarkets(matchId: matchId)
}
```

### Cell Reuse Pattern

```swift
override func prepareForReuse() {
    super.prepareForReuse()
    cardView.prepareForReuse()
}

func configure(with viewModel: InlineMatchCardViewModelProtocol) {
    cardView.configure(with: viewModel)

    // Re-establish callbacks
    cardView.onCardTapped = { ... }
    cardView.onOutcomeSelected = { ... }
}
```

## Data Models

### InlineMatchCardDisplayState

```swift
struct InlineMatchCardDisplayState {
    let matchId: String
    let homeParticipantName: String
    let awayParticipantName: String
    let isLive: Bool
}
```

### InlineMatchData (Full Data)

```swift
struct InlineMatchData {
    let matchId: String
    let homeParticipantName: String
    let awayParticipantName: String
    let isLive: Bool
    let headerData: CompactMatchHeaderDisplayState
    let outcomesData: CompactOutcomesLineDisplayState
    let scoreData: InlineScoreDisplayState?
}
```

## Protocol Requirements

### Dual-Access Pattern

```swift
protocol InlineMatchCardViewModelProtocol {
    // Publishers (async updates)
    var displayStatePublisher: AnyPublisher<...>
    var headerViewModelPublisher: AnyPublisher<...>
    var outcomesViewModelPublisher: AnyPublisher<...>
    var scoreViewModelPublisher: AnyPublisher<...>

    // Current values (sync access for UITableView sizing)
    var currentDisplayState: InlineMatchCardDisplayState
    var currentHeaderViewModel: CompactMatchHeaderViewModelProtocol
    var currentOutcomesViewModel: CompactOutcomesLineViewModelProtocol
    var currentScoreViewModel: InlineScoreViewModelProtocol?

    // Actions
    func onCardTapped()
    func onOutcomeSelected(outcomeId: String)
    func onOutcomeDeselected(outcomeId: String)
    func onMoreMarketsTapped()
}
```

## States

| State | Header | Score | Outcomes |
|-------|--------|-------|----------|
| Pre-live Football | TODAY, 14:00 | Hidden | 1 X 2 |
| Pre-live Tennis | 17/07, 11:00 | Hidden | 1 2 |
| Live Football | LIVE 45' | 2-1 | 1 X 2 |
| Live Tennis | LIVE 2ND SET | 30|6 4 | 1 2 |
| Selected | Any | Any | One highlighted |
| Locked | Any | Any | All locked |

## Mock Configurations

### Pre-Live
```swift
MockInlineMatchCardViewModel.preLiveFootball    // Football 1X2
MockInlineMatchCardViewModel.preLiveFutureDate  // Future date
MockInlineMatchCardViewModel.productionMode     // No icons
```

### Live
```swift
MockInlineMatchCardViewModel.liveTennis         // Tennis with sets
MockInlineMatchCardViewModel.liveFootball       // Football with score
MockInlineMatchCardViewModel.liveBasketball     // Basketball with quarters
```

### Special States
```swift
MockInlineMatchCardViewModel.withSelectedOutcome // Selection
MockInlineMatchCardViewModel.lockedMarket       // All locked
```

## Comparison with TallOddsMatchCardView

| Feature | InlineMatchCardView | TallOddsMatchCardView |
|---------|--------------------|-----------------------|
| Height | Compact | Taller |
| Multi-line outcomes | No | Yes |
| Market name pill | No | Yes |
| Separator line | No | Yes |
| Score position | Inline with names | Separate column |
| Use case | BetssonCameroonApp | Legacy/other clients |

## Styling

All styling via StyleProvider:
- Background: `StyleProvider.Color.backgroundCards`
- Participant text: `StyleProvider.fontWith(type: .semibold, size: 14)`
- Text color: `StyleProvider.Color.textPrimary`

## Constants

```swift
containerSpacing: 8.0pt   // Between header and content
contentSpacing: 12.0pt    // Between participants and outcomes
horizontalPadding: 12.0pt // Card horizontal padding
verticalPadding: 10.0pt   // Card vertical padding
```
