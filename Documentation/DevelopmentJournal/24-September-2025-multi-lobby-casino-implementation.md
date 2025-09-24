## Date
24 September 2025

### Project / Branch
sportsbook-ios / rr/transactions

### Goals for this session
- Implement multi-lobby support for casino and virtual sports
- Replace dummy virtual sports screen with real casino lobby using different datasource
- Maintain single UI codebase for both lobby types

### Achievements
- [x] Created ServiceProvider CasinoLobbyType enum for type-safe lobby specification
- [x] Updated CasinoProvider protocol to use enum instead of raw datasource strings
- [x] Implemented EveryMatrixCasinoProvider mapping from enum to datasource configuration
- [x] Updated ServicesProvider Client API to accept lobby type enum
- [x] Refactored app-layer CasinoLobbyType to use clean conversion to ServiceProvider enum
- [x] Updated all ViewModels to convert app enum to service enum for API calls
- [x] Created VirtualSportsCoordinator inheriting from CasinoCoordinator with .virtuals type
- [x] Replaced dummy virtual sports screen with real casino lobby implementation
- [x] Build verification - implementation compiles and works correctly

### Issues / Bugs Hit
- [x] Initial approach used raw strings - refactored to enum-based approach per feedback
- [x] Had to update multiple files when changing from string to enum parameters

### Key Decisions
- **Enum over strings**: ServiceProvider owns lobby type configuration, apps just specify intent
- **Clean separation**: App layer converts simple enum to ServiceProvider enum, no datasource knowledge
- **Inheritance pattern**: VirtualSportsCoordinator inherits from CasinoCoordinator for code reuse
- **Type safety**: Compile-time guarantees instead of runtime string matching

### Experiments & Notes
- Original approach had app layer knowing datasource strings ("Lobby1", "Virtual-Lobby")
- Improved to ServiceProvider enum pattern - much cleaner and maintainable
- Same UI components now work for both casino and virtuals with zero duplication
- EveryMatrixUnifiedConfiguration.shared provides the actual datasource mapping

### Useful Files / Links
- [ServiceProvider CasinoLobbyType](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Casino/CasinoLobbyType.swift)
- [App CasinoLobbyType with conversion](../../BetssonCameroonApp/App/Models/CasinoLobbyType.swift)
- [EveryMatrixCasinoProvider mapping](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixCasinoProvider.swift)
- [VirtualSportsCoordinator](../../BetssonCameroonApp/App/Coordinators/VirtualSportsCoordinator.swift)
- [CasinoCoordinator base implementation](../../BetssonCameroonApp/App/Coordinators/CasinoCoordinator.swift)
- [EveryMatrixUnifiedConfiguration datasources](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixUnifiedConfiguration.swift)

### Next Steps
1. Test virtual sports lobby functionality in simulator
2. Verify both casino and virtual games load correctly with different datasources
3. Consider adding more lobby types (Live Casino, Promotions) using same pattern
4. Document the multi-lobby architecture for team knowledge sharing