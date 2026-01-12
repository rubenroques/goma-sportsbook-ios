# ClassicMatchCard Refactoring - Jira Ticket Specifications

This document contains the 13 component specifications for refactoring `MatchWidgetCollectionViewCell` into modular GomaUI components.

---

## LAYER 1: BUILDING BLOCKS (7 Components)

---

### 1. ClassicMatchCardHeaderBarView

**Title:** `[iOS] BF - V2 - Create ClassicMatchCardHeaderBarView - Card Header with Favorite/Status`

**Description:**
```
## Overview
Header bar component for the ClassicMatchCard family displaying match metadata.

## Visual Structure
```
[★] [⚽] [🇫🇷] Tournament Name                    [€↻] [LIVE ●]
 │    │    │         │                              │      │
Fav  Sport Flag   League                        CashOut  Badge
```

## Elements
- **Favorite toggle** (★/☆): 17x17pt icon, 44x44pt touch target
- **Sport icon**: 17x17pt from `MatchHeaderImageResolver`
- **Country flag**: 17x17pt circular with 0.5pt border
- **Tournament name**: Medium 11pt, truncates with ellipsis
- **CashOut icon** (conditional): 18x18pt, shown when `canHaveCashback`
- **Status badge** (conditional): LIVE pill (orange, pulsing dot) or BOOSTED badge

## Badge Types (enum)
- `.none` - Hidden (pre-match)
- `.live` - Orange pill "LIVE ⦿" with shadow
- `.boosted` - Lightning bolt badge

## Key Behaviors
- Favorite tap toggles state + notifies parent
- CashOut icon repositions when LIVE badge appears
- All colors via StyleProvider

## Files to Create
- `ClassicMatchCardHeaderBarView.swift`
- `ClassicMatchCardHeaderBarViewModelProtocol.swift`
- `ClassicMatchCardHeaderBadgeType.swift`
- `MockClassicMatchCardHeaderBarViewModel.swift`

## Reference
- Legacy: `MatchWidgetCollectionViewCell.swift` lines 50-150, 1858-2174
- GomaUI pattern: `MatchHeaderView/`

## Acceptance Criteria
- [ ] Fixed height: 17pt
- [ ] 4 mock presets (pre-match, live+cashout, boosted, favorited)
- [ ] SwiftUI previews for all variants
- [ ] Snapshot test coverage
```

---

### 2. ClassicMatchCardTeamsView

**Title:** `[iOS] BF - V2 - Create ClassicMatchCardTeamsView - Team Names with Score Display`

**Description:**
```
## Overview
Displays home/away team names with optional live score for ClassicMatchCard family.

## Visual Structure
**Pre-Live:**
```
Paris Saint-Germain
Olympique Marseille
```

**Live:**
```
Paris Saint-Germain          │ 1-2-1 │
Olympique Marseille    2 - 1 │ 0-1-0 │
```

## Elements
- **Home team label**: Bold 14pt (normal) / 13pt (compact), max 3 lines
- **Away team label**: Bold 14pt (normal) / 13pt (compact), max 3 lines
- **Score label** (live only): Bold 17pt, format "X - Y"
- **Detailed score view** (live only): Sets/periods grid (see ClassicMatchCardDetailedScoreView)
- **Serving indicator** (tennis): 9x9 white dot next to serving player

## Layout Modes
- **Pre-Live**: Team names stacked vertically, no score
- **Live**: Team names left, score right, detailed score far right

## Typography
- Team names: `StyleProvider.fontWith(type: .bold, size: 14)` normal / `size: 13` compact
- Score: `StyleProvider.fontWith(type: .bold, size: 17)`
- Colors: `textPrimary` default, `buttonTextPrimary` on background image cards

## Files to Create
- `ClassicMatchCardTeamsView.swift`
- `ClassicMatchCardTeamsViewModelProtocol.swift`
- `MockClassicMatchCardTeamsViewModel.swift`

## Reference
- Legacy: Lines containing `homeParticipantNameLabel`, `awayParticipantNameLabel`, `resultLabel`

## Acceptance Criteria
- [ ] Supports pre-live and live modes
- [ ] Team names truncate properly (3 lines max)
- [ ] Score appears only when live
- [ ] Content hugging priority 990 for flexible layout
```

---

### 3. ClassicMatchCardOutcomesLineView

**Title:** `[iOS] BF - V2 - Create ClassicMatchCardOutcomesLineView - 1-X-2 Betting Buttons`

**Description:**
```
## Overview
Horizontal row of outcome buttons (1, X, 2) for bet selection with real-time odds updates.

## Visual Structure
```
┌─────────┐ ┌─────────┐ ┌─────────┐
│ 1  1.85 │ │ X  3.40 │ │ 2  4.20 │
└─────────┘ └─────────┘ └─────────┘
```

## Market Modes
- **3-way**: All 3 buttons visible (Home/Draw/Away)
- **2-way**: 2 buttons visible (Home/Away, middle hidden)
- **1-way**: Single button visible

## Button States
- **Normal**: Default appearance
- **Selected**: Highlighted (in betslip)
- **Disabled**: Alpha 0.5, non-interactive
- **Suspended**: Shows suspended overlay, hides odds

## Odds Change Animation
- **Odds Up**: Green border + up arrow, fade in 0.4s → hold 3s → fade out 0.4s
- **Odds Down**: Red border + down arrow, same timing
- Uses CABasicAnimation for border color transition

## Interactions
- **Tap**: Toggle selection, add/remove from betslip, haptic feedback
- **Long Press**: Triggers `didLongPressOdd` callback for additional options

## Files to Create
- `ClassicMatchCardOutcomesLineView.swift`
- `ClassicMatchCardOutcomesLineViewModelProtocol.swift`
- `ClassicMatchCardOutcomeButton.swift` (individual button)
- `MockClassicMatchCardOutcomesLineViewModel.swift`

## Reference
- Legacy: `homeBaseView`, `drawBaseView`, `awayBaseView`, odds animation methods
- GomaUI pattern: `OutcomeItemView/`, `MarketOutcomesLineView/`

## Acceptance Criteria
- [ ] Supports 1/2/3 way markets
- [ ] Real-time odds update animations
- [ ] Selection state syncs with betslip
- [ ] Haptic feedback on selection
- [ ] Suspended state overlay
```

---

### 4. ClassicMatchCardDateTimeView

**Title:** `[iOS] BF - V2 - Create ClassicMatchCardDateTimeView - Match Date and Time Display`

**Description:**
```
## Overview
Displays match start date and time for pre-live matches.

## Visual Structure
```
Wed 15 Jan
  20:45
```

## Elements
- **Date label**: Medium 12pt (normal) / Semibold 10pt (small)
  - Color: `textSecondary`
- **Time label**: Bold 16pt (normal) / Bold 13pt (small)
  - Color: `textPrimary`

## Date Formatting Logic
- **Today**: "Today"
- **Yesterday**: "Yesterday"
- **Other dates**: "dd MMM" format (e.g., "18 Jan", "25 Dec")

## Time Formatting
- Uses device locale settings
- Short time style (e.g., "14:30" or "2:30 PM")

## Visibility
- **Shown**: Pre-live matches only
- **Hidden**: Live matches (replaced by LiveIndicator + match time)

## Files to Create
- `ClassicMatchCardDateTimeView.swift`
- `ClassicMatchCardDateTimeViewModelProtocol.swift`
- `MockClassicMatchCardDateTimeViewModel.swift`

## Reference
- Legacy: `dateLabel`, `timeLabel`, `dateStackView`
- ViewModel: `startDateString(fromDate:)`, `startTimeStringPublisher`

## Acceptance Criteria
- [ ] Relative date formatting (Today/Yesterday)
- [ ] Locale-aware time formatting
- [ ] Responsive font sizes for card styles
- [ ] Hidden when match is live
```

---

### 5. ClassicMatchCardLiveIndicatorView

**Title:** `[iOS] BF - V2 - Create ClassicMatchCardLiveIndicatorView - Live Badge and Match Time`

**Description:**
```
## Overview
Live status indicator with "LIVE" pill badge and current match time display.

## Visual Structure
```
┌────────┐
│LIVE ⦿  │   45' - 1st Half
└────────┘
```

## Elements
- **Live pill badge**:
  - Height: 18pt, corner radius 9pt (pill shape)
  - Background: `highlightPrimary`
  - Text: "LIVE ⦿" (Unicode dot character)
  - Font: Bold 10pt, color `buttonTextPrimary`
  - Shadow: color=highlightPrimary, opacity=0.7, offset=(-4,2), radius=5

- **Match time label**:
  - Font: Bold 11pt
  - Color: `buttonBackgroundPrimary`
  - Format: "45' - 1st Half", "2nd Half", "45+2'"

## Live Border (GradientBorderView)
- Width: 2.1pt (thicker than normal 1.2pt)
- Gradient colors: `[liveBorderGradient3, liveBorderGradient2, liveBorderGradient1]`
- Corner radius: 9pt

## Visibility
- **Shown**: Live matches only
- **Hidden**: Pre-live matches

## Files to Create
- `ClassicMatchCardLiveIndicatorView.swift`
- `ClassicMatchCardLiveIndicatorViewModelProtocol.swift`
- `MockClassicMatchCardLiveIndicatorViewModel.swift`

## Reference
- Legacy: `liveTipView`, `liveTipLabel`, `liveGradientBorderView`, `matchTimeStatusNewLabel`

## Acceptance Criteria
- [ ] Pill badge with shadow effect
- [ ] Match time displays period info
- [ ] Gradient border for live state
- [ ] Position: top-right of card (8pt right, 10pt top)
```

---

### 6. ClassicMatchCardDetailedScoreView

**Title:** `[iOS] BF - V2 - Create ClassicMatchCardDetailedScoreView - Sets/Periods Score Grid`

**Description:**
```
## Overview
Sport-specific detailed score display showing sets, periods, or innings breakdown.

## Visual Structure (Tennis example)
```
│ 6 │ 4 │ 2 │ 40 │
│ 3 │ 6 │ 1 │ 30 │
  ↑   ↑   ↑   ↑
 S1  S2  S3  Game
```

## Score Cell Styles
1. **Simple** (previous sets): No background, `textSecondary`, alpha=1.0 (winner) / 0.5 (loser)
2. **Border** (current set): No background, `textPrimary`, 1px border
3. **Background** (match total): `backgroundTertiary` fill, `highlightPrimary` text

## Sport-Specific Logic
- **Tennis** (TNS): Sets + current game (shows "A" for advantage/50)
- **Basketball/Volleyball/Badminton/Hockey**: Sets/quarters + total
- **Other sports**: Match total only

## Score Data Model
```swift
enum Score {
    case set(index: Int, home: Int?, away: Int?)
    case gamePart(index: Int?, home: Int?, away: Int?)
    case matchFull(home: Int?, away: Int?)
}
```

## Layout
- Horizontal stack with 4pt spacing
- Cell width: 26px (simple/border), 29px (background)
- Max 6 previous sets shown

## Files to Create
- `ClassicMatchCardDetailedScoreView.swift`
- `ClassicMatchCardDetailedScoreViewModelProtocol.swift`
- `ClassicMatchCardScoreCellView.swift`
- `MockClassicMatchCardDetailedScoreViewModel.swift`

## Reference
- Legacy: `ScoreView.swift`, `ScoreCellView`

## Acceptance Criteria
- [ ] Sport-specific score configurations
- [ ] Three cell visual styles
- [ ] Winner highlighting (alpha difference)
- [ ] Max 6 sets displayed
- [ ] Theme-aware colors
```

---

### 7. ClassicMatchCardMarketPillView

**Title:** `[iOS] BF - V2 - Create ClassicMatchCardMarketPillView - Market Name Badge`

**Description:**
```
## Overview
Pill-shaped badge displaying the current market name with fading line decoration.

## Visual Structure
```
┌────────────┐───────
│Match Result│  ──→
└────────────┘
      ↑           ↑
   Pill       Fading line
```

## Elements
- **Border pill container**:
  - Border: 1px `separatorLineSecondary`
  - Corner radius: height/2 (auto-rounded pill)
  - Padding: 6px horizontal, 2px vertical

- **Market name label**:
  - Font: System 10pt (light)
  - Color: `textSecondary`
  - Examples: "Match Result", "Total Goals", "Over/Under 2.5"

- **Fading line** (FadingView):
  - Width: 19px fixed
  - Height: 1px
  - Gradient: black → clear (horizontal)

## Visibility Logic
- **Shown**: Live matches with `.normal` type + valid market, OR `.boosted` type
- **Hidden**: Pre-live, TopImage variants, Outright

## Files to Create
- `ClassicMatchCardMarketPillView.swift`
- `ClassicMatchCardMarketPillViewModelProtocol.swift`
- `MockClassicMatchCardMarketPillViewModel.swift`

## Reference
- Legacy: `PillLabelView.swift`, `marketNamePillLabelView`

## Acceptance Criteria
- [ ] Auto-sizing pill based on text
- [ ] Fading line decoration
- [ ] Conditional visibility per card type
- [ ] Theme-aware styling
```

---

## LAYER 2: CARD TYPE COMPOSITES (6 Components)

---

### 8. ClassicPreLiveMatchCardView

**Title:** `[iOS] BF - V2 - Create ClassicPreLiveMatchCardView - Pre-Match Card Composite`

**Description:**
```
## Overview
Full pre-live match card composing building block components. This is the baseline card type.

## Visual Structure
```
┌─────────────────────────────────────────────┐
│ 🇫🇷 Ligue 1  ⚽                    ♡  💰   │ ← HeaderBar
├─────────────────────────────────────────────┤
│     Wed 15 Jan                              │ ← DateTime
│       20:45                                 │
├─────────────────────────────────────────────┤
│  Paris Saint-Germain                        │ ← Teams
│  Olympique Marseille                        │
├─────────────────────────────────────────────┤
│  ┌─────────┐ ┌─────────┐ ┌─────────┐       │ ← Outcomes
│  │ 1  1.85 │ │ X  3.40 │ │ 2  4.20 │       │
└─────────────────────────────────────────────┘
```

## Composed Components
1. `ClassicMatchCardHeaderBarView` - with badge=.none
2. `ClassicMatchCardDateTimeView` - visible
3. `ClassicMatchCardTeamsView` - without score
4. `ClassicMatchCardOutcomesLineView` - 2 or 3 way

## Card Styling
- Border: 1.2pt gradient `[cardBorderLineGradient1/2/3]`
- Corner radius: 9pt
- Background: `backgroundCards`
- Height: ~162pt (normal style)

## ViewModel Composition
Protocol exposes child ViewModels for each building block.

## Files to Create
- `ClassicPreLiveMatchCardView.swift`
- `ClassicPreLiveMatchCardViewModelProtocol.swift`
- `MockClassicPreLiveMatchCardViewModel.swift`

## Reference
- Legacy: `MatchWidgetType.normal` + `MatchWidgetStatus.preLive`
- Legacy methods: `drawAsPreLiveCard()`, `drawForMatchWidgetType(.normal)`

## Acceptance Criteria
- [ ] Composes 4 building blocks
- [ ] Gradient border styling
- [ ] ReusableView compliance (prepareForReuse)
- [ ] Exposes child VMs via protocol
- [ ] Snapshot tests for normal and small styles
```

---

### 9. ClassicLiveMatchCardView

**Title:** `[iOS] BF - V2 - Create ClassicLiveMatchCardView - Live Match Card Composite`

**Description:**
```
## Overview
Full live match card with score display, match time, and live indicator.

## Visual Structure
```
┌─────────────────────────────────────────────┐
│ 🇫🇷 Ligue 1  ⚽                 💰  LIVE ⦿ │ ← HeaderBar + LiveIndicator
├─────────────────────────────────────────────┤
│  Paris Saint-Germain          │ 1-2-1 │    │ ← Teams + DetailedScore
│  Olympique Marseille    2 - 1 │ 0-1-0 │    │
├─────────────────────────────────────────────┤
│  45' - 1st Half          ┌────────────┐    │ ← MatchTime + MarketPill
│                          │Match Result│    │
├─────────────────────────────────────────────┤
│  ┌─────────┐ ┌─────────┐ ┌─────────┐       │ ← Outcomes
│  │ 1  1.85 │ │ X  3.40 │ │ 2  4.20 │       │
└─────────────────────────────────────────────┘
```

## Composed Components
1. `ClassicMatchCardHeaderBarView` - with badge=.live
2. `ClassicMatchCardLiveIndicatorView` - visible
3. `ClassicMatchCardTeamsView` - with score
4. `ClassicMatchCardDetailedScoreView` - visible
5. `ClassicMatchCardMarketPillView` - visible
6. `ClassicMatchCardOutcomesLineView` - with real-time updates

## Card Styling
- Border: 2.1pt live gradient `[liveBorderGradient1/2/3]`
- Background: `backgroundDrop`
- Corner radius: 9pt

## Files to Create
- `ClassicLiveMatchCardView.swift`
- `ClassicLiveMatchCardViewModelProtocol.swift`
- `MockClassicLiveMatchCardViewModel.swift`

## Reference
- Legacy: `MatchWidgetType.normal` + `MatchWidgetStatus.live`
- Legacy methods: `drawAsLiveCard()`

## Acceptance Criteria
- [ ] Composes 6 building blocks
- [ ] Live gradient border
- [ ] Real-time score updates
- [ ] Sport-specific detailed score
- [ ] Match time display
```

---

### 10. ClassicTopImageMatchCardView

**Title:** `[iOS] BF - V2 - Create ClassicTopImageMatchCardView - Promotional Image Card`

**Description:**
```
## Overview
Match card with promotional image banner at top, optional MixMatch CTA.

## Visual Structure
```
┌─────────────────────────────────────────────┐
│                                             │
│            [PROMO IMAGE]                    │ ← TopImage
│                                             │
├─────────────────────────────────────────────┤
│ 🇫🇷 Ligue 1  ⚽                    ♡  💰   │ ← HeaderBar
├─────────────────────────────────────────────┤
│  Paris Saint-Germain                        │ ← Teams
│  Olympique Marseille                        │
├─────────────────────────────────────────────┤
│  ┌─────────┐ ┌─────────┐ ┌─────────┐       │ ← Outcomes
│  │ 1  1.85 │ │ X  3.40 │ │ 2  4.20 │       │
├─────────────────────────────────────────────┤
│  ┌─────────────────────────────────────┐   │ ← MixMatch CTA (optional)
│  │  🎯 Or bet with MixMatch  →         │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## Modes
- `.topImage` - Basic promotional image, optional "See All" CTA
- `.topImageWithMixMatch` - Promotional image + MixMatch CTA button

## Composed Components
1. Promotional image view (top banner)
2. `ClassicMatchCardHeaderBarView`
3. `ClassicMatchCardTeamsView`
4. `ClassicMatchCardOutcomesLineView`
5. MixMatch/SeeAll CTA button (conditional)

## Card Styling
- No gradient border (border hidden)
- Image aspect ratio maintained
- Corner radius: 9pt

## Files to Create
- `ClassicTopImageMatchCardView.swift`
- `ClassicTopImageMatchCardViewModelProtocol.swift`
- `MockClassicTopImageMatchCardViewModel.swift`

## Reference
- Legacy: `MatchWidgetType.topImage`, `.topImageWithMixMatch`
- Legacy: `topImageBaseView`, `mixMatchContainerView`

## Acceptance Criteria
- [ ] Promotional image loading with placeholder
- [ ] MixMatch CTA button (conditional)
- [ ] No gradient border
- [ ] Supports both topImage modes
```

---

### 11. ClassicOutrightCardView

**Title:** `[iOS] BF - V2 - Create ClassicOutrightCardView - Competition/Outright Card`

**Description:**
```
## Overview
Card for outright betting (e.g., "Who will win the league?") - no teams, shows competition name.

## Visual Structure
```
┌─────────────────────────────────────────────┐
│                                             │
│            [PROMO IMAGE]                    │ ← TopImage
│                                             │
├─────────────────────────────────────────────┤
│ 🇫🇷 Ligue 1  ⚽                    ♡       │ ← HeaderBar
├─────────────────────────────────────────────┤
│                                             │
│     Who will win Ligue 1 2024/25?          │ ← Outright Name
│                                             │
├─────────────────────────────────────────────┤
│        ┌──────────────────────┐            │
│        │   View All Markets   │            │ ← View Markets Button
│        └──────────────────────┘            │
└─────────────────────────────────────────────┘
```

## Key Differences from Other Cards
- **No teams section** - replaced by outright/event name
- **No outcomes line** - replaced by "View All Markets" button
- Uses `eventName` instead of `competitionName` in header

## Composed Components
1. Promotional image view
2. `ClassicMatchCardHeaderBarView` (uses eventName)
3. Outright name label (centered, multi-line)
4. "View All Markets" button

## Visibility Changes
- `participantsBaseView`: Hidden
- `oddsStackView`: Hidden
- `outrightNameBaseView`: Visible
- `outrightBaseView`: Visible

## Files to Create
- `ClassicOutrightCardView.swift`
- `ClassicOutrightCardViewModelProtocol.swift`
- `MockClassicOutrightCardViewModel.swift`

## Reference
- Legacy: `MatchWidgetType.topImageOutright`
- Legacy method: `showOutrightLayout()`

## Acceptance Criteria
- [ ] No teams/outcomes display
- [ ] Centered outright name
- [ ] "View Markets" button with tap action
- [ ] Header shows event name (not competition)
```

---

### 12. ClassicBoostedMatchCardView

**Title:** `[iOS] BF - V2 - Create ClassicBoostedMatchCardView - Boosted Odds Promotional Card`

**Description:**
```
## Overview
Special promotional card highlighting boosted odds with before/after comparison.

## Visual Structure
```
┌─────────────────────────────────────────────┐
│ 🇫🇷 Ligue 1  ⚽                 ⚡ BOOSTED  │ ← HeaderBar + Boosted Badge
├─────────────────────────────────────────────┤
│  Paris Saint-Germain                        │ ← Teams
│  Olympique Marseille                        │
├─────────────────────────────────────────────┤
│  ┌────────────┐              ┌────────────┐ │ ← BoostedOddsComparison
│  │    1       │      →       │     1      │ │
│  │   1̶.̶5̶0̶     │              │   1.85    │ │   (strikethrough old)
│  └────────────┘              └────────────┘ │
├═════════════════════════════════════════════┤ ← AnimatedGradientLine
└─────────────────────────────────────────────┘
```

## Unique Elements
- **Boosted badge**: Replaces LIVE badge in header (lightning icon)
- **Odds comparison view**: Shows original (strikethrough) → boosted odds
- **Animated gradient line**: Bottom border animation

## Boosted Odds Views (3)
- `homeBoostedOddValueBaseView`
- `drawBoostedOddValueBaseView`
- `awayBoostedOddValueBaseView`

Each shows:
- Outcome title (1, X, 2)
- Original odds with strikethrough
- Boosted odds (highlighted)

## Market Pill
- Visible with boosted badge

## Files to Create
- `ClassicBoostedMatchCardView.swift`
- `ClassicBoostedMatchCardViewModelProtocol.swift`
- `ClassicBoostedOddsComparisonView.swift`
- `MockClassicBoostedMatchCardViewModel.swift`

## Reference
- Legacy: `MatchWidgetType.boosted`
- Legacy: `boostedTopRightCornerBaseView`, `boostedOddBottomLineView`
- Legacy method: `setupBoostedOddsSubviews()`

## Acceptance Criteria
- [ ] Strikethrough original odds
- [ ] Boosted odds highlighted
- [ ] Animated bottom gradient line
- [ ] Boosted badge in header
- [ ] Market pill visible
```

---

### 13. ClassicBackgroundImageMatchCardView

**Title:** `[iOS] BF - V2 - Create ClassicBackgroundImageMatchCardView - Full Background Image Card`

**Description:**
```
## Overview
Match card with full background image - header dimmed, outcomes hidden.

## Visual Structure
```
┌─────────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│ ░░░░░░░░░░ BACKGROUND IMAGE ░░░░░░░░░░░░░░ │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│                                             │
│    Paris Saint-Germain                      │ ← Teams (contrast text)
│    Olympique Marseille                      │
│                                             │
└─────────────────────────────────────────────┘
```

## Key Differences
- **Full background image**: Covers entire card
- **Header hidden**: `headerLineStackView.alpha = 0.0`
- **No outcomes**: `oddsStackView` hidden
- **No gradient border**: Border hidden entirely
- **Contrast text**: Team names use `buttonTextPrimary` for visibility

## Layout Adjustments
- `bottomMargin`: 28pt (largest)
- `teamsHeight`: 47pt (smallest)
- `topMargin`: 0pt (no top margin)

## Composed Components
1. Background image view (full bleed)
2. `ClassicMatchCardTeamsView` (contrast colors)

## Files to Create
- `ClassicBackgroundImageMatchCardView.swift`
- `ClassicBackgroundImageMatchCardViewModelProtocol.swift`
- `MockClassicBackgroundImageMatchCardViewModel.swift`

## Reference
- Legacy: `MatchWidgetType.backgroundImage`
- Legacy: `backgroundImageView`

## Acceptance Criteria
- [ ] Full-bleed background image
- [ ] Header completely hidden
- [ ] No outcomes section
- [ ] Contrast text colors for visibility
- [ ] No border styling
```

---

## Summary

| # | Component | Type | Story Points (suggested) |
|---|-----------|------|--------------------------|
| 1 | ClassicMatchCardHeaderBarView | Building Block | 3 |
| 2 | ClassicMatchCardTeamsView | Building Block | 2 |
| 3 | ClassicMatchCardOutcomesLineView | Building Block | 5 |
| 4 | ClassicMatchCardDateTimeView | Building Block | 1 |
| 5 | ClassicMatchCardLiveIndicatorView | Building Block | 2 |
| 6 | ClassicMatchCardDetailedScoreView | Building Block | 3 |
| 7 | ClassicMatchCardMarketPillView | Building Block | 1 |
| 8 | ClassicPreLiveMatchCardView | Card Composite | 3 |
| 9 | ClassicLiveMatchCardView | Card Composite | 5 |
| 10 | ClassicTopImageMatchCardView | Card Composite | 3 |
| 11 | ClassicOutrightCardView | Card Composite | 2 |
| 12 | ClassicBoostedMatchCardView | Card Composite | 5 |
| 13 | ClassicBackgroundImageMatchCardView | Card Composite | 2 |

**Total: ~37 story points**

---

*Generated: January 2026*
*Source: MatchWidgetCollectionViewCell refactoring analysis*
