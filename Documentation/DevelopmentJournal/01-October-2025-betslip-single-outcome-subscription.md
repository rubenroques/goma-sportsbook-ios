## Date
01 October 2025

### Project / Branch
sportsbook-ios / rr/virtuals

### Goals for this session
- Fix critical betslip odds update issue where live odds were being ghosted by the app
- Implement proper single-outcome WebSocket subscription for betslip items
- Replace broken `subscribeToMarketDetails` API with new `subscribeToEventWithSingleOutcome` endpoint

### Achievements
- [x] Identified root cause: BetslipManager was using `subscribeToMarketDetails()` which returns `.notSupportedForProvider` for EveryMatrix
- [x] Created `SingleOutcomeSubscriptionManager` that subscribes to individual betting offers via WebSocket
- [x] Added `subscribeToEventWithSingleOutcome` method to EventsProvider protocol
- [x] Implemented method in EveryMatrixEventsProvider with proper subscription manager lifecycle
- [x] Updated Client.swift to expose new public API endpoint
- [x] Implemented fallback methods for SportRadar and Goma providers (return `.notSupportedForProvider`)
- [x] Updated BetslipManager to use new single outcome subscription API
- [x] Fixed SingleOutcomeSubscriptionManager to use builder pattern correctly (removed 60+ compilation errors)
- [x] Added comprehensive logging to SingleOutcomeSubscriptionManager for debugging and verification

### Issues / Bugs Hit
- [x] Initial implementation manually constructed EveryMatrix.Market and EveryMatrix.Match objects instead of using builders
- [x] ~60 compilation errors due to mismatched property names and types (no `marketId` on Outcome, wrong Match initializer signature, etc.)
- [x] Assumed data structures without checking actual internal models

### Key Decisions
- **Used existing `bettingOfferPublisher` WebSocket endpoint** (`/sports/{op}/{lang}/bettingOffers/{bettingOfferId}`) - already available in WAMPRouter
- **Leveraged EntityStore filtering** - Since store only contains subscribed outcome's data, builders naturally return filtered results
- **No backward compatibility needed** - Clean implementation for BetssonCameroonApp only
- **Kept loop logic in BetslipManager** - User wanted to maintain existing `updateBettingTickets(ofMarket:)` pattern
- **Builder pattern is key** - Let MatchBuilder/MarketBuilder/OutcomeBuilder handle hierarchical construction from store

### Experiments & Notes
- **EntityStore as filtered database**: Store acts as a scoped data container. When subscribing to single outcome, store only contains that outcome's entities, so builders automatically return filtered results without manual construction
- **WebSocket endpoint choice**: The `bettingOfferPublisher` endpoint is perfect for betslip - subscribes to single betting offer and receives real-time odds updates
- **Manager lifecycle**: EveryMatrixEventsProvider maintains dictionary of SingleOutcomeSubscriptionManager instances (keyed by "eventId:outcomeId") to support multiple concurrent betslip items

### Architecture Pattern
```
BetslipManager
  ↓ addBettingTicket(ticket)
  ↓ calls Env.servicesProvider.subscribeToEventWithSingleOutcome(eventId, outcomeId)
  ↓
Client.swift
  ↓ delegates to eventsProvider.subscribeToEventWithSingleOutcome()
  ↓
EveryMatrixEventsProvider
  ↓ creates SingleOutcomeSubscriptionManager(eventId, outcomeId)
  ↓ stores in singleOutcomeManagers["eventId:outcomeId"]
  ↓
SingleOutcomeSubscriptionManager
  ↓ subscribes to WAMPRouter.bettingOfferPublisher(outcomeId)
  ↓ WebSocket: /sports/4093/en/bettingOffers/{outcomeId}
  ↓ receives: MATCH, MARKET, OUTCOME, BETTING_OFFER entities
  ↓ stores in local EntityStore
  ↓
  buildSingleOutcomeEvent()
    ↓ MatchBuilder.build(matchDTO, store)
    ↓   → queries store for markets (finds 1)
    ↓   → MarketBuilder.build() queries for outcomes (finds 1)
    ↓   → OutcomeBuilder.build() queries for betting offers (finds 1)
    ↓ returns Event with 1 Market, 1 Outcome, 1 BettingOffer
  ↓
BetslipManager
  ↓ receives Event updates
  ↓ extracts market.first → loops outcomes → updates BettingTicket
  ↓ publishes updated odds to UI
```

### Logging Added
Comprehensive logging with emoji prefixes for easy filtering:
- 🔵 `[SingleOutcome]` - Lifecycle events (subscribe, connect, disconnect, unsubscribe)
- 📥 `[SingleOutcome]` - Data reception (initial content, updates, record counts)
- ⚙️ `[SingleOutcome]` - Processing (store contents, entity counts, building progress)
- 🔄 `[SingleOutcome]` - Real-time updates (CREATE/UPDATE/DELETE change records, odds changes)
- ❌ `[SingleOutcome]` - Errors (missing DTOs, build failures)
- ✅ `[SingleOutcome]` - Success (event built, data processed)

### Useful Files / Links
- [SingleOutcomeSubscriptionManager](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/SubscriptionManagers/SingleOutcomeSubscriptionManager.swift)
- [EventsProvider Protocol](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/EventsProvider.swift)
- [EveryMatrixEventsProvider](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixProvider.swift)
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift)
- [BetslipManager](../../BetssonCameroonApp/App/Services/BetslipManager.swift)
- [WAMPRouter](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Libs/WAMPClient/WAMPRouter.swift) - Line 148: bettingOfferPublisher endpoint
- [MatchBuilder](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Builders/MatchBuilder.swift)
- [MarketBuilder](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Builders/MarketBuilder.swift)
- [OutcomeBuilder](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Builders/OutcomeBuilder.swift)

### Next Steps
1. **Test in simulator** - Add outcomes to betslip and verify logs show WebSocket connection and odds updates
2. **Verify odds changes in real-time** - Watch for `🔄 [SingleOutcome] Current odds:` log entries during live matches
3. **Test with multiple betslip items** - Verify multiple concurrent SingleOutcomeSubscriptionManager instances work correctly
4. **Test reconnection logic** - Ensure subscriptions reestablish after WebSocket disconnect (handled by `reconnectBettingTicketsUpdates()`)
5. **Monitor for memory leaks** - Verify SingleOutcomeSubscriptionManager instances are properly cleaned up when outcomes removed from betslip
6. **Consider removing LiveMatchesPaginator optimization** - The `return nil` on line 261-263 that prevents odds updates from propagating to match list screens (separate issue, not addressed in this session)
