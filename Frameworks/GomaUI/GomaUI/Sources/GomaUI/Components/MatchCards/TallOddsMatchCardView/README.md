# TallOddsMatchCardView

A comprehensive match betting card displaying league header, participants, scores, market info, and betting outcomes.

## Overview

TallOddsMatchCardView is a composite component that displays all betting-relevant information for a sports match in a tall card format. It includes a league/competition header, home and away participant names with optional live scores, market information with icons, and selectable betting outcomes. The component supports both live and pre-match states with real-time reactive updates.

## Component Relationships

### Used By (Parents)
- `SuggestedBetsExpandedView` - suggested bets carousel
- Match listing screens
- Home page match displays

### Uses (Children)
- `MatchHeaderView` - league/competition header with icons
- `MarketInfoLineView` - market name and icons
- `MarketOutcomesMultiLineView` - betting outcome buttons
- `ScoreView` - live match scores
- `FadingView` - separator with gradient fade

## Features

- League/competition header with sport icon and favorite toggle
- Home and away participant name labels
- Live score display (visible only during live matches)
- Market information with icons (popular, statistics, bet builder)
- Multi-line betting outcome selection
- Animated separator with gradient fade
- Custom background color support
- Cell reuse support with prepareForReuse()
- Synchronous state access for UITableView sizing
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockTallOddsMatchCardViewModel.premierLeagueMock
let matchCard = TallOddsMatchCardView(viewModel: viewModel)

// With custom background
let clearCard = TallOddsMatchCardView(
    viewModel: viewModel,
    customBackgroundColor: .clear
)

// With custom image resolver
let customCard = TallOddsMatchCardView(
    viewModel: viewModel,
    imageResolver: CustomImageResolver()
)

// Handle callbacks
matchCard.onMatchHeaderTapped = { navigateToMatchDetails() }
matchCard.onOutcomeSelected = { outcomeId in addToBetslip(outcomeId) }
matchCard.onCardTapped = { navigateToMatch() }

// Reconfigure for cell reuse
matchCard.configure(with: newViewModel)
```

## Data Model

```swift
struct TallOddsMatchData: Equatable, Hashable {
    let matchId: String
    let leagueInfo: MatchHeaderData
    let homeParticipantName: String
    let awayParticipantName: String
    let marketInfo: MarketInfoData
    let outcomes: MarketGroupData
    let liveScoreData: LiveScoreData?
}

struct TallOddsMatchCardDisplayState: Equatable {
    let matchId: String
    let homeParticipantName: String
    let awayParticipantName: String
    let isLive: Bool
}

protocol TallOddsMatchCardViewModelProtocol {
    // Synchronous access
    var currentDisplayState: TallOddsMatchCardDisplayState { get }
    var currentMatchHeaderViewModel: MatchHeaderViewModelProtocol { get }
    var currentMarketInfoLineViewModel: MarketInfoLineViewModelProtocol { get }
    var currentMarketOutcomesViewModel: MarketOutcomesMultiLineViewModelProtocol { get }
    var currentScoreViewModel: ScoreViewModelProtocol? { get }

    // Publishers
    var displayStatePublisher: AnyPublisher<TallOddsMatchCardDisplayState, Never> { get }
    var matchHeaderViewModelPublisher: AnyPublisher<MatchHeaderViewModelProtocol, Never> { get }
    var marketInfoLineViewModelPublisher: AnyPublisher<MarketInfoLineViewModelProtocol, Never> { get }
    var marketOutcomesViewModelPublisher: AnyPublisher<MarketOutcomesMultiLineViewModelProtocol, Never> { get }
    var scoreViewModelPublisher: AnyPublisher<ScoreViewModelProtocol?, Never> { get }

    // Actions
    func onMatchHeaderAction()
    func onFavoriteToggle()
    func onOutcomeSelected(outcomeId: String)
    func onOutcomeDeselected(outcomeId: String)
    func onMarketInfoTapped()
    func onCardTapped()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundCards` - container background
- `StyleProvider.Color.backgroundSecondary` - fallback container background
- `StyleProvider.Color.textPrimary` - participant name labels
- `StyleProvider.Color.highlightPrimary` - separator line color
- `StyleProvider.fontWith(type: .semibold, size: 14.5)` - participant name font

Layout constants:
- Content stack spacing: 4pt
- Separator container height: 10pt
- Separator line height: 1pt
- Participant label height: 20pt
- Participant stack spacing: 2pt
- Score to participant spacing: 8pt minimum

Child component heights:
- MatchHeaderView: dynamic
- MarketInfoLineView: 18pt
- MarketOutcomesMultiLineView: dynamic based on outcome count

## Mock ViewModels

Available presets:
- `.premierLeagueMock` - Liverpool vs Arsenal with icons
- `.compactMock` - Barcelona vs Real Madrid minimal
- `.bundesliegaMock` - Bayern vs Dortmund with all icons
- `.liveMock` - Chelsea vs Tottenham live with scores

Factory methods:
- `.premierLeagueMock(singleLineOutcomes:)` - Control outcome layout
- `.compactMock(singleLineOutcomes:)` - Minimal with layout control
- `.bundesliegaMock(singleLineOutcomes:)` - Full icons with layout
- `.liveMock(singleLineOutcomes:)` - Live match with layout control

Methods:
- `configure(with:)` - Reconfigure with new ViewModel
- `prepareForReuse()` - Clear state for cell reuse
