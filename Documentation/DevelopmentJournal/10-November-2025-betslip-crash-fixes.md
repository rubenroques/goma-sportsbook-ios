## Date
10 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix betslip crash when clearing tickets with "clear button"
- Fix EveryMatrix WebSocket JSON serialization crash on property updates

### Achievements
- [x] Fixed betslip array index out of bounds crash in `SportsBetslipViewController`
- [x] Fixed EveryMatrix `__SwiftValue` JSON serialization crash in `EntityStore`
- [x] Implemented safe array subscript pattern for table view data source
- [x] Added JSON-safe value converter for WebSocket property updates

### Issues / Bugs Hit
- [x] Race condition between Combine publishers triggering duplicate table reloads
- [x] `NSJSONSerialization` cannot serialize Swift `()` (Void/empty tuple) type
- [x] `__SwiftValue` bridging error when null values from WebSocket become empty tuples

### Key Decisions
- **Betslip Fix**: Used existing `array[safe: index]` extension with registered default cell fallback
  - Registered `UITableViewCell` with "DefaultCell" identifier for proper table view reuse
  - Changed unsafe subscript `viewModel.currentTickets[indexPath.row]` to safe `viewModel.currentTickets[safe: indexPath.row]`
  - Returns empty cell during race condition window (graceful degradation)

- **EveryMatrix Fix**: Added `jsonSafeValue` computed property to `AnyChange`
  - Converts Swift-only types (`()` empty tuple) to Foundation types (`NSNull()`)
  - Applied at exact point before `NSJSONSerialization.data(withJSONObject:)`
  - Minimal code impact: 1 property addition + 1 line change

### Root Cause Analysis

#### Betslip Crash
**Location**: `SportsBetslipViewController.swift:541`

**Flow**:
1. User taps "Clear Betslip" → `viewModel.clearAllTickets()` called
2. Two separate Combine publishers fire:
   - `ticketsPublisher` (lines 340-354) → calls `reloadData()`
   - `ticketsStatePublisher` (lines 357-363) → calls `reloadData()` again
3. Between the two reloads, data source cleared but UITableView has stale index paths
4. `tableView(_:cellForRowAt:)` called with `indexPath.row = 2` when `currentTickets.count = 0`
5. **CRASH**: `Fatal error: Index out of range`

**Fix**: Safe subscript with guard at line 542:
```swift
guard let ticket = viewModel.currentTickets[safe: indexPath.row] else {
    return tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
}
```

#### EveryMatrix WebSocket Crash
**Location**: `EntityStore.swift:183` → `NSJSONSerialization.data(withJSONObject: json)`

**Flow**:
1. WebSocket sends update: `{ "changedProperties": { "someProperty": null } }`
2. `AnyChange.init(from decoder:)` decodes `null` → stores as `()` (empty tuple) - Line 23
3. `EntityStore.mergeChangedProperties` assigns `value.value` → inserts `()` into JSON dict - Line 179
4. `()` is Swift-only type with no Objective-C equivalent
5. When bridged, becomes `__SwiftValue` wrapper
6. **CRASH**: `'NSInvalidArgumentException', reason: 'Invalid type in JSON write (__SwiftValue)'`

**Fix**: JSON-safe value conversion at line 179:
```swift
// Before: json[key] = value.value  // Unsafe
// After:  json[key] = value.jsonSafeValue  // Safe
```

Added to `AnyChange.swift` (lines 94-115):
```swift
var jsonSafeValue: Any {
    switch value {
    case let int as Int: return int
    case let double as Double: return double
    case let string as String: return string
    case let bool as Bool: return bool
    case let array as [Any]: return array
    case let dict as [String: Any]: return dict
    case is Void: return NSNull()  // Convert () to NSNull
    default: return NSNull()  // Fallback
    }
}
```

### Experiments & Notes
- Verified Plan agent's analysis against actual code - 100% accurate on EveryMatrix crash
- Deep-dived into `AnyChange` decoder to confirm only primitives + `()` are possible values
- Confirmed `EntityStore` is WebSocket-only (REST bypasses it completely per CLAUDE.md)
- Arrays/dicts not decoded by `AnyChange` but added defensive handling anyway

### Useful Files / Links
- [SportsBetslipViewController](BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/SportsBetslipViewController.swift)
- [EntityStore](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/Store/EntityStore.swift)
- [AnyChange](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/WebSocket/Response/AnyChange.swift)
- [EveryMatrix CLAUDE.md](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CLAUDE.md) - Critical architecture context

### Technical Context
- **Betslip**: BetssonCameroonApp modern MVVM-C architecture with GomaUI components
- **EveryMatrix**: Hybrid WebSocket (WAMP) + REST provider with 4-layer model transformation
- **EntityStore**: In-memory reactive store exclusively for WebSocket DTOs (not REST data)
- **AnyChange**: Type-erased wrapper for dynamic property updates from WebSocket

### Next Steps
1. Test betslip clear with 10+ tickets to verify no crash
2. Monitor production for EveryMatrix WebSocket updates with null values
3. Consider consolidating duplicate `reloadData()` calls in betslip (architectural improvement)
4. Document Pattern: Safe subscript + registered default cell for all table view data sources
