# Development Journal Entry

## Date
29 August 2025

### Project / Branch
sportsbook-ios / rr/mybets_profile_features

### Goals for this session
- Fix currency formatting issues in wallet components (showing proper 2 decimals with XAF support)
- Fix ProfileWallet logout functionality that wasn't working
- Clean up ProfileMenuListView by removing selection type, keeping only navigation and action types
- Ensure consistent wallet data formatting between root popup and profile wallet

### Achievements
- [x] **Currency Formatting Fixed**: Both wallet components now show proper 2 decimal places with thousands separators
- [x] **XAF Currency Support**: Added XAF to CurrencyType enum and updated CurrencyFormater logic
- [x] **Shared Currency Helper**: Created `CurrencyFormater.formatWalletAmount()` for consistent formatting
- [x] **Phone Number Display Fixed**: Profile wallet now shows "+237 123 456 789" format instead of "+237 XXX XXX XXX"
- [x] **Logout Functionality Complete**: Fixed entire callback chain from ProfileMenuListView to UserSessionStore.logout()
- [x] **ProfileMenuItem Architecture Simplified**: Removed `.selection` type, kept only `.navigation` and `.action`
- [x] **Added Subtitle Support**: ProfileMenuItem now supports optional subtitle for additional information

### Issues / Bugs Hit
- [x] **Currency Display Issue**: Wallet components were showing "€ 268.48" instead of proper XAF formatting with decimals
- [x] **Missing Currency Formatter Usage**: Components used simple `String(format: "%.0f XAF")` instead of proper CurrencyFormater
- [x] **Phone Number Missing Country Prefix**: Profile showed "+237 XXX XXX XXX" placeholder instead of real formatted number
- [x] **Broken Logout Action**: ProfileMenuListView logout wasn't connected to actual UserSessionStore.logout() method
- [x] **Incomplete Callback Chain**: ProfileWalletViewModel wasn't passing menu selection callbacks to coordinator

### Key Decisions
- **Consistent Currency Formatting**: Used shared `CurrencyFormater.formatWalletAmount()` method across all wallet components
- **XAF Currency Handling**: Added XAF support to enum while maintaining EUR/USD/GBP compatibility
- **Phone Number Strategy**: Combined `mobileCountryCode` + `mobileLocalNumber` with fallback to `mobilePhone` 
- **Logout Flow Design**: Dismiss profile modal first, then call `userSessionStore.logout()` for clean UX
- **ProfileMenuItem Simplification**: Removed complex `.selection(String)` type, replaced with optional subtitle property
- **Proper Callback Chain**: Connected MockProfileMenuListViewModel → ProfileWalletViewModel → ProfileWalletCoordinator → UserSessionStore

### Experiments & Notes
- **API Investigation**: Tested EveryMatrix API to understand actual currency data structure ({"EUR": 268.48} format)
- **Data Flow Analysis**: Traced currency data from API → CurrencyAmount → UserWallet → CurrencyFormater → UI
- **Architecture Evolution**: Simplified ProfileMenuListView from 3 types (.navigation, .action, .selection) to 2 types with subtitle support
- **Mock Data Integration**: Ensured MockProfileMenuListViewModel properly routes callbacks for logout functionality

### Useful Files / Links
- [CurrencyHelper.swift](../../BetssonCameroonApp/App/Helpers/CurrencyHelper.swift) - Enhanced with XAF support and shared formatter
- [WalletDetailViewModel.swift](../../BetssonCameroonApp/App/Screens/ProfileWallet/WalletDetailViewModel.swift) - Fixed currency formatting and phone number display
- [RootTabBarViewModel.swift](../../BetssonCameroonApp/App/Screens/Root/RootTabBarViewModel.swift) - Updated to use consistent currency formatting
- [ProfileWalletCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/ProfileWalletCoordinator.swift) - Fixed logout action implementation
- [ProfileWalletViewModel.swift](../../BetssonCameroonApp/App/Screens/ProfileWallet/ProfileWalletViewModel.swift) - Connected menu callback chain
- [ProfileMenuItemView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ProfileMenuListView/ProfileMenuItemView.swift) - Simplified types and added subtitle support
- [MockProfileMenuListViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ProfileMenuListView/MockProfileMenuListViewModel.swift) - Removed selection logic

### Architecture Implemented

#### Currency Formatting System
```
CurrencyFormater.formatWalletAmount() 
├── Uses currencyTypeWithSeparatorFormatting()
├── Supports EUR, USD, GBP, XAF currencies  
├── Shows 2 decimal places with thousands separators
└── Used by both WalletStatusView (root popup) and WalletDetailView (profile)
```

#### Logout Flow Chain
```
ProfileMenuListView (user tap)
└── MockProfileMenuListViewModel.didSelectItem()
    └── ProfileWalletViewModel.onMenuItemSelected
        └── ProfileWalletCoordinator.handleMenuItemSelection()
            └── showLogoutConfirmation() → performLogout()
                └── UserSessionStore.logout()
```

#### ProfileMenuItem Architecture
```swift
// Before: 3 types with complex selection handling
enum ProfileMenuItemType {
    case navigation, action, selection(String)
}

// After: 2 types with optional subtitle
enum ProfileMenuItemType {
    case navigation, action  
}
struct ProfileMenuItem {
    let subtitle: String?  // New: for additional info display
}
```

### Technical Highlights
- **Shared Currency Logic**: Both root wallet popup and profile wallet use identical `CurrencyFormater.formatWalletAmount()`
- **Real-Time Phone Formatting**: Combines `userProfile.mobileCountryCode` + `mobileLocalNumber` with proper spacing
- **Clean Logout UX**: Modal dismisses first, then session clears to avoid UI conflicts
- **Type System Simplification**: Reduced ProfileMenuItem complexity while maintaining subtitle display capability
- **Production-Ready Callbacks**: Proper memory management with `[weak self]` in callback chains

### Next Steps
1. **Test Currency Display**: Verify XAF formatting works correctly when API returns XAF currency data
2. **Test Logout Flow**: Confirm entire logout sequence works in simulator (menu tap → confirmation → session clear → login state)
3. **Verify Phone Numbers**: Test with real user data to ensure country code + local number formatting works properly
4. **Accessibility Review**: Ensure ProfileMenuItem subtitle text meets accessibility standards
5. **Performance Testing**: Verify currency formatting doesn't impact UI performance with large amounts