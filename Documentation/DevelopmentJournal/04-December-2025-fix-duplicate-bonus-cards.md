## Date
04 December 2025

### Project / Branch
BetssonCameroonApp / rr/feature/lang-switcher

### Goals for this session
- Investigate and fix duplicate bonus cards bug in Profile > Bonuses screen
- Ensure each bonus displays its unique name and description

### Achievements
- [x] Identified root cause: `bonusPlanId` was mapped from `domainID` (operator ID = 4374), which is identical for ALL bonuses
- [x] Confirmed bug via PROD API test - two bonuses have same `domainID` but unique `id` fields
- [x] Changed `bonusPlanId` type from `Int` to `String` in domain model
- [x] Fixed EveryMatrix mapper to use `bonusItem.id` instead of `bonusItem.domainID`
- [x] Updated SportRadar internal model for consistency
- [x] Fixed BonusViewModel cache to use `bonus.id` as key

### Issues / Bugs Hit
- Cache collision: All bonuses had same `bonusPlanId` (4374), so first bonus was cached and returned for all subsequent bonuses

### Key Decisions
- Changed `bonusPlanId` from `Int` to `String` to properly handle large API IDs like `"1479675370876699200"`
- Used `bonus.id` as cache key since it's guaranteed unique per bonus

### Experiments & Notes
- Tested PROD API with `+237650888006:4050` credentials
- API returns two bonuses:
  - `id: "1479675370876699200"` → "Welcome to Betsson!" / "Get a 200% First Deposit Sports Bonus + 100 Free Spins!"
  - `id: "1479713123639230724"` → "This is just a test" / "For testing purposes"
- Both share `domainID: 4374` (operator ID), confirming the bug

### Useful Files / Links
- [AvailableBonus Domain Model](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Betting/Bonus/AvailableBonus.swift)
- [EveryMatrix Bonus Mapper](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/ModelMappers/EveryMatrixModelMapper+Bonus.swift)
- [BonusViewModel](../../BetssonCameroonApp/App/Screens/Bonus/BonusViewModel.swift)
- [SportRadar AvailableBonus](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/Models/Business/Bonus/SportRadarModels+AvailableBonus.swift)

### Next Steps
1. Test with different user accounts to verify fix works across all scenarios
2. Consider adding unit tests for bonus mapping
