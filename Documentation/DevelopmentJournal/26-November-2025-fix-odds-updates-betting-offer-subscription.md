## Date
26 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix real-time odds updates not reaching UI
- Implement BettingOffer subscription pattern to resolve entity type mismatch

### Achievements
- [x] Diagnosed root cause: BETTING_OFFER updates don't notify OUTCOME observers in EntityStore
- [x] Added `subscribeToBettingOfferAsOutcomeUpdates()` to LiveMatchesPaginator
- [x] Added `subscribeToBettingOfferAsOutcomeUpdates()` to PreLiveMatchesPaginator
- [x] Added `subscribeToBettingOfferAsOutcomeUpdates()` to MatchDetailsManager
- [x] Added `subscribeToEventOnListsBettingOfferAsOutcomeUpdates()` to EveryMatrixEventsProvider
- [x] Added protocol method to EventsProvider
- [x] Added public method to Client.swift (ServicesProvider entry point)
- [x] Modified OutcomeItemViewModel to use new BettingOffer subscription with fallback

### Issues / Bugs Hit
- [x] Real-time odds updates now working correctly
- [ ] **Paginator/Manager lookup needs improvement**: Current implementation in `EveryMatrixEventsProvider.subscribeToEventOnListsBettingOfferAsOutcomeUpdates()` checks managers in fixed order (matchDetailsManager → livePaginator → prelivePaginator). This is fragile.
- [ ] **Breaks when switching sports**: When user switches sports, the paginator is recreated but existing subscriptions may still reference the old paginator's store, causing updates to fail

### Key Decisions
- **Subscribe to BettingOffer, return merged Outcome**: Instead of creating a new BettingOffer domain model (which would break 90% of the app), we subscribe to BettingOfferDTO updates and return the parent Outcome with merged odds data
- **Fallback pattern**: If `bettingOfferId` is not available, fall back to existing Outcome subscription
- **Merge with cached**: When BettingOffer update arrives, look up parent OutcomeDTO via `bettingOfferDTO.outcomeId`, rebuild hierarchical Outcome using OutcomeBuilder

### Experiments & Notes
- The entity mismatch was confirmed by logs: `EntityStore.notifyEntityChange - MISMATCH! BETTING_OFFER:xxx updated but UI observes OUTCOME:yyy`
- BettingOfferDTO has `outcomeId` field which acts as foreign key to parent OutcomeDTO
- OutcomeBuilder.build() reconstructs hierarchical Outcome with all nested BettingOffers from EntityStore

### Useful Files / Links
- [LiveMatchesPaginator.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/LiveMatchesPaginator.swift) - Added subscribeToBettingOfferAsOutcomeUpdates()
- [PreLiveMatchesPaginator.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/PreLiveMatchesPaginator.swift) - Added subscribeToBettingOfferAsOutcomeUpdates()
- [MatchDetailsManager.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/MatchDetailsManager.swift) - Added subscribeToBettingOfferAsOutcomeUpdates()
- [EveryMatrixEventsProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixEventsProvider.swift) - Added provider method
- [EventsProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/EventsProvider.swift) - Added protocol declaration
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift) - Added public entry point
- [OutcomeItemViewModel.swift](../../BetssonCameroonApp/App/ViewModels/TallOddsMatchCard/OutcomeItemViewModel.swift) - Uses new subscription
- [Plan file](~/.claude/plans/misty-wondering-turing.md) - Detailed implementation plan

### Next Steps
1. ~~Build and test BetssonCameroonApp to verify compilation~~ Done
2. ~~Test real-time odds updates with live matches~~ Done - working correctly
3. **Fix paginator/manager lookup**: Consider tracking which paginator owns which bettingOfferId, or using a registry pattern
4. **Fix sport switching issue**: Ensure subscriptions are properly cancelled and recreated when sport changes, or implement subscription lifecycle tied to paginator lifecycle
5. Consider adding `bettingOfferExists(id:)` method to paginators similar to `outcomeExists(id:)`
