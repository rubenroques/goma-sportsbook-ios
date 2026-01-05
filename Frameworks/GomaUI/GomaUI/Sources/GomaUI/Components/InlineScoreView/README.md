# InlineScoreView

A compact horizontal score display for live sports events with multi-column support.

## Overview

InlineScoreView displays live scores in a compact horizontal format with support for multiple score columns. It handles various sports formats including single scores (football), set scores with game points (tennis), and quarter breakdowns (basketball). The component uses column-based architecture with optional separators between score groups.

## Component Relationships

### Used By (Parents)
- `InlineMatchCardView` - inline score display for live matches

### Uses (Children)
- `InlineScoreColumnView` - individual score column

## Features

- Multi-column score display
- Three highlighting modes: winnerLoser, bothHighlight, noHighlight
- Optional trailing separators between columns
- Sport-specific layouts:
  - Football: single total score column
  - Tennis: game points + set scores (separator after points)
  - Basketball: total + quarter scores (separator after total)
- Visibility toggle for pre-live/live states
- Column-by-column rendering
- Cleanup for cell reuse
- Reactive updates via Combine publisher

## Usage

```swift
// Tennis match
let viewModel = MockInlineScoreViewModel.tennisMatch
let scoreView = InlineScoreView(viewModel: viewModel)

// Football match
let footballVM = MockInlineScoreViewModel.footballMatch
let footballScoreView = InlineScoreView(viewModel: footballVM)

// Hide for pre-live
viewModel.setVisible(false)

// Update columns dynamically
viewModel.updateColumns(newColumns)

// For cell reuse
scoreView.cleanupForReuse()
scoreView.configure(with: newViewModel)
```

## Data Model

```swift
struct InlineScoreColumnData: Equatable, Hashable {
    let id: String
    let homeScore: String
    let awayScore: String
    let highlightingMode: HighlightingMode
    let showsTrailingSeparator: Bool

    enum HighlightingMode: Equatable, Hashable {
        case winnerLoser    // Winner in primary color, loser dimmed
        case bothHighlight  // Both scores in highlight color
        case noHighlight    // Both scores in default text color
    }
}

struct InlineScoreDisplayState: Equatable, Hashable {
    let columns: [InlineScoreColumnData]
    let isVisible: Bool
    let isEmpty: Bool

    static let hidden: InlineScoreDisplayState
    static let empty: InlineScoreDisplayState
}

protocol InlineScoreViewModelProtocol: AnyObject {
    var displayStatePublisher: AnyPublisher<InlineScoreDisplayState, Never> { get }
    var currentDisplayState: InlineScoreDisplayState { get }

    func updateColumns(_ columns: [InlineScoreColumnData])
    func setVisible(_ visible: Bool)
    func clearScores()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.textSecondary` - separator color (30% opacity)

Layout constants:
- Horizontal stack spacing: 0pt
- Separator width: 1pt
- Separator height: 32pt
- Separator padding: 2-3pt on each side
- Background: clear

## Mock ViewModels

Available presets:
- `.tennisMatch` - tennis with points (30-15) + 3 sets, separator after points
- `.tennisSecondSet` - tennis in second set
- `.footballMatch` - football single score (2-1)
- `.footballMatchTied` - football tied (1-1)
- `.basketballMatch` - basketball with total + 4 quarters, separator after total
- `.volleyballMatch` - volleyball with points + sets
- `.hidden` - hidden state (pre-live)
- `.empty` - visible but no columns
- `.custom(columns:isVisible:)` - fully customizable
