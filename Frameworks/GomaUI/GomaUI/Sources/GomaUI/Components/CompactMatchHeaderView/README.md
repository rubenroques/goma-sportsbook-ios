# CompactMatchHeaderView

A compact header for inline match cards showing time/status and market count.

## Overview

CompactMatchHeaderView displays match timing information on the left (date/time for pre-live matches or LIVE badge with game status for live matches) and market count with optional icons on the right. It's designed for use in compact inline match card layouts where space is limited.

## Component Relationships

### Used By (Parents)
- `InlineMatchCardView` - header section of inline match cards

### Uses (Children)
- None (leaf component)

## Features

- Two display modes: pre-live (date/time) and live (LIVE badge + status)
- LIVE badge with highlight primary background
- Status text (e.g., "2ND SET", "45'", "HT")
- Configurable icons row (e.g., eRep, Bet Builder)
- Market count with "+" prefix (e.g., "+123")
- Optional chevron arrow for navigation
- Tap gesture on market count area
- Clear background
- Cell reuse support via cleanupForReuse()
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockCompactMatchHeaderViewModel.liveFootball
let headerView = CompactMatchHeaderView(viewModel: viewModel)

headerView.onMarketCountTapped = {
    print("Navigate to full market list")
}
```

## Data Model

```swift
enum CompactMatchHeaderMode: Equatable, Hashable {
    case preLive(dateText: String)
    case live(statusText: String)
}

struct CompactMatchHeaderIcon: Equatable, Hashable {
    let id: String
    let iconName: String
    let isVisible: Bool
}

struct CompactMatchHeaderDisplayState: Equatable, Hashable {
    let mode: CompactMatchHeaderMode
    let icons: [CompactMatchHeaderIcon]
    let marketCount: Int?
    let showMarketCountArrow: Bool

    var marketCountText: String? // "+123" format
}

protocol CompactMatchHeaderViewModelProtocol: AnyObject {
    var displayStatePublisher: AnyPublisher<CompactMatchHeaderDisplayState, Never> { get }
    var currentDisplayState: CompactMatchHeaderDisplayState { get }

    func updateMode(_ mode: CompactMatchHeaderMode)
    func updateIcons(_ icons: [CompactMatchHeaderIcon])
    func updateMarketCount(_ count: Int?)
    func onMarketCountTapped()
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - LIVE badge background, status text, market count, arrow
- `StyleProvider.Color.backgroundPrimary` - view background in previews
- `StyleProvider.fontWith(type: .bold, size: 10)` - LIVE badge font
- `StyleProvider.fontWith(type: .bold, size: 12)` - status text font
- `StyleProvider.fontWith(type: .semibold, size: 12)` - market count font

Layout constants:
- LIVE badge padding: 6pt horizontal, 2pt vertical
- LIVE badge corner radius: 4pt
- Icon size: 18pt
- Arrow size: 8x12pt
- Stack spacing: 4-8pt

## Mock ViewModels

Available presets:
- `.preLiveToday` - "TODAY, 14:00" with icons
- `.preLiveFutureDate` - "17/07, 11:00" with icons
- `.preLiveTomorrow` - "TOMORROW, 20:00" without icons
- `.preLiveNoIcons` - pre-live without icons
- `.liveTennis` - LIVE + "2ND SET"
- `.liveFootball` - LIVE + "45'"
- `.liveBasketball` - LIVE + "3RD QTR"
- `.liveHalftime` - LIVE + "HT"
- `.liveTennisFirstSet` - LIVE + "1ST SET"
- `.liveNoIcons` - live without icons
- `.highMarketCount` - market count 999
- `.noMarketCount` - no market count displayed
- `.minimal` - no icons, no arrow
- `.custom(mode:icons:marketCount:showMarketCountArrow:)` - custom configuration
