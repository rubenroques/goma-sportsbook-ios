# ClassicMatchCardView Refactoring

This document tracks the refactoring of `MatchWidgetCollectionViewCell` from BetssonFranceLegacy into modular GomaUI components.

## Overview

### The Problem

`MatchWidgetCollectionViewCell` is a 2700+ line monster cell that handles 6 different card types, 3 status modes, and 2 size variations through extensive conditional logic. It's essentially 6+ different cells merged into one.

**File**: `BetssonFranceLegacy/Core/Screens/PreLive/Cells/MatchWidgetCollectionViewCell.swift`
**Size**: ~40,000 tokens (~2700 lines)
**IBOutlets**: 50+
**Lazy views**: 30+
**Combine subscriptions per configure**: 15+

### The Solution

Break this into modular GomaUI components following the established patterns:
- Protocol-driven ViewModels
- Mock implementations for previews
- Composable building blocks
- One card type = one component

## Original Mode Analysis

### MatchWidgetType (from MatchWidgetCellViewModel.swift)

```swift
enum MatchWidgetType: String, CaseIterable {
    case normal
    case topImage
    case topImageWithMixMatch
    case topImageOutright
    case boosted
    case backgroundImage
}
```

### MatchWidgetStatus

```swift
enum MatchWidgetStatus: String, CaseIterable {
    case unknown
    case live
    case preLive
}
```

### CardsStyle (IGNORED - only supporting .normal)

```swift
enum CardsStyle: Codable, CaseIterable {
    case small   // 92pt - IGNORED
    case normal  // 162pt - SUPPORTED
}
```

## New Component Architecture

### Naming Convention

- **GomaUI existing**: `TallOddsMatchCardView`, inline variants
- **New family**: `ClassicMatchCardView` variants

### Layer 1: Atomic Building Blocks

Reusable components that compose into full cards:

| Component | Description | Used In |
|-----------|-------------|---------|
| `ClassicMatchCardHeaderBarView` | Flag + competition name + sport icon + favorite + cashback | All cards |
| `ClassicMatchCardTeamsView` | Home/Away names with optional score display | All match cards |
| `ClassicMatchCardOutcomesLineView` | 1-X-2 buttons (2 or 3 outcomes) | Most cards |
| `ClassicMatchCardDateTimeView` | Date + Time stack | PreLive only |
| `ClassicMatchCardLiveIndicatorView` | "LIVE ⦿" badge with glow | Live cards |
| `ClassicMatchCardDetailedScoreView` | Sets/periods score grid | Live cards |
| `ClassicMatchCardMarketPillView` | Market name pill (e.g., "Match Result") | Live/Boosted |

### Layer 2: Card Type Components

Each card type composes building blocks:

| Card Type | Composes | Original Type |
|-----------|----------|---------------|
| `ClassicPreLiveMatchCardView` | Header + DateTime + Teams + Outcomes | `.normal` + `.preLive` |
| `ClassicLiveMatchCardView` | Header + LiveIndicator + Teams + DetailedScore + MarketPill + Outcomes | `.normal` + `.live` |
| `ClassicTopImageMatchCardView` | TopImage + Header + Teams + Outcomes + (MixMatchCTA OR SeeAllCTA) | `.topImage` / `.topImageWithMixMatch` |
| `ClassicOutrightCardView` | TopImage + Header + OutrightName + ViewMarketsButton | `.topImageOutright` |
| `ClassicBoostedMatchCardView` | Header + Teams + BoostedOddsComparison + AnimatedBottomLine | `.boosted` |
| `ClassicBackgroundImageMatchCardView` | BackgroundImage + Teams + Outcomes | `.backgroundImage` |

## Visual Reference

### PreLive Card Layout
```
┌─────────────────────────────────────────────┐
│ 🇫🇷 Ligue 1  ⚽                    ♡  💰   │ ← Header
├─────────────────────────────────────────────┤
│     Wed 15 Jan                              │ ← DateTime
│       20:45                                 │
├─────────────────────────────────────────────┤
│  Paris Saint-Germain                        │ ← Teams
│  Olympique Marseille                        │
├─────────────────────────────────────────────┤
│  ┌─────────┐ ┌─────────┐ ┌─────────┐       │ ← Outcomes
│  │ 1  1.85 │ │ X  3.40 │ │ 2  4.20 │       │
│  └─────────┘ └─────────┘ └─────────┘       │
└─────────────────────────────────────────────┘
```

### Live Card Layout
```
┌─────────────────────────────────────────────┐
│ 🇫🇷 Ligue 1  ⚽                 💰  LIVE ⦿ │ ← Header + LiveIndicator
├─────────────────────────────────────────────┤
│  Paris Saint-Germain          │ 1-2-1 │    │ ← Teams + DetailedScore
│  Olympique Marseille    2 - 1 │ 0-1-0 │    │
├─────────────────────────────────────────────┤
│  45' - 1st Half          ┌────────────┐    │ ← MatchTime + MarketPill
│                          │Match Result│    │
├─────────────────────────────────────────────┤
│  ┌─────────┐ ┌─────────┐ ┌─────────┐       │ ← Outcomes
│  │ 1  1.85 │ │ X  3.40 │ │ 2  4.20 │       │
│  └─────────┘ └─────────┘ └─────────┘       │
└─────────────────────────────────────────────┘
```

### TopImage Card Layout
```
┌─────────────────────────────────────────────┐
│                                             │
│            [PROMO IMAGE]                    │ ← TopImage
│                                             │
├─────────────────────────────────────────────┤
│ 🇫🇷 Ligue 1  ⚽                    ♡  💰   │ ← Header
├─────────────────────────────────────────────┤
│  Paris Saint-Germain                        │
│  Olympique Marseille                        │
├─────────────────────────────────────────────┤
│  ┌─────────┐ ┌─────────┐ ┌─────────┐       │
│  │ 1  1.85 │ │ X  3.40 │ │ 2  4.20 │       │
│  └─────────┘ └─────────┘ └─────────┘       │
├─────────────────────────────────────────────┤
│  ┌─────────────────────────────────────┐   │ ← MixMatch OR SeeAll CTA
│  │  🎯 Or bet with MixMatch  →         │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

### Boosted Card Layout
```
┌─────────────────────────────────────────────┐
│ 🇫🇷 Ligue 1  ⚽                 ⚡ BOOSTED  │ ← Header + BoostedBadge
├─────────────────────────────────────────────┤
│  Paris Saint-Germain                        │
│  Olympique Marseille                        │
├─────────────────────────────────────────────┤
│  ┌────────────┐              ┌────────────┐ │ ← BoostedOddsComparison
│  │    1       │      →       │     1      │ │
│  │   1̶.̶5̶0̶     │              │   1.85    │ │
│  └────────────┘              └────────────┘ │
├═════════════════════════════════════════════┤ ← AnimatedGradientLine
└─────────────────────────────────────────────┘
```

## Implementation Order

### Phase 1: Building Blocks
1. [ ] `ClassicMatchCardHeaderBarView` → [Documentation](./Components/ClassicMatchCardHeaderBarView/)
2. [ ] `ClassicMatchCardTeamsView`
3. [ ] `ClassicMatchCardOutcomesLineView`
4. [ ] `ClassicMatchCardDateTimeView`

### Phase 2: PreLive Card (baseline)
5. [ ] `ClassicPreLiveMatchCardView`

### Phase 3: Live Card
6. [ ] `ClassicMatchCardLiveIndicatorView`
7. [ ] `ClassicMatchCardDetailedScoreView`
8. [ ] `ClassicMatchCardMarketPillView`
9. [ ] `ClassicLiveMatchCardView`

### Phase 4: TopImage Cards
10. [ ] `ClassicTopImageMatchCardView` (with mixMatch mode)
11. [ ] `ClassicOutrightCardView`

### Phase 5: Special Cards
12. [ ] `ClassicBoostedMatchCardView`
13. [ ] `ClassicBackgroundImageMatchCardView`

## File Locations

### Source (Legacy)
- `BetssonFranceLegacy/Core/Screens/PreLive/Cells/MatchWidgetCollectionViewCell.swift`
- `BetssonFranceLegacy/Core/Screens/PreLive/ViewModels/MatchWidgetCellViewModel.swift`

### Target (GomaUI)
- `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchCards/ClassicMatchCard*/`

## Component Documentation Structure

Each component has its own documentation folder in `./Components/`:

```
Components/
└── ClassicMatchCardHeaderBarView/
    ├── SPECIFICATION.md      # Visual specs, element breakdown, behavior
    ├── IMPLEMENTATION_GUIDE.md # GomaUI patterns, references, file structure
    └── LEGACY_REFERENCE.md   # Pointers to original legacy code
```

When implementing a component, read all three files in order.

## Migration Strategy

1. Build new GomaUI components with previews
2. Test in GomaUICatalog
3. Create adapter layer to use new components in legacy cells
4. Gradually replace usage in BetssonFranceLegacy
5. Eventually deprecate MatchWidgetCollectionViewCell

---

*Created: January 2026*
*Status: Planning*
