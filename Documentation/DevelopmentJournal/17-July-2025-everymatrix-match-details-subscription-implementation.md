## Date
17 July 2025

### Project / Branch
sportsbook-ios / feature/everymatrix-match-details-subscription

### Goals for this session
- Implement EveryMatrix match details subscription architecture
- Create MatchDetailsManager for real-time match data and market groups
- Add MARKET_GROUP entity support to EveryMatrix data parsing
- Update ServicesProvider to return real market groups from WebSocket data
- Fix compilation errors and prepare for production view model integration

### Achievements
- [x] **MatchDetailsManager Created**: Complete subscription manager with dual WebSocket endpoints
- [x] **Market Groups Support**: Added MarketGroupDTO, EntityData, and EntityRecord parsing for MARKET_GROUP entities
- [x] **Real Market Groups**: getMarketGroups() now returns actual market groups from EveryMatrix (Fast, Main, Bet Builder, etc.)
- [x] **WebSocket Architecture**: Two-endpoint strategy - matchDetailsAggregatorPublisher for event details + market groups, oddsMatch for live markets
- [x] **Unified Subscriptions**: Outcome buttons work in both lists and match details via single MatchDetailsManager
- [x] **Entity Store Integration**: Enhanced store with MarketGroupDTO support and proper change record handling

### Issues / Bugs Hit
- [x] **MarketGroupDTO Entity Conformance**: Had to make MarketGroupDTO conform to Entity protocol
- [x] **EntityRecord Missing Case**: Added marketGroup case to EntityRecord enum with proper decoding/encoding
- [x] **EntityData Missing Case**: Added marketGroup case to EntityData enum with MARKET_GROUP parsing
- [x] **EventLiveData Mapping**: Fixed missing eventLiveData mapper by creating buildEventLiveData method
- [x] **Compilation Errors**: Addressed 4 compilation errors in MatchDetailsManager

### Key Decisions
- **Single MatchDetailsManager**: Only one instance per match, cleaned up when switching matches
- **Dual WebSocket Strategy**: Event details + market groups from one endpoint, live markets from another
- **Real Market Groups**: Use actual EveryMatrix market group data instead of single "All Markets" fallback
- **Unified Architecture**: Same manager serves both list-based and match details outcome subscriptions
- **Store-Based Approach**: Market groups stored in EntityStore and accessed via getMarketGroups() method

### Experiments & Notes
- **WebSocket Endpoint Analysis**: Studied match-aggregator-groups-overview.txt to understand MARKET_GROUP structure
- **Entity Store Extension**: Added MarketGroupDTO support with proper Entity protocol conformance
- **EventLiveData Mapping**: Created direct mapping from EventInfoDTO to EventLiveData without external mapper
- **Market Group Sorting**: Implemented position-based sorting for correct tab order
- **Fallback Strategy**: Single "All Markets" group when no market groups available

### Useful Files / Links
- [MatchDetailsManager.swift](../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/SubscriptionManagers/MatchDetailsManager.swift) - New match details subscription manager
- [MarketGroupDTO.swift](../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/DataTransferObjects/MarketGroupDTO.swift) - New DTO for MARKET_GROUP entities
- [EveryMatrixProvider.swift](../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixProvider.swift) - Updated with match details methods
- [EntityData.swift](../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Response/EntityData.swift) - Enhanced with marketGroup case
- [EntityRecord.swift](../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Response/EntityRecord.swift) - Enhanced with marketGroup case
- [match-aggregator-groups-overview.txt](../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Documentation/ExampleResponses/match-aggregator-groups-overview.txt) - Example WebSocket response

### Architecture Compliance
- **✅ Protocol-Oriented**: MatchDetailsManager follows same patterns as SportsManager/LiveMatchesPaginator
- **✅ Reactive Programming**: Full Combine integration with proper error handling
- **✅ Entity Store Pattern**: MarketGroupDTO properly integrated with EntityStore
- **✅ WebSocket Abstraction**: Uses existing WAMPRouter and EveryMatrixConnector
- **✅ Clean Separation**: Event details vs markets data clearly separated

### WebSocket Integration
- **Event Details Endpoint**: `/sports/{operatorId}/{language}/match-aggregator-groups-overview/{matchId}/1`
  - Returns: MATCH, EVENT_INFO, MARKET_GROUP, TOURNAMENT, LOCATION entities
  - Used for: Event details, live data, market group tabs
- **Markets Endpoint**: `/sports/{operatorId}/{language}/{matchId}/match-odds`
  - Returns: MARKET, OUTCOME, BETTING_OFFER, MARKET_OUTCOME_RELATION entities
  - Used for: Live odds, market data, outcome updates

### Data Flow Architecture
1. **subscribeEventDetails()**: Creates MatchDetailsManager, subscribes to event details + market groups
2. **subscribeToLiveDataUpdates()**: Uses MatchDetailsManager to observe EVENT_INFO changes
3. **getMarketGroups()**: Returns real market groups from MatchDetailsManager store
4. **subscribeToEventOnListsMarketUpdates()**: Checks MatchDetailsManager first, falls back to paginators
5. **subscribeToEventOnListsOutcomeUpdates()**: Checks MatchDetailsManager first, falls back to paginators

### Market Groups Implementation
- **Real Data**: Returns actual market groups like "Fast", "Main", "Bet Builder", "Goals", "Scores", etc.
- **Sorted by Position**: Market groups returned in correct display order
- **Type Classification**: Distinguishes between regular and bet builder groups
- **Market Count**: Shows numberOfMarkets from EveryMatrix data
- **Fallback Support**: Single "All Markets" group when no market groups available

### Files Modified/Created
```
ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/
├── SubscriptionManagers/
│   └── MatchDetailsManager.swift (NEW)
├── Models/
│   ├── DataTransferObjects/
│   │   └── MarketGroupDTO.swift (NEW)
│   └── Response/
│       ├── EntityData.swift (MODIFIED - added marketGroup case)
│       └── EntityRecord.swift (MODIFIED - added marketGroup case)
└── EveryMatrixProvider.swift (MODIFIED - added match details methods)
```

### Next Steps
1. **Complete Compilation Fixes**: Finish EventLiveData mapping and EventStatus handling
2. **Production View Models**: Replace mock view models with real EveryMatrix subscriptions
3. **UI Integration**: Update MatchDetailsTextualViewController to use production view models
4. **Market Filtering**: Implement market filtering by market group for tab content
5. **Error Handling**: Add comprehensive error states for WebSocket failures
6. **Testing**: Verify market group tabs and real-time updates work correctly

### Performance Optimizations
- **Single Manager**: Only one MatchDetailsManager instance per match
- **Efficient Store**: MarketGroupDTO stored in EntityStore with proper indexing
- **Reactive Updates**: Only rebuilds when necessary, not on every WebSocket message
- **Memory Management**: Proper cleanup when switching matches

### Technical Implementation Notes
- **Entity Protocol**: MarketGroupDTO conforms to Entity with proper rawType
- **WebSocket Parsing**: MARKET_GROUP entities decoded from WebSocket responses
- **Store Integration**: MarketGroupDTO fully integrated with EntityStore observe/get methods
- **Combine Integration**: All subscriptions return proper AnyPublisher types
- **Error Handling**: ServiceProviderError mapping for all failure cases