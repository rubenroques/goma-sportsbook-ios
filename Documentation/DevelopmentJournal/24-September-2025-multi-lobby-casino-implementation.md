## Date
24 September 2025

### Project / Branch
sportsbook-ios / rr/transactions

### Goals for this session
- Implement multi-lobby support for casino and virtual sports
- Replace dummy virtual sports screen with real casino lobby using different datasource
- Maintain single UI codebase for both lobby types
- Add configurable banner display (casino shows banners, virtuals doesn't)

### Achievements
- [x] Created ServiceProvider CasinoLobbyType enum for type-safe lobby specification
- [x] Updated CasinoProvider protocol to use enum instead of raw datasource strings
- [x] Implemented EveryMatrixCasinoProvider mapping from enum to datasource configuration
- [x] Updated ServicesProvider Client API to accept lobby type enum
- [x] Refactored app-layer CasinoLobbyType to use clean conversion to ServiceProvider enum
- [x] Updated all ViewModels to convert app enum to service enum for API calls
- [x] ~~Created VirtualSportsCoordinator inheriting from CasinoCoordinator with .virtuals type~~ **REMOVED**
- [x] Simplified to use single CasinoCoordinator with enum parameter differentiation
- [x] Renamed coordinator variables: `traditionalCasinoCoordinator` and `virtualSportsCasinoCoordinator`
- [x] Replaced dummy virtual sports screen with real casino lobby implementation
- [x] **Added configurable banner display**: Traditional casino shows banners, virtual sports doesn't
- [x] **Implemented fixed sections approach**: Clean UICollectionView sections-based layout
- [x] Build verification - implementation compiles and works correctly

### Issues / Bugs Hit
- [x] Initial approach used raw strings - refactored to enum-based approach per feedback
- [x] Had to update multiple files when changing from string to enum parameters
- [x] Over-engineered with VirtualSportsCoordinator - removed in favor of single coordinator
- [x] Complex index math in collection view - solved with fixed sections approach

### Key Decisions
- **Enum over strings**: ServiceProvider owns lobby type configuration, apps just specify intent
- **Clean separation**: App layer converts simple enum to ServiceProvider enum, no datasource knowledge
- **~~Inheritance pattern~~**: ~~VirtualSportsCoordinator inherits from CasinoCoordinator~~ **REMOVED**
- **Parameterization over inheritance**: Single CasinoCoordinator with enum parameter is cleaner
- **Clear variable naming**: `traditionalCasinoCoordinator` vs `virtualSportsCasinoCoordinator`
- **Type safety**: Compile-time guarantees instead of runtime string matching
- **Fixed sections over dynamic indexing**: UICollectionView sections (0=Banner, 1=Recent, 2=Categories) instead of complex index math
- **Simple boolean configuration**: `showTopBanner` flag defaults to lobby type behavior

### Experiments & Notes
- Original approach had app layer knowing datasource strings ("Lobby1", "Virtual-Lobby")
- Improved to ServiceProvider enum pattern - much cleaner and maintainable
- Same UI components now work for both casino and virtuals with zero duplication
- EveryMatrixUnifiedConfiguration.shared provides the actual datasource mapping
- **Mid-session refactor**: Realized VirtualSportsCoordinator was unnecessary - CasinoCoordinator already supported lobbyType parameter
- **Parameterization > Inheritance**: Single class with enum parameter beats inheritance hierarchy
- **Collection view sections insight**: Fixed sections (0=Banner, 1=Recent, 2=Categories) with section 0 returning 0 items when disabled is much cleaner than dynamic indexing
- **Banner configuration**: `showTopBanner` boolean automatically determined by lobby type, topBannerSliderViewModel becomes optional

### Useful Files / Links
- [ServiceProvider CasinoLobbyType](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Casino/CasinoLobbyType.swift)
- [App CasinoLobbyType with conversion](../../BetssonCameroonApp/App/Models/CasinoLobbyType.swift)
- [EveryMatrixCasinoProvider mapping](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixCasinoProvider.swift)
- [~~VirtualSportsCoordinator~~](~~../../BetssonCameroonApp/App/Coordinators/VirtualSportsCoordinator.swift~~) **REMOVED**
- [CasinoCoordinator unified implementation](../../BetssonCameroonApp/App/Coordinators/CasinoCoordinator.swift)
- [MainTabBarCoordinator with both lobby types](../../BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift)
- [CasinoCategoriesListViewModel with banner config](../../BetssonCameroonApp/App/Screens/Casino/CasinoCategoriesList/CasinoCategoriesListViewModel.swift)
- [CasinoCategoriesListViewController with sections](../../BetssonCameroonApp/App/Screens/Casino/CasinoCategoriesList/CasinoCategoriesListViewController.swift)
- [EveryMatrixUnifiedConfiguration datasources](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixUnifiedConfiguration.swift)

### Next Steps
1. ~~Test virtual sports lobby functionality in simulator~~ **COMPLETED - Working!**
2. ~~Verify both casino and virtual games load correctly with different datasources~~ **COMPLETED - Working!**
3. ~~Verify banner display works correctly for both lobby types~~ **COMPLETED - Working!**
4. Consider adding more lobby types (Live Casino, Promotions) using same pattern
5. Document the multi-lobby architecture for team knowledge sharing