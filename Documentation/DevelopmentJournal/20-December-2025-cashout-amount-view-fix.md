## Date
20 December 2025

### Project / Branch
BetssonCameroonApp / rr/cashout_fixes

### Goals for this session
- Fix CashoutAmountView to show historical cashout amount (not slider value)
- Fix double currency display issue ("XAF XAF 1,790")
- Fix localization key for partial cashout title

### Achievements
- [x] Added `totalCashedOut` and `hasPreviousCashouts` computed properties to `MyBet`
- [x] Updated `ServiceProviderModelMapper+MyBets.swift` to map `partialCashOuts` array
- [x] Refactored `setupCashoutViewModels()` to show static historical amount (not slider-linked)
- [x] Removed slider → amount binding (amount view now static for historical data)
- [x] Removed unused `subscribeToSliderChanges()` and `updateCashoutAmount()` methods
- [x] Fixed double currency by using `CurrencyHelper.formatAmount()` instead of `formatAmountWithCurrency()`
- [x] Fixed localization key: `mybets_cashed_out` → `partial_cashout` (exists in Phrase)

### Issues / Bugs Hit
- [x] `mybets_cashed_out` localization key didn't exist - used existing `partial_cashout` from Phrase
- [x] Double currency display - `CashoutAmountView` concatenates `currency + amount`, but factory was pre-formatting with currency
- [ ] Localization sync issue - keys exist in Phrase but not always synced to local Localizable.strings

### Key Decisions
- **CashoutAmountView purpose clarified**: Shows total already cashed out from previous partial cashouts (historical), NOT the current slider selection
- **Static vs reactive**: Amount view is now static (created once with historical total), slider changes don't affect it
- **Factory method fix**: Both `create()` overloads in `CashoutAmountViewModel` now use `formatAmount()` without currency since the view adds currency separately

### Experiments & Notes
- `CashoutAmountView` line 87: `amountLabel.text = "\(data.currency) \(data.amount)"` - view adds currency
- `CashoutAmountData` has separate `currency` and `amount` fields by design
- Historical cashout = sum of `partialCashOuts.compactMap { $0.cashOutAmount }.reduce(0, +)`

### Useful Files / Links
- [MyBet.swift](../../BetssonCameroonApp/App/Models/Betting/MyBet.swift) - Added `totalCashedOut`, `hasPreviousCashouts`
- [PartialCashOut.swift](../../BetssonCameroonApp/App/Models/Betting/PartialCashOut.swift) - Model for cashout history
- [ServiceProviderModelMapper+MyBets.swift](../../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+MyBets.swift) - Added mapping
- [TicketBetInfoViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift) - Refactored amount VM setup
- [CashoutAmountViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/CashoutAmountViewModel.swift) - Fixed factory methods
- [CashoutAmountView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CashoutAmountView/CashoutAmountView.swift) - View rendering logic
- [Previous session journal](./20-December-2025-mybets-cashout-status-and-amount.md) - Earlier work on cashedOut status

### Next Steps
1. Sync Phrase localizations to get `partial_cashout` key locally
2. Build and test with actual bet that has partial cashout history
3. Verify amount displays correctly without double currency
4. Consider adding snapshot tests for CashoutAmountView states
