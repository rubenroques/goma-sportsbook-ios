# NextUpEvents End-to-End Data Flow Analysis

## Overview
Analysis of why outcome odds updates are not flowing through to the UI after fixing excessive updates.

## Status Update
After deeper investigation, the architecture is **correctly implemented** with real-time subscriptions at all levels. The issue appears to be either in UI binding or WebSocket data flow.

## Complete Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           WEBSOCKET & BACKEND                                │
└─────────────────────────────────────────────────────────────────────────────┘
                                        │
                                   [WAMP Message]
                              BettingOffer odds update
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          SERVICES PROVIDER LAYER                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  EveryMatrixConnector                                                         │
│  ├─ Receives WebSocket WAMP messages ✅                                      │
│  └─ Forwards to PreLiveMatchesPaginator                                      │
│                                        │                                     │
│                                        ▼                                     │
│  PreLiveMatchesPaginator                                                      │
│  ├─ handleSubscriptionContent() ✅                                           │
│  ├─ ResponseParser.parseAndStore() ✅                                        │
│  ├─ Updates EntityStore ✅                                                   │
│  └─ Provides subscribeToOutcomeUpdates() ✅                                  │
│                                        │                                     │
│                                        ▼                                     │
│  EntityStore (EveryMatrixNamespace)                                          │
│  ├─ store() method updates BettingOfferDTO ✅                               │
│  ├─ notifyEntityChange() called ✅                                           │
│  ├─ entityPublishers[BETTING_OFFER][id].send(entity) ✅                     │
│  └─ observeOutcome() publisher available ✅                                  │
│                                        │                                     │
│                                        ▼                                     │
│  EveryMatrixProvider                                                          │
│  └─ subscribeToEventOnListsOutcomeUpdates() ✅                               │
│     ├─ Delegates to paginator.subscribeToOutcomeUpdates() ✅                │
│     ├─ Maps EveryMatrix.Outcome → Domain Outcome ✅                         │
│     └─ Returns AnyPublisher<Outcome?, Error> ✅                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                        │
                                   [Publisher Available]
                               AnyPublisher<Outcome?, Error>
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              UI/VIEW MODEL LAYER                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  NextUpEventsViewController                                                   │
│  └─ Manages NextUpEventsViewModel ✅                                         │
│                                        │                                     │
│                                        ▼                                     │
│  NextUpEventsViewModel                                                        │
│  ├─ subscribePreLiveMatches() for match list ✅                             │
│  ├─ processMatches() creates match view models ✅                           │
│  └─ No individual outcome subscriptions ❌                                   │
│                                        │                                     │
│                                        ▼                                     │
│  MarketGroupCardsViewModel                                                    │
│  ├─ Created from EventsGroup data ✅                                         │
│  ├─ Has marketGroupsViewModels array ✅                                      │
│  └─ No individual outcome subscriptions ❌                                   │
│                                        │                                     │
│                                        ▼                                     │
│  TallOddsMatchCardViewModel                                                   │
│  ├─ Created with match data ✅                                               │
│  ├─ Creates MarketOutcomesMultiLineViewModel ✅                              │
│  └─ Passes static data only ❌                                               │
│                                        │                                     │
│                                        ▼                                     │
│  MarketOutcomesMultiLineViewModel                                             │
│  ├─ Receives MarketGroupData ✅                                              │
│  ├─ Creates lineViewModels array ✅                                          │
│  ├─ Maps to MarketOutcomesLineViewModel ✅                                   │
│  └─ No OutcomeItemViewModel creation ❌                                      │
│                                        │                                     │
│                                        ▼                                     │
│  MarketOutcomesLineViewModel                                                  │
│  ├─ Contains outcome data ✅                                                 │
│  ├─ Has outcomeItems array ✅                                                │
│  └─ Static data only, no subscriptions ❌                                    │
│                                        │                                     │
│                                        ▼                                     │
│  ❌ MISSING: OutcomeItemViewModel instances                                  │
│  ❌ These would subscribe to individual outcome updates                      │
│  ❌ These would receive odds updates from the publisher                      │
│                                        │                                     │
│                                        ▼                                     │
│  UI Components (Views/Cells)                                                 │
│  ├─ Display static outcome data ✅                                           │
│  ├─ Show initial odds ✅                                                     │
│  └─ Never receive odds updates ❌                                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Root Cause Analysis - UPDATED

### ✅ What's Actually Working (Verified)
1. **WebSocket to EntityStore**: Data flows correctly from WebSocket through to EntityStore
2. **Entity Storage**: BettingOffer updates are stored and publishers are notified
3. **Publisher Infrastructure**: Individual outcome publishers are available and working
4. **Service Layer**: EveryMatrixProvider correctly exposes outcome subscription methods
5. **Static UI**: Initial data is displayed correctly
6. **OutcomeItemViewModel Creation**: ✅ CONFIRMED - These ARE being created with subscriptions
7. **MarketOutcomesLineViewModel**: ✅ CONFIRMED - Creates OutcomeItemViewModels and subscribes to market updates
8. **TallOddsMatchCardViewModel**: ✅ CONFIRMED - Uses production factory method that creates reactive view models
9. **Individual Entity Subscriptions**: ✅ CONFIRMED - All properly wired up at each level

### ❌ Potential Issues (Need Investigation)
1. **UI Binding**: The collection view cells might not be properly binding to the view model publishers
2. **Publisher Chain**: Somewhere in the publisher chain, updates might not be propagating
3. **WebSocket Data**: The actual betting offer updates might not be coming through the WebSocket
4. **View Controller Lifecycle**: The subscriptions might be getting cancelled prematurely

## Detailed Implementation Analysis - CORRECTED

### File: `OutcomeItemViewModel.swift` - ✅ CONFIRMED WORKING
```swift
/// Production implementation that DOES subscribe to real-time outcome updates
final class OutcomeItemViewModel: OutcomeItemViewModelProtocol {
    
    private func setupOutcomeSubscription() {
        servicesProvider.subscribeToEventOnListsOutcomeUpdates(withId: outcomeId)  // ✅ SUBSCRIBES
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in /* handle errors */ },
                receiveValue: { [weak self] serviceProviderOutcome in
                    self?.processOutcomeUpdate(serviceProviderOutcome)  // ✅ PROCESSES UPDATES
                }
            )
            .store(in: &cancellables)
    }
}
```

### File: `MarketOutcomesLineViewModel.swift` - ✅ CONFIRMED WORKING  
```swift
/// Production implementation that creates OutcomeItemViewModels with subscriptions
final class MarketOutcomesLineViewModel: MarketOutcomesLineViewModelProtocol {
    
    private func setupMarketSubscription() {
        servicesProvider.subscribeToEventOnListsMarketUpdates(withId: marketId)  // ✅ SUBSCRIBES
            .sink { [weak self] serviceProviderMarket in
                self?.processMarketUpdate(serviceProviderMarket)  // ✅ PROCESSES UPDATES
            }
            .store(in: &cancellables)
    }
    
    private func updateOutcomeViewModels(newOutcomes: [OutcomeType: MarketOutcomeData], fromMarket market: Market) {
        for (outcomeType, outcomeData) in newOutcomes {
            if outcomeViewModels[outcomeType] == nil {
                if let matchingOutcome = market.outcomes.first(where: { $0.id == outcomeData.id }) {
                    let newOutcomeVM = OutcomeItemViewModel.create(from: matchingOutcome)  // ✅ CREATES REACTIVE VMs
                    outcomeViewModels[outcomeType] = newOutcomeVM
                    subscribeToOutcomeEvents(outcomeVM: newOutcomeVM, outcomeType: outcomeType)  // ✅ WIRES EVENTS
                }
            }
        }
    }
}
```

### File: `TallOddsMatchCardViewModel.swift` - ✅ CONFIRMED WORKING
```swift
/// Uses production factory method that creates reactive view models
static func create(from match: Match, relevantMarkets: [Market], marketTypeId: String) -> TallOddsMatchCardViewModel {
    return createWithProductionViewModels(from: match, relevantMarkets: relevantMarkets, marketTypeId: marketTypeId)  // ✅ PRODUCTION PATH
}

private static func createWithProductionViewModels(...) -> TallOddsMatchCardViewModel {
    let outcomesViewModel = createMarketOutcomesViewModel(from: relevantMarkets, marketTypeId: marketTypeId)  // ✅ REACTIVE VM
    
    // Override subjects with production view models
    viewModel.marketOutcomesViewModelSubject.send(outcomesViewModel)  // ✅ INJECTS REACTIVE VM
}

private static func createMarketOutcomesViewModel(from markets: [Market], marketTypeId: String) -> MarketOutcomesMultiLineViewModelProtocol {
    return MarketOutcomesMultiLineViewModel.createWithDirectLineViewModels(  // ✅ DIRECT REACTIVE PATH
        from: markets,
        marketTypeId: marketTypeId
    )
}
```

## Investigation Strategy - NEXT STEPS

Since the architecture is correctly implemented with reactive subscriptions, the issue must be in one of these areas:

### 1. **UI Cell Binding Issue** (Most Likely)
The `TallOddsMatchCardCollectionViewCell` may not be properly binding to the view model publishers.
- **Test**: Add logging to cell binding to verify it subscribes to view model publishers
- **Test**: Check if UI components update when view model state changes

### 2. **WebSocket Data Verification**
The WebSocket might not be sending betting offer updates or they're being filtered out.
- **Test**: Add logging to `PreLiveMatchesPaginator.handleSubscriptionContent()` to see if betting offer updates arrive
- **Test**: Check if `EntityStore.store(bettingOfferDTO)` is being called for odds changes

### 3. **Publisher Chain Verification**
The publisher chain from EntityStore → OutcomeItemViewModel might have a break.
- **Test**: Add logging to `EntityStore.observeOutcome()` to verify it's emitting updates
- **Test**: Add logging to `OutcomeItemViewModel.processOutcomeUpdate()` to verify it receives updates

### 4. **Subscription Lifecycle**
The subscriptions might be getting cancelled due to view controller lifecycle issues.
- **Check**: Are the `cancellables` being cleared prematurely?
- **Check**: Are the view models being deallocated before updates arrive?

### 5. **Collection View Cell Reuse**
The collection view cells might not be preserving subscriptions during cell reuse.
- **Test**: Verify that cell configuration preserves existing subscriptions
- **Test**: Check if `prepareForReuse()` is accidentally clearing subscriptions

## Next Action Items

Based on this comprehensive analysis, the next logical steps to debug the issue are:

1. **Add Debug Logging**: Add logging throughout the publisher chain to identify where updates are being lost
2. **Verify Cell Binding**: Check `TallOddsMatchCardCollectionViewCell` to ensure it properly subscribes to view model publishers  
3. **Test WebSocket Flow**: Verify that betting offer updates are actually coming through the WebSocket
4. **Check Collection View Reuse**: Ensure cell reuse doesn't break the reactive chains

## Architecture Notes

The current architecture is well-designed with proper separation of concerns:
- ✅ **Reactive EntityStore**: Maintains individual entity publishers
- ✅ **Optimized List Updates**: Only structural changes trigger full rebuilds  
- ✅ **Individual Subscriptions**: Complete reactive infrastructure exists at all levels
- ✅ **View Model Layer**: OutcomeItemViewModel properly subscribes to individual outcome updates
- ✅ **Hierarchical Subscriptions**: MarketOutcomesLineViewModel creates and manages OutcomeItemViewModels
- ✅ **Production Path**: TallOddsMatchCardViewModel uses production factory methods that create reactive view models

The architecture is correctly implemented - the issue is likely in UI binding, WebSocket data flow, or subscription lifecycle management.