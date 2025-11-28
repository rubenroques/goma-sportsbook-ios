# Development Journal

## Date
28 November 2025

### Project / Branch
BetssonCameroonApp / rr/bugfix/match_detail_blinks

### Goals for this session
- Fix broken casino quick links navigation (Aviator, Slots, Crash, Lite)
- Replace fragile string-matching approach with hardcoded category IDs
- Support dynamic localized category titles from API

### Achievements
- [x] Discovered API category IDs via cURL requests to staging and production
- [x] Added `categoryName: String?` to `CasinoGamesResponse` model
- [x] Updated `EveryMatrixCasinoProvider` to pass category name from API response
- [x] Added `QuickLinkConstants` enum with hardcoded IDs (environment-aware)
- [x] Refactored `CasinoCoordinator` quick link methods to use direct navigation
- [x] Updated `CasinoCategoryGamesListViewModel` to accept optional title
- [x] Added `updateTitle(_:)` method to `SimpleNavigationBarView` for dynamic updates
- [x] Added binding in ViewController to update nav bar when title loads from API

### Issues / Bugs Hit
- [x] Original quick link methods used Combine subscriptions that accumulated (race conditions)
- [x] String matching (`contains("aviator")`) was fragile and unreliable
- [x] Staging and production have different category ID formats (hyphenated vs concatenated)
- [x] Navigation bar title was empty when opened via quick links (fixed with reactive binding)

### Key Decisions
- **Hardcoded IDs in CasinoCoordinator**: Keeps casino-specific logic contained, no config pollution
- **Dynamic titles from API**: Avoids hardcoded localized strings, supports EN/FR automatically
- **No extra API calls**: Reuse existing `getGamesByCategory` response which already contains category name
- **Environment check**: Used `TargetVariables.serviceProviderEnvironment == .prod` for consistency with project patterns

### Experiments & Notes

**API Discovery Results:**
```
Production Categories:
- Lobby1$video-slots => Video Slots
- Lobby1$crash-games => Crash Games
- Lobby1$lite => Lite
- Lobby1$popular => Popular (contains Aviator)

Staging Categories (different naming):
- Lobby1$videoslots
- Lobby1$crashgames

Aviator Game ID: 32430 (same in both environments)
```

**The Original Problem:**
```swift
// BROKEN: Race condition + subscription accumulation
func showAviatorGame() {
    casinoCategoriesListViewModel?.$categorySections
        .first(where: { !$0.isEmpty })
        .sink { [weak self] sections in
            // Multiple subscriptions if tapped multiple times
            // Categories might not be loaded yet
        }
        .store(in: &cancellables)  // Never cleaned up!
}
```

**The Fix:**
```swift
// FIXED: Direct navigation with hardcoded IDs
func showAviatorGame() {
    showGamePrePlay(gameId: QuickLinkConstants.aviatorGameId)
}

func showSlotsGames() {
    let categoryId = isProduction
        ? QuickLinkConstants.slotsCategoryIdProduction
        : QuickLinkConstants.slotsCategoryIdStaging
    showCategoryGamesList(categoryId: categoryId, categoryTitle: nil)
}
```

### Useful Files / Links
- `BetssonCameroonApp/App/Coordinators/CasinoCoordinator.swift` - Quick link constants and navigation
- `Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Casino/CasinoGame.swift` - Added categoryName
- `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixCasinoProvider.swift` - Pass-through mapping
- `BetssonCameroonApp/App/Screens/Casino/CasinoCategoryGamesList/CasinoCategoryGamesListViewModel.swift` - Optional title handling
- `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SimpleNavigationBarView/SimpleNavigationBarView.swift` - Dynamic title update

### Next Steps
1. Test all four quick links (Aviator, Slots, Crash, Lite) on both staging and production
2. Verify localized titles appear correctly in both EN and FR
3. Consider adding the Virtual Lobby quick links if needed in the future
