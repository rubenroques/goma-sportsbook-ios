# MarketInfoLineView

A market information line with market name pill, feature icons, and market count.

## Overview

MarketInfoLineView displays a horizontal line of market information commonly used in sports betting interfaces. It shows a market name in a pill label on the left, feature icons in the middle (express pick, popular, statistics, bet builder), and a market count on the right. The component handles dynamic icon visibility and long text truncation gracefully.

## Component Relationships

### Used By (Parents)
- None (standalone market info component)

### Uses (Children)
- `MarketNamePillLabelView` - market name display pill

## Features

- Market name pill on the left (truncates for long names)
- Dynamic feature icons (up to 4 types)
- Market count on the right (+count format)
- 17pt fixed height
- Icons stack with 4pt spacing
- Minimum 16pt spacing between pill and icons
- Icons compressed to maintain layout
- Cleanup/configure methods for cell reuse
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockMarketInfoLineViewModel.defaultMock
let marketInfoLine = MarketInfoLineView(viewModel: viewModel)

// For cell reuse
marketInfoLine.cleanupForReuse()
marketInfoLine.configure(with: newViewModel)
```

## Data Model

```swift
enum MarketInfoIconType: String, CaseIterable, Equatable, Hashable {
    case expressPickShort = "erep_short_info"
    case mostPopular = "most_popular_info"
    case statistics = "stats_info"
    case betBuilder = "bet_builder_info"
}

struct MarketInfoIcon: Equatable, Hashable {
    let type: MarketInfoIconType
    let isVisible: Bool
}

struct MarketInfoData: Equatable, Hashable {
    let marketName: String
    let marketCount: Int
    let marketId: String
    let marketTypeId: String?
    let icons: [MarketInfoIcon]
}

struct MarketInfoLineDisplayState: Equatable {
    let marketName: String
    let marketCountText: String
    let visibleIcons: [MarketInfoIcon]
    let shouldShowMarketCount: Bool
}

protocol MarketInfoLineViewModelProtocol {
    var displayStatePublisher: AnyPublisher<MarketInfoLineDisplayState, Never> { get }
    var marketNamePillViewModelPublisher: AnyPublisher<MarketNamePillLabelViewModelProtocol, Never> { get }
    var marketInfoData: MarketInfoData { get }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.highlightPrimary` - market count color
- `StyleProvider.fontWith(type: .semibold, size: 12)` - market count font

Layout constants:
- Line height: 17pt
- Icon height: 15pt
- Icon spacing: 4pt
- Pill-to-icons spacing: 16pt minimum
- Market count alignment: right

## Mock ViewModels

Available presets:
- `.defaultMock` - "1X2 TR" with 3 icons, count +1235
- `.manyIconsMock` - "Both Teams To Score" with all 4 icons, count +2340
- `.noIconsMock` - "Over/Under Goals" with no icons, count +567
- `.noCountMock` - "Match Winner" with 1 icon, count hidden (0)
- `.longMarketNameMock` - very long name with 4 icons, count +1235 (tests truncation)
