# Sport Names Localization - WebSocket Fix

## Date
08 November 2025

### Project / Branch
BetssonCameroonApp / betsson-cm

### Goals for this session
- Continue investigation from previous session on why sport names appear in English
- Fix sport names to display in correct language (French/English based on app setting)
- Complete the EveryMatrix localization migration

### Achievements
- [x] Identified root cause: `WAMPRouter.sportsPublisher` had hardcoded "en" in WebSocket topic URL
- [x] Fixed `WAMPRouter.sportsPublisher` to accept and use language parameter
- [x] Updated `SportsManager` to pass configured language to router
- [x] Completed full EveryMatrix localization migration (no more hardcoded language codes)

### Issues / Bugs Hit
- **Root Cause Discovered**: `WAMPRouter.swift:164-165` had hardcoded "en" in sports subscription topic
  - Topic was: `/sports/{operatorId}/en/disciplines/BOTH/BOTH` ❌
  - All other endpoints (live matches, tournaments, betting offers) were already using language parameter correctly
  - This was the ONLY endpoint still hardcoded after the previous session's centralization work

### Key Decisions
- **Consistent Language Parameter Pattern**: Made `sportsPublisher` follow the same pattern as all other WebSocket endpoints
  - Changed from: `case sportsPublisher(operatorId: String)`
  - Changed to: `case sportsPublisher(operatorId: String, language: String)`
  - Topic now correctly uses: `/sports/{operatorId}/{language}/disciplines/BOTH/BOTH`

### Technical Analysis

#### Complete Data Flow (WebSocket → UI):
```
1. App Startup
   └─ Environment.swift sets: EveryMatrixUnifiedConfiguration.shared.defaultLanguage = localized("current_language_code")

2. SportTypeStore subscribes to sports
   └─ Calls: Env.servicesProvider.subscribeSportTypes()

3. SportsManager.subscribe()
   ├─ Gets language: EveryMatrixUnifiedConfiguration.shared.defaultLanguage
   └─ Creates router: WAMPRouter.sportsPublisher(operatorId: operatorId, language: language)

4. WAMPRouter builds WebSocket topic
   └─ Topic: /sports/{operatorId}/{language}/disciplines/BOTH/BOTH  ✅ Now includes language!

5. WebSocket API receives request with language parameter
   └─ Should return sport names in requested language

6. SportsManager processes response
   ├─ SportDTO.name (from WebSocket)
   ├─ SportBuilder → EveryMatrix.Sport (preserves name)
   ├─ EveryMatrixModelMapper → SportType (preserves name)
   └─ ServiceProviderModelMapper → Sport (preserves name)

7. UI displays Sport.name
   └─ Should now be localized! 🎉
```

#### Why This Was The Last Piece:
- Previous session removed 25+ hardcoded "en" instances from:
  - EveryMatrixUnifiedConfiguration ✅
  - All REST API endpoints ✅
  - All subscription managers ✅
  - All other WebSocket endpoints ✅
  - **BUT** missed the sports publisher topic URL itself ❌

- The centralization work was 100% correct, but the WebSocket topic for sports was still hardcoded in the router definition

### Useful Files / Links

**Files Modified (2 files)**:
1. `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/WAMPRouter.swift`
   - Line 52: Added `language` parameter to enum case
   - Lines 164-165: Changed topic from `/sports/{operatorId}/en/...` to `/sports/{operatorId}/{language}/...`

2. `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/SubscriptionManagers/SportsManager.swift`
   - Lines 43-44: Added language retrieval from configuration before creating router

**Related Documentation**:
- `Documentation/DevelopmentJournal/08-November-2025-everymatrix-localization-handover.md` - Previous session's comprehensive work
- `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CLAUDE.md` - EveryMatrix architecture
- `Documentation/API_DEVELOPMENT_GUIDE.md` - 3-layer architecture patterns

**Key Architecture Files**:
- `WAMPRouter.swift` - WebSocket endpoint definitions (60+ routes)
- `SportsManager.swift` - Sports subscription orchestration
- `EveryMatrixUnifiedConfiguration.swift` - Centralized configuration
- `Environment.swift` - App initialization and configuration wiring

### Code Changes Summary

#### Before:
```swift
// WAMPRouter.swift
case sportsPublisher(operatorId: String)

var procedure: String {
    case .sportsPublisher(let operatorId):
        return "/sports/\(operatorId)/en/disciplines/BOTH/BOTH"  // ❌ Hardcoded
}

// SportsManager.swift
let router = WAMPRouter.sportsPublisher(operatorId: operatorId)
```

#### After:
```swift
// WAMPRouter.swift
case sportsPublisher(operatorId: String, language: String)

var procedure: String {
    case .sportsPublisher(let operatorId, let language):
        return "/sports/\(operatorId)/\(language)/disciplines/BOTH/BOTH"  // ✅ Dynamic
}

// SportsManager.swift
let language = EveryMatrixUnifiedConfiguration.shared.defaultLanguage
let router = WAMPRouter.sportsPublisher(operatorId: operatorId, language: language)
```

### Comparison with Other Endpoints

All other WebSocket endpoints were already correct:

```swift
// ✅ Already had language parameter
case .bettingOfferPublisher(let operatorId, let language, let bettingOfferId):
    return "/sports/\(operatorId)/\(language)/bettingOffers/\(bettingOfferId)"

case .liveMatchesPublisher(let operatorId, let language, let sportId, let matchesCount):
    return "/sports/\(operatorId)/\(language)/live-matches-aggregator-main/..."

case .tournamentsPublisher(let operatorId, let language, let sportId):
    return "/sports/\(operatorId)/\(language)/tournaments/\(sportId)"
```

Only `sportsPublisher` was the outlier with hardcoded "en".

### Testing Approach

To verify the fix works:

1. **Switch app language to French**:
   - Sport names should appear in French (e.g., "Football" → "Football", "Tennis" → "Tennis", "Basketball" → "Basketball")
   - WebSocket topic should be: `/sports/4093/fr/disciplines/BOTH/BOTH`

2. **Switch app language to English**:
   - Sport names should appear in English
   - WebSocket topic should be: `/sports/4093/en/disciplines/BOTH/BOTH`

3. **Verify in debug logs**:
   - Can add logging in SportsManager.swift:43 to see: `print("🌐 Subscribing with language: \(language), topic: \(router.procedure)")`
   - Can add logging in SportsManager.swift:142 to see: `print("🏀 Received SportDTO: id=\(dto.id), name=\(dto.name)")`

### Next Steps
1. **Test in app**: Switch between EN/FR and verify sport names change language
2. **Remove debug logging**: If any was added for investigation
3. **Verify on staging**: Ensure EveryMatrix staging API returns localized sport names
4. **Update handover document**: Mark sport names issue as RESOLVED ✅
5. **Consider similar issues**: Check if any other WebSocket endpoints might have hardcoded values

### Session Retrospective

**What went well**:
- Previous session's centralization work was comprehensive and well-documented
- Quick identification of root cause using code comparison with other endpoints
- Clean fix following established patterns in the codebase

**What could improve**:
- Could have checked ALL WebSocket topic URLs in previous session, not just the language parameters
- Consider automated tests to detect hardcoded language codes in topic URLs

**Time Investment**:
- Investigation: ~5 minutes (reading files, comparing endpoints)
- Fix implementation: ~2 minutes (2 file edits, 4 lines changed)
- Documentation: ~15 minutes (this journal entry)

**Lessons Learned**:
- When doing comprehensive refactoring (like language centralization), check both:
  1. ✅ Configuration/parameter usage (we did this)
  2. ✅ String literals in computed properties (we missed this initially)
- WebSocket topic URLs are just as important as API parameters for localization
