## Date
13 June 2025

### Project / Branch
sportsbook-ios / main - EveryMatrix Sports Subscription Implementation

### Goals for this session
- Implement real-time sports subscription for EveryMatrix provider
- Create sports manager similar to PreLiveMatchesPaginator but without pagination
- Use EntityStore for initial dump and real-time updates
- Replace mock data in `subscribeSportTypes()` with actual WebSocket subscription

### Achievements
- [x] Created `EveryMatrixSportsManager` class with EntityStore integration
- [x] Implemented WebSocket subscription using existing `WAMPRouter.sportsPublisher` 
- [x] Added real-time sports updates handling (initial dump + incremental updates)
- [x] Updated `EveryMatrixProvider.subscribeSportTypes()` to use new sports manager
- [x] Proper error handling and Combine publisher chain with `ServiceProviderError` mapping
- [x] Successfully compiled and tested - working implementation!

### Issues / Bugs Hit
- [x] **Fixed**: Combine publisher type mismatch - needed `.mapError` to convert `Never` to `ServiceProviderError`
- [x] **Fixed**: Import error - removed incorrect `Common` import, types available in same module
- [x] **Fixed**: Initial value error for `CurrentValueSubject` - used `.disconnected` case from `SubscribableContent`

### Key Decisions
- **Reused existing architecture**: Followed `PreLiveMatchesPaginator` pattern for consistency
- **Leveraged existing WebSocket topic**: Used `WAMPRouter.sportsPublisher(operatorId: "4093")` which generates `/sports/4093/en/disciplines/BOTH/BOTH`
- **EntityStore per manager**: Each subscription manager maintains its own EntityStore instance
- **Natural topic separation**: Each WebSocket subscription has its own callback, no manual topic filtering needed
- **Always rebuild sports**: Unlike matches, sports are few in number so always rebuild list on updates for simplicity

### Experiments & Notes
- **Sports data structure**: Each sport has `numberOfEvents`, `numberOfLiveEvents`, `numberOfUpcomingMatches` etc.
- **Filtering logic**: Only show sports with `events > 0 || liveEvents > 0 || outrightEvents > 0`
- **Real-time updates**: WebSocket sends frequent updates to sport counters (every few seconds)
- **Data mapping chain**: `SportDTO` → `EveryMatrix.Sport` → `SportType` using existing builders and mappers

### Useful Files / Links
- [EveryMatrixSportsManager.swift](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixSportsManager.swift) - New sports subscription manager
- [EveryMatrixProvider.swift](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixProvider.swift) - Updated to use sports manager
- [PreLiveMatchesPaginator.swift](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/PreLiveMatchesPaginator.swift) - Architecture pattern reference
- [sports_example.txt](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/ExampleResponses/sports_example.txt) - Real WebSocket data example
- [EveryMatrixNamespace.swift](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/EveryMatrixNamespace.swift) - EntityStore and data models
- [SportTypeStore.swift](../../../Core/Services/SportTypeStore.swift) - Consumer of sports subscription

### Next Steps
1. ✅ **Complete** - Implementation working and compiled successfully
2. Monitor real-time sports data in app to verify update frequency and accuracy
3. Consider optimizations if sports update too frequently (batching, debouncing)
4. Document WebSocket message patterns for future reference