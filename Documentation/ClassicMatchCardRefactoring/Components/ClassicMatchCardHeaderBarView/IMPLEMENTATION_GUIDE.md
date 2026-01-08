# ClassicMatchCardHeaderBarView - Implementation Guide

## Prerequisites

Read these GomaUI documents before implementing:

1. **`Frameworks/GomaUI/CLAUDE.md`** - Critical rules for GomaUI components
2. **`Frameworks/GomaUI/UIKIT_CODE_ORGANIZATION_GUIDE.md`** - UIKit coding patterns

## Reference Implementation

Use `MatchHeaderView` as the primary reference - it's the closest existing component:

**Location**: `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchCards/MatchHeaderView/`

Study these files:
- `MatchHeaderView.swift` - View structure, factory methods, bindings
- `MatchHeaderViewModelProtocol.swift` - Protocol pattern with `MatchHeaderImageResolver`
- `MockMatchHeaderViewModel.swift` - Mock preset patterns

## File Structure

Create in `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchCards/ClassicMatchCardHeaderBarView/`:

```
ClassicMatchCardHeaderBarView/
├── ClassicMatchCardHeaderBarView.swift
├── ClassicMatchCardHeaderBarViewModelProtocol.swift
├── ClassicMatchCardHeaderBadgeType.swift
├── MockClassicMatchCardHeaderBarViewModel.swift
└── README.md
```

## Key Patterns to Follow

### 1. Synchronous State Access (CRITICAL)

The component MUST support synchronous state access for UITableView cell sizing:

```
Protocol must expose:
- currentDisplayState (synchronous)
- displayStatePublisher (reactive)
```

Reference: `MatchHeaderView` uses individual publishers, but newer components use `DisplayState` pattern. Check `CompactMatchHeaderView` for DisplayState example.

### 2. Image Resolution

Reuse existing `MatchHeaderImageResolver` protocol from `MatchHeaderViewModelProtocol.swift`:
- `countryFlagImage(for:)`
- `sportIconImage(for:)`
- `favoriteIcon(isFavorite:)`

### 3. ReusableView Conformance

Must implement:
- `configure(with:)` - Sets ViewModel, renders immediately, sets up bindings
- `prepareForReuse()` - Clears cancellables, resets callbacks, clears visuals

### 4. Factory Methods Pattern

All UI components created via `private static func create*() -> UIView` pattern.

## Differences from MatchHeaderView

| Aspect | MatchHeaderView | ClassicMatchCardHeaderBarView |
|--------|-----------------|-------------------------------|
| Right side | Match time + LIVE pill | CashOut icon + Status badge |
| Status badge | LIVE only | LIVE or BOOSTED variants |
| Match time | Shown in header | NOT shown (elsewhere in card) |
| CashOut icon | Not present | Present (conditional) |

## Badge Type Enum

Create `ClassicMatchCardHeaderBadgeType`:
- `.none` - Hidden
- `.live` - Orange pill with "LIVE" + pulsing dot
- `.boosted` - Orange badge with lightning icon

## Mock Presets to Create

1. **Pre-match football** - No badge, with cashout
2. **Live basketball** - LIVE badge, with cashout, favorited
3. **Boosted odds** - BOOSTED badge, no cashout
4. **Favorited Serie A** - No badge, with cashout, favorited

## Catalog Integration

After implementation, register in `ComponentRegistry.swift` and create a demo ViewController in `Catalog/Components/`.

## Build Verification

```bash
xcodebuild -workspace Sportsbook.xcworkspace -scheme GomaUICatalog -destination 'platform=iOS Simulator,id=YOUR_DEVICE_ID' build 2>&1 | xcbeautify --quieter
```

Get device ID from: `xcrun simctl list devices available | grep iPhone`
