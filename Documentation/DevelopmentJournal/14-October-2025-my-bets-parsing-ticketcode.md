## Date
08 October 2025

### Project / Branch
BetssonCameroonApp / rr/register_fields_fix

### Goals for this session
- Fix My Bets parsing/decoding errors preventing bet history from loading
- Study complete data flow architecture for My Bets feature
- Add support for ticketCode field from API

### Achievements
- [x] Fixed critical decoding error: `earlySettlementOption` type mismatch
- [x] Added 4 missing bonus-related fields to prevent future parsing issues
- [x] Implemented ticketCode field throughout entire 7-layer data flow chain
- [x] Updated My Bets List UI to display ticketCode (with UUID fallback)
- [x] Updated My Bet Detail UI to display ticketCode consistently
- [x] Documented complete My Bets data flow architecture
- [x] Identified 5+ parsing/mapping issues for future fixes

### Issues / Bugs Hit
- [x] **CRITICAL**: Decoding error - `earlySettlementOption` expected String but API returned dictionary `{"scoreDifference": 2.0}`
- [x] **HIGH**: 4 bonus fields missing from model: `bonusWalletId`, `hasBonusMoney`, `realStake`, `bonusStake`
- [ ] **MEDIUM**: Incorrect `totalReturn` field mapping (uses `potentialNetReturns` instead of `overallBetReturns` for settled bets)
- [ ] **MEDIUM**: Currency hardcoded to "EUR" instead of using API's `currency` field
- [ ] **MEDIUM**: Score data not parsed from `eventScoreAtPlaceBet`
- [ ] **LOW**: "SETTLED" bet result incorrectly maps to `.open` instead of proper result

### Key Decisions
- **Created `EarlySettlementOption` struct**: Proper typing for complex API field instead of String
- **Added ticketCode with fallback pattern**: New `displayTicketReference` property returns `ticketCode ?? identifier`
- **Made all bonus fields optional**: Future-proofs for bonus wallet features without breaking changes
- **Kept unused API fields as optional**: 43 bet-level and 23 selection-level fields remain for future use

### Data Flow Architecture Discovery

Documented complete 7-layer data flow:
```
EveryMatrix API Response
    ↓
EveryMatrix.Bet Model (EveryMatrix+MyBets.swift)
    ↓
EveryMatrixModelMapper+MyBets.swift
    ↓
ServicesProvider.Bet (Betting.swift)
    ↓
ServiceProviderModelMapper+MyBets.swift
    ↓
App MyBet Model (MyBet.swift)
    ↓
UI (TicketBetInfoViewModel → MyBetsViewController)
```

### Experiments & Notes
- **API Response Analysis**: Found 4 undocumented fields in production response
- **Pattern Discovery**: `earlySettlementOption` can be null OR object, not String
- **Unused Fields Count**: 66 total fields parsed but not used by public models (safe to keep optional)

### Files Modified

#### 1. Fixed Decoding Error
**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Shared/EveryMatrix+MyBets.swift`
- Line 14-16: Added `EarlySettlementOption` struct
- Line 186: Changed `earlySettlementOption: String?` → `earlySettlementOption: EarlySettlementOption?`

#### 2. Added Missing Bonus Fields
**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Shared/EveryMatrix+MyBets.swift`
- Lines 87-90: Added `bonusWalletId`, `hasBonusMoney`, `realStake`, `bonusStake` properties
- Lines 146-149: Added corresponding CodingKeys

#### 3. Added ticketCode to ServicesProvider Layer
**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/Betting.swift`
- Line 53: Added `public var ticketCode: String?` property
- Line 76: Added `ticketCode: String? = nil` to initializer
- Line 98: Added `self.ticketCode = ticketCode` assignment

#### 4. Mapped ticketCode in EveryMatrix Mapper
**File**: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+MyBets.swift`
- Line 52: Added `ticketCode: everyMatrixBet.ticketCode` to Bet initialization

#### 5. Added ticketCode to App Domain Model
**File**: `BetssonCameroonApp/App/Models/Betting/MyBet.swift`
- Line 35: Added `let ticketCode: String?` property
- Line 55: Added `ticketCode: String? = nil` to initializer
- Line 72: Added `self.ticketCode = ticketCode` assignment
- Lines 77-80: Added `displayTicketReference` computed property with fallback logic

#### 6. Mapped ticketCode in App Mapper
**File**: `BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+MyBets.swift`
- Line 52: Added `ticketCode: servicesProviderBet.ticketCode` to MyBet initialization

#### 7. Updated My Bets List UI
**File**: `BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift`
- Line 233: Changed `"Bet ID: \(myBet.identifier)"` → `"Ticket: \(myBet.displayTicketReference)"`

#### 8. Updated My Bet Detail UI
**File**: `BetssonCameroonApp/App/Screens/MyBetDetail/ViewModels/BetDetailValuesSummaryViewModel.swift`
- Line 54: Changed label "Bet ID" → "Ticket"
- Line 55: Changed `"#\(myBet.identifier)"` → `"#\(myBet.displayTicketReference)"`

**File**: `BetssonCameroonApp/App/Screens/MyBetDetail/MyBetDetailViewModel.swift`
- Line 78: Updated unused property for consistency

### Useful Files / Links
- [EveryMatrix API Models](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Shared/EveryMatrix+MyBets.swift)
- [EveryMatrix Mapper](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+MyBets.swift)
- [ServicesProvider Betting Models](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/Betting.swift)
- [App Domain Models](../../BetssonCameroonApp/App/Models/Betting/MyBet.swift)
- [App Model Mapper](../../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+MyBets.swift)
- [My Bets ViewModel](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewModel.swift)
- [Ticket Info ViewModel](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift)

### Next Steps
1. Test My Bets screen in simulator - verify bets load successfully
2. Verify ticketCode displays correctly (e.g., "0002014" instead of UUID)
3. Fix remaining parsing issues:
   - Use `overallBetReturns` for settled bets `totalReturn`
   - Add `currency` field to ServicesProvider.Bet and map through
   - Parse `eventScoreAtPlaceBet` for score display
   - Fix "SETTLED" → `.open` result mapping
4. Add currency field support (currently hardcoded to "EUR")
5. Consider adding score parsing from `eventScoreAtPlaceBet`
