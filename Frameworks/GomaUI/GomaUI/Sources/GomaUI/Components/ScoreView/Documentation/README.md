# ScoreView

A flexible, protocol-based UI component for displaying sports match scores in a horizontal layout. Supports multiple score cells with different visual styles and reactive state management.

## Overview

The `ScoreView` displays an array of score cells, each showing home and away scores with customizable styling. The component follows GomaUI architectural patterns with protocol-based ViewModels, reactive publishers, and StyleProvider integration.

## Key Features

- **Multiple Score Cells**: Display series of scores (sets, quarters, periods, etc.)
- **Three Visual Styles**: Simple, border, and background styling options
- **Reactive Updates**: Real-time score updates through Combine publishers
- **State Management**: Loading, empty, and display states
- **StyleProvider Integration**: Consistent theming across the app
- **Winner Highlighting**: Automatic highlighting for winning scores in simple style

## Architecture

### Protocol-Based Design
```swift
public protocol ScoreViewModelProtocol {
    var scoreCellsPublisher: AnyPublisher<[ScoreDisplayData], Never> { get }
    var visualStatePublisher: AnyPublisher<ScoreViewVisualState, Never> { get }

    func updateScoreCells(_ cells: [ScoreDisplayData])
    func setVisualState(_ state: ScoreViewVisualState)
}
```

### Data Models
```swift
public struct ScoreDisplayData: Equatable, Hashable {
    public let id: String           // Unique identifier for updates
    public let homeScore: String    // Home team/player score
    public let awayScore: String    // Away team/player score
    public let style: ScoreCellStyle // Visual presentation style
}

public enum ScoreCellStyle: Equatable {
    case simple     // Plain text with winner highlighting
    case border     // Text with border outline
    case background // Text with background fill
}

public enum ScoreViewVisualState: Equatable {
    case idle       // Initial state
    case loading    // Showing loading indicator
    case display    // Showing score cells
    case empty      // Showing empty state message
}
```

## Basic Usage

### 1. Create ScoreView
```swift
let scoreView = ScoreView()
view.addSubview(scoreView)

// Add constraints
NSLayoutConstraint.activate([
    scoreView.topAnchor.constraint(equalTo: container.topAnchor),
    scoreView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
    scoreView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
    scoreView.heightAnchor.constraint(equalToConstant: 50)
])
```

### 2. Configure with ViewModel
```swift
// Using mock for testing/previews
let viewModel = MockScoreViewModel.tennisMatch
scoreView.configure(with: viewModel)

// Using custom implementation
let customViewModel = MyScoreViewModel()
scoreView.configure(with: customViewModel)
```

### 3. Update Scores Dynamically
```swift
let updatedScores = [
    ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "4", style: .simple),
    ScoreDisplayData(id: "set2", homeScore: "4", awayScore: "6", style: .simple),
    ScoreDisplayData(id: "current", homeScore: "3", awayScore: "2", style: .border)
]

viewModel.updateScoreCells(updatedScores)
```

## Sport-Specific Examples

### Tennis Match
```swift
let tennisScores = [
    ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "4", style: .simple),    // Previous set
    ScoreDisplayData(id: "set2", homeScore: "4", awayScore: "6", style: .simple),    // Previous set
    ScoreDisplayData(id: "set3", homeScore: "6", awayScore: "7", style: .border),    // Current set
    ScoreDisplayData(id: "game", homeScore: "15", awayScore: "30", style: .background) // Current game
]
```

### Basketball Game
```swift
let basketballScores = [
    ScoreDisplayData(id: "q1", homeScore: "25", awayScore: "22", style: .simple),
    ScoreDisplayData(id: "q2", homeScore: "18", awayScore: "28", style: .simple),
    ScoreDisplayData(id: "q3", homeScore: "31", awayScore: "24", style: .simple),
    ScoreDisplayData(id: "q4", homeScore: "26", awayScore: "30", style: .border),    // Current quarter
    ScoreDisplayData(id: "total", homeScore: "100", awayScore: "104", style: .background) // Final score
]
```

### Simple Football Match
```swift
let footballScores = [
    ScoreDisplayData(id: "final", homeScore: "2", awayScore: "1", style: .background)
]
```

### Tennis with Advantage
```swift
let tennisAdvantage = [
    ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "3", style: .simple),
    ScoreDisplayData(id: "set2", homeScore: "5", awayScore: "6", style: .border),
    ScoreDisplayData(id: "current", homeScore: "A", awayScore: "40", style: .background)
]
```

## Cell Styles

### Simple Style
- Plain text display
- Winner highlighting (alpha transparency for losing score)
- Secondary text color from StyleProvider
- Used for: Previous sets/quarters/periods

### Border Style
- Text with border outline
- No winner highlighting
- Primary text color from StyleProvider
- Used for: Current active period

### Background Style
- Text with background fill
- No winner highlighting
- Primary color text on background color fill
- Used for: Final/total scores, current game scores

## State Management

### Visual States
```swift
// Show loading spinner
viewModel.setLoading()

// Show score cells
viewModel.setVisualState(.display)

// Show empty message
viewModel.setEmpty()

// Clear all and show empty
viewModel.clearScores()
```

### Reactive Updates
The component automatically updates when publishers emit new values:
```swift
// ViewModel publishes new scores
viewModel.scoreCellsPublisher
    .sink { scores in
        // UI automatically updates
    }
```

## Implementation Guidelines

### Creating Score Data
When implementing your own ViewModels, simply create `ScoreDisplayData` arrays directly from your domain models:

```swift
class MyScoreViewModel: ScoreViewModelProtocol {

    func loadTennisMatch() {
        let scores = [
            ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "4", style: .simple),
            ScoreDisplayData(id: "set2", homeScore: "4", awayScore: "6", style: .simple),
            ScoreDisplayData(id: "current_set", homeScore: "3", awayScore: "2", style: .border),
            ScoreDisplayData(id: "current_game", homeScore: "30", awayScore: "15", style: .background)
        ]
        updateScoreCells(scores)
    }

    func handleLiveScoreUpdate(newGameScore: String) {
        // Update just the current game score
        var currentScores = scoreCellsSubject.value
        if let gameIndex = currentScores.firstIndex(where: { $0.id == "current_game" }) {
            currentScores[gameIndex] = ScoreDisplayData(
                id: "current_game",
                homeScore: newGameScore,
                awayScore: "15",
                style: .background
            )
            updateScoreCells(currentScores)
        }
    }
}
```

### Business Logic Guidelines
The ScoreView component is UI-focused. Your application should handle:

1. **Data Conversion**: Transform your domain models into `ScoreDisplayData`
2. **Sport-Specific Formatting**: Handle tennis "A" for advantage, etc.
3. **User Authentication**: Determine when to show/hide scores
4. **Real-time Updates**: Manage live score updates from your data layer

## Mock ViewModels

The component includes extensive mock implementations for testing and previews:

```swift
// Pre-built scenarios
MockScoreViewModel.tennisMatch      // Tennis with multiple sets
MockScoreViewModel.tennisAdvantage  // Tennis with advantage scoring
MockScoreViewModel.basketballMatch  // Basketball with quarters
MockScoreViewModel.footballMatch    // Simple football score
MockScoreViewModel.loading          // Loading state
MockScoreViewModel.empty           // Empty state

// Test edge cases
MockScoreViewModel.maxCells        // Maximum score cells
MockScoreViewModel.mixedStyles     // Different style combinations
MockScoreViewModel.tiedMatch       // Tied scores
```

## Styling Customization

The component uses StyleProvider for consistent theming:

```swift
// Customize colors
StyleProvider.Color.customize(
    primaryColor: .systemBlue,
    secondaryColor: .systemGray,
    backgroundColor: .systemGray6,
    textColor: .label
)

// Customize fonts
StyleProvider.setFontProvider { type, size in
    // Return your custom fonts
}
```

## Accessibility

The component includes accessibility support:
- Score labels are automatically accessible
- Loading states announce properly
- Empty states provide context

## Best Practices

1. **Use Meaningful IDs**: Provide descriptive IDs for each score cell to enable proper updates
2. **Consistent Styling**: Use style conventions consistently across your app
3. **Handle Empty States**: Always provide feedback when no scores are available
4. **Optimize Updates**: Only update scores when values actually change
5. **Proper Cleanup**: Call `cleanupForReuse()` when using in collection views

## Advanced Usage

### Custom ViewModel Implementation
```swift
class LiveTennisScoreViewModel: ScoreViewModelProtocol {
    private let scoreCellsSubject = CurrentValueSubject<[ScoreDisplayData], Never>([])
    private let visualStateSubject = CurrentValueSubject<ScoreViewVisualState, Never>(.idle)

    var scoreCellsPublisher: AnyPublisher<[ScoreDisplayData], Never> {
        scoreCellsSubject.eraseToAnyPublisher()
    }

    var visualStatePublisher: AnyPublisher<ScoreViewVisualState, Never> {
        visualStateSubject.eraseToAnyPublisher()
    }

    var currentVisualState: ScoreViewVisualState {
        visualStateSubject.value
    }

    func connectToLiveData() {
        setLoading()

        // Your live data connection logic
        liveDataService.connect { [weak self] matchData in
            let scores = self?.convertMatchDataToScores(matchData) ?? []
            self?.updateScoreCells(scores)
        }
    }

    private func convertMatchDataToScores(_ matchData: MatchData) -> [ScoreDisplayData] {
        // Convert your domain model to ScoreDisplayData
        var scores: [ScoreDisplayData] = []

        // Add previous sets
        for (index, set) in matchData.completedSets.enumerated() {
            scores.append(ScoreDisplayData(
                id: "set\(index)",
                homeScore: "\(set.homeScore)",
                awayScore: "\(set.awayScore)",
                style: .simple
            ))
        }

        // Add current set if in progress
        if let currentSet = matchData.currentSet {
            scores.append(ScoreDisplayData(
                id: "current_set",
                homeScore: "\(currentSet.homeScore)",
                awayScore: "\(currentSet.awayScore)",
                style: .border
            ))
        }

        // Add current game score
        scores.append(ScoreDisplayData(
            id: "current_game",
            homeScore: formatTennisScore(matchData.currentGame.homeScore),
            awayScore: formatTennisScore(matchData.currentGame.awayScore),
            style: .background
        ))

        return scores
    }

    private func formatTennisScore(_ score: Int) -> String {
        switch score {
        case 0: return "0"
        case 1: return "15"
        case 2: return "30"
        case 3: return "40"
        case 4: return "A"  // Advantage
        default: return "\(score)"
        }
    }

    // Required protocol methods
    func updateScoreCells(_ cells: [ScoreDisplayData]) {
        scoreCellsSubject.send(cells)
        visualStateSubject.send(cells.isEmpty ? .empty : .display)
    }

    func setVisualState(_ state: ScoreViewVisualState) {
        visualStateSubject.send(state)
    }

    func clearScores() {
        scoreCellsSubject.send([])
        visualStateSubject.send(.empty)
    }

    func setLoading() {
        visualStateSubject.send(.loading)
    }

    func setEmpty() {
        scoreCellsSubject.send([])
        visualStateSubject.send(.empty)
    }
}
```