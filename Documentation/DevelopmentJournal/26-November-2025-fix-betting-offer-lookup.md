## Date
26 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix fragile paginator/manager lookup in `subscribeToEventOnListsBettingOfferAsOutcomeUpdates()`
- Add existence validation before delegating to managers/paginators

### Achievements
- [x] Added `bettingOfferExists(id:)` to LiveMatchesPaginator
- [x] Added `bettingOfferExists(id:)` to PreLiveMatchesPaginator
- [x] Added `bettingOfferExists(id:)` to MatchDetailsManager (checks both main store AND market group stores)
- [x] Updated `EveryMatrixEventsProvider.subscribeToEventOnListsBettingOfferAsOutcomeUpdates()` with existence checks
- [x] Established priority order: MatchDetails > Live > Pre-live

### Issues / Bugs Hit
- None - straightforward implementation following existing patterns

### Key Decisions
- **Priority order**: MatchDetails > Live > Pre-live (user choice)
  - MatchDetailsManager is authoritative when viewing match details screen
  - Live prioritized over pre-live (more frequent odds changes for live matches)
- **MatchDetailsManager checks both stores**: Main `store` AND `marketGroupStores` dictionary (betting offers may come from market group subscriptions)

### Experiments & Notes
- Followed existing pattern from `subscribeToEventOnListsOutcomeUpdates()` which uses `outcomeExists(id:)` before delegating
- The previous implementation blindly delegated to first available manager without checking if betting offer existed there

### Useful Files / Links
- [LiveMatchesPaginator.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/LiveMatchesPaginator.swift) - Added `bettingOfferExists(id:)`
- [PreLiveMatchesPaginator.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/PreLiveMatchesPaginator.swift) - Added `bettingOfferExists(id:)`
- [MatchDetailsManager.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/MatchDetailsManager.swift) - Added `bettingOfferExists(id:)` with dual-store check
- [EveryMatrixEventsProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixEventsProvider.swift) - Updated lookup logic
- [Previous session journal](./26-November-2025-fix-odds-updates-betting-offer-subscription.md) - Context for the betting offer subscription pattern

### Next Steps
1. Test odds updates on live match list
2. Test odds updates on pre-live match list
3. Test odds updates on match details screen (market groups)
4. Address remaining issue from previous session: subscription lifecycle tied to paginator lifecycle (sport switching)
