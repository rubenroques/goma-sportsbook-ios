# Odds Boost Header: Complete MVVM Refactor - Description Text

## Date
15 November 2025

### Project / Branch
sportsbook-ios / rr/breadcrumb (Betsson Cameroon)

### Goals for this session
- Fix compilation errors from incomplete MVVM refactor
- Complete the MVVM separation by moving description logic to ViewModel
- Ensure all business logic is in ViewModel, not View
- Update all components (protocol, production VM, mock VM, view, demo)

### Achievements
- [x] Added `descriptionText: String` property to `BetslipOddsBoostHeaderState` protocol
- [x] Created `computeDescriptionText()` method in production ViewModel
- [x] Fixed production ViewModel initial state to use new properties (minOdds, headingText, descriptionText)
- [x] Updated production ViewModel's `updateHeaderState()` to compute and use descriptionText
- [x] Simplified View render logic from 14 lines to 1 line: `descriptionLabel.text = state.descriptionText`
- [x] Updated Mock ViewModel factory methods to include descriptionText parameter
- [x] Fixed GomaUI SwiftUI preview to include descriptionText in state creation
- [x] Fixed Demo ViewController to use new state properties

### Issues / Bugs Hit
- [x] **Incomplete MVVM refactor from previous session**
  - **Problem**: Previous refactor added `headingText` but left description logic in View
  - **Root cause**: View was still making business logic decisions (checking minOdds, nextTierPercentage)
  - **Fix**: Moved ALL description assembly logic to ViewModel via `computeDescriptionText()`
  - **Location**: `BetslipOddsBoostHeaderView.swift:213-227` → now single line at 214

- [x] **Production ViewModel using removed properties**
  - **Problem**: Initial state used `nextTierPercentage` and `currentBoostPercentage` (removed in previous refactor)
  - **Fix**: Updated to use `minOdds`, `headingText`, `descriptionText`
  - **Location**: `BetslipOddsBoostHeaderViewModel.swift:36-41`

- [x] **SwiftUI preview missing new property**
  - **Problem**: Interactive preview creating state without `descriptionText`
  - **Fix**: Added descriptionText computation to preview's updateState() method
  - **Location**: `BetslipOddsBoostHeaderView.swift:520-529`

- [x] **Demo ViewController using old properties**
  - **Problem**: Segmented control creating states with removed properties
  - **Fix**: Updated all 4 state creations to use new properties
  - **Location**: `BetslipOddsBoostHeaderViewController.swift:104-134`

### Key Decisions
- **Complete MVVM separation**: View is now truly a "dumb renderer"
  - Rationale: View should have ZERO business logic, just render what ViewModel provides
  - Before: View had 14 lines deciding which description message to show
  - After: View has 1 line: `descriptionLabel.text = state.descriptionText`

- **Description logic mirrors heading logic**: Created `computeDescriptionText()` following same pattern as `computeHeadingText()`
  - Rationale: Consistent architecture, both messages assembled in ViewModel
  - Priority 1: Use minOdds message ("by adding X more legs (1.10 min odds)")
  - Priority 2: Fallback to percentage message ("add X matches to get Y% bonus")
  - Priority 3: All selections added ("All qualifying events added")

- **State struct contains only display-ready data**: All properties are final, formatted strings
  - `minOdds: String?` - already formatted (e.g., "1.10")
  - `headingText: String` - pre-assembled message
  - `descriptionText: String` - pre-assembled message
  - Rationale: View never needs to format or make decisions, just display

### Experiments & Notes
- **Why this matters for MVVM**:
  - The previous refactor was 80% done - moved heading logic but not description logic
  - Left the View making decisions: "if minOdds exists, else if nextPercentage, else..."
  - This violates MVVM because the View contains business logic
  - Now 100% complete: View just sets `text` properties, no if-else chains

- **Architecture consistency**:
  ```swift
  // BEFORE (inconsistent)
  headingLabel.text = state.headingText  // ✓ ViewModel provides this
  descriptionLabel.text = /* 14 lines of if-else logic */ // ✗ View decides this

  // AFTER (consistent)
  headingLabel.text = state.headingText       // ✓ ViewModel provides this
  descriptionLabel.text = state.descriptionText // ✓ ViewModel provides this
  ```

- **Testing benefits**:
  - `computeDescriptionText()` is pure Swift, can be unit tested without UIKit
  - Mock ViewModels can provide exact strings for UI tests
  - View rendering is deterministic (no branching logic)

### Useful Files / Links

**Modified Files:**
- [BetslipOddsBoostHeaderViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/BetslipOddsBoostHeaderViewModelProtocol.swift)
  - Line 19-22: Added `descriptionText` property to state struct
  - Line 29: Added to initializer

- [BetslipOddsBoostHeaderViewModel.swift](../../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/BetslipOddsBoostHeaderViewModel.swift)
  - Line 36-42: Fixed initial state with new properties
  - Line 78-79: Compute descriptionText and include in state
  - Line 207-231: New `computeDescriptionText()` method with 3-tier priority logic

- [BetslipOddsBoostHeaderView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/BetslipOddsBoostHeaderView.swift)
  - Line 213-214: Simplified from 14 lines to 1 line
  - Line 507-520: Fixed SwiftUI preview to include descriptionText

- [MockBetslipOddsBoostHeaderViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/MockBetslipOddsBoostHeaderViewModel.swift)
  - Line 49: Added descriptionText parameter to activeMock()
  - Line 68: Added descriptionText to maxBoostMock()
  - Line 83: Added descriptionText to disabledMock()

- [BetslipOddsBoostHeaderViewController.swift](../../Frameworks/GomaUI/Demo/Components/BetslipOddsBoostHeaderViewController.swift)
  - Line 104-134: Updated all 4 state creations with new properties

**Related Documentation:**
- [14-November-2025-odds-boost-refactor-mvvm.md](./14-November-2025-odds-boost-refactor-mvvm.md)
  - Previous session that started the MVVM refactor (added headingText)
  - This session completes what was started there

### Next Steps
1. Run full build to verify all compilation errors are resolved
2. Test in simulator with real betslip scenarios:
   - Add selections and verify description updates correctly
   - Check minOdds-based message appears when available
   - Verify fallback to percentage-based message works
   - Confirm "All qualifying events added" shows when complete
3. Verify both English and French localizations display correctly
4. Consider adding unit tests for `computeDescriptionText()` method
5. Update the original refactor DJ to note this completion
