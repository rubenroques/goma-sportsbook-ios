## Date
28 November 2025

### Project / Branch
BetssonCameroonApp / rr/bugfix/match_detail_blinks

### Goals for this session
- Investigate duplicate `/v1/casino/recommendedGames` API calls on login
- Fix Casino Search page to use correct endpoints (matching web app behavior)
- Fix Casino Lobby "Recently Played" section to use actual API data

### Achievements
- [x] Identified root cause of duplicate API calls in `CasinoSearchViewModel.getMostPlayedGames()`
- [x] Fixed `getMostPlayedGames()` to call `/v1/player/{userId}/games/most-played` instead of falling back to `getRecommendedGames()`
- [x] Implemented proper "Recently Played" section in Casino Lobby:
  - Added `showRecentlyPlayed` published property to control visibility
  - Added `loadRecentlyPlayedGames()` method calling `/v1/player/{userId}/games/last-played` API
  - Added `setupUserSessionSubscription()` to react to login/logout
  - Section now only shows when user is logged in AND has play history
- [x] Removed placeholder `updateRecentlyPlayedFromCategories()` that was using category games as fake "recently played"

### Issues / Bugs Hit
- [x] SSE endpoint `/v2/player/{userId}/information/updates` returning 503 - server-side issue, not app bug (reconnection logic working correctly with exponential backoff)

### Key Decisions
- **Casino Search page endpoints** (matching web app):
  - Initial state: Only `recommendedGames`
  - Searching: `searchGames` + `mostPlayedGames` (web also has `recentlyPlayedGames` but iOS doesn't show that on search)
- **Casino Lobby "Recently Played"**: Uses `/v1/player/{userId}/games/last-played` API, hidden when logged out or no games

### Experiments & Notes
- Web app analysis revealed endpoint mapping:
  - `/v1/casino/recommendedGames` - AI recommended games
  - `/v1/player/{userId}/games/most-played` - Most played by user
  - `/v1/player/{userId}/games/last-played` - Recently played (last 7 days)
- ServicesProvider already had all endpoints implemented, just needed to wire them up correctly

### Useful Files / Links
- [CasinoSearchViewModel](../../BetssonCameroonApp/App/Screens/CasinoSearch/CasinoSearchViewModel.swift) - Fixed duplicate calls
- [CasinoCategoriesListViewModel](../../BetssonCameroonApp/App/Screens/Casino/CasinoCategoriesList/CasinoCategoriesListViewModel.swift) - Added Recently Played API integration
- [CasinoCategoriesListViewController](../../BetssonCameroonApp/App/Screens/Casino/CasinoCategoriesList/CasinoCategoriesListViewController.swift) - Added visibility binding
- [EveryMatrixPlayerAPI](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/PlayerAPI/EveryMatrixPlayerAPI.swift) - Endpoint definitions

### Next Steps
1. Build and test the changes in simulator
2. Verify Recently Played section shows/hides correctly on login/logout
3. Test with user that has actual play history to confirm API returns data
4. Consider adding "Recently Played" to search page when searching (like web app does)
