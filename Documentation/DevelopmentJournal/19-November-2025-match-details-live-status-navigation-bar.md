## Date
19 November 2025

### Project / Branch
sportsbook-ios / rr/match_details_score

### Goals for this session
- Add dynamic match status display (e.g., "1st Half, 45 min") to match details screen
- Move status from MatchHeaderCompactView to MatchDateNavigationBarView (correct per design)
- Fix live data updates via WebSocket

### Achievements
- [x] Added `matchTime` and `isLive` fields to MatchHeaderCompactViewModelProtocol (initially - REVERTED)
- [x] Implemented live WebSocket subscription in MatchDateNavigationBarViewModel
- [x] **CORRECTLY reverted** - removed status from MatchHeaderCompactView (wrong location per design)
- [x] **CORRECTLY placed** - status now in MatchDateNavigationBarView top nav bar (correct location)
- [x] Added `updateFromLiveData()` method to process WebSocket events
- [x] Identified CRITICAL BUG: Global live data shutdown after viewing match details

### Issues / Bugs Hit
- [x] **CRITICAL**: Opening match details then going back kills ALL live data globally
- [x] Root cause: `EveryMatrixEventsProvider.subscribeToLiveDataUpdates()` blocks ALL events when `matchDetailsManager` exists
- [x] `matchDetailsManager` never cleared after match details closes → persistent state pollution
- [ ] TODO implementation blocks working features with `Fail()` placeholder

### Key Decisions
- **Design correction**: Match status belongs in MatchDateNavigationBarView (top nav bar), NOT MatchHeaderCompactView
- **Architecture fix**: MatchHeaderCompactView should ONLY show breadcrumbs (Sport / Country / League)
- **Bug fix approach**: One-line conditional check instead of complex cleanup coordination
- Chose surgical fix over architectural refactor for safety and speed

### Experiments & Notes
- Initially added status to wrong component (MatchHeaderCompactView)
- Discovered the design calls for status in navigation bar capsule
- Tried removing `liveDataCancellable?.cancel()` - did NOT fix the bug
- Traced through WebSocket subscription architecture in ServicesProvider
- Found incomplete TODO comments revealing original intent

### Root Cause Analysis
**The Bug Flow**:
1. User opens match details → `matchDetailsManager` created in `EveryMatrixEventsProvider`
2. User navigates back → `matchDetailsManager` NEVER cleared (no cleanup trigger)
3. InPlay cards request live data → `subscribeToLiveDataUpdates()` checks:
   ```swift
   if let matchDetailsManager = self.matchDetailsManager {
       return Fail()  // Blocks ALL events, not just match details event
   }
   ```
4. ALL live data stops working until app restart

**Why This Happens**:
- Line 298: Conditional doesn't check if event ID matches
- Incomplete TODO: Developer intended to use matchDetailsManager for live data but never implemented it
- Placeholder `Fail()` blocks all subscriptions as side effect
- No cleanup: ViewModel.deinit doesn't notify provider to clear manager

### Useful Files / Links
- [EveryMatrixEventsProvider.swift:298](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixEventsProvider.swift#L298) - THE BUG LOCATION
- [MatchDateNavigationBarViewModel.swift](../../BetssonCameroonApp/App/ViewModels/MatchDateNavigationBar/MatchDateNavigationBarViewModel.swift) - Live subscription implementation
- [MatchDateNavigationBarView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchDateNavigationBar/MatchDateNavigationBarView.swift) - Status display UI
- [MatchHeaderCompactView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchHeaderCompactView/MatchHeaderCompactView.swift) - Reverted to breadcrumb-only

### The Fix (Ready to Apply)
**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixEventsProvider.swift`

**Line 298 - Change**:
```swift
// BEFORE (BROKEN):
if let matchDetailsManager = self.matchDetailsManager {
    return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
}

// AFTER (FIXED):
if let matchDetailsManager = self.matchDetailsManager, matchDetailsManager.matchId == id {
    return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
}
```

**Impact**: Only blocks live data for the specific match being viewed in match details, not all matches.

### Next Steps
1. **Apply one-line fix** to EveryMatrixEventsProvider.subscribeToLiveDataUpdates() line 298
2. Test:
   - Open InPlay → Verify live scores updating
   - Open match details → Verify nav bar shows "1st Half, 45 min"
   - Go back to InPlay → Verify scores CONTINUE updating (bug fixed)
   - Switch sports → Verify works
3. Consider implementing the TODO properly:
   - Add `MatchDetailsManager.observeEventInfoForEvent()` method
   - Use match details manager for its own event's live data
   - This allows proper cleanup without breaking InPlay
4. Add cleanup method to provider for future-proofing:
   ```swift
   func clearMatchDetailsManager() {
       matchDetailsManager?.unsubscribe()
       matchDetailsManager = nil
   }
   ```

### Code Changes Summary
**Files Modified**:
1. ✅ `MatchHeaderCompactViewModelProtocol.swift` - Reverted (removed matchTime/isLive)
2. ✅ `MatchHeaderCompactView.swift` - Reverted (removed UI components)
3. ✅ `MatchHeaderCompactViewModel.swift` - Reverted (removed live subscription)
4. ✅ `MockMatchHeaderCompactViewModel.swift` - Reverted (simplified)
5. ✅ `MatchDateNavigationBarViewModel.swift` - Added WebSocket subscription
6. ⏳ `EveryMatrixEventsProvider.swift` - **FIX PENDING** (one-line change at line 298)

**Architecture Pattern**:
- MatchHeaderCompactView: Static breadcrumb display only
- MatchDateNavigationBarView: Dynamic live status in nav bar capsule
- Separation of concerns: Header for context, nav bar for real-time status
