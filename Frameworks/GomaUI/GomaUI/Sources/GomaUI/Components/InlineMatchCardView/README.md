# InlineMatchCardView

A compact inline match card for sports event display with header, participants, scores, and betting outcomes.

## Overview

InlineMatchCardView provides a compact, horizontal layout for displaying sports match information. It combines a header with match metadata, participant names with optional live scores, and betting outcomes. The component is designed for efficient rendering in list-based interfaces and supports both pre-live and live events.

## Component Relationships

### Used By (Parents)
- None (standalone match card component)

### Uses (Children)
- `CompactMatchHeaderView` - match header with league, time, market count
- `CompactOutcomesLineView` - betting outcomes row
- `InlineScoreView` - live score display
- `ScoreView` - alternative score display

## Features

- Vertical layout: header row + content row
- Content row: participants with scores on left, outcomes on right
- Home/away participant labels (semibold 14pt)
- Live score display (hidden for pre-live events)
- Fixed 200pt outcomes line width
- Card tap gesture for navigation
- Outcome selection/deselection callbacks
- "More markets" tap callback
- Table view cell wrapper available
- Reusable with prepareForReuse support
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockInlineMatchCardViewModel.preLiveFootball
let matchCard = InlineMatchCardView(viewModel: viewModel)

matchCard.onCardTapped = {
    print("Navigate to match details")
}

matchCard.onOutcomeSelected = { outcomeId in
    print("Outcome selected: \(outcomeId)")
}

matchCard.onOutcomeDeselected = { outcomeId in
    print("Outcome deselected: \(outcomeId)")
}

matchCard.onMoreMarketsTapped = {
    print("Show more markets")
}

// Reconfigure for cell reuse
matchCard.configure(with: newViewModel)
```

## Data Model

```swift
struct InlineMatchData: Equatable, Hashable {
    let matchId: String
    let homeParticipantName: String
    let awayParticipantName: String
    let isLive: Bool
    let headerData: CompactMatchHeaderDisplayState
    let outcomesData: CompactOutcomesLineDisplayState
    let scoreData: InlineScoreDisplayState?
}

struct InlineMatchCardDisplayState: Equatable {
    let matchId: String
    let homeParticipantName: String
    let awayParticipantName: String
    let isLive: Bool
}

protocol InlineMatchCardViewModelProtocol: AnyObject {
    var displayStatePublisher: AnyPublisher<InlineMatchCardDisplayState, Never> { get }
    var currentDisplayState: InlineMatchCardDisplayState { get }

    var headerViewModelPublisher: AnyPublisher<CompactMatchHeaderViewModelProtocol, Never> { get }
    var outcomesViewModelPublisher: AnyPublisher<CompactOutcomesLineViewModelProtocol, Never> { get }
    var scoreViewModelPublisher: AnyPublisher<InlineScoreViewModelProtocol?, Never> { get }

    var currentHeaderViewModel: CompactMatchHeaderViewModelProtocol { get }
    var currentOutcomesViewModel: CompactOutcomesLineViewModelProtocol { get }
    var currentScoreViewModel: InlineScoreViewModelProtocol? { get }

    func onCardTapped()
    func onOutcomeSelected(outcomeId: String)
    func onOutcomeDeselected(outcomeId: String)
    func onMoreMarketsTapped()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundCards` - card background
- `StyleProvider.Color.textPrimary` - participant label color
- `StyleProvider.fontWith(type: .semibold, size: 14)` - participant font

Layout constants:
- Container vertical spacing: 4pt
- Content horizontal spacing: 4pt
- Participants vertical spacing: 1pt
- Horizontal padding: 10pt
- Vertical padding: 6pt
- Outcomes line width: 200pt
- Participant label height: 20pt

## Mock ViewModels

Available presets:
- `.preLiveFootball` - pre-live football match (1X2 market)
- `.preLiveFutureDate` - pre-live with future date
- `.liveTennis` - live tennis match (2-way with score)
- `.liveFootball` - live football match (3-way with score)
- `.liveBasketball` - live basketball match
- `.withSelectedOutcome` - pre-live with selected outcome
- `.lockedMarket` - market with locked outcomes
- `.productionMode` - no icons mode
- `.custom(...)` - fully customizable
