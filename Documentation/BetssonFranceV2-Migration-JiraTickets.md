# BetssonFrance V2 Migration - GomaUI Component Jira Tickets

> **Project**: Betsson France Legacy → Betsson France V2 (Modern MVVM-C)
> **Generated**: December 10, 2025
> **Total Tickets**: 46 components to create

---

## Executive Summary

This document contains all Jira tickets needed to migrate BetssonFrance Legacy UI components to modern GomaUI architecture. Components are organized by feature area with priority classifications.

### Priority Legend
- **P1**: Critical for launch - Must have for MVP
- **P2**: Important - Required for full feature parity
- **P3**: Nice to have - Can be implemented post-launch

### Complexity Legend
- **S**: Small (1 hour)
- **M**: Medium (2-4 hours)
- **L**: Large (1-2 days)
- **XL**: Extra Large (+3 days)

---

## Feature Area 1: Match/Event Cards (13 tickets)

### MATCH-01: HeroMatchBannerView
| Field | Value |
|-------|-------|
| **Title** | Create HeroMatchBannerView - Large Featured Match Card with Promotional Image |
| **Component** | `HeroMatchBannerView` |
| **Complexity** | XL |
| **Priority** | P1 |
| **Legacy** | `HeroCardTableViewCell` |

**Description**:
Large featured match card for home screen hero sections. Displays promoted match with full-bleed promotional background image, competition info bar, auto-scrolling markets carousel, and page control indicator.

**Acceptance Criteria**:
- [ ] Fixed height of 500pt with rounded card corners (9pt radius)
- [ ] Full-bleed promotional background image with gradient overlay
- [ ] Top info bar (31pt) with favorite icon, sport icon, country flag, competition name
- [ ] Horizontal collection view carousel for markets
- [ ] Page control indicator (CustomPageControl style)
- [ ] Auto-scroll timer (5 second interval)
- [ ] Pan gesture for manual carousel navigation
- [ ] Tap gesture navigates to match details
- [ ] Protocol-driven ViewModel with Combine bindings
- [ ] Mock ViewModel with sample data

**Dependencies**: MarketInfoLineView, OutcomeItemView, HeroCardMarketItemView (MATCH-02)

---

### MATCH-02: HeroCardMarketItemView
| Field | Value |
|-------|-------|
| **Title** | Create HeroCardMarketItemView - Market Display for Hero Card Carousel |
| **Component** | `HeroCardMarketItemView` |
| **Complexity** | L |
| **Priority** | P1 |
| **Legacy** | `HeroCardMarketCollectionViewCell`, `HeroCardSecondaryMarketCollectionViewCell` |

**Description**:
Market display component for HeroMatchBannerView carousel. Shows team names, date/time, market name pill, and 2-3 outcome buttons.

**Acceptance Criteria**:
- [ ] Transparent background (overlays hero card gradient)
- [ ] Team names display (home/away)
- [ ] Date and time labels (right-aligned)
- [ ] Market name pill with bordered style
- [ ] Horizontal stack of 2-3 outcome buttons (1-X-2 and Over/Under)
- [ ] Selection state synchronization with betslip
- [ ] Real-time odds updates with animated change indicators
- [ ] Long press gesture for quick actions

**Dependencies**: MarketInfoLineView

---

### MATCH-03: MarketWidgetCardView
| Field | Value |
|-------|-------|
| **Title** | Create MarketWidgetCardView - Compact Market Card with Stats Integration |
| **Component** | `MarketWidgetCardView` |
| **Complexity** | XL |
| **Priority** | P1 |
| **Legacy** | `OddDoubleCollectionViewCell`, `OddTripleCollectionViewCell`, `MatchWidgetCollectionViewCell` |

**Description**:
Primary card for horizontal scrolling match rows. Compact market card with 2-3 outcomes, gradient border (live vs prematch), optional stats, and cashback indicator.

**Acceptance Criteria**:
- [ ] Gradient border (different for live vs prematch)
- [ ] Header row with participants name and country flag
- [ ] Market name label with optional stats button
- [ ] Support 2-outcome (Over/Under) and 3-outcome (1-X-2) layouts
- [ ] Outcome buttons with title, value, selection state, animated odds changes
- [ ] Optional stats line visualization
- [ ] Cashback icon indicator
- [ ] Card style variants: small and normal
- [ ] Long press on outcome for quick bet

**Dependencies**: OutcomeItemView, GradientBorderView, MarketStatsLineView (MATCH-04)

---

### MATCH-04: MarketStatsLineView
| Field | Value |
|-------|-------|
| **Title** | Create MarketStatsLineView - Inline Market Statistics Display |
| **Component** | `MarketStatsLineView` |
| **Complexity** | M |
| **Priority** | P2 |
| **Legacy** | `HeadToHeadCardStatsView`, `HomeAwayCardStatsView` |

**Description**:
Compact inline statistics visualization for market cards. Shows head-to-head or home/away statistics with colored indicators.

**Acceptance Criteria**:
- [ ] Two visualization types: Head-to-head (Win/Draw/Loss) and Home/Away (Over/Under)
- [ ] Home/Away team indicators (colored circles)
- [ ] Compact height for inline display
- [ ] Optional "Stats" button for fullscreen stats

**Dependencies**: None

---

### MATCH-05: ExpandableMarketSectionView
| Field | Value |
|-------|-------|
| **Title** | Create ExpandableMarketSectionView - Collapsible Market Display for Match Details |
| **Component** | `ExpandableMarketSectionView` |
| **Complexity** | L |
| **Priority** | P1 |
| **Legacy** | `ThreeAwayMarketDetailTableViewCell`, `OverUnderMarketDetailTableViewCell`, `SimpleListMarketDetailTableViewCell` |

**Description**:
Expandable/collapsible market section for match details. Displays market header with expand controls, cashback/custom bet icons, and grid of outcomes.

**Acceptance Criteria**:
- [ ] Card with gradient border and rounded corners (9pt)
- [ ] Header with market name, cashback icon, custom bet icon, expand button
- [ ] Column-based outcome grid (2 or 3 columns)
- [ ] Collapsed: Show first 4 rows only
- [ ] Expanded: Show all rows
- [ ] "See more"/"See less" toggle

**Dependencies**: OutcomeItemView, GradientBorderView

---

### MATCH-06: GridMarketOutcomesView
| Field | Value |
|-------|-------|
| **Title** | Create GridMarketOutcomesView - Dynamic Column Grid for Market Outcomes |
| **Component** | `GridMarketOutcomesView` |
| **Complexity** | M |
| **Priority** | P1 |
| **Legacy** | Grid logic in `SimpleListMarketDetailTableViewCell` |

**Description**:
Flexible grid layout for outcomes in configurable column counts. Used within ExpandableMarketSectionView.

**Acceptance Criteria**:
- [ ] Support 2, 3, or dynamic column counts
- [ ] Automatic row calculation
- [ ] Handle sparse grids (empty cells)
- [ ] Proper cell spacing

**Dependencies**: OutcomeItemView

---

### MATCH-07: CompetitionCardView
| Field | Value |
|-------|-------|
| **Title** | Create CompetitionCardView - Competition/Tournament Display Card |
| **Component** | `CompetitionCardView` |
| **Complexity** | M |
| **Priority** | P2 |
| **Legacy** | `OutrightCompetitionLargeWidgetCollectionViewCell`, `CompetitionWidgetCollectionViewCell` |

**Description**:
Card for displaying competitions/tournaments with name, flags, icons, and CTA button.

**Acceptance Criteria**:
- [ ] Gradient border with rounded corners
- [ ] Header with favorite icon, sport icon, country flag, venue name
- [ ] Competition name (centered, bold)
- [ ] CTA button ("View Markets")
- [ ] Small and normal size variants

**Dependencies**: GradientBorderView, ButtonView

---

### MATCH-08: CompetitionPillSelectorView
| Field | Value |
|-------|-------|
| **Title** | Create CompetitionPillSelectorView - Pill-Style Competition Quick Filter |
| **Component** | `CompetitionPillSelectorView` |
| **Complexity** | S |
| **Priority** | P3 |
| **Legacy** | `TopCompetitionCollectionViewCell` |

**Description**:
Horizontal scrollable pill selector for competition filtering.

**Acceptance Criteria**:
- [ ] Horizontal scroll container
- [ ] Pill items with text and optional icon
- [ ] Single selection behavior
- [ ] Selected/unselected visual states

**Dependencies**: PillSelectorBarView (may extend)

---

### MATCH-09: HorizontalMatchCardScrollView
| Field | Value |
|-------|-------|
| **Title** | Create HorizontalMatchCardScrollView - Horizontal Scrolling Match Cards Container |
| **Component** | `HorizontalMatchCardScrollView` |
| **Complexity** | M |
| **Priority** | P1 |
| **Legacy** | `SportMatchSingleLineTableViewCell`, `SportMatchDoubleLineTableViewCell` |

**Description**:
Container for horizontal row of match cards with section header.

**Acceptance Criteria**:
- [ ] Section header with title
- [ ] Optional "See All" button
- [ ] Horizontal collection view
- [ ] Single-row and double-row variants
- [ ] Paging behavior

**Dependencies**: TallOddsMatchCardView, MarketWidgetCardView

---

### MATCH-10: PromotionalBannerScrollView
| Field | Value |
|-------|-------|
| **Title** | Create PromotionalBannerScrollView - Scrollable Promotional Banner Container |
| **Component** | `PromotionalBannerScrollView` |
| **Complexity** | M |
| **Priority** | P2 |
| **Legacy** | `BannerScrollTableViewCell`, `BannerMatchCollectionViewCell` |

**Description**:
Horizontal scrolling container for promotional and match banners.

**Acceptance Criteria**:
- [ ] Horizontal collection view with paging
- [ ] Auto-scroll timer
- [ ] Page control indicator
- [ ] Support different banner types

**Dependencies**: MatchBannerView

---

### MATCH-11: SeeMoreMarketsCardView
| Field | Value |
|-------|-------|
| **Title** | Create SeeMoreMarketsCardView - "See All" Navigation Card |
| **Component** | `SeeMoreMarketsCardView` |
| **Complexity** | S |
| **Priority** | P3 |
| **Legacy** | `SeeMoreMarketsCollectionViewCell` |

**Description**:
Card at end of lists showing count and navigation to full listings.

**Acceptance Criteria**:
- [ ] Card matching surrounding card dimensions
- [ ] Circular progress ring or count badge
- [ ] "See All Markets" text
- [ ] Arrow icon

**Dependencies**: None

---

### MATCH-12: BoostedOddsBarView
| Field | Value |
|-------|-------|
| **Title** | Create BoostedOddsBarView - Odds Boost Comparison Display |
| **Component** | `BoostedOddsBarView` |
| **Complexity** | M |
| **Priority** | P2 |
| **Legacy** | Boosted odds elements in `MatchWidgetCollectionViewCell` |

**Description**:
Component showing boosted odds with before/after comparison.

**Acceptance Criteria**:
- [ ] Old odds (muted, strikethrough)
- [ ] Arrow indicator
- [ ] New boosted odds (highlighted)
- [ ] Animated gradient/pulsing effect

**Dependencies**: OutcomeItemView patterns

---

### MATCH-13: LiveMatchBorderView
| Field | Value |
|-------|-------|
| **Title** | Create LiveMatchBorderView - Animated Gradient Border for Live Matches |
| **Component** | `LiveMatchBorderView` |
| **Complexity** | S |
| **Priority** | P1 |
| **Legacy** | `GradientBorderView`, `liveGradientBorderView` |

**Description**:
Gradient border with live match styling and optional glow effects.

**Acceptance Criteria**:
- [ ] Configurable gradient colors array
- [ ] Live match preset (red/orange tones)
- [ ] Prematch preset (neutral tones)
- [ ] Configurable border width and corner radius
- [ ] Optional glow/shadow for live state

**Dependencies**: GradientBorderView (may extend)

---

## Feature Area 2: Betting/Betslip/MyBets (16 tickets)

### BET-01: MyBetsTicketCardView
| Field | Value |
|-------|-------|
| **Title** | Create MyBetsTicketCardView - Full ticket card for bet history display |
| **Component** | `MyBetsTicketCardView` |
| **Complexity** | XL |
| **Priority** | P1 |
| **Legacy** | `MyTicketCardView` (~1080 lines) |

**Description**:
Comprehensive ticket card for My Bets section. Shows header (bet type, status, date, bet ID), selection lines, amounts, cashout controls, and bonus indicators.

**Acceptance Criteria**:
- [ ] Header with bet type, status badge, date, bet ID
- [ ] Selection lines stack
- [ ] Amounts section: Total Odds, Bet Amount, Winnings/Returns
- [ ] Status-based card highlighting (won, lost, cashed_out, cancelled, open)
- [ ] CashoutSliderView integration for partial cashout
- [ ] FreeBet badge
- [ ] Cashback badge with info button
- [ ] WinBoost info bar
- [ ] Share button
- [ ] Loading overlay during cashout

**Dependencies**: TicketSelectionView, CashoutSliderView, BetTicketStatusView, CashbackBadgeView (BET-08), WinBoostBannerView (BET-09)

---

### BET-02: MyBetsSelectionLineView
| Field | Value |
|-------|-------|
| **Title** | Create MyBetsSelectionLineView - Individual bet selection line for ticket display |
| **Component** | `MyBetsSelectionLineView` |
| **Complexity** | L |
| **Priority** | P1 |
| **Legacy** | `MyTicketBetLineView` (~370 lines) |

**Description**:
Detailed selection line for individual bets within ticket cards.

**Acceptance Criteria**:
- [ ] Sport icon, country flag, tournament name
- [ ] Home/away team names with scores
- [ ] Market name with event part
- [ ] Outcome name and odd value
- [ ] Result status indicator badge (color-coded)
- [ ] Date display / Live indicator
- [ ] Tappable for match navigation

**Dependencies**: BetTicketStatusView

---

### BET-03: SimpleTicketCardView
| Field | Value |
|-------|-------|
| **Title** | Create SimpleTicketCardView - Simplified ticket card for sharing |
| **Component** | `SimpleTicketCardView` |
| **Complexity** | M |
| **Priority** | P2 |
| **Legacy** | `SimpleMyTicketCardView` |

**Description**:
Simplified ticket without interactive elements for sharing and image generation.

**Acceptance Criteria**:
- [ ] Header (bet type, status, date)
- [ ] Selection lines stack
- [ ] Amounts summary
- [ ] Status-based coloring
- [ ] No cashout/interactive elements
- [ ] Optimized for image snapshot

**Dependencies**: MyBetsSelectionLineView, BetTicketStatusView

---

### BET-04: BetslipErrorBannerView
| Field | Value |
|-------|-------|
| **Title** | Create BetslipErrorBannerView - Warning/error message banner for betslip |
| **Component** | `BetslipErrorBannerView` |
| **Complexity** | S |
| **Priority** | P1 |
| **Legacy** | `BetslipErrorView` |

**Description**:
Banner for displaying betslip warnings and errors.

**Acceptance Criteria**:
- [ ] Warning mode (yellow/orange)
- [ ] Error mode (red)
- [ ] Icon based on mode
- [ ] Multi-line message text
- [ ] Optional dismiss button
- [ ] Animated show/hide
- [ ] Left accent line indicator

**Dependencies**: ButtonView

---

### BET-05: BonusSwitchRowView
| Field | Value |
|-------|-------|
| **Title** | Create BonusSwitchRowView - Toggle row for FreeBet/OddsBoost/Cashback bonuses |
| **Component** | `BonusSwitchRowView` |
| **Complexity** | S |
| **Priority** | P1 |
| **Legacy** | `BonusSwitchView` |

**Description**:
Toggle row for enabling bonus features during bet placement.

**Acceptance Criteria**:
- [ ] Bonus type icon (FreeBet, OddsBoost, Cashback)
- [ ] Bonus label
- [ ] Available amount display
- [ ] Toggle switch
- [ ] Disabled state
- [ ] Optional info button

**Dependencies**: AmountPillView

---

### BET-06: BoostedOddsReofferView
| Field | Value |
|-------|-------|
| **Title** | Create BoostedOddsReofferView - Re-offer dialog with countdown timer |
| **Component** | `BoostedOddsReofferView` |
| **Complexity** | M |
| **Priority** | P2 |
| **Legacy** | `BoostedBetConfirmationView` |

**Description**:
Modal dialog for boosted odds re-offers with countdown.

**Acceptance Criteria**:
- [ ] Original odds value
- [ ] New/boosted odds (highlighted)
- [ ] Countdown timer (30 seconds)
- [ ] Accept button (primary)
- [ ] Reject button (secondary)
- [ ] Auto-reject on timer expiry

**Dependencies**: ButtonView

---

### BET-07: BetSubmissionSuccessView
| Field | Value |
|-------|-------|
| **Title** | Create BetSubmissionSuccessView - Success screen content view for placed bets |
| **Component** | `BetSubmissionSuccessView` |
| **Complexity** | L |
| **Priority** | P2 |
| **Legacy** | `BetSubmissionSuccessViewController` (~1070 lines) |

**Description**:
Success view after bet placement with summary and sharing options.

**Acceptance Criteria**:
- [ ] Success header with animation slot
- [ ] Scrollable ticket cards area
- [ ] "Keep bet in betslip" checkbox
- [ ] Spin Wheel button (enabled/disabled/loading)
- [ ] Continue button
- [ ] Optional cashback result display

**Dependencies**: SimpleTicketCardView, ButtonView, CheckboxView

---

### BET-08: CashbackBadgeView
| Field | Value |
|-------|-------|
| **Title** | Create CashbackBadgeView - Small badge with info button for cashback display |
| **Component** | `CashbackBadgeView` |
| **Complexity** | S |
| **Priority** | P2 |
| **Legacy** | `CashbackInfoView` |

**Description**:
Compact badge showing "Cashback" with info button for tooltip.

**Acceptance Criteria**:
- [ ] Compact pill/badge shape
- [ ] "Cashback" text label
- [ ] Info icon button
- [ ] Tap callback for info action
- [ ] StyleProvider colors

**Dependencies**: None

---

### BET-09: WinBoostBannerView
| Field | Value |
|-------|-------|
| **Title** | Create WinBoostBannerView - Win boost info banner with gradient border |
| **Component** | `WinBoostBannerView` |
| **Complexity** | M |
| **Priority** | P2 |
| **Legacy** | `WinBoostInfoView` |

**Description**:
Promotional banner for Win Boost with gradient border and boost info.

**Acceptance Criteria**:
- [ ] Gradient border (configurable colors)
- [ ] Rocket/boost icon
- [ ] Title label
- [ ] Boost percentage label
- [ ] Boosted win value label

**Dependencies**: GradientView

---

### BET-10: CashbackTooltipView
| Field | Value |
|-------|-------|
| **Title** | Create CashbackTooltipView - Tooltip popup with triangle pointer |
| **Component** | `CashbackTooltipView` |
| **Complexity** | S |
| **Priority** | P3 |
| **Legacy** | `CashbackLearnMoreView` |

**Description**:
Tooltip/popover for cashback information with triangle pointer.

**Acceptance Criteria**:
- [ ] Floating card with shadow
- [ ] Triangular pointer (configurable position)
- [ ] Info text with "Learn More" link
- [ ] Tap callback for learn more
- [ ] Auto-dismiss on external tap

**Dependencies**: None

---

### BET-11: QuickBetCardView
| Field | Value |
|-------|-------|
| **Title** | Create QuickBetCardView - Compact modal card for quick single bet placement |
| **Component** | `QuickBetCardView` |
| **Complexity** | L |
| **Priority** | P2 |
| **Legacy** | `QuickBetViewController` (~1070 lines) |

**Description**:
Compact card for quick single bet without full betslip.

**Acceptance Criteria**:
- [ ] Outcome with odd (change indicators)
- [ ] Market and match info
- [ ] Stake text field with currency
- [ ] Quick-add buttons (+10, +20, +50)
- [ ] Place Bet button
- [ ] Return amount display
- [ ] Error message area
- [ ] Loading overlay
- [ ] Suspended overlay
- [ ] Close button

**Dependencies**: BorderedTextFieldView, AmountPillView, ButtonView

---

### BET-12: QuickBetSuccessView
| Field | Value |
|-------|-------|
| **Title** | Create QuickBetSuccessView - Success state for quick bet placement |
| **Component** | `QuickBetSuccessView` |
| **Complexity** | S |
| **Priority** | P2 |
| **Legacy** | Success state in `QuickBetViewController` |

**Description**:
Success view within quick bet modal.

**Acceptance Criteria**:
- [ ] Success icon/image
- [ ] "Bet Registered" title
- [ ] "Good Luck" subtitle
- [ ] Possible winnings display
- [ ] Continue button

**Dependencies**: ButtonView

---

### BET-13: SuggestedBetCardView
| Field | Value |
|-------|-------|
| **Title** | Create SuggestedBetCardView - Suggested bet combination card |
| **Component** | `SuggestedBetCardView` |
| **Complexity** | M |
| **Priority** | P3 |
| **Legacy** | `SuggestedBetTableViewCell` |

**Description**:
Card displaying suggested bet combination with stacked selections.

**Acceptance Criteria**:
- [ ] Stacked selection cards (overlapping style)
- [ ] Number of selections label
- [ ] Total odds value
- [ ] "Bet Now" button
- [ ] Loading indicator
- [ ] Selection details on expand

**Dependencies**: GameSelectionCardView (BET-14), ButtonView

---

### BET-14: GameSelectionCardView
| Field | Value |
|-------|-------|
| **Title** | Create GameSelectionCardView - Individual game selection in suggested bets |
| **Component** | `GameSelectionCardView` |
| **Complexity** | S |
| **Priority** | P3 |
| **Legacy** | `GameSuggestedView` |

**Description**:
Compact card for single game selection within suggested bets.

**Acceptance Criteria**:
- [ ] Sport type icon
- [ ] Team names
- [ ] Market name
- [ ] Selected outcome
- [ ] Odd value
- [ ] Compact layout for stacking

**Dependencies**: None

---

### BET-15: BrandedTicketShareView
| Field | Value |
|-------|-------|
| **Title** | Create BrandedTicketShareView - Branded ticket image for social sharing |
| **Component** | `BrandedTicketShareView` |
| **Complexity** | M |
| **Priority** | P3 |
| **Legacy** | `BrandedTicketShareView` |

**Description**:
View for generating branded shareable ticket images.

**Acceptance Criteria**:
- [ ] Brand logo header
- [ ] Ticket details
- [ ] Bet share token/ID
- [ ] Optimized for image capture
- [ ] generateShareContent() returning UIImage + text

**Dependencies**: SimpleTicketCardView

---

### BET-16: BetBuilderSelectionView
| Field | Value |
|-------|-------|
| **Title** | Create BetBuilderSelectionView - Selection cell for bet builder markets |
| **Component** | `BetBuilderSelectionView` |
| **Complexity** | S |
| **Priority** | P3 |
| **Legacy** | `BetbuilderSelectionCollectionViewCell` |

**Description**:
Selection view for same-game parlay bet builder.

**Acceptance Criteria**:
- [ ] Market name label
- [ ] Selection/outcome name
- [ ] Odd value display
- [ ] Selected/unselected state
- [ ] Disabled state for incompatible selections

**Dependencies**: OutcomeItemView

---

## Feature Area 3: Filters, Forms & Registration (17 tickets)

### FILTER-01: CollapsibleFilterSectionView
| Field | Value |
|-------|-------|
| **Title** | Create CollapsibleFilterSectionView - Expandable/collapsible filter section container |
| **Component** | `CollapsibleFilterSectionView` |
| **Complexity** | M |
| **Priority** | P1 |
| **Legacy** | `FilterCollapseView` |

**Description**:
Container for collapsible filter sections with checkbox support and animated transitions.

**Acceptance Criteria**:
- [ ] Header with title and expand/collapse arrow
- [ ] Optional checkbox for section enable/disable
- [ ] Animated expand/collapse transition
- [ ] Content stack view for filter options
- [ ] Collapsed/expanded state publisher

**Dependencies**: None

---

### FILTER-02: RangeSliderView
| Field | Value |
|-------|-------|
| **Title** | Create RangeSliderView - Dual-thumb range slider for time/odds filtering |
| **Component** | `RangeSliderView` |
| **Complexity** | L |
| **Priority** | P1 |
| **Legacy** | `MultiSlider`, `FilterSliderCollapseView`, `FilterSliderInfoView` |

**Description**:
Dual-thumb slider for selecting ranges (time, odds). Includes value labels above each thumb.

**Acceptance Criteria**:
- [ ] Dual thumbs for min/max values
- [ ] Track with filled section between thumbs
- [ ] Value labels above each thumb
- [ ] Configurable min/max bounds
- [ ] Step increment support
- [ ] Combine value publishers

**Dependencies**: CustomSliderView (may extend)

---

### FILTER-03: FilterRowView
| Field | Value |
|-------|-------|
| **Title** | Create FilterRowView - Selectable filter row with checkbox/radio support |
| **Component** | `FilterRowView` |
| **Complexity** | M |
| **Priority** | P1 |
| **Legacy** | `FilterRowView` |

**Description**:
Selectable row for filter options with checkbox or radio button mode.

**Acceptance Criteria**:
- [ ] Title label
- [ ] Checkbox mode (multi-select)
- [ ] Radio mode (single-select)
- [ ] Selected/unselected visual states
- [ ] Optional separator line
- [ ] Tap gesture handler

**Dependencies**: CheckboxView (FORM-07), RadioButtonView (FORM-08)

---

### FILTER-04: FilterBadgeView
| Field | Value |
|-------|-------|
| **Title** | Create FilterBadgeView - Active filter count badge |
| **Component** | `FilterBadgeView` |
| **Complexity** | S |
| **Priority** | P2 |
| **Legacy** | `FilterCountView` |

**Description**:
Compact badge showing count of active filters.

**Acceptance Criteria**:
- [ ] Circular badge shape
- [ ] Count number display
- [ ] Configurable colors
- [ ] Hide when count is 0

**Dependencies**: None

---

### FORM-01: ActionTextFieldView
| Field | Value |
|-------|-------|
| **Title** | Create ActionTextFieldView - Text field with action button |
| **Component** | `ActionTextFieldView` |
| **Complexity** | M |
| **Priority** | P1 |
| **Legacy** | `ActionTextFieldView`, `ActionSearchTextFieldView` |

**Description**:
Text field with embedded action button (search, apply, etc.).

**Acceptance Criteria**:
- [ ] Floating placeholder label
- [ ] Text input field
- [ ] Action button with configurable title/icon
- [ ] Clear button option
- [ ] Combine textPublisher
- [ ] Error state display
- [ ] Disabled state

**Dependencies**: BorderedTextFieldView (extend)

---

### FORM-02: DropdownFieldView
| Field | Value |
|-------|-------|
| **Title** | Create DropdownFieldView - Dropdown picker field with floating label |
| **Component** | `DropdownFieldView` |
| **Complexity** | M |
| **Priority** | P1 |
| **Legacy** | `DropDownSelectionView`, `HeaderDropDownSelectionView` |

**Description**:
Dropdown field with floating header, date picker and selection picker modes.

**Acceptance Criteria**:
- [ ] Floating header label (animated)
- [ ] Selected value display
- [ ] Dropdown arrow indicator
- [ ] Date picker mode
- [ ] Selection picker mode with options array
- [ ] Disabled state styling
- [ ] Error state with message

**Dependencies**: BorderedTextFieldView pattern

---

### FORM-03: CheckboxView
| Field | Value |
|-------|-------|
| **Title** | Create CheckboxView - Standalone checkbox control |
| **Component** | `CheckboxView` |
| **Complexity** | S |
| **Priority** | P1 |
| **Legacy** | `CheckboxButton`, `CheckboxToggleView` |

**Description**:
Standalone checkbox control with configurable colors and states.

**Acceptance Criteria**:
- [ ] Checked/unchecked states
- [ ] Checkmark icon when checked
- [ ] Configurable colors (selected, unselected)
- [ ] Disabled state
- [ ] Tap gesture toggle
- [ ] isChecked publisher

**Dependencies**: None

---

### FORM-04: RadioButtonView
| Field | Value |
|-------|-------|
| **Title** | Create RadioButtonView - Radio button control with mutual exclusion |
| **Component** | `RadioButtonView` |
| **Complexity** | S |
| **Priority** | P1 |
| **Legacy** | `RadioButton` |

**Description**:
Radio button control for single-select groups.

**Acceptance Criteria**:
- [ ] Selected/unselected states
- [ ] Center dot when selected
- [ ] Configurable colors
- [ ] Disabled state
- [ ] Group exclusion support

**Dependencies**: None

---

### FORM-05: LabeledRadioOptionView
| Field | Value |
|-------|-------|
| **Title** | Create LabeledRadioOptionView - Radio option with label |
| **Component** | `LabeledRadioOptionView` |
| **Complexity** | S |
| **Priority** | P1 |
| **Legacy** | `OptionRadioView`, `CardOptionRadioView` |

**Description**:
Radio option row with label text.

**Acceptance Criteria**:
- [ ] Radio button
- [ ] Title label
- [ ] Optional separator
- [ ] Tappable entire row
- [ ] Selected state styling

**Dependencies**: RadioButtonView

---

### FORM-06: LabeledCheckboxView
| Field | Value |
|-------|-------|
| **Title** | Create LabeledCheckboxView - Checkbox with label and optional description |
| **Component** | `LabeledCheckboxView` |
| **Complexity** | M |
| **Priority** | P1 |
| **Legacy** | Various checkbox+label combinations |

**Description**:
Checkbox with title, optional description, and optional clickable links.

**Acceptance Criteria**:
- [ ] Checkbox control
- [ ] Title label
- [ ] Optional description text
- [ ] Support for attributed text with links
- [ ] Tappable entire row

**Dependencies**: CheckboxView, HighlightedTextView

---

### FORM-07: GenderSelectionView
| Field | Value |
|-------|-------|
| **Title** | Create GenderSelectionView - Male/Female selection buttons |
| **Component** | `GenderSelectionView` |
| **Complexity** | S |
| **Priority** | P2 |
| **Legacy** | `GenderFormStepView` |

**Description**:
Gender selection with Male/Female buttons.

**Acceptance Criteria**:
- [ ] Two side-by-side buttons
- [ ] Male button with icon
- [ ] Female button with icon
- [ ] Single selection behavior
- [ ] Selected state styling

**Dependencies**: None

---

### REG-01: FormStepContainerView
| Field | Value |
|-------|-------|
| **Title** | Create FormStepContainerView - Base container for registration form steps |
| **Component** | `FormStepContainerView` |
| **Complexity** | M |
| **Priority** | P1 |
| **Legacy** | `FormStepView` |

**Description**:
Base container for multi-step registration forms with header and content area.

**Acceptance Criteria**:
- [ ] Header area with title
- [ ] Content stack view
- [ ] Scroll view wrapper
- [ ] Protocol for step completion
- [ ] Error presentation support

**Dependencies**: None

---

### REG-02: StepProgressBarView
| Field | Value |
|-------|-------|
| **Title** | Create StepProgressBarView - Multi-step progress indicator |
| **Component** | `StepProgressBarView` |
| **Complexity** | S |
| **Priority** | P1 |
| **Legacy** | `TallProgressBarView`, `ProgressSegments` |

**Description**:
Progress bar showing current step in multi-step flow.

**Acceptance Criteria**:
- [ ] Segmented progress bar
- [ ] Current step highlighting
- [ ] Completed steps filled
- [ ] Configurable step count
- [ ] Animated transitions

**Dependencies**: ProgressSegments (may extend)

---

### REG-03: PasswordRequirementsView
| Field | Value |
|-------|-------|
| **Title** | Create PasswordRequirementsView - Password strength requirements display |
| **Component** | `PasswordRequirementsView` |
| **Complexity** | M |
| **Priority** | P1 |
| **Legacy** | `PasswordFormStepView` requirements section |

**Description**:
Visual display of password requirements with real-time validation.

**Acceptance Criteria**:
- [ ] List of requirement items
- [ ] Check icon when requirement met
- [ ] X icon when not met
- [ ] Requirements: length, uppercase, lowercase, numbers, special chars
- [ ] Real-time updates as user types

**Dependencies**: ProgressInfoCheckView (may extend)

---

### REG-04: AddressAutocompleteView
| Field | Value |
|-------|-------|
| **Title** | Create AddressAutocompleteView - Address input with autocomplete suggestions |
| **Component** | `AddressAutocompleteView` |
| **Complexity** | L |
| **Priority** | P2 |
| **Legacy** | `AddressFormStepView`, `SearchCompletionView` |

**Description**:
Address input field with autocomplete suggestions dropdown.

**Acceptance Criteria**:
- [ ] Text input field
- [ ] Suggestions dropdown list
- [ ] Loading state during search
- [ ] Tap to select suggestion
- [ ] Selected address formatting
- [ ] Integration callback for address API

**Dependencies**: BorderedTextFieldView, SelectOptionsView

---

### REG-05: AvatarSelectionView
| Field | Value |
|-------|-------|
| **Title** | Create AvatarSelectionView - Avatar picker grid |
| **Component** | `AvatarSelectionView` |
| **Complexity** | M |
| **Priority** | P2 |
| **Legacy** | `AvatarFormStepView` |

**Description**:
Grid of avatar options for user profile selection.

**Acceptance Criteria**:
- [ ] Grid layout of avatar images
- [ ] Selected state highlight (border)
- [ ] Tap to select
- [ ] Single selection
- [ ] Optional custom upload button

**Dependencies**: None

---

### REG-06: PhonePrefixFieldView
| Field | Value |
|-------|-------|
| **Title** | Create PhonePrefixFieldView - Phone input with country prefix selector |
| **Component** | `PhonePrefixFieldView` |
| **Complexity** | M |
| **Priority** | P1 |
| **Legacy** | `ContactsFormStepView` phone section |

**Description**:
Phone number input with country code prefix selector.

**Acceptance Criteria**:
- [ ] Country flag button
- [ ] Country code label
- [ ] Phone number text field
- [ ] Country picker trigger
- [ ] Number formatting
- [ ] Validation support

**Dependencies**: BorderedTextFieldView, SelectOptionsView

---

## Summary by Priority

### P1 - Critical for Launch (20 tickets)
| Area | Tickets |
|------|---------|
| Match Cards | MATCH-01, MATCH-02, MATCH-03, MATCH-05, MATCH-06, MATCH-09, MATCH-13 |
| Betting | BET-01, BET-02, BET-04, BET-05 |
| Filters/Forms | FILTER-01, FILTER-02, FILTER-03, FORM-01, FORM-02, FORM-03, FORM-04, FORM-05, FORM-06, REG-01, REG-02, REG-03, REG-06 |

### P2 - Important (17 tickets)
| Area | Tickets |
|------|---------|
| Match Cards | MATCH-04, MATCH-07, MATCH-10, MATCH-12 |
| Betting | BET-03, BET-06, BET-07, BET-08, BET-09, BET-11, BET-12 |
| Filters/Forms | FILTER-04, FORM-07, REG-04, REG-05 |

### P3 - Nice to Have (9 tickets)
| Area | Tickets |
|------|---------|
| Match Cards | MATCH-08, MATCH-11 |
| Betting | BET-10, BET-13, BET-14, BET-15, BET-16 |

---

## Estimated Effort

| Complexity | Count | Days Each | Total Days |
|------------|-------|-----------|------------|
| S | 15 | 1 | 15 |
| M | 17 | 2.5 | 42.5 |
| L | 8 | 4.5 | 36 |
| XL | 6 | 8 | 48 |
| **Total** | **46** | | **~141.5 days** |

---

## Recommended Sprint Planning

### Sprint 1: Foundation (P1 Core Components)
- MyBetsSelectionLineView (BET-02)
- MyBetsTicketCardView (BET-01)
- BetslipErrorBannerView (BET-04)
- BonusSwitchRowView (BET-05)
- CheckboxView (FORM-03)
- RadioButtonView (FORM-04)

### Sprint 2: Match Cards Core
- LiveMatchBorderView (MATCH-13)
- MarketWidgetCardView (MATCH-03)
- HeroCardMarketItemView (MATCH-02)
- HeroMatchBannerView (MATCH-01)

### Sprint 3: Match Details & Filters
- GridMarketOutcomesView (MATCH-06)
- ExpandableMarketSectionView (MATCH-05)
- CollapsibleFilterSectionView (FILTER-01)
- RangeSliderView (FILTER-02)
- FilterRowView (FILTER-03)

### Sprint 4: Forms & Registration
- FormStepContainerView (REG-01)
- StepProgressBarView (REG-02)
- PasswordRequirementsView (REG-03)
- ActionTextFieldView (FORM-01)
- DropdownFieldView (FORM-02)
- PhonePrefixFieldView (REG-06)

### Sprint 5: Home Screen & Layout
- HorizontalMatchCardScrollView (MATCH-09)
- LabeledRadioOptionView (FORM-05)
- LabeledCheckboxView (FORM-06)

### Sprint 6-8: P2 Components
- Remaining P2 tickets based on feature priorities

### Sprint 9+: P3 Components
- P3 tickets as time permits

---

## Critical Implementation Files

### GomaUI Patterns to Follow
- `TallOddsMatchCardView.swift` - Complex card composition
- `OutcomeItemView.swift` - Core outcome button
- `BorderedTextFieldView.swift` - Text field patterns
- `TermsAcceptanceView.swift` - Checkbox + label patterns
- `CashoutSliderView.swift` - Slider integration

### Legacy References
- `HeroCardTableViewCell.swift` - Hero card features
- `MatchWidgetCollectionViewCell.swift` (137KB) - All match card features
- `MyTicketCardView.swift` (~1080 lines) - Full ticket logic
- `QuickBetViewController.swift` (~1070 lines) - Quick bet features
- `FormStepView.swift` - Registration base pattern
