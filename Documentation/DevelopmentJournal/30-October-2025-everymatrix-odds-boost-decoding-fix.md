## Date
30 October 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix decoding error in EveryMatrix odds boost stairs API response
- Improve type safety for odds range structures

### Achievements
- [x] Fixed `typeMismatch` decoding error in `getOddsBoostStairs` API call
- [x] Created proper `OddsRange` struct with `Double` types instead of `String`
- [x] Refactored odds structure into semantic `EventOddsRangeCollection` wrapper
- [x] Made `min` and `max` properties optional for robustness
- [x] Added convenient accessor methods for event odds lookup

### Issues / Bugs Hit
- [x] EveryMatrix API returning numeric values (`1.1`, `9999`) but model expected strings
- [x] Error path: `[...odds, _CodingKey(stringValue: "284443475567742976", intValue: nil), _CodingKey(stringValue: "min", intValue: nil)]`
- [x] Error message: "Expected to decode String but found number instead"

### Key Decisions
- **Wrapped dictionary in `EventOddsRangeCollection`** instead of exposing raw `[String: OddsRange]`
  - Provides better encapsulation and semantic meaning
  - Adds convenient methods: `oddsRange(forEventId:)`, `hasConstraints(forEventId:)`, `eventIds`
- **Made `OddsRange.min` and `OddsRange.max` optional** for defensive decoding
  - API may not always provide both values
  - Prevents crashes if fields are missing
- **Custom Codable implementation** for `EventOddsRangeCollection`
  - Decodes/encodes transparently as dictionary
  - Maintains clean API surface with private storage

### Code Changes

**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/REST/EveryMatrix+OddsBoost.swift`

**Before**:
```swift
struct BonusWalletItem: Codable {
    // ...
    let odds: [String: [String: String]]?  // ❌ Wrong type
}
```

**After**:
```swift
struct BonusWalletItem: Codable {
    // ...
    let odds: EventOddsRangeCollection?  // ✅ Semantic wrapper
}

struct EventOddsRangeCollection: Codable {
    private let ranges: [String: OddsRange]

    func oddsRange(forEventId eventId: String) -> OddsRange?
    var eventIds: [String]
    func hasConstraints(forEventId eventId: String) -> Bool
}

struct OddsRange: Codable {
    let min: Double?  // ✅ Optional Double
    let max: Double?  // ✅ Optional Double
}
```

### Root Cause Analysis

**Problem**: Type mismatch between API contract and Swift model

**API Response**:
```json
"odds": {
  "284443475567742976": {
    "min": 1.1,     // Double
    "max": 9999     // Double (can be Int or Double)
  }
}
```

**Original Model**: Expected nested `[String: [String: String]]`

**Why It Failed**:
- EveryMatrix API returns numeric literals (JSON numbers)
- Swift's `Codable` strictly enforces type matching
- `String` decoder cannot decode JSON numbers directly

**Solution**: Use proper numeric types (`Double`) and wrap in semantic struct

### Testing Notes

Error occurred in: `BetssonCameroonApp/App/Services/BetslipManager.swift`
- Method: `Env.servicesProvider.getOddsBoostStairs`
- Context: Calculating bonus tiers for user's betslip

Expected behavior after fix:
- API response decodes successfully
- `EventOddsRangeCollection` provides clean access to event odds constraints
- BetslipManager can check min/max odds requirements per event

### Useful Files / Links
- [EveryMatrix OddsBoost Models](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/REST/EveryMatrix+OddsBoost.swift)
- [OddsBoost Domain Models](Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/OddsBoost/OddsBoostStairs.swift)
- [EveryMatrix PAM Provider](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixPAMProvider.swift)
- [BetslipManager](BetssonCameroonApp/App/Services/BetslipManager.swift)

### Next Steps
1. Test `getOddsBoostStairs` in BetslipManager with real API call
2. Verify decoding works with various API response scenarios
3. Update BetslipManager to use new `EventOddsRangeCollection` API
4. Consider adding validation logic for odds constraints (min < max, positive values)
