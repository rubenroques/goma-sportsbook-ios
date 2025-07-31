# TallOddsMatchCardView

A comprehensive match card component that assembles multiple existing GomaUI components to display pre-live sports betting matches with all necessary information and betting options.

## Overview

The `TallOddsMatchCardView` is a **Tier 3 complex component** that combines:
- **MatchHeaderView** - League information, favorite toggle, match date/time
- **Separator Line** - Visual division between header and content
- **MatchParticipantsInfoView** - Team/participant names in vertical layout
- **MarketInfoLineView** - Market name pill, market count, and info icons
- **MarketOutcomesMultiLineView** - Betting outcomes in multiple lines

## Architecture

### Component Structure
```
TallOddsMatchCardView
├── MatchHeaderView (league info, date, favorite)
├── Separator Line (1px divider)
├── MatchParticipantsInfoView (vertical team layout)
├── MarketInfoLineView (market pill + count + icons)
└── MarketOutcomesMultiLineView (betting outcomes)
```

### MVVM Pattern
- **Protocol**: `TallOddsMatchCardViewModelProtocol`
- **View**: `TallOddsMatchCardView`
- **Mock**: `MockTallOddsMatchCardViewModel`
- **Child VMs**: Creates and manages all child component view models

## Usage

### Basic Implementation

```swift
import GomaUI

// Create match data
let matchData = PreLiveMatchData(
    matchId: "liverpool_arsenal",
    leagueInfo: headerData,
    participants: participantsData,
    marketInfo: marketInfoData,
    outcomes: outcomesData
)

// Create view model
let viewModel = MockTallOddsMatchCardViewModel(matchData: matchData)

// Create view
let matchCardView = TallOddsMatchCardView(viewModel: viewModel)

// Setup callbacks
matchCardView.onMatchHeaderTapped = {
    // Navigate to match details
}

matchCardView.onOutcomeSelected = { outcomeId in
    // Add to betslip
}
```

### Callback Configuration

```swift
matchCardView.onMatchHeaderTapped = {
    // Handle header tap (navigate to match details)
}

matchCardView.onFavoriteToggled = {
    // Handle favorite toggle
}

matchCardView.onOutcomeSelected = { outcomeId in
    // Handle outcome selection (add to betslip)
}

matchCardView.onMarketInfoTapped = {
    // Handle market info tap (show more markets)
}
```

## Data Models

### PreLiveMatchData
Main data structure containing all child component data:

```swift
public struct PreLiveMatchData: Equatable, Hashable {
    public let matchId: String
    public let leagueInfo: MatchHeaderData
    public let participants: MatchParticipantsInfoData
    public let marketInfo: MarketInfoData
    public let outcomes: MarketOutcomesMultiLineData
}
```

### Child Component Data
- `MatchHeaderData` - League, country, competition info
- `MatchParticipantsInfoData` - Team names and layout configuration
- `MarketInfoData` - Market name, count, info icons
- `MarketOutcomesMultiLineData` - Betting outcomes in multiple lines

## Display Configuration

### TallOddsMatchCardDisplayState
Controls visual appearance and spacing:

```swift
public struct TallOddsMatchCardDisplayState: Equatable {
    public let matchId: String
    public let showSeparatorLine: Bool
    public let cardBackgroundColor: UIColor
    public let cornerRadius: CGFloat
    public let horizontalPadding: CGFloat
    public let verticalSpacing: CGFloat
}
```

### Default Values
- **Background**: `StyleProvider.Color.backgroundSecondary`
- **Corner Radius**: `8.0`
- **Horizontal Padding**: `16.0`
- **Vertical Spacing**: `12.0`
- **Separator**: Always shown

## Mock Data

### Available Mocks

#### Premier League Match
```swift
let viewModel = MockTallOddsMatchCardViewModel.premierLeagueMock
```
- Liverpool F.C. vs Arsenal F.C.
- Premier League competition
- Multiple market icons
- Two-column outcome layout

#### La Liga Match (Compact)
```swift
let viewModel = MockTallOddsMatchCardViewModel.compactMock
```
- FC Barcelona vs Real Madrid
- La Liga competition
- Three-way betting (1X2)
- Minimal icons

#### Bundesliga Match
```swift
let viewModel = MockTallOddsMatchCardViewModel.bundesliegaMock
```
- Bayern Munich vs Borussia Dortmund
- Bundesliga competition
- Both Teams Score market
- All info icons displayed

## Layout & Spacing

### Vertical Stack Layout
The component uses `UIStackView` with vertical axis:

1. **Spacing**: 12pt between components
2. **Padding**: 16pt horizontal margins
3. **Alignment**: Fill (full width)
4. **Distribution**: Fill (natural heights)

### Responsive Design
- Adapts to different screen sizes
- Flexible content compression
- Proper constraint priorities

## Child Component Integration

### Parent-Child Relationship
The parent view model creates and manages all child view models:

```swift
// Parent creates child view models from single data source
let headerViewModel = MockMatchHeaderViewModel(headerData: matchData.leagueInfo)
let participantsViewModel = MockMatchParticipantsInfoViewModel(participantsData: matchData.participants)
let marketInfoViewModel = MockMarketInfoLineViewModel(marketInfoData: matchData.marketInfo)
let outcomesViewModel = MockMarketOutcomesMultiLineViewModel(marketData: matchData.outcomes)
```

### Reactive Updates
All child components receive updates through Combine publishers:

```swift
// Child view model publishers
var matchHeaderViewModelPublisher: AnyPublisher<MatchHeaderViewModelProtocol, Never> { get }
var matchParticipantsViewModelPublisher: AnyPublisher<MatchParticipantsInfoViewModelProtocol, Never> { get }
var marketInfoLineViewModelPublisher: AnyPublisher<MarketInfoLineViewModelProtocol, Never> { get }
var marketOutcomesViewModelPublisher: AnyPublisher<MarketOutcomesMultiLineViewModelProtocol, Never> { get }
```

## Testing & Previews

### SwiftUI Previews
Multiple preview configurations available:

```swift
#Preview("Premier League Match") {
    PreviewUIView {
        TallOddsMatchCardView(viewModel: MockTallOddsMatchCardViewModel.premierLeagueMock)
    }
    .frame(height: 300)
}
```

### TestCase Integration
Available in TestCase app gallery with interactive demo:
- Segmented control to switch between mock data
- Live callback testing
- Alert dialogs for user actions

## MarketInfoLineView Component

### New Tier 2 Component
Created specifically for this card assembly:

**Features:**
- Market name pill on the left
- Market count label on the right
- Info icons (EP, Popular, Stats, etc.)
- Horizontal layout with proper spacing

**Data Structure:**
```swift
public struct MarketInfoData: Equatable, Hashable {
    public let marketName: String
    public let marketCount: Int
    public let icons: [MarketInfoIcon]
}
```

**Available Icons:**
- `erep_short_info` - EP Short icon
- `most_popular_info` - Popular markets icon
- `stats_info` - Statistics icon
- `bet_builder_info` - Bet Builder icon

## Best Practices

### Memory Management
- Uses `[weak self]` in all closures
- Proper Combine subscription management
- Avoids retain cycles

### Performance
- Lazy component initialization
- Efficient constraint updates
- Minimal view recreation

### Accessibility
- Inherits accessibility from child components
- Proper gesture recognition
- Screen reader support

## Migration Notes

### From Individual Components
When migrating from using individual components separately:

1. **Data Consolidation**: Combine individual data models into `PreLiveMatchData`
2. **View Model Updates**: Replace multiple view models with single parent
3. **Layout Removal**: Remove manual spacing/layout code
4. **Callback Consolidation**: Use card-level callbacks instead of individual ones

### Spacing Adjustments
The card provides consistent spacing that may differ from manual layouts:
- **12pt vertical spacing** between components
- **16pt horizontal padding** from edges
- **1px separator line** after header

## Troubleshooting

### Common Issues

#### Child Components Not Updating
**Cause**: View model publishers not properly bound
**Solution**: Ensure all child view model publishers are connected in `setupChildViewModelBindings()`

#### Layout Issues
**Cause**: Incorrect constraint priorities
**Solution**: Verify compression resistance settings for horizontal layouts

#### Missing Icons
**Cause**: Icon names don't match asset bundle
**Solution**: Check icon names in `Resources/Icons.xcassets/info_card_line/`

## Future Enhancements

### Live Mode Support
The next iteration will include:
- Live score updates
- Live status indicators
- Real-time odds changes
- Different layout for in-play matches

### Additional Features
- Betting slip integration
- Favorite persistence
- Market expansion
- Performance analytics
