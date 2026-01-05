# MatchDateNavigationBar

A navigation bar with back button and match date/live status display.

## Overview

MatchDateNavigationBarView displays a navigation bar for match detail screens, featuring a back button on the left and match status on the right. For pre-match events, it shows a formatted date with mixed font weights. For live matches, it displays a CapsuleView with the current period and time. The component supports customizable date formats and optional back button visibility.

## Component Relationships

### Used By (Parents)
- Match detail screens
- Event detail view controllers

### Uses (Children)
- `CapsuleView` - live status indicator

## Features

- Back button with chevron icon and customizable text
- Pre-match date display with mixed font weights (bold date, regular time)
- Live status capsule with period and time
- Customizable date format
- Optional back button visibility
- Back button tap callback
- Reactive updates via Combine publishers
- 47pt fixed height

## Usage

```swift
let viewModel = MockMatchDateNavigationBarViewModel.liveMock
let navBar = MatchDateNavigationBarView(viewModel: viewModel)

navBar.onBackTapped = {
    navigationController.popViewController(animated: true)
}

// Update match status dynamically
viewModel.configure(with: MatchDateNavigationBarData(
    matchStatus: .live(period: "2nd Half", time: "67mins")
))
```

## Data Model

```swift
enum MatchStatus: Equatable {
    case preMatch(date: Date)
    case live(period: String, time: String)
}

struct MatchDateNavigationBarData: Equatable {
    let id: String
    let matchStatus: MatchStatus
    let backButtonText: String        // Default: "Back"
    let isBackButtonHidden: Bool      // Default: false
    let dateFormat: String            // Default: "HH:mm EEE dd/MM"
}

protocol MatchDateNavigationBarViewModelProtocol {
    var dataPublisher: AnyPublisher<MatchDateNavigationBarData, Never> { get }
    var data: MatchDateNavigationBarData { get }

    func configure(with data: MatchDateNavigationBarData)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundPrimary` - container background
- `StyleProvider.Color.iconPrimary` - back chevron icon tint
- `StyleProvider.Color.textPrimary` - back label, pre-match text color
- `StyleProvider.Color.highlightSecondary` - live capsule background
- `StyleProvider.Color.buttonTextPrimary` - live capsule text color
- `StyleProvider.fontWith(type: .bold, size: 12)` - back label, pre-match date part
- `StyleProvider.fontWith(type: .regular, size: 12)` - pre-match time part
- `StyleProvider.fontWith(type: .bold, size: 10)` - live capsule text

Layout constants:
- Bar height: 47pt
- Horizontal padding: 16pt
- Back icon size: 20pt
- Back icon-text spacing: 6pt
- Live pill horizontal padding: 12pt
- Live pill vertical padding: 4pt
- Live pill corner radius: 12pt

Display modes:
- **Pre-match**: Shows formatted date with bold date part, regular time part
- **Live**: Shows CapsuleView with "period, time" or just "period" if time is empty

## Mock ViewModels

Available presets:
- `.defaultPreMatchMock` - Future date (3 days ahead)
- `.liveMock` - "1st Half, 41mins"
- `.secondHalfMock` - "2nd Half, 67mins"
- `.halfTimeMock` - "Half Time" (no time)
- `.extraTimeMock` - "Extra Time, 105mins"
- `.noBackButtonMock` - "2nd Half, 89mins" with hidden back button
- `.customDateFormatMock` - Custom format "EEEE, MMM d 'at' h:mm a"
- `.createAnimatedMock()` - Cycles through states every 3 seconds
