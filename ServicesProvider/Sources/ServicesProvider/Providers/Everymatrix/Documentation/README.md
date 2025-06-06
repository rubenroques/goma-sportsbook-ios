# EveryMatrix Provider Documentation

Welcome to the EveryMatrix provider documentation! This directory contains detailed technical documentation for implementing granular updates in the sports betting application.

## 📁 Documentation Structure

### 🏗️ Implementation Guides

- **[granular-updates-implementation.md](./granular-updates-implementation.md)**
  - Complete development diary of Phase 1 implementation
  - Architecture decisions and design patterns
  - Code examples and technical details
  - Performance benefits and next steps

### 📡 Data Analysis

- **[websocket-message-analysis.md](./websocket-message-analysis.md)**
  - Real WebSocket message captures from EveryMatrix
  - Message pattern analysis (UPDATE, CREATE, DELETE)
  - Frequency analysis and performance implications
  - UI update strategy recommendations

## 🎯 Project Overview

**Goal**: Implement granular UI updates for betting odds without full collection view reloads

**Problem**: When a single betting offer changes odds, the entire collection view reloads, causing poor UX

**Solution**: Leverage EveryMatrix's existing WebSocket granular updates to update only specific UI cells

## 📊 Current Status

### ✅ Phase 1 Complete - Model Updates
- Enhanced `AggregatorResponse` to handle UPDATE/CREATE/DELETE
- Extended `EntityStore` with merge and delete capabilities  
- Updated `ResponseParser` for change record processing
- Added type-safe change models (`ChangeRecord`, `ChangeType`)

### 🚧 Phase 2 - Observable EntityStore (Next)
- Add change notification publishers to EntityStore
- Implement entity-specific observation methods
- Create publisher lifecycle management

### 📱 Phase 3 - UI Integration (Future)
- Update provider methods to support granular subscriptions
- Implement cell-level change observing
- Add smooth animations for odds updates

## 🔧 Key Components

### Models (`EveryMatrixNamespace.swift`)
```swift
// Enhanced entity record with change support
enum EntityRecord {
    case sport(SportDTO)
    case changeRecord(ChangeRecord)  // NEW
}

// Change tracking
struct ChangeRecord {
    let changeType: ChangeType       // CREATE/UPDATE/DELETE
    let entityType: String
    let id: String
    let changedProperties: [String: AnyCodable]?
}
```

### EntityStore Extensions
```swift
// NEW methods for change handling
func updateEntity(type: String, id: String, changedProperties: [String: AnyCodable])
func deleteEntity(type: String, id: String)
private func mergeChangedProperties(entity: Entity, changes: [String: AnyCodable])
```

### ResponseParser Updates
```swift
// NEW change record processing
case .changeRecord(let changeRecord):
    handleChangeRecord(changeRecord, in: store)
```

## 📈 Performance Benefits

- **Network**: Only changed fields transmitted (not full entities)
- **CPU**: No collection view reloads, only targeted cell updates  
- **Memory**: In-place updates via property merging
- **UX**: Smooth animations, preserved scroll state

## 🔗 Related Code

### Provider Interface
- `EveryMatrixProvider.subscribeToEventOnListsMarketUpdates` (Phase 2 target)
- `EveryMatrixProvider.subscribeToEventOnListsOutcomeUpdates` (Phase 2 target)

### Data Flow
1. WebSocket → `AggregatorResponse` → `ResponseParser` → `EntityStore`
2. EntityStore → Publishers (Phase 2) → ViewModels → UI

### UI Integration Points
- Collection view cells observing specific outcomes
- Market group headers watching market changes
- Match cards monitoring betting offer counts

## 🧪 Testing Strategy

### Unit Tests (Phase 2)
- EntityStore change notification accuracy
- Property merging correctness
- Publisher lifecycle management

### Integration Tests (Phase 3)  
- End-to-end WebSocket → UI update flow
- Performance benchmarks vs full reload
- Memory leak detection with many publishers

## 💡 Implementation Notes

### Design Decisions
- **Backward Compatibility**: No breaking changes to existing flows
- **Type Safety**: Strong typing with Codable throughout
- **Thread Safety**: Concurrent dispatch queue for EntityStore
- **Memory Efficiency**: JSON-based property merging

### Future Enhancements
- **Conflict Resolution**: Handle out-of-order updates with timestamps
- **Batch Updates**: Optimize multiple simultaneous changes
- **Selective Subscriptions**: Fine-grained entity filtering
- **Offline Support**: Cache and replay changes when reconnected

---

**Contributing**: When adding new features or fixes, please update the relevant documentation files and include real WebSocket examples where applicable.

**Questions?** Check the implementation diary for detailed context and decision rationale.