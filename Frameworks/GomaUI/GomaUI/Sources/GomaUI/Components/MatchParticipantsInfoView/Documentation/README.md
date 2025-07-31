# MatchParticipantsInfoView

A flexible, reusable UI component for displaying match participant information in sports betting applications. Supports both horizontal and vertical layouts with live scores, serving indicators, and detailed sport-specific scoring.

## Features

- **Dual Layout Modes**: Horizontal (compact) and vertical (detailed) display options
- **Live Match States**: Pre-live, live with scores, and ended match support
- **Serving Indicators**: Visual indicators for sports like tennis and volleyball
- **Detailed Scoring**: Sport-specific score displays (tennis sets, basketball quarters, etc.)
- **Reactive Updates**: Real-time UI updates via Combine publishers
- **Accessibility**: Full accessibility support with proper labels and traits
- **StyleProvider Integration**: Consistent theming across all visual elements

## Usage Example

### Basic Implementation

```swift
import GomaUI

// Create match data
let matchData = MatchParticipantsData(
    homeParticipantName: "Real Madrid",
    awayParticipantName: "Barcelona",
    matchState: .live(score: "2 - 1", matchTime: "67'"),
    servingIndicator: .none
)

// Create display state
let displayState = MatchParticipantsDisplayState(
    displayMode: .horizontal,
    matchData: matchData
)

// Create view model (use your actual implementation)
let viewModel = YourMatchParticipantsViewModel(displayState: displayState)

// Create and configure the view
let matchView = MatchParticipantsInfoView(viewModel: viewModel)
parentView.addSubview(matchView)

// Setup constraints
NSLayoutConstraint.activate([
    matchView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
    matchView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -16),
    matchView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 20)
])
```

### Tennis Match with Detailed Scoring

```swift
let matchData = MatchParticipantsData(
    homeParticipantName: "Novak Djokovic",
    awayParticipantName: "Rafael Nadal",
    matchState: .live(score: "1 - 1", matchTime: "3rd Set"),
    servingIndicator: .home
)

let displayState = MatchParticipantsDisplayState(
    displayMode: .vertical,
    matchData: matchData
)

// Create score display data for the ScoreView component
let tennisScores = [
    ScoreDisplayData(id: "set1", homeScore: "6", awayScore: "4", style: .simple),
    ScoreDisplayData(id: "set2", homeScore: "3", awayScore: "6", style: .simple),
    ScoreDisplayData(id: "set3", homeScore: "40", awayScore: "30", style: .background)
]

let scoreViewModel = MockScoreViewModel(scoreCells: tennisScores, visualState: .display)

// Your view model should provide both the display state and score view model
```

### Using Mock Data for Testing

```swift
// Use predefined mock examples
let viewModel = MockMatchParticipantsInfoViewModel.verticalTennisLive
let matchView = MatchParticipantsInfoView(viewModel: viewModel)

// Handle participant interactions
matchView.onParticipantTapped = { participantName in
    print("Participant tapped: \(participantName)")
    // Navigate to participant details or perform action
}
```

## Component Architecture

### Data Models

#### `MatchParticipantsData`
Contains all information about the match participants and current state:
- `homeParticipantName`: Name of the home team/player
- `awayParticipantName`: Name of the away team/player  
- `matchState`: Current state (pre-live, live, ended)
- `servingIndicator`: Which participant is serving (if applicable)

#### `MatchState`
Represents the current match status:
- `.preLive(date: String, time: String)`: Match hasn't started yet
- `.live(score: String, matchTime: String?)`: Match is in progress
- `.ended(score: String)`: Match has finished

#### `ServingIndicator`
For sports with serving (tennis, volleyball):
- `.none`: No serving indication
- `.home`: Home participant is serving
- `.away`: Away participant is serving

#### `ScoreView Integration`
For vertical layout mode, the component uses the existing `ScoreView` component:
- Managed through `scoreViewModelPublisher` in the view model protocol
- Supports all `ScoreDisplayData` formats (simple, border, background styles)
- Automatically shown/hidden based on layout mode

### Layout Modes

#### Horizontal Layout
- **Use Case**: Compact display in lists or cards
- **Height**: ~70pt
- **Content**: Participant names on sides, center shows date/time or score
- **Features**: Live indicator dot, match time display

#### Vertical Layout  
- **Use Case**: Detailed match information display
- **Height**: ~80pt
- **Content**: Stacked participant names with serving indicators, detailed scores on right
- **Features**: Serving indicators, detailed sport-specific scoring, enhanced information density

## Customization Options

### Layout Mode Switching
```swift
// Switch between horizontal and vertical layouts
viewModel.setDisplayMode(.vertical)
viewModel.setDisplayMode(.horizontal)
```

### Match State Updates
```swift
// Update match to live state
let newMatchData = MatchParticipantsData(
    homeParticipantName: currentData.homeParticipantName,
    awayParticipantName: currentData.awayParticipantName,
    matchState: .live(score: "1 - 0", matchTime: "23'"),
    servingIndicator: .home
)
viewModel.updateMatchData(newMatchData)
```

### Serving Indicator Updates
```swift
// Update who is serving (tennis, volleyball, etc.)
let updatedData = MatchParticipantsData(
    homeParticipantName: "Player 1",
    awayParticipantName: "Player 2", 
    matchState: .live(score: "40 - 30", matchTime: "Game 5"),
    servingIndicator: .away // Away player now serving
)
viewModel.updateMatchData(updatedData)
```

## Mock View Models

The component includes comprehensive mock implementations for testing:

- `MockMatchParticipantsInfoViewModel.defaultMock`: Basic horizontal layout
- `MockMatchParticipantsInfoViewModel.horizontalLive`: Live football match
- `MockMatchParticipantsInfoViewModel.verticalTennisLive`: Tennis with serving and detailed scores
- `MockMatchParticipantsInfoViewModel.verticalBasketballLive`: Basketball with quarter scores
- `MockMatchParticipantsInfoViewModel.longTeamNames`: Edge case with long names

## Accessibility

The component provides full accessibility support:
- Proper accessibility labels for all interactive elements
- Voice-over descriptions for match states and scores
- Dynamic accessibility updates as match state changes
- Support for accessibility font scaling

## Performance Considerations

- **Efficient Updates**: Only renders changed elements when state updates
- **Memory Management**: Proper cleanup of Combine subscriptions
- **Layout Optimization**: Constraint-based layout for smooth animations
- **Preview Performance**: Lightweight mock data for SwiftUI previews

## Integration with Existing Systems

### With ScoreView Component
```swift
// MatchParticipantsInfoView automatically integrates ScoreView for vertical layout
// Your view model should implement scoreViewModelPublisher to provide score data

protocol YourMatchViewModelProtocol: MatchParticipantsInfoViewModelProtocol {
    // Implement both required publishers
    var displayStatePublisher: AnyPublisher<MatchParticipantsDisplayState, Never> { get }
    var scoreViewModelPublisher: AnyPublisher<ScoreViewModelProtocol?, Never> { get }
}
```

### Migration from Legacy Code
This component replaces the legacy `MatchInfoView`, `HorizontalMatchInfoView`, and `VerticalMatchInfoView` with:
- Improved data model design
- Better separation of concerns
- Enhanced testability
- StyleProvider integration
- Reactive programming patterns

## Testing

The component includes extensive testing support:
- Multiple mock scenarios for different sports
- Edge cases (long names, missing data)
- Layout mode switching
- State transition testing

Use the TestCase app to interactively test all component features and states.