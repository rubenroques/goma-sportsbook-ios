# Real-Time Subscription Fix for Market Outcomes

## Date: June 10, 2025

## Problem
The TallOddsMatchCard component was not showing real-time odds updates. Investigation revealed that while the view model architecture was properly designed to support real-time updates through a chain of subscriptions (TallOddsMatchCardViewModel → MarketOutcomesMultiLineViewModel → MarketOutcomesLineViewModel → OutcomeItemViewModel), the actual subscriptions were not being activated.

## Root Cause
1. **MarketOutcomesLineViewModel**: The `setupMarketSubscription()` call was commented out in the initializer (line 43), preventing market-level subscriptions from being established.

2. **TallOddsMatchCardViewModel**: Was using a factory pattern that created view models from static `MarketGroupData` instead of using the production pattern that creates view models directly from `Market` objects with active subscriptions.

## Solution

### 1. Activated Market Subscriptions
In `MarketOutcomesLineViewModel.swift`, uncommented the `setupMarketSubscription()` call:

```swift
init(
    marketId: String,
    initialDisplayState: MarketOutcomesDisplayState
) {
    self.marketId = marketId
    self.marketStateSubject = CurrentValueSubject(initialDisplayState)
    self.oddsChangeEventSubject = PassthroughSubject()
    
    // Create initial outcome view models
    createOutcomeViewModels(from: initialDisplayState)
    
    // Setup market subscription
    setupMarketSubscription() // ← This was commented out
}
```

### 2. Updated TallOddsMatchCardViewModel Factory Pattern
Added a new production factory method that creates view models with real-time subscriptions:

```swift
private static func createWithProductionViewModels(
    from match: Match, 
    relevantMarkets: [Market], 
    marketTypeId: String
) -> TallOddsMatchCardViewModel {
    // ... create header and market info data ...
    
    // Create child view models with real subscriptions
    let headerViewModel = createMatchHeaderViewModel(from: matchHeaderData)
    let marketInfoViewModel = createMarketInfoLineViewModel(from: marketInfoData)
    let outcomesViewModel = createMarketOutcomesViewModel(from: relevantMarkets, marketTypeId: marketTypeId)
    
    // ... create view model and update subjects ...
}
```

### 3. Added Overloaded Factory Method
Created a new `createMarketOutcomesViewModel` method that uses the production pattern:

```swift
private static func createMarketOutcomesViewModel(
    from markets: [Market], 
    marketTypeId: String
) -> MarketOutcomesMultiLineViewModelProtocol {
    return MarketOutcomesMultiLineViewModel.createWithDirectLineViewModels(
        from: markets,
        marketTypeId: marketTypeId
    )
}
```

## View Model Subscription Chain
After the fix, the subscription chain works as follows:

1. **OutcomeItemViewModel** subscribes to individual outcome updates via `subscribeToEventOnListsOutcomeUpdates`
2. **MarketOutcomesLineViewModel** subscribes to market updates via `subscribeToEventOnListsMarketUpdates` and manages child OutcomeItemViewModels
3. **MarketOutcomesMultiLineViewModel** manages multiple line view models
4. **TallOddsMatchCardViewModel** coordinates all child view models

## Testing
Created `TallOddsRealTimeTest.swift` to verify:
- View models are properly created with the production pattern
- Line view models can create outcome view models
- The subscription chain is properly established

## Impact
- Real-time odds updates now flow through the entire component hierarchy
- Odds changes trigger visual updates in the UI
- Market suspensions and outcome availability changes are reflected immediately
- The architecture supports efficient updates without recreating views

## Next Steps
1. Monitor performance with real-time updates active
2. Add integration tests for odds change animations
3. Implement reconnection logic for dropped subscriptions
4. Add logging for subscription lifecycle events