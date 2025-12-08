## Date
07 December 2025

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Investigate why Match Details screen blinks/flickers constantly during live matches
- Fix excessive UI rebuilds caused by WebSocket updates
- Understand the root cause pattern for future prevention

---

## Status: UNRESOLVED

**We were unable to fix this issue in this session.** All attempted fixes caused regressions where the market tabs wouldn't load at all (stuck in "loading markets" state). The original behavior (excessive flickering) has been restored while we investigate further.

---

## The Problem: Constant UI Flickering

The Match Details textual screen experiences severe flickering during live matches. Market tabs are constantly destroyed and recreated, causing:
- Visual blinking/flickering
- Loss of scroll position
- Poor user experience
- Excessive WebSocket subscription churn

---

## Root Cause Analysis

### The Symptom
Logs showed this pattern repeating on EVERY WebSocket message:
```
⚠️ SAME MATCH but updateMatch called - will clear and reload anyway!
🗑️ Sending EMPTY market groups (clearing old data)
🔃 Calling reloadMarketGroups()
```

### The WebSocket Message Triggering This
```json
{
  "messageType": "UPDATE",
  "records": [{
    "changeType": "UPDATE",
    "entityType": "MATCH",
    "id": "288615660027940864",
    "changedProperties": {
      "numberOfMarkets": 142,
      "numberOfBettingOffers": 326
    }
  }]
}
```

These `numberOfMarkets` / `numberOfBettingOffers` updates are cosmetic counters that trigger full UI rebuilds.

### The Call Chain
1. **ServicesProvider** emits event update (including `numberOfMarkets` changes)
2. **MatchDetailsTextualViewModel** receives update, calls `marketGroupSelectorTabViewModel.updateMatch(match)`
3. **MarketGroupSelectorTabViewModel.updateMatch()** clears all market groups and restarts WebSocket subscription
4. ViewController receives empty array → rebuilds → receives full array → rebuilds again
5. Repeat on every WebSocket message

---

## Approaches Tried (ALL FAILED)

### Attempt 1: Filter at ServicesProvider Level
**Idea**: Skip storing/emitting MATCH entity updates that only contain `numberOfMarkets`/`numberOfBettingOffers`.

**Implementation**: Added `meaningfulMatchProperties` allowlist in `MatchDetailsManager.swift`, only update store and emit if meaningful properties changed.

**Result**: REVERTED - Architectural concern raised: ServicesProvider is a shared layer. Different consumers have different "meaningful" definitions (e.g., Market Group tabs badge counts DO need `numberOfMarkets`).

### Attempt 2: Add `.removeDuplicates()` to ViewController Subscription
**Idea**: Filter duplicate `[MarketGroupTabItemData]` arrays at the Combine level.

**Implementation**:
```swift
marketGroupsSubscription = viewModel.marketGroupSelectorTabViewModel.marketGroupsPublisher
    .removeDuplicates()  // Added this
    .receive(on: DispatchQueue.main)
    .sink { ... }
```

**Result**: REVERTED - Did not solve the problem because the ViewModel was sending EMPTY → FULL cycle on every update. `.removeDuplicates()` saw them as different arrays.

### Attempt 3: Guard in `handleMarketGroupsResponse()`
**Idea**: Skip `updateMarketGroups()` if the new tab items are identical to current.

**Implementation**:
```swift
guard tabItems != currentMarketGroups else {
    return  // Skip if unchanged
}
updateMarketGroups(tabItems)
```

**Result**: REVERTED - Did not solve the problem because by the time we reach `handleMarketGroupsResponse()`, the subscription had already been restarted and was delivering fresh data.

### Attempt 4: Early Return in `updateMatch()`
**Idea**: If match ID hasn't changed, skip the clear/reload cycle.

**Implementation**:
```swift
func updateMatch(_ newMatch: Match) {
    guard self.match.id != newMatch.id else {
        return  // Skip if same match
    }
    // ... proceed with clear and reload
}
```

**Result**: BROKE INITIAL LOAD - Market tabs stuck in "loading markets" forever. The initial load relies on `updateMatch()` being called even for the same match ID.

### Attempt 5: Guard at Caller Level
**Idea**: Only call `updateMatch()` in MatchDetailsTextualViewModel when match ID changes.

**Implementation**:
```swift
if matchIdChanged {
    self?.marketGroupSelectorTabViewModel.updateMatch(match)
}
```

**Result**: BROKE INITIAL LOAD - Same problem. Something in the flow depends on `updateMatch()` being called.

---

## Key Discovery: Complex Initialization Dependency

The `MarketGroupSelectorTabViewModel` has a complex initialization:

```swift
init(match: Match, ...) {
    self.match = match
    // ...
    loadMarketGroups()  // Starts WebSocket subscription
}
```

Even though `loadMarketGroups()` is called in `init()`, the initial load somehow depends on `updateMatch()` also being called. We couldn't determine exactly why, but blocking `updateMatch()` prevents the initial market groups from appearing.

**Possible reasons:**
1. Race condition between init and first event update
2. ViewController subscription setup happens after init completes
3. Some state isn't properly initialized until `updateMatch()` runs
4. The subscription from `init()` gets cancelled somewhere before delivering data

---

## The Anti-Pattern Identified

Even though we couldn't fix it, we identified the problematic pattern:

```swift
// In MatchDetailsTextualViewModel - called on EVERY event update
self?.marketGroupSelectorTabViewModel.updateMatch(match)
```

Where `updateMatch()` does:
```swift
func updateMatch(_ newMatch: Match) {
    // 1. Clear all data
    tabDataSubject.send(clearedData)  // Sends empty array

    // 2. Cancel subscriptions
    cancellables.removeAll()

    // 3. Restart subscription
    loadMarketGroups()
}
```

This is inherently destructive - it tears down and rebuilds on every call. The challenge is that the initial load depends on this behavior.

---

## Suspected Similar Issues

This pattern likely exists in other parts of the app:
- **NextUp/Upcoming matches** - cells may rebuild on every odds update
- **Live matches screens** - match cards likely recreate on status updates
- **Other detail screens** - similar `updateX()` patterns in WebSocket handlers

---

## Files Investigated

| File | What We Found |
|------|---------------|
| `MatchDetailsManager.swift` | WebSocket subscription manager - correctly delivers all updates |
| `MatchDetailsTextualViewModel.swift` | Calls `updateMatch()` on every event update |
| `MatchDetailsMarketGroupSelectorTabViewModel.swift` | `updateMatch()` is destructive - clears and reloads |
| `MatchDetailsTextualViewController.swift` | Subscribes to market groups publisher, recreates controllers |

---

## What We Need to Investigate Next

1. **Why does initial load depend on `updateMatch()` being called?**
   - Trace the exact sequence of events from screen open to tabs appearing
   - Check if there's a race condition or missing initialization

2. **Can we separate "initial setup" from "refresh"?**
   - Maybe `updateMatch()` should have different behavior first time vs subsequent

3. **Is the subscription from `init()` being cancelled prematurely?**
   - Add logging to track subscription lifecycle
   - Check if `cancellables.removeAll()` is called unexpectedly

4. **Consider debouncing approach**
   - Instead of blocking updates, debounce them
   - Only process the last update in a time window

---

## Achievements
- [x] Identified root cause: `updateMatch()` called on every WebSocket event
- [x] Identified the destructive nature of `updateMatch()` (clear → reload)
- [x] Documented the anti-pattern for future reference
- [x] Tried 5 different fix approaches

### Issues / Bugs Hit
- [ ] All fix attempts broke initial market groups load
- [ ] Couldn't determine why initial load depends on `updateMatch()`
- [ ] Screen stuck in "loading markets" with all attempted fixes

### Key Decisions
- **Reverted all changes** - better to have flickering than broken functionality
- **Need deeper investigation** of initialization flow before attempting fixes

---

## Useful Files / Links
- [MatchDetailsTextualViewModel.swift](../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MatchDetailsTextualViewModel.swift) - Contains the problematic `updateMatch()` call
- [MatchDetailsMarketGroupSelectorTabViewModel.swift](../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MatchDetailsMarketGroupSelectorTabViewModel.swift) - Contains destructive `updateMatch()` implementation
- [MatchDetailsTextualViewController.swift](../../BetssonCameroonApp/App/Screens/MatchDetailsTextual/MatchDetailsTextualViewController.swift) - Subscribes to market groups
- [MatchDetailsManager.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/MatchDetailsManager.swift) - ServicesProvider WebSocket manager

---

## Next Steps
1. Add comprehensive logging to trace initialization sequence
2. Understand exactly when/why first market groups appear
3. Determine if this is a race condition or architectural issue
4. Consider if the screen needs architectural refactoring
5. Possibly file this as tech debt for dedicated sprint
