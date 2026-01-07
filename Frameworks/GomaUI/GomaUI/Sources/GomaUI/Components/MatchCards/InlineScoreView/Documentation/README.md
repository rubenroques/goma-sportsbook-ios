# InlineScoreView

A compact inline score display component designed for live event cards. Displays scores horizontally with home scores on top row and away scores on bottom row.

## Overview

`InlineScoreView` provides a space-efficient way to display live scores inline with participant names. Unlike the full `ScoreView` component, this is designed for compact card layouts where vertical space is limited.

## Architecture

### Files
```
InlineScoreView/
├── InlineScoreView.swift                 # Main container view
├── InlineScoreColumnView.swift           # Individual score column
├── InlineScoreViewModelProtocol.swift    # Protocol + data models
├── MockInlineScoreViewModel.swift        # Mock implementation
└── Documentation/
    └── README.md
```

### Component Structure
```
InlineScoreView
├── containerStackView (horizontal)
│   ├── InlineScoreColumnView (points/score)
│   ├── SeparatorView (optional)
│   ├── InlineScoreColumnView (set1/q1)
│   ├── InlineScoreColumnView (set2/q2)
│   └── ...
```

## Usage

### Basic Usage

```swift
// Create with mock for testing
let scoreView = InlineScoreView(viewModel: MockInlineScoreViewModel.tennisMatch)

// Or create empty and configure later
let scoreView = InlineScoreView()
scoreView.configure(with: viewModel)
```

### In a Card Layout

```swift
// Inline with participant names
participantsStackView.addArrangedSubview(homeLabel)
participantsStackView.addArrangedSubview(awayLabel)

// Score view positioned to the right
containerView.addSubview(participantsStackView)
containerView.addSubview(scoreView)

NSLayoutConstraint.activate([
    scoreView.leadingAnchor.constraint(equalTo: participantsStackView.trailingAnchor, constant: 8),
    scoreView.centerYAnchor.constraint(equalTo: participantsStackView.centerYAnchor)
])
```

### Cell Reuse

```swift
override func prepareForReuse() {
    super.prepareForReuse()
    scoreView.cleanupForReuse()
}

func configure(with viewModel: InlineScoreViewModelProtocol) {
    scoreView.configure(with: viewModel)
}
```

## Data Models

### InlineScoreColumnData

```swift
struct InlineScoreColumnData {
    let id: String                           // Unique identifier
    let homeScore: String                    // Top row score
    let awayScore: String                    // Bottom row score
    let highlightingMode: HighlightingMode   // Visual highlighting
    let showsTrailingSeparator: Bool         // Add separator after this column
}
```

### Highlighting Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| `.winnerLoser` | Winner highlighted, loser dimmed | Completed sets/quarters |
| `.bothHighlight` | Both scores in highlight color | Current game/points, totals |
| `.noHighlight` | Both scores in default color | Neutral display |

## Sport-Specific Formats

### Tennis
```swift
// Points | Set1 Set2 Set3
[30|15] | [6|4] [4|6] [2|1]
```

### Football
```swift
// Single score
[2|1]
```

### Basketball
```swift
// Total | Q1 Q2 Q3 Q4
[78|82] | [22|18] [19|24] [21|22] [16|18]
```

## Mock Configurations

```swift
MockInlineScoreViewModel.tennisMatch       // Tennis with sets
MockInlineScoreViewModel.tennisSecondSet   // Tennis mid-match
MockInlineScoreViewModel.footballMatch     // Football score
MockInlineScoreViewModel.footballMatchTied // Tied football
MockInlineScoreViewModel.basketballMatch   // Basketball with quarters
MockInlineScoreViewModel.volleyballMatch   // Volleyball with sets
MockInlineScoreViewModel.hidden            // Hidden state
MockInlineScoreViewModel.empty             // Empty/no scores
```

## Styling

All colors and fonts use `StyleProvider`:
- Score text: `StyleProvider.fontWith(type: .bold, size: 14)`
- Highlight color: `StyleProvider.Color.highlightPrimary`
- Secondary color: `StyleProvider.Color.textSecondary`
- Separator: `StyleProvider.Color.textSecondary` at 30% opacity

## Design Decisions

1. **Compact Height**: Fixed 38pt height (18pt per row + 2pt spacing)
2. **Flexible Width**: Content-hugging, expands based on score count
3. **Separator Support**: Optional vertical separator between column groups
4. **No Background**: Transparent to blend with card backgrounds
