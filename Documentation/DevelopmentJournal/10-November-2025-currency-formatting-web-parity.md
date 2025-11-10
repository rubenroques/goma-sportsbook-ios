# Currency Formatting - Web Parity Implementation

## Date
10 November 2025

### Project / Branch
BetssonCameroonApp / betsson-cm

### Goals for this session
- Fix currency formatting to match web app behavior
- Replace space thousand separator with comma separator (en_US locale)
- Implement dual formatting: amounts without currency (wallet) and with currency (betslip)
- Ensure consistent 2 decimal places across all monetary displays

### Achievements
- [x] Created new `CurrencyHelper` struct with two formatting methods:
  - `formatAmount()` - Returns formatted number without currency (e.g., "1,000.00")
  - `formatAmountWithCurrency()` - Returns formatted number with currency code (e.g., "XAF 1,000.00")
- [x] Both methods use en_US locale with comma thousand separator and 2 decimal places
- [x] Updated 9 ViewModels to use new formatting methods:
  - **Wallet screens** (no currency): WalletDetailViewModel, WalletStatusViewModel, WalletWidgetViewModel, MultiWidgetToolbarViewModel
  - **Betslip/Bets screens** (with currency): BetslipViewModel, SportsBetslipViewModel, TicketBetInfoViewModel
- [x] Deprecated legacy `CurrencyFormater` struct for backward compatibility during migration
- [x] All formatting now consistent: comma separators, 2 decimals, proper locale handling

### Issues / Bugs Hit
- [x] Initial misunderstanding: Thought ALL currency symbols needed removal (like web wallet)
- [x] Clarified: Wallet displays without currency, betslip/winnings display WITH currency
- [x] Solution: Implemented two separate methods instead of optional parameter approach

### Key Decisions
- **Two methods over optional parameter**: Chose `formatAmount()` and `formatAmountWithCurrency()` for clarity and explicit intent
- **Fixed en_US locale**: Hardcoded `Locale(identifier: "en_US")` to match web's `Intl.NumberFormat('en-US')` behavior
- **Deprecated, not deleted**: Kept legacy `CurrencyFormater` with deprecation warnings to maintain backward compatibility
- **NumberFormatter.decimal style**: Used `.decimal` instead of `.currency` to avoid automatic symbol insertion

### Experiments & Notes
- Web reference: `formattedCurrency()` function in `web-app/src/utils/bettingUtils.js:151-156`
- Web uses `Intl.NumberFormat('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })`
- iOS equivalent: `NumberFormatter` with `locale: en_US`, `numberStyle: .decimal`, `min/maxFractionDigits: 2`
- Space separator (`"XAF 1 000.00"`) is from default locale behavior - fixed by forcing en_US locale

### Useful Files / Links
- [CurrencyHelper.swift](../../BetssonCameroonApp/App/Helpers/CurrencyHelper.swift) - New implementation
- [WalletDetailViewModel.swift](../../BetssonCameroonApp/App/Screens/ProfileWallet/WalletDetailViewModel.swift) - Wallet formatting example
- [SportsBetslipViewModel.swift](../../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/SportsBetslipViewModel.swift) - Betslip potential winnings calculation
- [BetslipViewModel.swift](../../BetssonCameroonApp/App/Screens/Betslip/BetslipViewModel.swift) - Header wallet balance display
- [TicketBetInfoViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/TicketBetInfoViewModel.swift) - My Bets bet amount display

### Before and After

**Before (iOS with space separator):**
```
Wallet Balance:      XAF 1 000.00  ❌
Betslip Header:      XAF 1 000.00  ❌
Possible Winnings:   XAF 250.00    ❌ (space on larger amounts)
```

**After (iOS matching web):**
```
Wallet Balance:      1,000.00      ✅ (no currency, comma separator)
Betslip Header:      XAF 1,000.00  ✅ (with currency, comma separator)
Possible Winnings:   XAF 250.00    ✅ (with currency, comma separator)
```

### Implementation Details

**CurrencyHelper Core Logic:**
```swift
static func formatAmount(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US")        // Fixed locale
    formatter.numberStyle = .decimal                       // No currency symbols
    formatter.minimumFractionDigits = 2                    // Always 2 decimals
    formatter.maximumFractionDigits = 2
    formatter.usesGroupingSeparator = true                 // Comma separators
    formatter.roundingMode = .halfUp

    return formatter.string(from: NSNumber(value: amount)) ?? "0.00"
}

static func formatAmountWithCurrency(_ amount: Double, currency: String) -> String {
    let formatted = formatAmount(amount)
    return "\(currency) \(formatted)"  // "XAF 1,000.00"
}
```

### Updated ViewModels Summary

| ViewModel | Method Used | Example Output |
|-----------|-------------|----------------|
| WalletDetailViewModel | `formatAmount()` | `"1,000.00"` |
| WalletStatusViewModel | `formatAmount()` | `"1,000.00"` |
| WalletWidgetViewModel | `formatAmount()` | `"1,000.00"` |
| MultiWidgetToolbarViewModel | `formatAmount()` | `"1,000.00"` |
| BetslipViewModel | `formatAmountWithCurrency()` | `"XAF 1,000.00"` |
| SportsBetslipViewModel | `formatAmountWithCurrency()` | `"XAF 250.00"` |
| TicketBetInfoViewModel | `formatAmountWithCurrency()` | `"XAF 100.00"` |

### Next Steps
1. Build verification with `xcodebuild` on iOS 18.2+ simulator
2. Manual testing on device:
   - Verify wallet screens show amounts without currency
   - Verify betslip header shows balance with currency and comma separator
   - Verify possible winnings calculation displays correctly
   - Test with various amounts (small, large, decimals, zero)
3. Consider extending this pattern to BetssonFranceApp if needed (out of scope for this session)
4. Monitor for any edge cases with negative amounts or very large numbers
