## Date
08 September 2025

### Project / Branch
sportsbook-ios / rr/mybets_profile_features

### Goals for this session
- Migrate EveryMatrix Casino API from v1 to v2 endpoints
- Apply same API structure changes from web implementation
- Fix vendor display issues in UI components
- Centralize datasource configuration

### Achievements
- [x] Added `casinoDataSource` property to EveryMatrixUnifiedConfiguration with "Lobby1" value
- [x] Updated Casino API endpoints from v1 to v2:
  - Categories: `/v1/casino/categories` → `/v2/casino/groups/{datasource}`
  - Games: `/v1/casino/games` → `/v2/casino/groups/{datasource}/{categoryId}`
- [x] Refactored DTOs to handle v2 response structure:
  - Removed `href` from CasinoCategoryDTO
  - Added CasinoGroupResponseDTO for nested games response
  - Simplified CasinoGameVendorDTO to only contain href
- [x] Updated EveryMatrixCasinoProvider to handle nested response (`response.games.items`)
- [x] Made vendor optional throughout system (CasinoGame model, DTOs, ViewModels)
- [x] Fixed compilation errors in BetssonCameroonApp
- [x] Updated GomaUI components to hide vendor labels when nil

### Issues / Bugs Hit
- [x] v2 API vendor structure only contains href, not full vendor details
- [x] Provider field type mismatches between optional and non-optional
- [x] FailableDecodable needed for arrays that could have parsing failures

### Key Decisions
- **No backwards compatibility** - Clean migration to v2 only
- **Vendor not displayed** - Matching web implementation, vendor removed from UI
- **Datasource centralized** - "Lobby1" in EveryMatrixUnifiedConfiguration
- **Simplified vendor handling** - Set to nil instead of complex extraction logic

### Experiments & Notes
- v2 API testing showed category IDs use format: `Lobby1$categoryName`
- Staging environment returns test data (test1, test2, abc categories)
- Web uses same datasource approach with query/URL params separation
- FailableDecodable prevents entire response failure when single item fails

### Useful Files / Links
- [EveryMatrixUnifiedConfiguration.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixUnifiedConfiguration.swift)
- [EveryMatrixCasinoAPI.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CasinoAPI/EveryMatrixCasinoAPI.swift)
- [EveryMatrixCasinoProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixCasinoProvider.swift)
- [CasinoGameCardView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CasinoGameCardView/CasinoGameCardView.swift)
- [Web implementation reference](../../../Web/sportsbook-frontend/sportsbook-frontend-demo)

### Next Steps
1. Verify production datasource configuration when available
2. Test with real casino data once staging has proper content
3. Consider removing vendor-related code completely in future cleanup
4. Monitor for any UI layout issues with hidden vendor labels