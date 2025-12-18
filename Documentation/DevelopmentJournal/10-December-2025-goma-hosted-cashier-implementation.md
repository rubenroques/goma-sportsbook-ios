## Date
10 December 2025

### Project / Branch
BetssonCameroonApp / rr/filter_default

### Goals for this session
- Understand current EveryMatrix-hosted deposit/withdraw cashier implementation
- Analyze new Goma-hosted cashier specification from web team
- Implement new Goma cashier screens (deposit & withdraw) as separate screens
- Keep old EM cashier screens intact, switch app to use new Goma screens

### Achievements
- [x] Analyzed current EM cashier architecture (API call for URL, JS bridge with "iOS" handler)
- [x] Reviewed new Goma cashier README with static URL pattern and query params
- [x] Created `GomaCashierConfiguration.swift` - environment-aware URL builder (STAGE vs UAT/PROD)
- [x] Created `GomaCashierBridge.swift` - dedicated JS bridge with "cashierHandler" handler name
- [x] Created `GomaCashierWebViewConfiguration.swift` - WebView setup for Goma cashier
- [x] Created `GomaCashierDepositViewController.swift` + `GomaCashierDepositViewModel.swift`
- [x] Created `GomaCashierWithdrawViewController.swift` + `GomaCashierWithdrawViewModel.swift`
- [x] Updated `BankingCoordinator.swift` with new `.gomaCashierDeposit` and `.gomaCashierWithdraw` transaction types
- [x] Wired up `MainTabBarCoordinator` and `ProfileWalletCoordinator` to use Goma cashier
- [x] Added GomaLogger throughout with `[GomaCashier]` prefix for easy filtering

### Issues / Bugs Hit
- None encountered during implementation

### Key Decisions
- **Separate screens, not replacement**: Old EM cashier screens kept intact, new Goma screens are parallel implementation
- **No API call needed**: Goma cashier builds URL client-side with query params (sessionId, userId, endpoint, currency, lang, theme, type)
- **New JS handler name**: `"cashierHandler"` instead of `"iOS"` per web team spec
- **Reuse existing patterns**: `CashierFrameState`, `BankingTimingMetrics`, `BankingNavigationAction` reused for consistency
- **No spinner polling**: Removed EM-specific spinner element polling (not applicable to Goma cashier)
- **Currency fallback**: Default to `"XAF"` if `UserProfile.currency` is nil
- **Theme detection**: Use `UIScreen.main.traitCollection.userInterfaceStyle` to pass "dark"/"light" to cashier

### Experiments & Notes
- Goma cashier URL pattern: `{BASE_URL}/cashier-page/index.html?sessionId=X&userId=X&endpoint=X&currency=X&lang=X&theme=X&type=X`
- Environment URLs:
  - STAGE: `https://sportsbook-stage.gomagaming.com` (API: `https://betsson-api.stage.norway.everymatrix.com`)
  - UAT/PROD: `https://www.betssonem.com` (API: `https://betsson.nwacdn.com`)
- Session data sourced from `Env.userSessionStore.loggedUserProfile?.sessionKey` and `.userIdentifier`

### Useful Files / Links
- [GomaCashierConfiguration](../../BetssonCameroonApp/App/Screens/Banking/GomaCashier/Configuration/GomaCashierConfiguration.swift)
- [GomaCashierBridge](../../BetssonCameroonApp/App/Screens/Banking/GomaCashier/Bridge/GomaCashierBridge.swift)
- [GomaCashierDepositViewController](../../BetssonCameroonApp/App/Screens/Banking/GomaCashier/Deposit/GomaCashierDepositViewController.swift)
- [GomaCashierWithdrawViewController](../../BetssonCameroonApp/App/Screens/Banking/GomaCashier/Withdraw/GomaCashierWithdrawViewController.swift)
- [BankingCoordinator](../../BetssonCameroonApp/App/Coordinators/BankingCoordinator.swift)
- [Original EM DepositWebContainerViewController](../../BetssonCameroonApp/App/Screens/Banking/Deposit/DepositWebContainerViewController.swift)
- Web team cashier README: `/Users/rroques/Downloads/README (2).md`

### Next Steps
1. Test deposit flow in simulator with logged-in user
2. Test withdraw flow in simulator
3. Verify JS bridge callbacks work correctly with Goma cashier page
4. Confirm theme parameter is correctly passed (dark/light mode)
5. Test on both STAGE and UAT environments
