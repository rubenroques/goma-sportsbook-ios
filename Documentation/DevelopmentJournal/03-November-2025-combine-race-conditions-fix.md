# Development Journal Entry

## Date
03 November 2025

### Project / Branch
sportsbook-ios / rr/live_scores

### Goals for this session
- Debug `EXC_BAD_ACCESS` crash in NextUpEventsViewModel
- Identify and fix race condition causing the crash
- Search for similar race conditions across BetssonCameroonApp

### Achievements
- [x] **Identified root cause**: Race condition between `processMatches()` and `updateMarketGroupViewModels()`
  - `processMatches()` was iterating over `marketGroupCardsViewModels` dictionary on main thread
  - `updateMarketGroupViewModels()` was removing ViewModels from same dictionary on background thread
  - ViewModels being deallocated while `@Published` properties were being mutated → `EXC_BAD_ACCESS`

- [x] **Fixed initial crash** in NextUpEventsViewModel.swift:205-209
  - Added missing `.receive(on: DispatchQueue.main)` to `marketGroupSelectorViewModel.marketGroupsPublisher`
  - Ensures both methods run serially on main queue, preventing concurrent dictionary access

- [x] **Conducted comprehensive codebase audit** using Task/Explore agent
  - Found **14 additional race conditions** with identical pattern across BetssonCameroonApp
  - All were Combine subscriptions missing `.receive(on: DispatchQueue.main)` before `.sink`

- [x] **Fixed MyBetsViewModel.swift** - 4 race conditions
  - Line 65-71: `tabViewModel.selectionEventPublisher` → mutates `@Published selectedTabType`
  - Line 78-86: `statusViewModel.selectionEventPublisher` → mutates `@Published selectedStatusType`
  - Line 131-138: `selectedTabTypePublisher` → triggers API calls and state mutations
  - Line 142-148: `selectedStatusTypePublisher` → triggers API calls and state mutations

- [x] **Fixed BetslipManager.swift** - 8 race conditions (CRITICAL - core betting functionality)
  - Line 61-68: `bettingTicketsDictionaryPublisher` → mutates `bettingTicketsPublisher`
  - Line 70-75: `bettingTicketsPublisher` → writes to UserDefaults
  - Line 77-85: `bettingTicketsPublisher` → calls `requestAllowedBetTypes()` (mutates subjects)
  - Line 87-94: `bettingTicketsPublisher` → calls `fetchOddsBoostStairs()` (mutates `oddsBoostStairsSubject`)
  - Line 97-111: `userProfileStatusPublisher` → mutates `oddsBoostStairsSubject`
  - Line 116-134: `userWalletPublisher` → calls `fetchOddsBoostStairs()` (mutates subjects)
  - Line 137-144: `bettingTicketsPublisher` → calls `validateBettingOptions()` (mutates `bettingOptionsSubject`)
  - Line 147-154: `userProfileStatusPublisher` → calls `validateBettingOptions()` (mutates subjects)

### Issues / Bugs Hit
- [x] Initial assumption: Threading issue with `.receive(on:)` missing in `loadEvents()`
  - **Reality**: `loadEvents()` HAD `.receive(on: DispatchQueue.main)` correctly
  - **Actual issue**: Different publisher (marketGroupsPublisher) was missing `.receive(on:)`
  - Stack trace showed `EXC_BAD_ACCESS` at memory address `0x1` → deallocated object, not threading

- [x] Crash was **intermittent** - classic race condition symptom
  - Only happened when market groups changed while processing matches
  - Timing-dependent: dictionary mutation during iteration

### Key Decisions
- **Pattern established**: ALL Combine `.sink` closures that mutate state MUST have `.receive(on: DispatchQueue.main)` before the sink
  - This includes: mutating `@Published` properties, `CurrentValueSubject.send()`, calling methods that trigger API calls, writing to UserDefaults

- **Prioritized fixes by risk**:
  1. NextUpEventsViewModel (immediate crash) ✅
  2. MyBetsViewModel (4 subscriptions) ✅
  3. BetslipManager (8 subscriptions - core functionality) ✅
  4. Remaining 2 issues deferred (lower risk)

- **Audit methodology validated**: Using Task/Explore agent proved highly effective
  - Found all 14 issues in single systematic search
  - Provided context (risk level, what each subscription does)
  - Confirmed many ViewModels already following best practices

### Experiments & Notes
- **Debugging approach that worked**:
  1. Stack trace analysis → identified setter crash on `@Published` property
  2. Memory address `0x1` → suggested object deallocation, not pure threading
  3. Searched for dictionary mutations → found `removeValue(forKey:)` in `updateMarketGroupViewModels()`
  4. Traced both methods to publisher subscriptions → found missing `.receive(on:)`

- **Explorer agent configuration**:
  - Used `subagent_type: Explore` with detailed search criteria
  - Specified: look for `.sink` patterns, check for missing `.receive(on: DispatchQueue.main)`
  - Categorized results by risk level (High/Medium/Low)
  - Scoped to BetssonCameroonApp only (not BetssonFranceApp legacy code)

- **Good practices observed in codebase**:
  - NextUpEventsViewModel, InPlayEventsViewModel, SportsBetslipViewModel already had correct threading
  - Shows team awareness of pattern, just inconsistent application

### Useful Files / Links
- [NextUpEventsViewModel.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/NextUpEventsViewModel.swift) - Original crash location
- [MarketGroupCardsViewModel.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/MarketGroupCardsViewModel.swift) - Where `@Published` property was mutated
- [MyBetsViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewModel.swift) - Fixed 4 race conditions
- [BetslipManager.swift](../../BetssonCameroonApp/App/Services/BetslipManager.swift) - Fixed 8 race conditions
- [CLAUDE.md](../../CLAUDE.md) - Project architecture documentation

### Next Steps
1. **Build and test** - Verify fixes don't introduce regressions
2. **Monitor crash reports** - Confirm `EXC_BAD_ACCESS` crashes eliminated in production
3. **Consider remaining issues** from audit:
   - Review 2 remaining MEDIUM risk issues (if explorer flagged any we didn't fix)
   - Potentially audit BetssonFranceApp (legacy codebase) for same pattern
4. **Establish linting rule** - Consider SwiftLint custom rule to enforce `.receive(on:)` pattern
5. **Team education** - Share this pattern in code review guidelines or team sync

---

## Technical Deep Dive

### The Race Condition Pattern

**Problematic Pattern:**
```swift
somePublisher
    .sink { [weak self] value in
        self?.mutateState()  // ⚠️ Can run on any thread
    }
```

**Safe Pattern:**
```swift
somePublisher
    .receive(on: DispatchQueue.main)  // ✅ Ensures main thread
    .sink { [weak self] value in
        self?.mutateState()  // Safe - always main thread
    }
```

### Why This Matters

Combine publishers can emit on **any thread** depending on their source:
- WebSocket subscriptions → background queue
- API responses → background queue
- User interactions → main queue
- Timer-based publishers → any queue

Without `.receive(on:)`, you get:
- ✅ **Works**: When publisher happens to emit on main thread
- ❌ **Crashes**: When publisher emits on background thread while another subscription mutates same state on main thread

Result: **Timing-dependent crashes** that are hard to reproduce and debug.

### Impact Assessment

**Total fixes: 13 race conditions**
- 1 in NextUpEventsViewModel (immediate crash fix)
- 4 in MyBetsViewModel
- 8 in BetslipManager

All were **production bugs waiting to happen** - especially BetslipManager which handles core betting flow.
