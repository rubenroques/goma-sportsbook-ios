# Match Details Textual Screen - Blink/Flicker Analysis

## Date
27 November 2025

## Problem Statement
The match details textual screen exhibits excessive re-rendering ("disco effect") where the entire UI flickers/blinks on every WebSocket update, even when the visible data hasn't changed.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           WEBSOCKET LAYER                                    │
│  EveryMatrix sends updates for: EVENT_INFO, MATCH, BETTING_OFFER, MARKET,   │
│  OUTCOME, MARKET_OUTCOME_RELATION                                           │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     SUBSCRIPTION MANAGER LAYER                               │
│                                                                              │
│  ┌─────────────────────────┐    ┌─────────────────────────────────────────┐ │
│  │  Match Aggregator Sub   │    │  Market Group Details Subs (x5)         │ │
│  │  (Event details, scores)│    │  Main, Bet_Builder, Set_Markets,        │ │
│  │                         │    │  Game_Markets, Player_Specials          │ │
│  └───────────┬─────────────┘    └───────────────────┬─────────────────────┘ │
│              │                                      │                        │
│              │  MatchDetailsManager                 │                        │
└──────────────┼──────────────────────────────────────┼────────────────────────┘
               │                                      │
               ▼                                      ▼
┌──────────────────────────────┐    ┌─────────────────────────────────────────┐
│  subscribeEventDetails()     │    │  subscribeToMarketGroupDetails()        │
│  → Event with match info     │    │  → [Market] array per group             │
│  → Live scores (EVENT_INFO)  │    │  → Outcomes with odds                   │
└──────────────┬───────────────┘    └───────────────────┬─────────────────────┘
               │                                        │
               ▼                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         VIEWMODEL LAYER                                      │
│                                                                              │
│  ┌─────────────────────────────────┐  ┌──────────────────────────────────┐  │
│  │ MatchDetailsTextualViewModel    │  │ MarketsTabSimpleViewModel (x5)   │  │
│  │ • Receives Event updates        │  │ • Receives [Market] updates      │  │
│  │ • Calls updateMatch() on ───────┼──│ • Converts to [MarketGroupWith   │  │
│  │   MarketGroupSelectorVM         │  │   Icons]                         │  │
│  └─────────────────────────────────┘  │ • Sends to subject               │  │
│                                       └──────────────┬───────────────────┘  │
│  ┌─────────────────────────────────┐                 │                      │
│  │ MarketGroupSelectorTabViewModel │                 │                      │
│  │ • Manages market group tabs     │                 │                      │
│  │ • On updateMatch(): CLEARS ALL  │◄────────────────┘                      │
│  │   and resubscribes              │                                        │
│  └─────────────────────────────────┘                                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                       VIEWCONTROLLER LAYER                                   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ MatchDetailsTextualViewController                                    │    │
│  │ • Observes market groups from MarketGroupSelectorTabViewModel       │    │
│  │ • On ANY change: calls recreateMarketControllers()                  │    │
│  │ • Contains UIPageViewController with MarketsTabSimpleViewController │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │ MarketsTabSimpleViewController (one per market group)               │    │
│  │ • Observes [MarketGroupWithIcons] from MarketsTabSimpleViewModel    │    │
│  │ • On ANY emission: calls tableView.reloadData() unconditionally     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Analysis from Logs

### What WebSocket Sends (166 updates observed)

| Entity Type | Count | What It Represents | Should Trigger Market UI Refresh? |
|-------------|-------|-------------------|-----------------------------------|
| `CHANGE(BETTING_OFFER)` | 131 | Odds changes | **YES** - but only the affected outcome |
| `CHANGE(EVENT_INFO)` | 23 | Score, match time, status | **NO** - not market data |
| `CHANGE(MATCH)` | ~10 | Match metadata | **NO** - not market data |
| `CHANGE(MARKET)` | varies | Market availability | **YES** - market structure changed |
| `CHANGE(OUTCOME)` | varies | Outcome availability | **YES** - outcome structure changed |

### Current Behavior (PROBLEMATIC)

```
WebSocket: CHANGE(EVENT_INFO):1  (just a score update)
    │
    ▼
MatchDetailsManager.handleMarketGroupDetailsContent()
    │ Receives update for EACH market group subscription (5x)
    │ ALWAYS rebuilds entire [Market] array
    │ ALWAYS emits .contentUpdate(content: markets)
    │
    ▼ (×5 market groups)
MarketsTabSimpleViewModel
    │ Receives [Market] array
    │ Converts to [MarketGroupWithIcons]
    │ Compares with previous: "data IDENTICAL"
    │ STILL sends to subject anyway
    │
    ▼
MarketsTabSimpleViewController
    │ Receives emission
    │ Compares: dataChanged = false
    │ STILL calls tableView.reloadData()
    │
    ▼
ALL CELLS RECREATED → BLINK!
```

### Parallel Cascade: Event Subscription

```
WebSocket: ANY update (even EVENT_INFO)
    │
    ▼
subscribeEventDetails() emits Event
    │
    ▼
MatchDetailsTextualViewModel.handleEventUpdate()
    │ Match ID unchanged (same match)
    │ STILL calls marketGroupSelectorTabViewModel.updateMatch(match)
    │
    ▼
MarketGroupSelectorTabViewModel.updateMatch()
    │ Detects: "SAME MATCH but updateMatch called"
    │ STILL clears all market groups: tabDataSubject.send(empty)
    │ STILL calls reloadMarketGroups()
    │
    ▼
MatchDetailsTextualViewController observes empty groups
    │ Groups changed: 5 → 0
    │ Calls recreateMarketControllers()
    │ DESTROYS all 5 controllers
    │
    ▼
Market groups resubscribe, new data arrives
    │ Groups changed: 0 → 5
    │ Calls recreateMarketControllers() AGAIN
    │ CREATES all 5 controllers
    │
    ▼
ENTIRE SCREEN REBUILT → MASSIVE BLINK!
```

---

## Identified Trigger Points (Root to Leaf)

### TRIGGER #1: MatchDetailsManager emits on non-market updates
**Location**: `MatchDetailsManager.handleMarketGroupDetailsContent()`
**File**: `Frameworks/ServicesProvider/.../SubscriptionManagers/MatchDetailsManager.swift`

**Current behavior**:
```swift
case .updatedContent(let response):
    parseMarketsDataForGroup(from: response, marketGroupKey: marketGroupKey)
    let markets = buildMarketsArrayForGroup(marketGroupKey: marketGroupKey)
    return .contentUpdate(content: markets)  // ALWAYS emits
```

**Problem**: Emits entire markets array even when update only contains EVENT_INFO (scores) or MATCH metadata.

**Should be**: Only emit if update contains market-related entities (BETTING_OFFER, MARKET, OUTCOME, MARKET_OUTCOME_RELATION).

---

### TRIGGER #2: updateMatch() called for same match
**Location**: `MatchDetailsTextualViewModel` calling `MarketGroupSelectorTabViewModel.updateMatch()`
**File**: `BetssonCameroonApp/.../MatchDetailsTextualViewModel.swift`

**Current behavior**:
```swift
// On EVERY event update:
self?.marketGroupSelectorTabViewModel.updateMatch(match)
```

**Problem**: Every event subscription update (even just score changes) triggers `updateMatch()`, which clears and rebuilds all market groups.

**Should be**: Only call `updateMatch()` if match ID actually changed (navigated to different match).

---

### TRIGGER #3: MarketGroupSelectorTabViewModel clears on same match
**Location**: `MarketGroupSelectorTabViewModel.updateMatch()`
**File**: `BetssonCameroonApp/.../MatchDetailsMarketGroupSelectorTabViewModel.swift`

**Current behavior**:
```swift
func updateMatch(_ newMatch: Match) {
    // Even if same match ID:
    tabDataSubject.send(clearedData)  // Clears all groups
    reloadMarketGroups()              // Resubscribes
}
```

**Problem**: Even when same match, it clears groups (causing UI to show empty) then reloads (causing full rebuild).

**Should be**: Early return if `newMatch.id == currentMatch.id`.

---

### TRIGGER #4: ViewController reloads on identical data
**Location**: `MarketsTabSimpleViewController`
**File**: `BetssonCameroonApp/.../MarketsTab/MarketsTabSimpleViewController.swift`

**Current behavior**:
```swift
.sink { newMarketGroups in
    let dataChanged = self.previousMarketGroups != newMarketGroups
    // Even if dataChanged == false:
    self.tableView.reloadData()  // ALWAYS reloads
}
```

**Problem**: Even when data hasn't changed, table is fully reloaded.

**Should be**: Only call `reloadData()` if `dataChanged == true`.

---

### TRIGGER #5: ViewModel forwards identical data
**Location**: `MarketsTabSimpleViewModel`
**File**: `BetssonCameroonApp/.../MarketsTab/MarketsTabSimpleViewModel.swift`

**Current behavior**:
```swift
if !dataChanged {
    print("⚠️ WebSocket update but data IDENTICAL - still sending to publisher")
}
marketGroupsSubject.send(marketGroups)  // ALWAYS sends
```

**Problem**: Knows data is identical but sends anyway.

**Should be**: Don't send if data hasn't changed, OR use `removeDuplicates()` on publisher.

---

## Recommended Fix Order (Root First)

### Fix #1: MatchDetailsManager - Filter non-market updates
**Impact**: Prevents 23+ unnecessary emissions at the source
**Risk**: Low - just skipping irrelevant updates

```swift
case .updatedContent(let response):
    // Check if update contains market-related changes
    let hasMarketChanges = response.records.contains { record in
        switch record {
        case .bettingOffer, .market, .outcome, .marketOutcomeRelation:
            return true
        case .changeRecord(let cr):
            return ["BETTING_OFFER", "MARKET", "OUTCOME", "MARKET_OUTCOME_RELATION"]
                .contains(cr.entityType)
        default:
            return false
        }
    }

    guard hasMarketChanges else {
        // EVENT_INFO, MATCH-only updates - skip emission
        return nil
    }

    parseMarketsDataForGroup(from: response, marketGroupKey: marketGroupKey)
    let markets = buildMarketsArrayForGroup(marketGroupKey: marketGroupKey)
    return .contentUpdate(content: markets)
```

### Fix #2: MatchDetailsTextualViewModel - Don't call updateMatch for same match
**Impact**: Prevents 19 full screen rebuilds
**Risk**: Low - just adding guard

```swift
// In handleEventUpdate or wherever updateMatch is called:
guard match.id != currentMatch?.id else {
    // Same match, just update header with new data (scores, etc.)
    matchHeaderCompactViewModel.updateMatch(match)
    return
}
marketGroupSelectorTabViewModel.updateMatch(match)
```

### Fix #3: MarketGroupSelectorTabViewModel - Guard updateMatch
**Impact**: Backup protection if Fix #2 missed
**Risk**: Low

```swift
func updateMatch(_ newMatch: Match) {
    guard newMatch.id != self.match?.id else {
        return  // Same match, no action needed
    }
    // ... existing clear and reload logic
}
```

### Fix #4: MarketsTabSimpleViewController - Guard reloadData
**Impact**: Prevents 54+ unnecessary table reloads
**Risk**: Low

```swift
if dataChanged {
    self.previousMarketGroups = newMarketGroups
    self.tableView.reloadData()
}
```

### Fix #5: MarketsTabSimpleViewModel - Add removeDuplicates (Safety Net)
**Impact**: Final defense against duplicate emissions
**Risk**: Very low - requires Equatable conformance (already present)

```swift
var marketGroupsPublisher: AnyPublisher<[MarketGroupWithIcons], Never> {
    marketGroupsSubject
        .removeDuplicates()
        .eraseToAnyPublisher()
}
```

---

## Expected Outcome After Fixes

```
WebSocket: CHANGE(EVENT_INFO):1
    │
    ▼
MatchDetailsManager: "No market-related changes, skipping emission"
    │
    ▼
NO DOWNSTREAM UPDATES → NO BLINK

---

WebSocket: CHANGE(BETTING_OFFER):4
    │
    ▼
MatchDetailsManager: "Has BETTING_OFFER changes, emitting"
    │
    ▼
MarketsTabSimpleViewModel: "Data changed: true"
    │
    ▼
MarketsTabSimpleViewController: "dataChanged: true, reloading"
    │
    ▼
Table updates with new odds → LEGITIMATE UPDATE (no unnecessary blink)
```

---

## Metrics to Verify Success

| Metric | Before Fix | Expected After |
|--------|------------|----------------|
| UPDATE emissions (per minute) | 166 | ~131 (only BETTING_OFFER/MARKET changes) |
| "data IDENTICAL" logs | 54 | 0 |
| "SAME MATCH but updateMatch" | 19 | 0 |
| recreateMarketControllers calls | 131 | 2 (only initial load) |
| tableView.reloadData calls | ~100+ | Only when data actually changes |

---

## Files to Modify

1. `Frameworks/ServicesProvider/.../SubscriptionManagers/MatchDetailsManager.swift`
2. `BetssonCameroonApp/.../MatchDetailsTextualViewModel.swift`
3. `BetssonCameroonApp/.../MatchDetailsMarketGroupSelectorTabViewModel.swift`
4. `BetssonCameroonApp/.../MarketsTab/MarketsTabSimpleViewController.swift`
5. `BetssonCameroonApp/.../MarketsTab/MarketsTabSimpleViewModel.swift`
