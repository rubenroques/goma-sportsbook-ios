# NextUpEvents Outcome Updates End-to-End Data Flow Analysis

## Overview

This document provides a comprehensive analysis of how outcome updates flow from WebSocket messages through the EveryMatrix provider to the UI components in the NextUpEvents feature.

## Data Flow Architecture

### 1. WebSocket → EntityStore

**Entry Point**: `EveryMatrixConnector` (WebSocket connection)
- Receives WAMP messages with aggregator responses
- Messages contain entity updates (CREATE, UPDATE, DELETE operations)

**Processing**: `EveryMatrix.ResponseParser`
- Parses `AggregatorResponse` containing entity records
- Handles different change types:
  - `CREATE`: New entities added to store
  - `UPDATE`: Existing entities updated with changed properties
  - `DELETE`: Entities removed from store

**Storage**: `EveryMatrix.EntityStore`
- Central storage for all flat entities (DTOs)
- Maintains publishers for individual entity observations
- Key methods:
  - `store<T: Entity>(_ entity: T)`: Stores entity and notifies observers
  - `updateEntity(type:id:changedProperties:)`: Updates entity and notifies observers
  - `observeOutcome(id: String) -> AnyPublisher<OutcomeDTO?, Never>`: Returns publisher for outcome updates

### 2. PreLiveMatchesPaginator Subscription Management

**Purpose**: Manages pre-live matches subscription and provides entity-level subscriptions

**Key Behaviors**:
- `subscribe()`: Creates WebSocket subscription for match lists
- Only emits `SubscribableContent<[EventsGroup]>` when match list structure changes (matches added/removed)
- Does NOT emit for individual entity updates (odds, markets, outcomes)

**Individual Entity Subscriptions**:
```swift
func subscribeToOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome?, ServiceProviderError> {
    return store.observeOutcome(id: id)
        .compactMap { outcomeDTO -> EveryMatrix.Outcome? in
            // Build hierarchical outcome from DTO
            return EveryMatrix.OutcomeBuilder.build(from: outcomeDTO, store: self.store)
        }
        .compactMap { outcome -> Outcome? in
            // Map to domain model
            return EveryMatrixModelMapper.outcome(fromInternalOutcome: outcome)
        }
        .setFailureType(to: ServiceProviderError.self)
        .eraseToAnyPublisher()
}
```

### 3. Provider Layer Integration

**EveryMatrixEventsProvider**:
```swift
func subscribeToEventOnListsOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome?, ServiceProviderError> {
    guard let paginator = prelivePaginator else {
        return Fail(error: ServiceProviderError.errorMessage(message: "Paginator not active"))
            .eraseToAnyPublisher()
    }
    
    // Delegate to paginator's outcome subscription method
    return paginator.subscribeToOutcomeUpdates(withId: id)
}
```

### 4. UI Layer Subscription Chain

#### NextUpEventsViewController
- Creates and manages `NextUpEventsViewModel`
- Handles page navigation between market groups
- Does NOT directly subscribe to outcome updates

#### NextUpEventsViewModel
- Subscribes to pre-live matches via `subscribePreLiveMatches`
- Creates `MarketGroupCardsViewModel` instances for each market type
- Passes matches to child view models but does NOT subscribe to individual outcomes

#### MarketGroupCardsViewModel
- Receives matches from parent
- Creates `TallOddsMatchCardViewModel` instances with initial data
- Does NOT subscribe to outcome updates (relies on initial data only)

#### TallOddsMatchCardViewModel
- Contains child view models including `MarketOutcomesMultiLineViewModel`
- Publishes updates via subjects but does NOT subscribe to real-time updates
- Static after creation with initial data

#### MarketOutcomesMultiLineViewModel
- Aggregates `MarketOutcomesLineViewModel` instances
- Each line contains `OutcomeItemViewModel` instances
- Does NOT subscribe to outcome updates

#### OutcomeItemViewModel (The Key Component)
- **This is where outcome subscriptions SHOULD happen**
- Has the infrastructure to subscribe:
```swift
private func setupOutcomeSubscription() {
    servicesProvider.subscribeToEventOnListsOutcomeUpdates(withId: outcomeId)
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { /* handle errors */ },
            receiveValue: { [weak self] serviceProviderOutcome in
                self?.processOutcomeUpdate(serviceProviderOutcome)
            }
        )
        .store(in: &cancellables)
}
```

## Current Issues

### 1. Production ViewModels Not Creating OutcomeItemViewModel

The production implementation of `TallOddsMatchCardViewModel` creates `MarketOutcomesMultiLineViewModel` with static data. The outcomes are not individually subscribing to updates because:

1. `MarketOutcomesLineViewModel` is created with static outcome data
2. Individual `OutcomeItemViewModel` instances (which have the subscription logic) are not being created
3. The UI components receive initial data but no real-time updates

### 2. Missing Connection in View Model Chain

The chain breaks at `MarketOutcomesMultiLineViewModel`:
- It receives line view models but doesn't create individual outcome view models
- The `OutcomeItemView` components in GomaUI are not receiving view models that subscribe to updates

### 3. Optimization Preventing Updates

In `PreLiveMatchesPaginator.handleSubscriptionContent`:
```swift
case .updatedContent(let response):
    // OPTIMIZATION: Only rebuild EventsGroups if match list structure changes
    let matchIdsBeforeUpdate = Set(store.getAll(EveryMatrix.MatchDTO.self).map { $0.id })
    
    // Parse and store the updated entities
    EveryMatrix.ResponseParser.parseAndStore(response: response, in: store)
    
    let matchIdsAfterUpdate = Set(store.getAll(EveryMatrix.MatchDTO.self).map { $0.id })
    
    // Check if match list structure changed
    if matchIdsBeforeUpdate != matchIdsAfterUpdate {
        let eventsGroups = buildEventsGroups()
        return .contentUpdate(content: eventsGroups)
    }
    
    // Only content changed (odds, markets, etc.), don't emit any update
    return nil
```

This optimization is correct - the list subscription should only emit when the list structure changes. Individual entity updates should flow through entity-specific subscriptions.

## Solution

### 1. Create OutcomeItemViewModel Instances

Modify the view model creation chain to ensure `OutcomeItemViewModel` instances are created for each outcome. This is where the subscription logic lives.

### 2. Wire Up View Models Properly

Ensure that:
1. `MarketOutcomesMultiLineViewModel` creates and manages individual outcome view models
2. These view models are passed to the UI components
3. The UI components bind to the view model publishers for real-time updates

### 3. Verify EntityStore Updates

Add logging to confirm:
1. WebSocket messages are received and parsed
2. EntityStore is updating individual entities
3. Entity publishers are emitting updates
4. View models are receiving these updates

## Debugging Steps

1. **Verify WebSocket Updates**: Add logging in `ResponseParser` to confirm outcome updates are received
2. **Check EntityStore**: Log when `observeOutcome` publishers emit values
3. **Trace Subscription Chain**: Log at each level to see where subscriptions are created/missing
4. **Monitor UI Updates**: Confirm which components are receiving real-time updates

## Summary

The infrastructure for outcome updates exists and is well-designed:
- EntityStore provides reactive individual entity observations
- PreLiveMatchesPaginator correctly separates list updates from entity updates
- OutcomeItemViewModel has the subscription logic

The issue is that the production view models are not creating the individual outcome view models that would subscribe to these updates. The solution is to complete the view model chain by ensuring OutcomeItemViewModel instances are created and wired up properly.