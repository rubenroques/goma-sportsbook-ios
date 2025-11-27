## Date
27 November 2025

### Project / Branch
BetssonCameroonApp / main

### Goals for this session
- Investigate why Virtuals bottom bar button shows the same content as Casino tab
- Fix the issue to ensure Virtuals has its own distinct page/data

### Achievements
- [x] Identified root cause: `CasinoCacheStore` cache keys don't include `lobbyType`
- [x] Updated `CacheKey` enum to include `lobbyType` parameter in key generation
- [x] Updated `getCachedCategories()` and `saveCachedCategories()` to accept `lobbyType`
- [x] Updated `getCachedGameList()` and `saveCachedGameList()` to accept `lobbyType`
- [x] Updated disk persistence methods to use lobbyType-specific file names
- [x] Updated `CasinoCacheProvider` to pass `lobbyType.displayName` to all cache store methods
- [x] Fixed compilation error: `CasinoLobbyType` uses `displayName` property, not `rawValue`

### Issues / Bugs Hit
- [x] Initial implementation used `.rawValue` but `CasinoLobbyType` is not a String enum
- [x] Fixed by using `.displayName` property instead

### Key Decisions
- Cache keys now include lobbyType suffix for isolation:
  - Categories: `casino_categories_casino` vs `casino_categories_virtuals`
  - Games: `casino_games_{id}_offset_0_casino` vs `casino_games_{id}_offset_0_virtuals`
- Backwards compatible: old cache entries become cache misses (key mismatch), new data fetched correctly
- No cache version bump needed - stale data naturally expires

### Experiments & Notes
- `CasinoCacheProvider` and `CasinoCacheStore` were created on 25-Nov-2025 (2 days ago)
- Cache was designed with only Casino in mind, then Virtuals was added using same `CasinoCoordinator` with different `lobbyType` parameter
- The cache key design was never updated to differentiate between lobbies

### Useful Files / Links
- [CasinoCacheStore.swift](../../BetssonCameroonApp/App/Services/CasinoCache/CasinoCacheStore.swift) - Cache key generation and storage
- [CasinoCacheProvider.swift](../../BetssonCameroonApp/App/Services/CasinoCache/CasinoCacheProvider.swift) - Cache layer decorator
- [CasinoCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/CasinoCoordinator.swift) - Creates VMs with lobbyType
- [MainTabBarCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift) - Creates Casino (`.casino`) and Virtuals (`.virtuals`) coordinators

### Next Steps
1. Verify build compiles successfully
2. Test Casino tab loads casino-specific categories
3. Test Virtuals tab loads virtuals-specific categories
4. Verify cache isolation (both tabs should have independent cached data)
