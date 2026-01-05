# MatchParticipantsInfoView

A match participants display with horizontal and vertical layouts for different sports contexts.

## Overview

MatchParticipantsInfoView displays home and away participant names with match state information (date/time, score, match time). It supports two display modes: horizontal (side-by-side participants with centered info) and vertical (stacked participants with right-aligned info and scores). The vertical mode is ideal for sports like tennis where detailed score breakdowns and serving indicators are needed.

## Component Relationships

### Used By (Parents)
- Match detail screens
- Match list cards
- Live match displays

### Uses (Children)
- `ScoreView` - detailed score display (vertical layout only)

## Features

- Horizontal layout (side-by-side participants)
- Vertical layout (stacked participants with ScoreView)
- Pre-live state (date and time display)
- Live state (score and match time display)
- Ended state (final score display)
- Serving indicator (home/away/none) for tennis/volleyball
- Multi-line participant names
- Live indicator dot (red pulse)
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockMatchParticipantsInfoViewModel.horizontalLive
let participantsView = MatchParticipantsInfoView(viewModel: viewModel)

participantsView.onParticipantTapped = { participantId in
    navigateToParticipant(participantId)
}

// Change display mode
viewModel.setDisplayMode(.vertical)

// Update match data
viewModel.updateMatchData(MatchParticipantsData(
    homeParticipantName: "Team A",
    awayParticipantName: "Team B",
    matchState: .live(score: "2 - 1", matchTime: "75'"),
    servingIndicator: .none
))
```

## Data Model

```swift
enum MatchDisplayMode: Equatable, Hashable {
    case horizontal
    case vertical
}

enum MatchState: Equatable, Hashable {
    case preLive(date: String, time: String)
    case live(score: String, matchTime: String?)
    case ended(score: String)
}

enum ServingIndicator: Equatable, Hashable {
    case none
    case home
    case away
}

struct MatchParticipantsData: Equatable, Hashable {
    let homeParticipantName: String
    let awayParticipantName: String
    let matchState: MatchState
    let servingIndicator: ServingIndicator
}

struct MatchParticipantsDisplayState: Equatable {
    let displayMode: MatchDisplayMode
    let matchData: MatchParticipantsData
}

protocol MatchParticipantsInfoViewModelProtocol {
    var displayStatePublisher: AnyPublisher<MatchParticipantsDisplayState, Never> { get }
    var scoreViewModelPublisher: AnyPublisher<ScoreViewModelProtocol?, Never> { get }

    func setDisplayMode(_ mode: MatchDisplayMode)
    func updateMatchData(_ data: MatchParticipantsData)
    func updateDisplayState(_ state: MatchParticipantsDisplayState)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - container background
- `StyleProvider.Color.textPrimary` - participant names, time label
- `StyleProvider.Color.textSecondary` - date label, match time label
- `StyleProvider.Color.liveTag` - live indicator dot
- `StyleProvider.Color.highlightPrimary` - serving indicator
- `StyleProvider.fontWith(type: .bold, size: 14)` - participant name font
- `StyleProvider.fontWith(type: .medium, size: 12)` - date label font
- `StyleProvider.fontWith(type: .bold, size: 16)` - time/score label font (horizontal)
- `StyleProvider.fontWith(type: .bold, size: 17)` - score label font
- `StyleProvider.fontWith(type: .medium, size: 10)` - match time label font

Layout constants:
- Horizontal height: 70pt minimum
- Vertical height: 80pt
- Center stack width: 78pt minimum
- Live indicator size: 8pt x 8pt
- Serving indicator size: 9pt x 9pt
- Vertical padding: 13pt top
- Horizontal padding: 12pt

Display modes:
- **Horizontal**: Participants on left/right, date/time or score in center
- **Vertical**: Participants stacked left, date/time or ScoreView right-aligned

## Mock ViewModels

Available presets:
- `.defaultMock` - Real Madrid vs Barcelona, pre-live
- `.horizontalPreLive` - Man United vs Liverpool, Dec 15 18:45
- `.horizontalLive` - Bayern vs Dortmund, 2-1, 67'
- `.horizontalEnded` - Arsenal vs Chelsea, 3-2
- `.verticalTennisLive` - Djokovic vs Nadal, 3 sets with serving
- `.verticalBasketballLive` - Lakers vs Warriors, 103-95
- `.verticalVolleyballLive` - Brazil vs Italy, serving away
- `.verticalFootballPreLive` - El Clasico, 21:00
- `.longTeamNames` - Borussia Mönchengladbach vs Eintracht Frankfurt
- `.liveWithoutTime` - Live state without match time
