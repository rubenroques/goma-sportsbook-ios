## Date
17 July 2025

### Project / Branch
sportsbook-ios / everymatrix-match-details-subscription

### Goals for this session
- Fix compilation error in MatchDetailsMarketGroupSelectorTabViewModel
- Implement subscription-based market groups architecture 
- Replace on-demand getMarketGroups() with real-time subscriptions
- Ensure full EveryMatrix market group feature support

### Achievements
- [x] **Fixed critical architecture flaw**: Removed automatic market groups subscription from event details
- [x] **Added subscribeToMarketGroups to EventsProvider protocol** with proper error handling
- [x] **Enhanced MatchDetailsManager**: subscribeToMarketGroups now returns publisher instead of void
- [x] **Fixed sink operator compilation error** in MatchDetailsManager with proper completion/receiveValue handlers
- [x] **Implemented eventId validation** in EveryMatrixProvider to prevent wrong match data access
- [x] **Added ServicesProvider.Client public API** for subscribeToMarketGroups following established patterns
- [x] **Expanded MarketGroup models** to support all EveryMatrix properties:
  - Added `isBetBuilder`, `isFast`, `isOutright` to both ServicesProvider and App models
  - Added `numberOfMarkets`, `loaded` to App model for retro-compatibility
- [x] **Created ServiceProviderModelMapper conversion** for proper type mapping
- [x] **Updated MatchDetailsMarketGroupSelectorTabViewModel** to use subscription pattern with model conversion
- [x] **Fixed type conversion error**: ServicesProvider.MarketGroup → App.MarketGroup

### Issues / Bugs Hit
- [x] ~~Type mismatch: Cannot convert SubscribableContent<[ServicesProvider.MarketGroup]> to SubscribableContent<[BetssonCM_STG.MarketGroup]>~~
- [x] ~~Sink operator error: 'ServiceProviderError' and 'Never' are not equivalent~~
- [x] ~~Missing EveryMatrix properties in both ServicesProvider and App MarketGroup models~~

### Key Decisions
- **Subscription-based architecture**: Market groups follow same real-time pattern as other data streams
- **Strict eventId validation**: Returns error if no MatchDetailsManager exists or wrong eventId (no automatic creation)
- **Three-tier model hierarchy**: EveryMatrix DTO → ServicesProvider MarketGroup → App MarketGroup
- **Retro-compatibility**: Added comprehensive initializer with defaults to prevent breaking changes
- **ServiceProviderModelMapper pattern**: Followed existing conversion patterns instead of direct type usage

### Experiments & Notes
- **EveryMatrix MarketGroupDTO analysis**: Found missing properties (isBetBuilder, isFast, isOutright)
- **Type derivation logic**: `type` field now derived from properties (regular/bet_builder/outright/fast)
- **Error handling**: Proper SubscribableContent lifecycle management (connected/contentUpdate/disconnected)

### Useful Files / Links
- [MatchDetailsManager](ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/SubscriptionManagers/MatchDetailsManager.swift) - Core subscription management
- [EveryMatrix MarketGroupDTO](ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/DataTransferObjects/MarketGroupDTO.swift) - Source of truth for properties
- [ServiceProviderModelMapper](Core/Models/ModelMappers/ServiceProviderModelMapper.swift) - Model conversion patterns
- [App MarketGroup](Core/Screens/MatchDetails/MarketGroupOrganizer.swift) - Business logic model
- [ServicesProvider MarketGroup](ServicesProvider/Sources/ServicesProvider/Models/Events/Events.swift) - API layer model
- [MatchDetailsMarketGroupSelectorTabViewModel](Core/Screens/MatchDetailsTextual/MatchDetailsMarketGroupSelectorTabViewModel.swift) - UI layer implementation

### Next Steps
1. **Test the build** to ensure all compilation errors are resolved
2. **Verify retro-compatibility** - check that existing MarketGroupOrganizer usage still works
3. **Test WebSocket subscriptions** with real EveryMatrix data
4. **Implement MarketsTabSimpleViewModel** to use real market subscriptions for individual market groups
5. **Add UI support** for bet builder, fast betting, and outright market indicators