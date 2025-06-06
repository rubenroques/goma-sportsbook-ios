# Phase 2: Observable EntityStore Implementation

## 🎯 Objective
Add reactive change notifications to EntityStore so UI components can subscribe to specific entity updates without polling or full reloads.

---

## 📋 Implementation Checklist

### ✅ Prerequisites (Completed in Phase 1)
- [x] EntityStore supports UPDATE/DELETE/CREATE operations
- [x] Property merging via `updateEntity()` method
- [x] Entity deletion via `deleteEntity()` method
- [x] Change record processing in ResponseParser

### 🚧 Phase 2 Tasks

#### Task 2.1: Add Change Notification Infrastructure
- [ ] Add Combine import to EveryMatrixNamespace.swift
- [ ] Create publishers dictionary in EntityStore
- [ ] Add cleanup mechanism for unused publishers
- [ ] Implement thread-safe publisher management

#### Task 2.2: Implement Entity Observation Methods
- [ ] Add generic `observeEntity<T: Entity>(_:id:)` method
- [ ] Add convenience methods for specific entity types
- [ ] Handle initial value emission (current entity state)
- [ ] Implement proper error handling for missing entities

#### Task 2.3: Integrate with Existing Operations
- [ ] Emit notifications in `store<T: Entity>(_:)` method
- [ ] Emit notifications in `updateEntity(type:id:changedProperties:)` method
- [ ] Emit deletion notifications in `deleteEntity(type:id:)` method
- [ ] Handle bulk operations (`store([T])`)

#### Task 2.4: Provider Method Implementation
- [ ] Implement `subscribeToEventOnListsMarketUpdates(withId:)`
- [ ] Implement `subscribeToEventOnListsOutcomeUpdates(withId:)`
- [ ] Add subscription lifecycle management
- [ ] Map internal models to domain models

#### Task 2.5: Memory Management
- [ ] Implement publisher cleanup strategy
- [ ] Add weak reference handling for observers
- [ ] Create subscription management utilities
- [ ] Add memory leak prevention

#### Task 2.6: Testing
- [ ] Unit tests for entity observation
- [ ] Integration tests with WebSocket updates
- [ ] Memory leak tests
- [ ] Concurrent access tests

---

## 🔧 Technical Implementation Details

### 2.1 Enhanced EntityStore Architecture

```swift
import Combine

class EntityStore: ObservableObject {
    @Published private var entities: [String: [String: any Entity]] = [:]
    private let queue = DispatchQueue(label: "entity.store.queue", attributes: .concurrent)
    
    // NEW: Publishers for entity change notifications
    private var entityPublishers: [String: [String: PassthroughSubject<any Entity?, Never>]] = [:]
    private var publisherCleanupQueue = DispatchQueue(label: "entity.publisher.cleanup")
    
    // Existing methods...
    
    // NEW: Entity observation methods
    func observeEntity<T: Entity>(_ type: T.Type, id: String) -> AnyPublisher<T?, Never>
    func observeMarket(id: String) -> AnyPublisher<MarketDTO?, Never>
    func observeOutcome(id: String) -> AnyPublisher<OutcomeDTO?, Never>
    func observeBettingOffer(id: String) -> AnyPublisher<BettingOfferDTO?, Never>
    
    // NEW: Publisher management
    private func getOrCreatePublisher(entityType: String, id: String) -> PassthroughSubject<any Entity?, Never>
    private func cleanupUnusedPublishers()
    private func notifyEntityChange<T: Entity>(_ entity: T?)
}
```

### 2.2 Core Observation Method

```swift
func observeEntity<T: Entity>(_ type: T.Type, id: String) -> AnyPublisher<T?, Never> {
    return queue.sync { [weak self] in
        guard let self = self else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        // Get current entity value
        let currentEntity = self.get(type, id: id)
        
        // Get or create publisher for this entity
        let publisher = self.getOrCreatePublisher(entityType: T.rawType, id: id)
        
        // Return current value + future changes
        return Just(currentEntity)
            .merge(with: publisher.compactMap { $0 as? T })
            .eraseToAnyPublisher()
    }
}
```

### 2.3 Notification Integration

```swift
// Enhanced store method with notifications
func store<T: Entity>(_ entity: T) {
    queue.async(flags: .barrier) { [weak self] in
        let type = T.rawType
        if self?.entities[type] == nil {
            self?.entities[type] = [:]
        }
        self?.entities[type]?[entity.id] = entity
        
        // NEW: Notify observers
        self?.notifyEntityChange(entity)
    }
}

// Enhanced update method with notifications
func updateEntity(type entityType: String, id: String, changedProperties: [String: AnyCodable]) {
    queue.async(flags: .barrier) { [weak self] in
        guard let existingEntity = self?.entities[entityType]?[id] else {
            print("Cannot update entity \(entityType):\(id) - entity not found")
            return
        }
        
        let updatedEntity = self?.mergeChangedProperties(entity: existingEntity, changes: changedProperties)
        
        if let updatedEntity = updatedEntity {
            self?.entities[entityType]?[id] = updatedEntity
            
            // NEW: Notify observers of the change
            self?.notifyEntityChange(updatedEntity)
        }
    }
}

// Enhanced delete method with notifications
func deleteEntity(type entityType: String, id: String) {
    queue.async(flags: .barrier) { [weak self] in
        self?.entities[entityType]?[id] = nil
        
        // NEW: Notify observers of deletion
        self?.notifyEntityChange(nil as (any Entity)?)
    }
}
```

### 2.4 Publisher Management

```swift
private func getOrCreatePublisher(entityType: String, id: String) -> PassthroughSubject<any Entity?, Never> {
    if entityPublishers[entityType] == nil {
        entityPublishers[entityType] = [:]
    }
    
    if let existingPublisher = entityPublishers[entityType]?[id] {
        return existingPublisher
    }
    
    let newPublisher = PassthroughSubject<any Entity?, Never>()
    entityPublishers[entityType]?[id] = newPublisher
    
    return newPublisher
}

private func notifyEntityChange<T: Entity>(_ entity: T?) {
    guard let entity = entity else {
        // Handle deletion case
        return
    }
    
    let entityType = type(of: entity).rawType
    let id = entity.id
    
    entityPublishers[entityType]?[id]?.send(entity)
}

private func cleanupUnusedPublishers() {
    publisherCleanupQueue.async { [weak self] in
        // Remove publishers with no active subscribers
        // Implementation depends on subscription tracking strategy
    }
}
```

---

## 🔗 Provider Integration

### 2.5 EveryMatrixProvider Updates

```swift
// File: EveryMatrixProvider.swift

func subscribeToEventOnListsMarketUpdates(withId id: String) -> AnyPublisher<Market?, ServiceProviderError> {
    // Ensure we have an active subscription to the parent topic
    guard connector.hasActiveSubscription() else {
        return Fail(error: ServiceProviderError.connectionError).eraseToAnyPublisher()
    }
    
    // Get the paginator's entity store
    guard let store = getCurrentEntityStore() else {
        return Fail(error: ServiceProviderError.connectionError).eraseToAnyPublisher()
    }
    
    return store.observeMarket(id: id)
        .compactMap { marketDTO -> Market? in
            guard let marketDTO = marketDTO else { return nil }
            return MarketBuilder.build(from: marketDTO, store: store)
        }
        .map { market -> Market? in
            // Map to domain model using existing mapper
            return EveryMatrixModelMapper.mapMarket(market)
        }
        .setFailureType(to: ServiceProviderError.self)
        .eraseToAnyPublisher()
}

func subscribeToEventOnListsOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome?, ServiceProviderError> {
    guard connector.hasActiveSubscription() else {
        return Fail(error: ServiceProviderError.connectionError).eraseToAnyPublisher()
    }
    
    guard let store = getCurrentEntityStore() else {
        return Fail(error: ServiceProviderError.connectionError).eraseToAnyPublisher()
    }
    
    return store.observeOutcome(id: id)
        .compactMap { outcomeDTO -> Outcome? in
            guard let outcomeDTO = outcomeDTO else { return nil }
            return OutcomeBuilder.build(from: outcomeDTO, store: store)
        }
        .map { outcome -> Outcome? in
            return EveryMatrixModelMapper.mapOutcome(outcome)
        }
        .setFailureType(to: ServiceProviderError.self)
        .eraseToAnyPublisher()
}

// Helper method to get current entity store from active paginator
private func getCurrentEntityStore() -> EntityStore? {
    // Implementation depends on how paginators are managed
    // May need to track active subscriptions
    return currentPaginator?.entityStore
}
```

---

## ⚠️ Important Considerations

### Thread Safety
- All publisher operations must be thread-safe
- Use concurrent dispatch queue for reads, barrier for writes
- Protect publisher dictionary access

### Memory Management
- Publishers should use weak references to avoid retain cycles
- Implement automatic cleanup for unused publishers
- Consider using `eraseToAnyPublisher()` to break reference chains

### Subscription Lifecycle
- Publishers should remain active as long as there are subscribers
- Clean up when parent WebSocket subscription ends
- Handle reconnection scenarios

### Error Handling
- What happens when observing non-existent entities?
- Handle WebSocket disconnections gracefully
- Provide fallback mechanisms for failed observations

---

## 🧪 Testing Strategy

### Unit Tests
```swift
class EntityStoreObservationTests: XCTestCase {
    func testObserveEntityEmitsCurrentValue() {
        // Test that observation immediately emits current entity state
    }
    
    func testObserveEntityEmitsUpdates() {
        // Test that updates trigger emissions
    }
    
    func testObserveEntityEmitsDeletion() {
        // Test that deletions trigger nil emissions
    }
    
    func testPublisherCleanup() {
        // Test that unused publishers are cleaned up
    }
    
    func testConcurrentObservation() {
        // Test multiple subscribers to same entity
    }
}
```

### Integration Tests
```swift
class ProviderObservationIntegrationTests: XCTestCase {
    func testMarketUpdatesEndToEnd() {
        // Test WebSocket → EntityStore → Provider → Domain Model flow
    }
    
    func testOutcomeUpdatesEndToEnd() {
        // Test betting offer odds changes
    }
    
    func testSubscriptionLifecycle() {
        // Test provider method subscription management
    }
}
```

---

## 📊 Success Criteria

### Functional Requirements
- [ ] Market observation returns current state immediately
- [ ] Outcome observation receives real-time odds updates
- [ ] Provider methods work without breaking existing functionality
- [ ] Deletion events properly notify subscribers

### Performance Requirements
- [ ] No memory leaks with long-running subscriptions
- [ ] Publisher creation overhead < 1ms
- [ ] Concurrent observation scales to 100+ entities
- [ ] Cleanup happens within 30 seconds of unsubscription

### Quality Requirements
- [ ] 100% test coverage for new observation methods
- [ ] Thread safety verified under stress testing
- [ ] Error scenarios handled gracefully
- [ ] Documentation updated with usage examples

---

## 🔄 Next Steps After Phase 2

Once Phase 2 is complete, Phase 3 will focus on:
- UI component integration
- Cell-level change subscriptions
- Smooth animations for odds updates
- Performance optimization for high-frequency updates

The foundation built in Phase 2 will enable surgical precision UI updates throughout the application.