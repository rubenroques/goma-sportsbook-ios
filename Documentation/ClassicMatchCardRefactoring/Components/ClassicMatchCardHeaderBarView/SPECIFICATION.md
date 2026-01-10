# ClassicMatchCardHeaderBarView - Component Specification

## Overview

`ClassicMatchCardHeaderBarView` is a header bar component for the Classic Match Card family. It displays match metadata including favorite toggle, sport type, country/region, tournament name, and conditional right-side elements like cashout availability and status badges.

## Visual Reference

### Structure Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  [★]  [⚽]  [🏳]  Tournament Name                      [€↻]  [STATUS BADGE] │
│   │     │     │         │                                │         │        │
│ Fav   Sport  Country  League/Tournament              CashOut   Live/Promo  │
│ Icon  Icon   Icon     Text Label                      Icon      Badge      │
└─────────────────────────────────────────────────────────────────────────────┘
        ╰──────────────────────╯                        ╰────────────────────╯
              LEFT SECTION                                  RIGHT SECTION
              (Always Present)                              (Conditional)
```

### Variant 1: Live Match with CashOut

```
┌─────────────────────────────────────────────────────────────────────────┐
│  ☆   🏀   🌐   Euroligue                                 €↻   ┌──────┐ │
│                                                               │LIVE ●│ │
│                                                               └──────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

- ☆ = Favorite toggle (outlined = not favorited)
- 🏀 = Sport icon (Basketball)
- 🌐 = Globe (international/no specific country)
- €↻ = CashOut available icon
- LIVE ● = Orange pill badge with pulsing dot indicator

### Variant 2: Pre-match with CashOut, No Badge

```
┌─────────────────────────────────────────────────────────────────────────┐
│  ★   ⚽   🇮🇹   Serie A - Italie                                     €↻  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

- ★ = Filled star (favorited)
- 🇮🇹 = Country flag icon (Italy)
- No status badge (pre-match state)
- CashOut icon present

### Variant 3: Boosted Odds Promotion

```
┌─────────────────────────────────────────────────────────────────────────┐
│  ☆   ⚽   🇫🇷   Trophee des Champions - France         ┌─────────────┐  │
│                                                        │ ⚡BOOSTED   │  │
│                                                        └─────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

- Special promo badge replaces LIVE badge
- No CashOut icon visible (mutually exclusive with boosted badge)

### Variant 4: Live + CashOut (Full Right Section)

```
┌─────────────────────────────────────────────────────────────────────────┐
│  ☆   ⚽   🌐   Ligue 1 - Algérie                          €↻   ┌──────┐│
│                                                                │LIVE ●││
│                                                                └──────┘│
└─────────────────────────────────────────────────────────────────────────┘
```

## Component Elements

### Element Specification Table

| Position | Element | Type | Visibility | Tap Action |
|----------|---------|------|------------|------------|
| Left 1 | Favorite Star | Icon Button | Always | Toggle favorite state |
| Left 2 | Sport Icon | Icon | Always | None |
| Left 3 | Country/Region | Flag/Globe Icon | Always | None |
| Left 4 | Tournament Name | Text Label | Always | None |
| Right 1 | CashOut Icon | Icon | Conditional | None |
| Right 2 | Status Badge | Pill/Badge View | Conditional | None |

### Status Badge Variants

| Badge Type | Appearance | Use Case |
|------------|------------|----------|
| `.none` | Hidden | Pre-match without promotions |
| `.live` | Orange pill, white "LIVE" text, pulsing dot | Live matches |
| `.boosted` | Orange/gold badge with lightning bolt icon | Boosted odds promotion |

## Layout Specifications

### Dimensions

- **Height**: 17pt (fixed)
- **Icon Size**: 17x17pt for all icons (favorite, sport, country)
- **Badge Height**: 17pt (pill-shaped, width fits content)
- **Spacing**: 4pt between left section elements
- **Touch Target**: Favorite button needs 44x44pt minimum touch area (invisible overlay)

### Typography

- **Tournament Name**: `StyleProvider.fontWith(type: .medium, size: 11)`
- **Badge Text**: `StyleProvider.fontWith(type: .semibold, size: 10)`

### Colors

- **Tournament Name**: `StyleProvider.Color.highlightPrimary`
- **Favorite Icon (selected)**: `StyleProvider.Color.favorites`
- **Favorite Icon (unselected)**: `StyleProvider.Color.favorites` (outlined variant)
- **Live Badge Background**: `StyleProvider.Color.highlightPrimary` (orange/red)
- **Live Badge Text**: `.white`
- **Boosted Badge Background**: `StyleProvider.Color.highlightPrimary` or gold variant
- **CashOut Icon**: `StyleProvider.Color.highlightPrimary`

## Behavior

### Favorite Toggle

1. User taps favorite icon area (44x44pt touch target)
2. Call `viewModel.toggleFavorite()`
3. ViewModel updates state
4. View receives new state via publisher and updates icon

### State Updates

All visual updates come through the ViewModel's publishers:
- Favorite state changes
- CashOut availability changes
- Status badge type changes
- Tournament name changes (rare, but possible in live updates)

## Image Resolution

The component should use `MatchHeaderImageResolver` protocol (already exists in GomaUI) for resolving:
- Country flag images from country codes
- Sport icons from sport identifiers
- Favorite icons (filled/outlined variants)

This allows the consuming app to provide its own image assets.

## Accessibility

- Favorite button should have accessibility label: "Add to favorites" / "Remove from favorites"
- Status badge should announce: "Live match" / "Boosted odds"
- Tournament name should be readable by VoiceOver
