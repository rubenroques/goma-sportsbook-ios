## Date
19 July 2025

### Project / Branch
sportsbook-ios / ServicesProvider EveryMatrix improvements

### Goals for this session
- Fix market group data isolation issue in MatchDetailsManager
- Implement outcome sorting using headerNameKey
- Add market sorting within betting type groups
- Add missing paramFloat2/paramFloat3 properties to Market models

### Achievements
- [x] **Market Group Data Isolation**: Added isolated EntityStore per market group subscription
  - [x] Fixed accumulation bug where later market groups received all previous group markets
  - [x] Added `marketGroupStores: [String: EveryMatrix.EntityStore]` dictionary
  - [x] Updated subscription cleanup to clear isolated stores
- [x] **Outcome Sorting**: Implemented consistent outcome ordering using headerNameKey
  - [x] Used existing `EveryMatrixModelMapper.sortValue(forOutcomeHeaderKey:)` method
  - [x] Applied sorting in MarketBuilder for home→draw→away, yes→no patterns
- [x] **Market Model Enhancement**: Added missing paramFloat properties
  - [x] Added `paramFloat2: Double?` and `paramFloat3: Double?` to MarketDTO
  - [x] Added same properties to composed Market model
  - [x] Updated MarketBuilder mapping to include new properties
- [x] **Market Sorting**: Implemented stable sort preserving original positioning
  - [x] Only sorts markets with same bettingTypeId by paramFloat1→paramFloat2→paramFloat3
  - [x] Preserves original market order for different betting types

### Issues / Bugs Hit
- [x] ~~Initially planned to import Core module but found ServicesProvider had its own sorting method~~
- [x] ~~First market sorting approach would have reordered all markets by bettingTypeId (architectural concern)~~

### Key Decisions
- **Used ServicesProvider's existing sorting**: Found `EveryMatrixModelMapper.sortValue(forOutcomeHeaderKey:)` instead of importing Core
- **Stable sort for markets**: Preserves original market positioning, only sorts within same bettingTypeId groups
- **Isolated EntityStore per market group**: Each subscription gets clean, separate data storage
- **paramFloat fallback**: Uses `Double.greatestFiniteMagnitude` for nil values to ensure they sort last

### Experiments & Notes
- Found paramFloat2/paramFloat3 in example response files but missing from DTOs/models
- Outcome.headerNameKey already properly mapped by OutcomeBuilder.swift:32
- Market sorting uses stable sort (return false for different betting types) to maintain business logic order

### Useful Files / Links
- [MatchDetailsManager](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/SubscriptionManagers/MatchDetailsManager.swift) - Main isolation fix
- [MarketBuilder](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Builders/MarketBuilder.swift) - Outcome sorting implementation  
- [MatchBuilder](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Builders/MatchBuilder.swift) - Market sorting implementation
- [MarketDTO](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/DataTransferObjects/MarketDTO.swift) - Added paramFloat2/3
- [Market Composed](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Composed/Market.swift) - Added paramFloat2/3
- [EveryMatrixModelMapper+Events](../../../ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+Events.swift) - Outcome sorting utility

### Next Steps
1. Test market group isolation fix with multiple concurrent subscriptions
2. Verify outcome sorting works correctly across different sports/markets
3. Validate market sorting behavior with real data containing paramFloat values
4. Consider adding unit tests for the new sorting logic