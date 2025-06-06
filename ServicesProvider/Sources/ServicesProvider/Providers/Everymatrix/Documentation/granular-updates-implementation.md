# EveryMatrix Provider - Granular Updates Implementation

## 📅 Development Diary - Phase 1 Complete

**Date**: December 2024  
**Objective**: Implement granular UI updates for betting odds without full collection view reloads  
**Status**: ✅ Phase 1 Complete - Models Updated  

---

## 🎯 The Problem We Solved

Previously, when a single betting offer changed odds (e.g., from 1.79 to 1.82), the entire collection view would reload. This caused:
- Poor user experience with unnecessary UI refreshes
- Performance issues with large event lists
- Loss of scroll position and visual state

**Goal**: Update only the specific UI cell that contains the changed odds.

---

## 🔍 Discovery: WebSocket Update Patterns

Through analysis of live WebSocket messages, we discovered EveryMatrix sends **three types** of messages:

### 1. INITIAL_DUMP (Subscription Start)
```json
{
  "messageType": "INITIAL_DUMP",
  "records": [
    {
      "_type": "BETTING_OFFER",
      "id": "272181284331364608", 
      "odds": 1.7936507,
      // ... full entity data
    }
  ]
}
```

### 2. UPDATE (Real-time Changes)
```json
{
  "messageType": "UPDATE",
  "records": [
    {
      "changeType": "UPDATE",
      "entityType": "BETTING_OFFER",
      "id": "272181284331364608",
      "changedProperties": {
        "odds": 1.7936507,
        "lastChangedTime": 1749227447608
      }
    }
  ]
}
```

### 3. CREATE/DELETE (Entity Lifecycle)
```json
{
  "messageType": "UPDATE",
  "records": [
    {
      "changeType": "DELETE",
      "entityType": "BETTING_OFFER", 
      "id": "272216361174037760"
    },
    {
      "changeType": "CREATE",
      "entityType": "MARKET",
      "id": "272271959988236288",
      "entity": {
        "_type": "MARKET",
        // ... full new entity data
      }
    }
  ]
}
```

**Key Insight**: The system already sends granular field-level updates! We just needed to expose them properly.

---

## 🏗️ Phase 1: Model Architecture Update

### New Models Added

#### 1. ChangeType Enum
```swift
enum ChangeType: String, Codable {
    case create = "CREATE"
    case update = "UPDATE" 
    case delete = "DELETE"
}
```

#### 2. ChangeRecord Structure
```swift
struct ChangeRecord: Codable {
    let changeType: ChangeType
    let entityType: String
    let id: String
    let entity: EntityData?              // For CREATE operations
    let changedProperties: [String: AnyCodable]?  // For UPDATE operations
}
```

#### 3. Enhanced EntityRecord
```swift
enum EntityRecord: Codable {
    // INITIAL_DUMP records (backward compatible)
    case sport(SportDTO)
    case market(MarketDTO)
    case outcome(OutcomeDTO)
    case bettingOffer(BettingOfferDTO)
    // ...
    
    // NEW: UPDATE/DELETE/CREATE records
    case changeRecord(ChangeRecord)
    case unknown(type: String)
}
```

#### 4. AnyCodable Wrapper
```swift
struct AnyCodable: Codable {
    let value: Any
    // Handles Bool, Int, Double, String, nil values
}
```

### Smart Decoding Logic

The new `EntityRecord.init(from decoder:)` detects message type:

```swift
// Check if this is a change record (has changeType)
if container.contains(.changeType) {
    let changeRecord = try ChangeRecord(from: decoder)
    self = .changeRecord(changeRecord)
    return
}

// Otherwise, decode as original entity type (INITIAL_DUMP)
let type = try container.decode(String.self, forKey: .type)
// ... existing entity decoding
```

---

## 🔧 Enhanced EntityStore

### New Methods Added

#### 1. Update Entity (Merge Properties)
```swift
func updateEntity(type entityType: String, id: String, changedProperties: [String: AnyCodable]) {
    // Thread-safe property merging using JSON reflection
    let updatedEntity = mergeChangedProperties(entity: existingEntity, changes: changedProperties)
}
```

#### 2. Delete Entity
```swift
func deleteEntity(type entityType: String, id: String) {
    entities[entityType]?[id] = nil
}
```

#### 3. Property Merging Strategy
Uses JSON-based reflection to merge changed properties:
1. Encode existing entity to JSON
2. Apply changed properties to JSON object
3. Decode back to strongly-typed DTO

**Why JSON reflection?** Swift structs are immutable. This approach allows us to create new instances with updated properties without manual field copying.

---

## 📦 Updated ResponseParser

### New Flow Handling

```swift
switch record {
// INITIAL_DUMP records - store full entities (existing)
case .sport(let dto):
    store.store(dto)

// UPDATE/DELETE/CREATE records - handle changes (NEW)
case .changeRecord(let changeRecord):
    handleChangeRecord(changeRecord, in: store)
}
```

### Change Processing Logic

```swift
switch change.changeType {
case .create:
    // Store full entity from change.entity
    storeEntityData(change.entity, in: store)
    
case .update: 
    // Merge changedProperties with existing entity
    store.updateEntity(type: change.entityType, id: change.id, changedProperties: change.changedProperties)
    
case .delete:
    // Remove entity from store
    store.deleteEntity(type: change.entityType, id: change.id)
}
```

---

## 🎯 What's Next: Phase 2 Preview

### Observable EntityStore (Coming Next)
Add change notification publishers:
```swift
func observeEntity<T: Entity>(_ type: T.Type, id: String) -> AnyPublisher<T?, Never>
func observeMarket(id: String) -> AnyPublisher<MarketDTO?, Never>  
func observeOutcome(id: String) -> AnyPublisher<OutcomeDTO?, Never>
```

### Provider Method Implementation
Enable granular subscriptions:
```swift
func subscribeToEventOnListsMarketUpdates(withId id: String) -> AnyPublisher<Market?, ServiceProviderError>
func subscribeToEventOnListsOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome?, ServiceProviderError>
```

### UI Integration
Cell-level subscriptions:
```swift
// Each cell observes only its specific outcome
viewModel.observeOutcome(outcomeId: "272181284331364608")
    .sink { [weak self] outcome in
        self?.updateOdds(outcome?.bettingOffers.first?.odds)
    }
```

---

## 💡 Key Design Decisions

### 1. Backward Compatibility
- Existing INITIAL_DUMP flow unchanged
- Progressive enhancement approach
- No breaking changes to current subscriptions

### 2. Type Safety
- Strong typing with Swift enums and structs
- Codable compliance throughout
- Runtime type checking for entity merging

### 3. Thread Safety
- All EntityStore operations use concurrent dispatch queue
- Barrier writes for mutations
- Concurrent reads for performance

### 4. Memory Efficiency
- Only changed properties transmitted over WebSocket
- In-place entity updates via merging
- No unnecessary object creation

---

## 🧪 Example Update Flow

1. **WebSocket receives**: Odds change from 1.79 → 1.82
2. **ResponseParser**: Detects UPDATE changeRecord
3. **EntityStore**: Merges `{"odds": 1.82}` with existing BettingOfferDTO
4. **Publisher** (Phase 2): Emits updated BettingOfferDTO to observers  
5. **UI Cell** (Phase 3): Updates only the odds label with animation

**Result**: Surgical precision updates! 🎯

---

## 📊 Performance Benefits

- **Network**: Only changed fields transmitted (not full entities)
- **CPU**: No collection view reloads, only targeted cell updates
- **Memory**: In-place updates via property merging
- **UX**: Smooth animations, preserved scroll state

---

## 🔗 Related Files

- **Models**: `EveryMatrixNamespace.swift` (updated)
- **Parser**: `ResponseParser.handleChangeRecord()` (new)
- **Store**: `EntityStore.updateEntity()` (new)
- **Provider**: `EveryMatrixProvider.swift` (Phase 2 target)

---

**Next**: Phase 2 - Observable EntityStore & Change Notifications 🚀