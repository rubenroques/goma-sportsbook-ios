# Bonus Boost: Min Odds Display & Selection Validation Fix

## Date
14 November 2025

### Project / Branch
sportsbook-ios / rr/breadcrumb (Betsson Cameroon)

### Goals for this session
- Display minimum odds requirement (e.g., "1.1 min odds") in betslip bonus boost header
- Fix odds boost API request to send complete selection data (odds value + marketId)
- Ensure progress bar correctly shows qualifying selections based on API validation

### Achievements
- [x] Added `minOdds` field throughout the entire data flow stack (SP → App → UI)
- [x] Extracted minimum odds from EveryMatrix API response (`odds.min` from first eligible event)
- [x] Updated UI to display min odds using existing localization string `"add_more_to_betslip"`
- [x] Added `marketId` and `odds` fields to `OddsBoostStairsSelection` for API validation
- [x] Fixed EveryMatrix API request to send actual selection data instead of random test values
- [x] Verified data flow from betslip tickets → API request → response → UI display

### Issues / Bugs Hit
- [x] Initial implementation only sent `outcomeId` and `eventId` to EveryMatrix API
  - **Root cause**: API needs actual odds values to validate minimum odds requirements
  - **Fix**: Added `marketId` and `odds` fields to selection payload
- [x] Random test values were being sent instead of real selection data
  - **Location**: `EveryMatrixPAMProvider.swift:779-780`
  - **Fix**: Removed random values, now uses actual `selection.outcomeId`, `selection.eventId`, etc.

### Key Decisions
- **Min odds source**: Extract from first eligible event's odds range in API response
  - Rationale: All events typically have same min odds requirement (e.g., 1.1)
  - Fallback: Shows `nil` if odds data unavailable (backward compatible)
- **Localization string choice**: Use existing `"add_more_to_betslip"` instead of creating new string
  - Avoids translation overhead
  - Already has correct placeholders: `{legNumber}` and `{minOdd}`
- **Odds format conversion**: Changed from `InternalOddFormat` to direct `Double` in EveryMatrix model
  - User modified to use `selection.odds.decimalOdd` directly
  - Simpler than mapper conversion, matches API expectations
- **Progress bar logic**: Keep existing `eligibleEventIds.count` for filled segments
  - Already correct - counts events that passed API validation
  - No changes needed to segment rendering logic

### Experiments & Notes
- EveryMatrix API validates selections server-side based on:
  1. Minimum odds per selection (e.g., >= 1.1)
  2. Event eligibility for the bonus promotion
  3. Market type compatibility
- API response differs based on qualifying selections:
  - **Below first tier**: Only `nextStair` present (e.g., 2/3 selections)
  - **At current tier**: Both `currentStair` and `nextStair` present (e.g., 3/3 reached, 4 available)
  - **At max tier**: Only `currentStair` present, `nextStair` is `nil`
- Progress segments use simple index-based logic: `shouldBeFilled = index < filledCount`
  - Works correctly with `eligibleEventIds.count` from validated API response

### Useful Files / Links

**Domain Models:**
- [OddsBoostStairs.swift (SP)](../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/OddsBoost/OddsBoostStairs.swift) - Added `minOdds: Double?` to `OddsBoostStairsResponse` and updated `OddsBoostStairsSelection`
- [OddsBoostStairs.swift (App)](../BetssonCameroonApp/App/Models/Betting/OddsBoostStairs.swift) - Added `minOdds: Double?` to `OddsBoostStairsState`

**Model Mappers:**
- [EveryMatrixModelMapper+OddsBoost.swift](../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+OddsBoost.swift:67-75) - Extracts `min` odds from first eligible event
- [ServiceProviderModelMapper+OddsBoost.swift](../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+OddsBoost.swift:48) - Passes minOdds through layers

**API Layer:**
- [EveryMatrix+OddsBoost.swift](../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/REST/EveryMatrix+OddsBoost.swift:21-26) - Updated `BetSelectionPointer` with `marketId` and `price`
- [EveryMatrixPAMProvider.swift](../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixPAMProvider.swift:776-792) - Fixed selection mapping to use real data

**App Layer:**
- [BetslipManager.swift](../BetssonCameroonApp/App/Services/BetslipManager.swift:366-373) - Maps betslip tickets to complete `OddsBoostStairsSelection` objects
- [BetslipOddsBoostHeaderViewModel.swift](../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/BetslipOddsBoostHeaderViewModel.swift:71-80) - Formats minOdds as string (e.g., "1.10")

**UI Components:**
- [BetslipOddsBoostHeaderViewModelProtocol.swift](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/BetslipOddsBoostHeaderViewModelProtocol.swift:14) - Added `minOdds: String?` to state
- [BetslipOddsBoostHeaderView.swift](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/BetslipOddsBoostHeaderView.swift:222-234) - Renders min odds in description label
- [MockBetslipOddsBoostHeaderViewModel.swift](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/MockBetslipOddsBoostHeaderViewModel.swift:49-86) - Updated all factory methods with `minOdds: "1.1"` default

**Localization:**
- [en.lproj/Localizable.strings](../BetssonCameroonApp/App/Resources/Language/en.lproj/Localizable.strings) - `"add_more_to_betslip"` string with `{legNumber}` and `{minOdd}` placeholders

### Data Flow Summary

```
User adds selections to betslip
  ↓
BetslipManager.fetchOddsBoostStairs()
  ↓ Maps to OddsBoostStairsSelection(outcomeId, eventId, marketId, odds)
EveryMatrix API POST /bonus/wallets/sports
  ↓ Validates each selection's odds against minOdds requirement
API Response: { odds: { "eventId": { min: 1.1 } }, eligibleEventID: [...] }
  ↓
EveryMatrixModelMapper extracts first event's min odds
  ↓
OddsBoostStairsResponse(minOdds: 1.1, eligibleEventIds: [...])
  ↓
ServiceProviderModelMapper → OddsBoostStairsState(minOdds: 1.1)
  ↓
BetslipOddsBoostHeaderViewModel formats as "1.10"
  ↓
BetslipOddsBoostHeaderState(minOdds: "1.10")
  ↓
BetslipOddsBoostHeaderView renders:
  "by adding 1 more legs to your betslip (1.10 min odds)."
```

### Next Steps
1. Test with real betslip containing:
   - Selections with odds >= 1.1 (should qualify)
   - Selections with odds < 1.1 (should NOT appear in eligibleEventID)
   - Mix of qualifying and non-qualifying selections
2. Verify progress bar shows correct number of segments based on actual qualifying events
3. Test edge cases:
   - No minimum odds requirement (minOdds = nil)
   - Different min odds per event (currently uses first event's min)
   - User reaches max tier (currentStair only, no nextStair)
4. Verify French localization string matches expected format
5. Consider adding debug logging to show which selections qualified vs rejected by API
