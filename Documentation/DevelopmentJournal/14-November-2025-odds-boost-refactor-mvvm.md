# Odds Boost Header: MVVM Refactor + Max Tier Bug Fix

## Date
14 November 2025

### Project / Branch
sportsbook-ios / rr/breadcrumb (Betsson Cameroon)

### Goals for this session
- Fix bug where "Max win boost activated!" showed at intermediate tiers (e.g., tier 2 of 5)
- Refactor to move message assembly logic from View to ViewModel (better MVVM)
- Replace cryptic tuple with self-documenting struct
- Add state diagram documentation for clarity

### Achievements
- [x] Fixed max tier detection bug - only shows "Max!" when nextTier is nil
- [x] Created `OddsBoostDisplayData` struct to replace `(String?, Int, String?)` tuple
- [x] Added comprehensive state diagram showing all UI scenarios
- [x] Moved message assembly logic from View to ViewModel (`computeHeadingText()`)
- [x] Simplified View render() from 8 lines to 1 line (just displays `headingText`)
- [x] Updated protocol to remove `nextTierPercentage` and `currentBoostPercentage`
- [x] Updated all mock view models and SwiftUI previews
- [x] Added detailed comments explaining why we return nil for currentPercentage at intermediate tiers

### Issues / Bugs Hit
- [x] **"Max boost activated!" showing at tier 2 of 5**
  - **Root cause**: `currentPercentage` was set whenever `currentTier` existed (even at intermediate tiers)
  - **Fix**: Only set `currentPercentage` when `nextTier == nil` (absolute max tier)
  - **Location**: `BetslipOddsBoostHeaderViewModel.swift:115-122`
- [x] **View making business logic decisions**
  - **Problem**: View had cascading if-else to choose which message to display
  - **Fix**: Moved decision logic to ViewModel, View just renders pre-assembled message
  - **Location**: `BetslipOddsBoostHeaderView.swift:211` (before), now single line

### Key Decisions
- **Tuple → Struct refactoring**: Replaced `(String?, Int, String?)` with `OddsBoostDisplayData`
  - Rationale: Self-documenting field names, no confusion about positions, extensible
  - Keeps internal to ViewModel (not exposed in protocol)
- **Message assembly in ViewModel**: Created `computeHeadingText()` method
  - Rationale: Better MVVM separation, testable business logic, single source of truth
  - View becomes "dumb renderer" - just displays what it's told
- **State diagram documentation**: Added ASCII table showing all API → UI state mappings
  - Rationale: Visual reference prevents confusion, helps QA/PM understand behavior
  - Clarifies difference between "current tier" (API) vs "max tier" (UI display)
- **Protocol simplification**: Removed `nextTierPercentage` and `currentBoostPercentage`
  - Rationale: View doesn't need raw data, just needs final rendered text
  - Added single `headingText: String` property instead

### Experiments & Notes
- **MVVM Architecture Improvement**: Moving decision logic from View to ViewModel
  - Before: View had 8-line if-else chain deciding which message to show
  - After: View has single line `headingLabel.text = state.headingText`
  - ViewModel now owns all localization and decision logic
  - Much easier to unit test (pure Swift, no UIKit needed)

- **Struct vs Tuple Pattern**:
  - Tuple `(String?, Int, String?)` is cryptic - position-dependent, hard to maintain
  - Struct `OddsBoostDisplayData { maxTierPercentage, totalEligibleCount, nextTierPercentage }`
  - Can add computed properties like `isAtMaxTier`
  - Compiler catches errors if fields accessed incorrectly

- **State Diagram Documents Complexity**:
  ```
  At tier 2 of 5:
    API: currentTier = 10%, nextTier = 15%
    We return: maxTierPercentage = nil (NOT 10%!)
    UI shows: "Get 15% win boost" (NOT "Max activated!")

  At max tier 5:
    API: currentTier = 40%, nextTier = nil
    We return: maxTierPercentage = "40%"
    UI shows: "Max win boost activated! (40%)"
  ```

### Useful Files / Links

**Core ViewModel:**
- [BetslipOddsBoostHeaderViewModel.swift](../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/BetslipOddsBoostHeaderViewModel.swift)
  - Line 95-114: `OddsBoostDisplayData` struct definition
  - Line 116-134: State diagram documentation
  - Line 138-182: `extractOddsBoostData()` with max tier logic
  - Line 184-203: `computeHeadingText()` - message assembly logic
  - Line 63-89: `updateHeaderState()` - uses computed heading

**GomaUI Protocol:**
- [BetslipOddsBoostHeaderViewModelProtocol.swift](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/BetslipOddsBoostHeaderViewModelProtocol.swift:9-30)
  - Removed: `nextTierPercentage`, `currentBoostPercentage`
  - Added: `headingText: String` with documentation

**GomaUI View:**
- [BetslipOddsBoostHeaderView.swift](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/BetslipOddsBoostHeaderView.swift:207-211)
  - Before: 8 lines of if-else decision logic
  - After: Single line `headingLabel.text = state.headingText`

**Mock ViewModels:**
- [MockBetslipOddsBoostHeaderViewModel.swift](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/MockBetslipOddsBoostHeaderViewModel.swift:43-82)
  - Updated factory methods to use `headingText` parameter
  - Examples: `activeMock(headingText: "Get 3% win boost")`

### Architecture Improvements

**Before Refactoring:**
```
┌─────────────┐
│  ViewModel  │  Provides: currentBoostPercentage, nextTierPercentage
└──────┬──────┘
       │ (raw data)
       ▼
  ┌────────┐
  │  View  │  Decides: if currentBoost != nil → "Max!"
  └────────┘           else if nextPercentage → "Get X%"
                       else → "Available"
```

**After Refactoring:**
```
┌─────────────┐
│  ViewModel  │  Computes: headingText = "Get 15% win boost"
└──────┬──────┘  (Business logic + Localization)
       │ (pre-assembled message)
       ▼
  ┌────────┐
  │  View  │  Renders: headingLabel.text = state.headingText
  └────────┘  (Dumb renderer)
```

**Benefits:**
- ✅ Better MVVM separation (View doesn't make decisions)
- ✅ Testable business logic (ViewModel can be unit tested)
- ✅ Single source of truth (only ViewModel knows localization)
- ✅ Type-safe (String, not Optional - always has value)
- ✅ Simpler View (1 line vs 8 lines)

### Next Steps
1. Test with real betslip scenarios:
   - Below first tier (2/3 selections)
   - At intermediate tier (3/4 selections, tier 2 of 5)
   - At maximum tier (10/10 selections, tier 5 of 5)
2. Verify text messages match design specs (EN and FR)
3. Check SwiftUI previews render correctly with new struct
4. Consider adding unit tests for `computeHeadingText()` method
5. Document this pattern for other components (message assembly in ViewModel)
