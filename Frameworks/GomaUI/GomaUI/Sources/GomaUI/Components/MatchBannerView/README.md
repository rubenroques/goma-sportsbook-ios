# MatchBannerView

A promotional banner for displaying match information with background image, team names, scores, and betting outcomes.

## Overview

MatchBannerView displays a featured match in a banner format with a customizable background image, league header, team names with optional live scores, and integrated betting outcomes. It conforms to TopBannerViewProtocol for use in banner carousels and supports both pre-live and live match states. The component uses Kingfisher for asynchronous image loading.

## Component Relationships

### Used By (Parents)
- Banner carousel components
- Home page featured matches

### Uses (Children)
- `MarketOutcomesLineView` - betting outcomes display

## Features

- Background image with Kingfisher loading
- League/competition header text
- Home and away team name labels
- Live score display (hidden for pre-live)
- Integrated betting outcomes (3-way market)
- Banner tap gesture with callback
- Outcome selection/deselection callbacks
- TopBannerViewProtocol conformance
- Visibility lifecycle methods
- Empty state handling
- Synchronous configuration for collection view sizing

## Usage

```swift
let viewModel = MockMatchBannerViewModel.liveMatch
let bannerView = MatchBannerView()
bannerView.configure(with: viewModel)

bannerView.onOutcomeSelected = { outcomeId in
    print("Selected outcome: \(outcomeId)")
}

bannerView.onOutcomeDeselected = { outcomeId in
    print("Deselected outcome: \(outcomeId)")
}

// ViewModel callbacks
viewModel.onMatchTap = { matchId in
    print("Navigate to match: \(matchId)")
}

viewModel.onOutcomeSelected = { outcomeId in
    print("Add to betslip: \(outcomeId)")
}
```

## Data Model

```swift
struct MatchBannerModel {
    let id: String
    let isLive: Bool
    let dateTime: Date
    let leagueName: String
    let homeTeam: String
    let awayTeam: String
    let backgroundImageURL: String?
    let matchTime: String?
    let homeScore: Int?
    let awayScore: Int?
    let outcomes: [MatchOutcome]

    // Computed properties
    var formattedDateTime: String
    var headerText: String
    var hasValidScore: Bool
}

struct MatchOutcome {
    let id: String
    let displayName: String
    let odds: Double
    let isSelected: Bool
    let isEnabled: Bool
}

protocol MatchBannerViewModelProtocol {
    var currentMatchData: MatchBannerModel { get }
    var marketOutcomesViewModel: MarketOutcomesLineViewModelProtocol { get }

    var onMatchTap: ((String) -> Void)? { get set }
    var onOutcomeSelected: ((String) -> Void)? { get set }
    var onOutcomeDeselected: ((String) -> Void)? { get set }

    func userDidTapBanner()
    func onOutcomeSelected(outcomeId: String)
    func onOutcomeDeselected(outcomeId: String)
}

protocol TopBannerViewProtocol {
    var type: String { get }
    var isVisible: Bool { get set }
    func bannerDidBecomeVisible()
    func bannerDidBecomeHidden()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.allWhite` - header, team, score text color
- `StyleProvider.Color.backgroundGradientDark` - fallback background color
- `StyleProvider.fontWith(type: .regular, size: 11)` - header label font
- `StyleProvider.fontWith(type: .bold, size: 14)` - team/score label font

Layout constants:
- Content padding: 16pt (all sides)
- Header height: 16pt
- Team label height: 16pt
- Header to home team gap: 4pt
- Home to away team gap: 4pt
- Away team to outcomes gap: 6pt
- Outcomes container height: 48pt
- Score label min width: 20pt

Display modes:
- **Pre-live**: Shows formatted date/time in header, scores hidden
- **Live**: Shows match time + league in header, scores visible
- **Empty**: All labels hidden when id is empty

## Mock ViewModels

Available presets:
- `.emptyState` - Empty banner for cell reuse
- `.preliveMatch` - Man City vs Arsenal, tomorrow, Premier League
- `.liveMatch` - Man City vs Arsenal, 1-1, 1st Half 44 Min
- `.interactiveMatch` - Barcelona vs Real Madrid, 2-1, 2nd Half 67 Min (El Clásico)
