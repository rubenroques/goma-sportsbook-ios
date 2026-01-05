# ScoreView

A horizontal sports score display supporting multiple cell styles and serving indicators.

## Overview

ScoreView displays a horizontal series of score cells for sports matches (tennis, basketball, football, volleyball, hockey, etc.). It supports multiple visual styles for cells (simple, border, background) combined with highlighting modes (winner/loser, both highlight, no highlight). Special features include serving indicators for tennis, trailing separators, and loading/empty states. The component is designed for live match displays and detailed score breakdowns.

## Component Relationships

### Used By (Parents)
- `MatchParticipantsInfoView`

### Uses (Children)
- `ScoreCellView` (internal helper)
- `ServingIndicatorView` (internal helper)

## Features

- Multiple cell styles: simple, border, background
- Highlighting modes: winnerLoser, bothHighlight, noHighlight
- Serving indicator column (tennis/volleyball)
- Trailing separator lines between cells
- Loading state with activity indicator
- Empty state with localized message
- Idle state (no scores)
- Display state with score cells
- Dynamic cell creation
- Fixed height (42pt)
- Right-aligned content
- Cell reuse cleanup support
- Reactive updates via Combine publishers

## Usage

```swift
// Tennis match with serving indicator
let tennisViewModel = MockScoreViewModel.tennisMatch
let scoreView = ScoreView()
scoreView.configure(with: tennisViewModel)

// Basketball match
let basketballView = ScoreView()
basketballView.configure(with: MockScoreViewModel.basketballMatch)

// Custom score display
let customCells = [
    ScoreDisplayData(
        id: "game",
        homeScore: "30",
        awayScore: "15",
        style: .background,
        highlightingMode: .bothHighlight,
        showsTrailingSeparator: true,
        servingPlayer: .home
    ),
    ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "4", style: .simple, highlightingMode: .winnerLoser),
    ScoreDisplayData(id: "set2", homeScore: "4", awayScore: "6", style: .simple, highlightingMode: .winnerLoser)
]
let customVM = MockScoreViewModel(scoreCells: customCells, visualState: .display)
scoreView.configure(with: customVM)

// Clean up for cell reuse
scoreView.cleanupForReuse()
```

## Data Model

```swift
struct ScoreDisplayData: Equatable, Hashable {
    let id: String
    let homeScore: String
    let awayScore: String
    let index: Int
    let style: ScoreCellStyle
    let highlightingMode: HighlightingMode
    let showsTrailingSeparator: Bool
    let servingPlayer: ServingPlayer?

    enum ServingPlayer: Equatable {
        case home
        case away
    }

    enum HighlightingMode: Equatable {
        case winnerLoser    // Winner: black, loser: gray
        case bothHighlight  // Both: orange (highlightPrimary)
        case noHighlight    // Both: black (default)
    }

    enum ScoreCellStyle: Equatable, CaseIterable {
        case simple     // Plain text, 26pt width
        case border     // 1pt border outline, 26pt width
        case background // Filled background, 29pt width
    }

    enum VisualState: Equatable {
        case idle
        case loading
        case display
        case empty
    }
}

protocol ScoreViewModelProtocol {
    var scoreCellsPublisher: AnyPublisher<[ScoreDisplayData], Never> { get }
    var visualStatePublisher: AnyPublisher<ScoreDisplayData.VisualState, Never> { get }
    var currentVisualState: ScoreDisplayData.VisualState { get }

    func updateScoreCells(_ cells: [ScoreDisplayData])
    func setVisualState(_ state: ScoreDisplayData.VisualState)
    func clearScores()
    func setLoading()
    func setEmpty()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - loading indicator, both highlight text, border style border
- `StyleProvider.Color.highlightSecondary` - empty label text
- `StyleProvider.Color.textPrimary` - winner text, no highlight text
- `StyleProvider.Color.textSecondary` - loser text
- `StyleProvider.Color.backgroundPrimary` - background style fill
- `StyleProvider.Color.separatorLine` - trailing separator color
- `StyleProvider.fontWith(type: .regular, size: 14)` - empty label font

Layout constants:
- Fixed height: 42pt
- Cell spacing: 4pt
- Separator width: 1pt
- Simple/border cell width: 26pt
- Background cell width: 29pt

Cell styles:
- **Simple**: Transparent, winner/loser text highlighting
- **Border**: 1pt border outline in highlightPrimary
- **Background**: Filled backgroundPrimary

Serving indicator:
- Displayed as first column when servingPlayer is set
- Shows dot indicator for home or away player

## Mock ViewModels

Available presets:
- `.simpleExample` - Basic 4-cell display
- `.tennisMatch` - Tennis with serving indicator, sets, current game
- `.tennisAdvantage` - Tennis with "A" (advantage) scoring
- `.basketballMatch` - Quarters + total score
- `.footballMatch` - Single total score cell
- `.volleyballMatch` - Set scores + total
- `.hockeyMatch` - Periods + total
- `.americanFootballMatch` - Quarters + total
- `.tiedMatch` - Single cell with tied score
- `.loading` - Loading state
- `.empty` - Empty state
- `.idle` - Idle state
- `.maxCells` - 7 cells for layout testing
- `.mixedStyles` - Different styles together
