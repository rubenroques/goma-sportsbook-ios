# WAMP Response Examples

## Testing Summary - 19 November 2025

### Tested Routes

All tests performed on live tennis match ID: `287259481896947712`

#### 1. `liveMatchesPublisher`
**Topic**: `/sports/4093/en/live-matches-aggregator-main/3/all-locations/default-event-info/5/3`
**File**: `liveMatchesPublisher_tennis_full.json`
**Purpose**: List of live matches with markets and scores
**Entity Types Returned**:
- 10 MATCH
- 22 EVENT_INFO ✅
- 30 MARKET
- 60 OUTCOME
- 60 BETTING_OFFER
- 30 SPORT
- 14 LOCATION
- 10 EVENT_CATEGORY
- 6 MAIN_MARKET

**Key Finding**: InPlay lists use this route - EVENT_INFO is included via `default-event-info` parameter

---

#### 2. `matchDetailsAggregatorPublisher`
**Topic**: `/sports/4093/en/match-aggregator-groups-overview/287259481896947712/1`
**File**: `matchDetailsAggregatorPublisher_tennis_match.json`
**Purpose**: Single match details with ALL markets and scores
**Entity Types Returned**:
- 2 MATCH
- 32 EVENT_INFO ✅

**Key Finding**: Match Details screen DOES receive EVENT_INFO entities, but MatchBuilder doesn't extract them!

---

#### 3. `eventPartScoresPublisher`
**Topic**: `/sports/4093/en/287259481896947712/eventPartScores/small`
**File**: `eventPartScoresPublisher_tennis_match.json`
**Purpose**: Lightweight scores-only subscription
**Entity Types Returned**:
- 2 EVENT_PART_SCORE (simplified format, NOT EVENT_INFO)

**Key Finding**: This is a different entity type (EVENT_PART_SCORE), not compatible with current EventLiveDataBuilder

---

## Root Cause Analysis

### The Problem

Match Details screen shows NO scores, but InPlay lists DO show scores.

### Why InPlay Works

InPlay uses `liveMatchesPublisher` which returns:
1. MATCH DTOs
2. EVENT_INFO DTOs ✅
3. MARKET/OUTCOME/BETTING_OFFER DTOs

LiveMatchesPaginator stores all these in EntityStore, including EVENT_INFO.
The EventLiveDataBuilder processes EVENT_INFO to create scores.

### Why Match Details Doesn't Work

Match Details uses `matchDetailsAggregatorPublisher` which ALSO returns:
1. MATCH DTOs
2. EVENT_INFO DTOs ✅
3. MARKET/OUTCOME/BETTING_OFFER DTOs

**BUT**: MatchBuilder does NOT extract EVENT_INFO from EntityStore!

Look at `MatchBuilder.swift` lines 15-127:
- Extracts SportDTO, LocationDTO, EventCategoryDTO ✅
- Extracts all MarketDTOs for the match ✅
- **NEVER extracts EventInfoDTOs** ❌

Then look at `EveryMatrix.Match` struct:
- Has `sport`, `venue`, `markets` properties ✅
- **NO score properties at all** ❌

Finally, `EveryMatrixModelMapper+Events.swift` lines 79-98:
```swift
return Event(
    homeTeamScore: nil, // EveryMatrix doesn't provide scores in match data ← WRONG COMMENT!
    awayTeamScore: nil,
    matchTime: nil,
    activePlayerServing: nil,
    scores: [:]  // ← HARDCODED EMPTY!
)
```

### The Solution

**Option A**: Extract EVENT_INFO in MatchBuilder (proper hierarchical approach)
1. Add score properties to `EveryMatrix.Match` struct
2. Update `MatchBuilder` to extract EVENT_INFO from EntityStore
3. Use `EventLiveDataBuilder` to transform EVENT_INFO → scores
4. Update `EveryMatrixModelMapper` to use scores from Match instead of nil

**Option B**: Use EveryMatrixProvider's existing observeEventInfosForEvent() method
- Already implemented in MatchDetailsManager (line 795-815)
- Already wired up in EveryMatrixEventsProvider (line 297-307)
- Just needs to be called from MatchDetailsTextualViewModel

## Conclusion

Match Details screen **DOES receive EVENT_INFO data** from WebSocket.
The bug is in the **transformation layer** (MatchBuilder → Match → Mapper).

The comment "EveryMatrix doesn't provide scores in match data" is **factually incorrect** - EveryMatrix sends 32 EVENT_INFO entities for the test match!
