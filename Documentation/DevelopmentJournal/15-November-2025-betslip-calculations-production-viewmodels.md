## Date
15 November 2025

### Project / Branch
sportsbook-ios / rr/breadcrumb

### Goals for this session
- Investigate and fix Win Boost calculation (showing XAF 0)
- Create production ViewModels for betslip components (remove Mock dependencies)
- Implement proper localization for betslip labels
- Match web app's exact business logic for odds, potential winnings, win boost, and payout

### Achievements
- [x] Identified BetInfoSubmissionView as the component displaying betslip calculations
- [x] Discovered app was using MockBetInfoSubmissionViewModel in production
- [x] Created production BetInfoSubmissionViewModel with reactive subscriptions
- [x] Fixed Win Boost calculation by subscribing to oddsBoostStairsPublisher (separate API)
- [x] Created 4 production ViewModels: BetSummaryRowViewModel, QuickAddButtonViewModel, AmountBorderedTextFieldViewModel, PlaceBetButtonViewModel
- [x] Implemented web app parity for all calculations: `WIN BOOST = min(potentialWinnings × percentage, capAmount)`
- [x] Added missing localization strings: "potential_winnings", "payout", "none" (EN + FR)
- [x] Made all labels uppercased: "ODDS", "POTENTIAL WINNINGS", "WIN BOOST (10%)", "PAYOUT"
- [x] Dynamic Win Boost label showing percentage: "WIN BOOST (NONE)" → "WIN BOOST (10%)"

### Issues / Bugs Hit
- **Win Boost always showing XAF 0**: Root cause was using wrong data source
  - Was looking at `UnifiedBettingOptions.availableOddsBoosts` (incorrect)
  - Should use `OddsBoostStairsState.currentTier` from separate API (`PUT /v1/bonus/wallets/sports`)
- **Missing localization strings**: Had to add "potential_winnings", "payout", "none" to both EN and FR
- **Inconsistent casing**: Labels needed to be uppercased to match design

### Key Decisions
- **Two separate API subscriptions required**:
  - `bettingOptionsPublisher` → provides `totalOdds` and `potentialWinnings`
  - `oddsBoostStairsPublisher` → provides `percentage` and `capAmount` for win boost
- **Production ViewModels over Mocks**:
  - Created app-specific ViewModels in BetssonCameroonApp instead of using GomaUI Mocks
  - Enables better control and customization without modifying shared components
  - All ViewModels follow same simple pattern: `CurrentValueSubject` + protocol conformance
- **CurrencyHelper mandatory**:
  - Use `CurrencyHelper.formatAmount()` for odds (returns "1,234.56")
  - Use `CurrencyHelper.formatAmountWithCurrency()` for money values (returns "XAF 1,234.56")
  - Never use manual `String(format:)` for currency/number formatting
- **Web app calculation parity**:
  ```swift
  // Step 1: ODDS = from API (priceValueFactor)
  odds = unifiedBettingOptions.totalOdds

  // Step 2: POTENTIAL WINNINGS = stake × totalOdds
  potentialWinnings = stake * totalOdds

  // Step 3: WIN BOOST = min(potentialWinnings × percentage, capAmount)
  rawBoost = potentialWinnings * percentage
  winBoost = min(rawBoost, capAmount)

  // Step 4: PAYOUT = potentialWinnings + winBoost
  payout = potentialWinnings + winBoost
  ```

### Implementation Details

#### Data Flow Architecture
```
User adds tickets → BetslipManager.fetchOddsBoostStairs()
                    ↓
        API: PUT /v1/bonus/wallets/sports
                    ↓
        Returns: OddsBoostStairsState { currentTier { percentage, capAmount } }
                    ↓
        oddsBoostStairsPublisher emits update
                    ↓
        BetInfoSubmissionViewModel receives:
        1. Updates label: "WIN BOOST (10%)" or "WIN BOOST (NONE)"
        2. Recalculates win boost: min(potentialWinnings × 0.1, 30)
        3. Updates payout: potentialWinnings + winBoost
```

#### Production ViewModels Created
1. **BetSummaryRowViewModel** - Summary rows (odds, winnings, boost, payout)
   - Factory methods: `.odds()`, `.potentialWinnings()`, `.winBonus()`, `.payout()`
   - All use `.uppercased()` localized strings

2. **QuickAddButtonViewModel** - Quick add amount buttons (100, 250, 500)
   - Factory methods: `.amount100()`, `.amount250()`, `.amount500()`

3. **AmountBorderedTextFieldViewModel** - Stake amount input field
   - Factory method: `.amountInput()`
   - Configured for numeric keyboard

4. **PlaceBetButtonViewModel** - Place bet button
   - Factory method: `.placeBet(currency:)`
   - Dynamic title: "PLACE BET XAF 1,000"

### Files Modified
- **Created** `BetssonCameroonApp/App/Screens/Betslip/BetSummaryRowViewModel.swift`
- **Created** `BetssonCameroonApp/App/Screens/Betslip/QuickAddButtonViewModel.swift`
- **Created** `BetssonCameroonApp/App/Screens/Betslip/AmountBorderedTextFieldViewModel.swift`
- **Created** `BetssonCameroonApp/App/Screens/Betslip/PlaceBetButtonViewModel.swift`
- **Created** `BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/BetInfoSubmissionViewModel.swift`
- **Modified** `BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/SportsBetslipViewModel.swift`
  - Updated to use production BetInfoSubmissionViewModel
  - Passed oddsBoostStairsPublisher parameter
  - Removed manual calculation methods (now self-updating)
- **Modified** `BetssonCameroonApp/App/Resources/Language/en.lproj/Localizable.strings`
  - Added: `"none" = "none";`
  - Added: `"potential_winnings" = "Potential Winnings";`
  - Added: `"payout" = "Payout";`
- **Modified** `BetssonCameroonApp/App/Resources/Language/fr.lproj/Localizable.strings`
  - Added: `"none" = "aucun";`
  - Added: `"potential_winnings" = "Gains Potentiels";`
  - Added: `"payout" = "Paiement";`

### Useful Files / Links
- [BetInfoSubmissionView (GomaUI)](../../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetInfoSubmissionView/BetInfoSubmissionView.swift) - UI component
- [BetInfoSubmissionViewModel (Production)](../../../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/BetInfoSubmissionViewModel.swift) - Production ViewModel
- [BetslipManager](../../../BetssonCameroonApp/App/Services/BetslipManager.swift) - Publishers for betting options and odds boost
- [OddsBoostStairs Model](../../../BetssonCameroonApp/App/Models/Betting/OddsBoostStairs.swift) - App model for boost tiers
- [CurrencyHelper](../../../BetssonCameroonApp/App/Helpers/CurrencyHelper.swift) - Currency formatting utility
- [Web App Logic Reference] - Documented in session (betslip.js calculation formulas)

### Experiments & Notes
- **Web App Analysis**: Spent time analyzing JavaScript code from web app to understand exact calculation logic
  - `betslip.js:305-317` - Win boost calculation with monetary cap
  - `betting.js:1231-1244` - Betting options API call
  - `betting.mapper.js:1-11` - Response mapping logic
- **Mock vs Production Pattern**: Established pattern where GomaUI provides Mock implementations for testing, but production apps create their own ViewModels
- **LocalizationProvider**: Already available globally via `localized()` function, no import needed

### Next Steps
1. Test in simulator with real odds boost scenarios:
   - No boost available (should show "WIN BOOST (NONE)" and XAF 0)
   - 10% boost with small bet (under cap)
   - 50% boost with large bet (should hit cap, e.g., max 30 XAF)
2. Verify calculations match web app exactly for same bet configuration
3. Test French localization displays correctly
4. Consider if other screens need similar Mock → Production ViewModel migration
5. Document this pattern in project guidelines for future ViewModels
