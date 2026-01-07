# MatchDateNavigationBar

A navigation bar component that displays match timing information with support for both pre-match and live match states.

## Overview

`MatchDateNavigationBar` is designed for sports betting applications to show match timing at the top of match detail screens. It features:

- **Pre-match state**: Displays the scheduled date and time
- **Live match state**: Shows current period and elapsed time in a highlighted pill
- Optional back navigation button
- Customizable date formatting

## Visual States

### Pre-Match
- Shows date/time in format: "18:45 Tue 21/01" (customizable)
- Time displayed in regular weight, date in bold
- Uses `textPrimary` color

### Live Match
- Green pill background (`highlightSecondary`)
- White text (`buttonTextPrimary`) 
- Shows period and time: "1st Half, 41mins"
- Bold font weight

## Usage

```swift
// Pre-match state
let preMatchData = MatchDateNavigationBarData(
    matchStatus: .preMatch(date: matchDate)
)
let viewModel = MockMatchDateNavigationBarViewModel(data: preMatchData)
let navigationBar = MatchDateNavigationBarView(viewModel: viewModel)

// Live match state
let liveData = MatchDateNavigationBarData(
    matchStatus: .live(period: "2nd Half", time: "67mins")
)
viewModel.configure(with: liveData)

// Handle back button tap
navigationBar.onBackTapped = {
    // Navigate back
}
```

## Customization

### Date Format
```swift
let data = MatchDateNavigationBarData(
    matchStatus: .preMatch(date: date),
    dateFormat: "EEEE, MMM d 'at' h:mm a" // "Tuesday, Jan 21 at 6:45 PM"
)
```

### Hide Back Button
```swift
let data = MatchDateNavigationBarData(
    matchStatus: matchStatus,
    isBackButtonHidden: true
)
```

## Mock View Models

The component includes several pre-configured mocks:

- `defaultPreMatchMock`: Shows a future match date
- `liveMock`: First half at 41 minutes
- `secondHalfMock`: Second half at 67 minutes
- `halfTimeMock`: Half time break
- `extraTimeMock`: Extra time period
- `noBackButtonMock`: Live state without back button
- `customDateFormatMock`: Alternative date formatting
- `createAnimatedMock()`: Simulates match progression for demos

## Design System Integration

The component uses StyleProvider for all visual attributes:

- **Colors**:
  - Background: `backgroundPrimary`
  - Text: `textPrimary`
  - Icons: `iconPrimary`
  - Live pill background: `highlightSecondary`
  - Live pill text: `buttonTextPrimary`

- **Fonts**:
  - Regular text: `footnoteRegular`
  - Bold text: `footnoteBold`

## Dimensions

- Height: 44pt (standard navigation bar)
- Horizontal padding: 16pt
- Live pill corner radius: 12pt
- Back icon size: 20pt

## SwiftUI Previews

The component includes SwiftUI previews showing:
- Pre-match state
- Live match state
- No back button variant

## Example Match States

Common live match periods:
- "1st Half", "2nd Half"
- "Half Time", "Full Time"
- "Extra Time", "Penalties"
- "1st Period", "2nd Period", "3rd Period" (for other sports)

Time can be:
- Minutes: "41mins", "90+3mins"
- Empty for breaks: "Half Time", ""
- Other formats as needed