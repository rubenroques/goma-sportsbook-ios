## Date
10 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Investigate why MyBets screen displays "EUR" instead of actual currency ("XAF")
- Trace complete data flow from EveryMatrix API through model layers to UI
- Fix currency hardcoding issue at all layers
- Ensure consistent currency formatting across MyBets list and detail screens

### Achievements
- [x] Completed comprehensive data flow investigation for MyBets feature
- [x] Identified root cause: currency lost during ServicesProvider.Bet transformation
- [x] Added `currency: String` field to ServicesProvider.Bet domain model
- [x] Updated EveryMatrixModelMapper to extract and pass through currency from API
- [x] Removed EUR hardcoding in ServiceProviderModelMapper+MyBets
- [x] Migrated BetDetailValuesSummaryViewModel to use CurrencyHelper for consistency
- [x] Verified all display components already use currency field correctly (no changes needed)

### Issues / Bugs Hit
- **Currency Hardcoding Bug**: ServiceProviderModelMapper+MyBets.swift:34 hardcoded `let currency = "EUR"`
  - Root cause: ServicesProvider.Bet model was missing currency field
  - EveryMatrix API correctly returns `currency: "XAF"` but value was lost in transformation
  - Fixed by adding currency field through all 3 model layers

### Key Decisions
- **Currency Field as Optional with EUR Fallback**: Made currency optional in EveryMatrixModelMapper with fallback to EUR if API doesn't provide it
  - Rationale: More forgiving approach, won't filter out bets if API is inconsistent
  - Implementation: `let currency = everyMatrixBet.currency ?? "EUR"`

- **CurrencyHelper Standardization**: Migrated BetDetailValuesSummaryViewModel away from custom NumberFormatter
  - Rationale: Ensures consistent "XAF 1,000.00" formatting across entire app (matches web)
  - Removed custom formatCurrency() and getCurrencySymbol() methods
  - All bet displays now use identical formatting via CurrencyHelper.formatAmountWithCurrency()

- **Default Parameter in ServicesProvider.Bet Init**: Added `currency: String = "EUR"` as default parameter
  - Rationale: Backward compatibility with existing code creating Bet objects
  - Allows gradual migration of other providers (Goma, SportRadar)

### Architecture Insights

**5-Layer Model Transformation Pipeline**:
```
EveryMatrix REST API Response (JSON with currency: "XAF")
    ↓
[Layer 1] EveryMatrix.Bet (REST internal model - has currency field)
    ↓
[Layer 2] EveryMatrixModelMapper → ServicesProvider.Bet (domain model - NOW has currency)
    ↓
[Layer 3] ServiceProviderModelMapper → MyBet (app model - has currency field)
    ↓
[Layer 4] TicketBetInfoViewModel / BetDetailValuesSummaryViewModel
    ↓
[Layer 5] UI Display (GomaUI components)
```

**Critical Understanding**:
- EveryMatrix uses **TWO different data flows**: WebSocket (WAMP with 4 layers, uses DTOs) vs REST (2 layers, no DTOs)
- MyBets uses **REST API only** (`/bets-api/v1/{operatorId}/open-bets` and `/settled-bets`)
- REST responses are already hierarchical, bypass EntityStore completely
- "DTO" suffix is exclusive to WebSocket entities, never use for REST models

**CurrencyHelper Implementation** (from 10 Nov journal):
- Two methods: `formatAmount()` (no currency) and `formatAmountWithCurrency()` (with currency code)
- Fixed en_US locale, comma thousand separator, 2 decimal places
- Matches web app's `Intl.NumberFormat('en-US')` behavior
- No currency symbols, uses codes (XAF, EUR, USD)

### Useful Files / Links
- [ServicesProvider.Bet](Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/Betting.swift:17-100) - Domain model (added currency field line 27)
- [EveryMatrixModelMapper+MyBets](Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+MyBets.swift:18-58) - Pass through currency (line 38, 48)
- [ServiceProviderModelMapper+MyBets](BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+MyBets.swift:24-54) - Use actual currency (line 34)
- [BetDetailValuesSummaryViewModel](BetssonCameroonApp/App/Screens/MyBetDetail/ViewModels/BetDetailValuesSummaryViewModel.swift:123-127) - CurrencyHelper migration
- [CurrencyHelper](BetssonCameroonApp/App/Helpers/CurrencyHelper.swift) - Currency formatting utilities
- [EveryMatrix API Response Example](provided by user in session) - Shows currency: "XAF" in actual API data

### API Endpoints
**EveryMatrix MyBets Endpoints**:
- **Open Bets**: `GET /bets-api/v1/{operatorId}/open-bets?limit=20&placedBefore={date}`
- **Settled Bets**: `GET /bets-api/v1/{operatorId}/settled-bets?limit=20&placedBefore={date}`
- **Won Bets**: `GET /bets-api/v1/{operatorId}/settled-bets?limit=20&placedBefore={date}&betStatus=WON`

All endpoints return bet objects with `currency: "XAF"` field.

### Files Modified (4 total)
1. `Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/Betting.swift`
   - Added `public var currency: String` property (line 27)
   - Added `currency: String = "EUR"` parameter to init (line 64)
   - Added `self.currency = currency` assignment (line 87)

2. `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+MyBets.swift`
   - Extract currency from API: `let currency = everyMatrixBet.currency ?? "EUR"` (line 38)
   - Pass to Bet init: `currency: currency` (line 48)

3. `BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+MyBets.swift`
   - Removed: `let currency = "EUR" // Hardcoded`
   - Added: `let currency = servicesProviderBet.currency` (line 34)

4. `BetssonCameroonApp/App/Screens/MyBetDetail/ViewModels/BetDetailValuesSummaryViewModel.swift`
   - Replaced custom formatCurrency() with `CurrencyHelper.formatAmountWithCurrency()` (line 126)
   - Removed getCurrencySymbol() method (no longer needed)

### Files Already Correct (No Changes Needed)
- ✅ TicketBetInfoViewModel.swift - Already uses CurrencyHelper.formatAmountWithCurrency()
- ✅ MyBetDetailViewModel.swift - Already uses bet.currency
- ✅ WalletStatusViewModel.swift - Already uses CurrencyHelper.formatAmount()
- ✅ All GomaUI components - Receive pre-formatted strings from ViewModels

### Testing Notes
**Expected Results**:
- Before: MyBets shows "EUR 1,234.00" for XAF bets
- After: MyBets shows "XAF 1,234.00" with correct currency from API

**Test Coverage**:
- MyBets list screen (all status tabs: Open, Settled, Won, Cashout)
- MyBet detail screen (stake, potential return, total return, partial cashout)
- Bet details values summary view
- All currency amounts should display "XAF X,XXX.XX" format

**Multi-Provider Support**:
- Fix is provider-agnostic at ServicesProvider level
- Goma and SportRadar providers will automatically work once they populate currency field
- Default "EUR" fallback ensures backward compatibility

### Next Steps
1. Build BetssonCameroonApp to verify compilation
2. Test with real EveryMatrix API to confirm XAF currency displays correctly
3. Verify MyBets list shows correct currency across all status tabs
4. Test MyBet detail screen currency display
5. Consider updating Goma/SportRadar providers to also populate currency field
6. Add unit tests for currency field mapping across all layers
