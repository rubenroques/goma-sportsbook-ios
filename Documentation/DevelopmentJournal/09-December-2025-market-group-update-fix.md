## Date
09 December 2025

### Project / Branch
sportsbook-ios / rr/new_client_structure

### Goals for this session
- Explore cWAMP tool for EveryMatrix WebSocket testing
- Debug Match Details screen showing "All Markets" fallback
- Fix MARKET_GROUP entity handling in EntityStore

### Achievements
- [x] Explored cWAMP tool - tested RPC calls, subscriptions, and register patterns
- [x] Successfully fetched live football matches, match details, and market groups via WAMP
- [x] Identified root cause of Match Details tab flickering/fallback issue
- [x] Fixed EntityStore missing MARKET_GROUP case in `mergeChangedProperties()`
- [x] Fixed MatchDetailsManager cache wipe bug in `parseMarketGroupsData()`

### Issues / Bugs Hit
- **Bug #1**: `EntityStore.mergeChangedProperties()` was missing `MARKET_GROUP` case, causing merge to fail and return `nil`
- **Bug #2**: `MatchDetailsManager.parseMarketGroupsData()` unconditionally called `updateCachedMarketGroups(from: marketGroupDTOs)` even when `marketGroupDTOs` was empty (on UPDATE messages), wiping the cache

### Key Decisions
- Added `MARKET_GROUP` case to EntityStore switch statement for proper DTO merging
- Added `if !marketGroupDTOs.isEmpty` guard to prevent cache wipe on UPDATE messages
- UPDATE messages contain only CHANGE_RECORDs (not full entities), so cache should be rebuilt from store, not from the empty array

### Experiments & Notes

**cWAMP Tool Usage Patterns:**
```bash
# Test connection
cwamp test

# Get live football matches
cwamp rpc --procedure "/sports#initialDump" --kwargs '{"topic":"/sports/4093/en/live-matches-aggregator-main/1/all-locations/default-event-info/20/5"}' --pretty

# Get market groups for a match
cwamp rpc --procedure "/sports#initialDump" --kwargs '{"topic":"/sports/4093/en/event/{matchId}/market-groups"}' --pretty

# Get odds with jq filtering
cwamp rpc --procedure "/sports#odds" --kwargs '{"lang":"en","matchId":"{matchId}","bettingTypeId":"69"}' 2>&1 | jq '.result.kwargs.records[] | select(._type == "BETTING_OFFER")'
```

**Bug Flow Analysis:**
```
UPDATE arrives → parseMarketGroupsData()
  → marketGroupDTOs = [] (empty - only change records in update)
  → handleMarketGroupChangeRecord() → rebuildCachedMarketGroups() ✓
  → updateCachedMarketGroups([]) ← WIPES CACHE!
  → cachedMarketGroups = []
  → App shows "All Markets" fallback
```

### Useful Files / Links
- [EntityStore.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/Store/EntityStore.swift) - Line 221-222 (MARKET_GROUP case added)
- [MatchDetailsManager.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/MatchDetailsManager.swift) - Line 527-531 (guard added)
- [MarketGroupDTO.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/WebSocket/DTOs/MarketGroupDTO.swift)
- [cWAMP Tool](../../tools/wamp-client/README.md)
- [Plan File](~/.claude/plans/joyful-sniffing-ritchie.md)

### Next Steps
1. Test Match Details screen with live WebSocket updates
2. Verify tabs remain stable after 30+ seconds of updates
3. Confirm no "Unknown entity type for merge: MARKET_GROUP" in logs
