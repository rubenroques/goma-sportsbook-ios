# CMS Banner Casino Category URL Routing

## Date
04 December 2025

### Project / Branch
BetssonCameroonApp / rr/feature/lang-switcher

### Goals for this session
- Investigate CMS banner URLs that weren't being handled correctly
- Fix `/casino/category/{slug}` deep link pattern support
- Centralize URL routing in MainTabBarCoordinator (avoid duplication)

### Achievements
- [x] Fetched production CMS banners to identify problematic URLs
- [x] Added `Route.casinoCategory(slug: String)` to Routes enum
- [x] Implemented `/casino/category/{slug}` parsing in `parseDeepLinkPath()`
- [x] Added `handleRoute()` case for casino category navigation
- [x] Created `showCasinoCategoryBySlug(_ slug: String)` method
- [x] Added `onBannerURLRequested` closure to CasinoCoordinator
- [x] Delegated URL handling from CasinoCoordinator to MainTabBarCoordinator
- [x] Removed `openExternalURL()` method from CasinoCoordinator
- [x] Wired up `onBannerURLRequested` callback in all 7 CasinoCoordinator creation sites

### Issues / Bugs Hit
- [x] CMS banner URL `https://www.betssonem.com/en/casino/category/video-slots` was opening Safari instead of navigating to video-slots category
- [x] Two separate code paths handled banner URLs (sports context vs casino context), causing inconsistent behavior
- [x] Casino banners had their own `openExternalURL()` that bypassed all deep link parsing

### Key Decisions
- **Centralized URL routing**: All banner URL handling now goes through `MainTabBarCoordinator.openBannerURL()` - single source of truth
- **Delegation pattern**: CasinoCoordinator uses `onBannerURLRequested` closure (same pattern as `onDepositRequested`, `onLoginRequested`)
- **Category ID mapping**: URL slug `video-slots` maps to category ID `Lobby1$video-slots`

### Experiments & Notes

#### CMS Banners in Production (fetched via API)
**Sport Banners:**
1. `https://www.betssonem.com/en/register` - Works (→ registration)
2. `https://www.betssonem.com/en/sports` - Works (→ sports home)

**Casino Banners:**
1. Game banner with `casino_game_id: "32430"` - Works (direct game launch)
2. `https://www.betssonem.com/en/casino/category/video-slots` - Was broken, now fixed

#### URL Flow Before Fix (Casino Context)
```
User Tap → SingleButtonBannerView → InfoBannerViewModel
→ CasinoTopBannerSliderViewModel → CasinoCategoriesListViewModel.handleBannerAction
→ CasinoCoordinator.openExternalURL() → Safari (WRONG!)
```

#### URL Flow After Fix
```
User Tap → SingleButtonBannerView → InfoBannerViewModel
→ CasinoTopBannerSliderViewModel → CasinoCategoriesListViewModel.handleBannerAction
→ CasinoCoordinator.onBannerURLRequested → MainTabBarCoordinator.openBannerURL()
→ parseURLToRoute() → handleRoute() → showCasinoCategoryBySlug() (CORRECT!)
```

### Useful Files / Links

#### Modified Files
- [Routes.swift](../../BetssonCameroonApp/App/Models/Configs/Routes.swift) - Added `casinoCategory(slug:)` case
- [MainTabBarCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift) - Added category routing + wired callbacks
- [CasinoCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/CasinoCoordinator.swift) - Added closure, removed `openExternalURL`

#### Reference Documentation
- [Previous DJ: Banner Callback Architecture](./04-November-2025-banner-callback-associated-types.md)
- [Previous DJ: RichBanner Pointer Implementation](./04-November-2025-richbanner-pointer-everymatrix-implementation.md)

### Architecture Summary

**MainTabBarCoordinator** is now the single source of truth for:
- Deep link parsing (`parseURLToRoute()`, `parseDeepLinkPath()`)
- Route handling (`handleRoute()`)
- External URL opening (`openExternalURL()`)
- Internal domain recognition (`betssonem.com`)
- Language prefix stripping (`/en/`, `/fr/`)

**CasinoCoordinator** delegates cross-cutting concerns:
- `onBannerURLRequested` → URL routing
- `onDepositRequested` → Deposit flow
- `onLoginRequested` → Login flow
- `onShowSportsQuickLinkScreen` → Sports navigation

**CasinoCoordinator** handles casino-specific navigation:
- `showCategoryGamesList()` - Push category screen
- `showGamePrePlay()` / `showGamePlay()` - Game screens
- `showAviatorGame()` / `showSlotsGames()` / etc. - Specific game categories

### Next Steps
1. Build and verify compilation
2. Test banner tap from sports context (NextUp/InPlay screens)
3. Test banner tap from casino context (Casino home screen)
4. Verify external URLs still open in Safari
5. Consider adding more category slug mappings if needed
