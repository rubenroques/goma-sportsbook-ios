# ClassicMatchCardHeaderBarView - Legacy Code Reference

## Original Implementation Location

The header elements are part of the monolithic `MatchWidgetCollectionViewCell`:

**File**: `BetssonFranceLegacy/Core/Screens/PreLive/Cells/MatchWidgetCollectionViewCell.swift`

## Relevant Code Sections

### Header UI Elements (Lines ~50-150)

Look for these IBOutlets/lazy properties:
- `eventNameLabel` - Tournament name
- `sportTypeImageView` - Sport icon
- `locationFlagImageView` - Country flag
- `favoriteIconImageView` / `favoritesButton` - Favorite toggle
- `cashbackIconImageView` - CashOut availability icon
- `liveTipView` - LIVE badge
- `boostedTopRightCornerBaseView` - BOOSTED badge

### Header Layout (Lines ~200-400)

The `headerLineStackView` and related constraints define the header layout.

### Configure Method (Lines ~1858-2174)

The `configure(withViewModel:)` method shows how header elements are bound:
- Favorite state binding
- CashOut visibility (`canHaveCashbackPublisher`)
- Live/preLive state switching

### Status Badge Logic

**Live Badge**: `drawAsLiveCard()` method (Line ~1649)
- Shows `liveTipView`
- Shows `marketNamePillLabelView` when live

**Boosted Badge**: `drawForMatchWidgetType(.boosted)` (Line ~1794)
- Shows `boostedTopRightCornerBaseView`
- Shows animated bottom gradient line

## ViewModel Reference

**File**: `BetssonFranceLegacy/Core/Screens/PreLive/ViewModels/MatchWidgetCellViewModel.swift`

Key publishers for header:
- `isFavoriteMatchPublisher` - Favorite state
- `canHaveCashbackPublisher` - CashOut icon visibility
- `matchWidgetTypePublisher` - Determines badge type (boosted)
- `matchWidgetStatusPublisher` - Determines live status
- `countryFlagImagePublisher` - Country flag
- `sportIconImagePublisher` - Sport icon

## Image Assets

The legacy code uses custom image resolvers from the app. Check:
- `Env.imageResolver` pattern in the legacy codebase
- Country flags: Usually named by country code (e.g., "FR", "IT")
- Sport icons: Named by sport identifier

## Key Behaviors to Preserve

1. **Favorite Toggle** - Tapping updates local state + calls backend
2. **CashOut Icon** - Only visible when match is eligible for cashout
3. **Badge Mutual Exclusivity** - LIVE and BOOSTED badges don't appear together
4. **Truncation** - Long tournament names truncate with ellipsis
