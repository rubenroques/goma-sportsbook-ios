# CompactMatchHeaderView

A compact header component for inline match cards displaying date/time or LIVE status with optional icons and market count.

## Overview

`CompactMatchHeaderView` provides a flexible header row for match cards with two modes:
- **Pre-live**: Shows date/time text (e.g., "TODAY, 14:00")
- **Live**: Shows LIVE badge + game status (e.g., "2ND SET")

## Architecture

### Files
```
CompactMatchHeaderView/
├── CompactMatchHeaderView.swift              # Main view
├── CompactMatchHeaderViewModelProtocol.swift # Protocol + data models
├── MockCompactMatchHeaderViewModel.swift     # Mock implementation
└── Documentation/
    └── README.md
```

### Component Structure
```
CompactMatchHeaderView
├── containerStackView (horizontal)
│   ├── leftStackView
│   │   ├── liveBadge (hidden when pre-live)
│   │   │   └── liveBadgeLabel ("LIVE")
│   │   └── statusLabel (date/time or game status)
│   │
│   └── rightStackView
│       ├── iconsStackView (EP, bet-builder, etc.)
│       ├── marketCountLabel ("+123")
│       └── arrowImageView (chevron.right)
```

## Usage

### Basic Usage

```swift
// Pre-live header
let preLiveHeader = CompactMatchHeaderView(
    viewModel: MockCompactMatchHeaderViewModel.preLiveToday
)

// Live header
let liveHeader = CompactMatchHeaderView(
    viewModel: MockCompactMatchHeaderViewModel.liveTennis
)
```

### In Card Layout

```swift
// Add header at top of card
cardStackView.addArrangedSubview(headerView)
cardStackView.addArrangedSubview(contentView)
```

### Handle Market Count Tap

```swift
headerView.onMarketCountTapped = { [weak self] in
    self?.coordinator?.showMoreMarkets()
}
```

### Cell Reuse

```swift
override func prepareForReuse() {
    super.prepareForReuse()
    headerView.cleanupForReuse()
}

func configure(with viewModel: CompactMatchHeaderViewModelProtocol) {
    headerView.configure(with: viewModel)
}
```

## Data Models

### CompactMatchHeaderMode

```swift
enum CompactMatchHeaderMode {
    case preLive(dateText: String)  // "TODAY, 14:00"
    case live(statusText: String)   // "2ND SET", "45'"
}
```

### CompactMatchHeaderIcon

```swift
struct CompactMatchHeaderIcon {
    let id: String
    let iconName: String     // Asset name in bundle
    let isVisible: Bool      // Can hide icons per client config
}
```

### CompactMatchHeaderDisplayState

```swift
struct CompactMatchHeaderDisplayState {
    let mode: CompactMatchHeaderMode
    let icons: [CompactMatchHeaderIcon]
    let marketCount: Int?
    let showMarketCountArrow: Bool
}
```

## Mode Examples

### Pre-Live
```
[TODAY, 14:00]                    [EP][BB] +123 >
[17/07, 11:00]                    [EP][BB] +89 >
[TOMORROW, 20:00]                        +45 >
```

### Live
```
[LIVE] 2ND SET                    [EP][BB] +123 >
[LIVE] 45'                        [EP][BB] +78 >
[LIVE] HT                                +65 >
```

## Icons Configuration

Icons can be shown or hidden based on client configuration:

```swift
// With icons (design mockup)
let icons = [
    CompactMatchHeaderIcon(id: "ep", iconName: "erep_short_info", isVisible: true),
    CompactMatchHeaderIcon(id: "betBuilder", iconName: "bet_builder_info", isVisible: true)
]

// Without icons (production)
let icons = [
    CompactMatchHeaderIcon(id: "ep", iconName: "erep_short_info", isVisible: false),
    CompactMatchHeaderIcon(id: "betBuilder", iconName: "bet_builder_info", isVisible: false)
]
```

## Mock Configurations

### Pre-Live States
```swift
MockCompactMatchHeaderViewModel.preLiveToday       // "TODAY, 14:00"
MockCompactMatchHeaderViewModel.preLiveFutureDate  // "17/07, 11:00"
MockCompactMatchHeaderViewModel.preLiveTomorrow    // "TOMORROW, 20:00"
MockCompactMatchHeaderViewModel.preLiveNoIcons     // Hidden icons
```

### Live States
```swift
MockCompactMatchHeaderViewModel.liveTennis         // "2ND SET"
MockCompactMatchHeaderViewModel.liveFootball       // "45'"
MockCompactMatchHeaderViewModel.liveBasketball     // "3RD QTR"
MockCompactMatchHeaderViewModel.liveHalftime       // "HT"
MockCompactMatchHeaderViewModel.liveNoIcons        // Hidden icons
```

### Edge Cases
```swift
MockCompactMatchHeaderViewModel.highMarketCount    // +999
MockCompactMatchHeaderViewModel.noMarketCount      // No count shown
MockCompactMatchHeaderViewModel.minimal            // No icons, no arrow
```

## Styling

All colors and fonts use `StyleProvider`:
- Date/status text: `StyleProvider.Color.highlightPrimary`
- LIVE badge background: `StyleProvider.Color.highlightPrimary`
- LIVE badge text: `StyleProvider.Color.textOnHighlight`
- Market count: `StyleProvider.Color.highlightPrimary`
- Arrow tint: `StyleProvider.Color.highlightPrimary`

## Design Decisions

1. **Flexible Height**: No fixed height constraint to accommodate client customization
2. **Icon Visibility**: Icons can be toggled per-icon for client-specific configurations
3. **Market Count Arrow**: Optional arrow for "more markets" indication
4. **LIVE Badge**: Rounded pill badge with bold text for visibility
