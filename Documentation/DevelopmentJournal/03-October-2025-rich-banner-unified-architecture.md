# Rich Banner Unified Architecture Implementation

## Date
03 October 2025

### Project / Branch
sportsbook-ios / rr/bettingOfferSubscription

### Goals for this session
- Unify casino and sport banner systems to support all banner types (info, casino game, sport event)
- Fix the issue where `getCasinoCarouselGames()` and `getCarouselEvents()` only returned one banner type
- Implement proper 3-layer architecture with enrichment for both endpoints

### Achievements
- [x] Created unified `RichBanner` enum with 3 cases: `info`, `casinoGame`, `sportEvent`
- [x] Implemented internal models (`GomaModels.RichBanner`) with custom Codable for type discrimination
- [x] Created public models (`RichBanner`, `InfoBanner`, `SportEventBanner`) with enriched data
- [x] Implemented model mappers with parallel enrichment logic
- [x] Updated GomaHomeContentAPIClient with new `casinoRichBanners()` and `sportRichBanners()` methods
- [x] Implemented parallel fetching of casino games and events while preserving banner order
- [x] Updated ManagedContentProvider protocol with new methods
- [x] Added stub implementations for EveryMatrix and SportRadar providers
- [x] Updated Client facade with public API methods
- [x] Fixed `getGameDetails()` to return non-optional and throw errors for consistency

### Issues / Bugs Hit
- [x] Cannot use `weak` on protocols without class constraints - removed `weak` references
- [x] Double dot typo `casinoProvider..getCasinoGames` - fixed
- [x] Wrong method names - CasinoProvider uses `getGameDetails()`, EventsProvider uses `getEventDetails()`
- [x] Missing legacy `CasinoCarouselPointer` types causing compile errors - re-added for backward compatibility
- [x] Type conversion issues with optionals - `getGameDetails` already returns optional, needed proper mapping
- [x] Order preservation concern with `Publishers.MergeMany` - resolved by having mapper iterate `internalBanners` in order

### Key Decisions
- **Unified enum approach**: Both endpoints return the same `RichBanners` array, not separate types
- **Shared "info" banner**: Both casino and sport endpoints use identical info banner structure (confirmed via API testing)
- **Naming**: `RichBanner` chosen over `CompositeBanner` for better semantics
- **Method naming**: `getCasinoRichBanners()` and `getSportRichBanners()` instead of confusing names like `getCarouselEvents`
- **Order preservation**: Mapper iterates `internalBanners` array in order and looks up games/events by ID from fetched results
- **Parallel fetching**: Use `Publishers.MergeMany` + `.collect()` for efficiency, with dictionary lookup in mapper
- **Error handling**: Updated `getGameDetails()` to return non-optional `CasinoGame` and throw `ServiceProviderError.resourceNotFound` for consistency
- **No backward compatibility**: Removed deprecated methods - clean break

### Experiments & Notes
- **API Analysis**: Used cURL to test both endpoints with anonymous auth token
  ```bash
  # Casino endpoint returns: type="game" | type="info"
  curl -X GET "https://api.gomademo.com/api/promotions/v1/casino-carousel-banners"

  # Sport endpoint returns: type="event" | type="info"
  curl -X GET "https://api.gomademo.com/api/promotions/v1/sport-banners"
  ```
- **Info banners are identical**: Same fields (id, title, subtitle, cta_text, cta_url, cta_target, image_url) in both endpoints
- **Order preservation strategy**: Dictionary doesn't preserve order, but mapper does by iterating `internalBanners` in original order and using `first(where:)` lookup
- **Optional handling**: `getGameDetails` returns `CasinoGame?` → need `.map { Optional.some($0) }` before `.catch`
  - **UPDATE**: Changed to non-optional `CasinoGame` for consistency, now uses `.map { Optional.some($0) }` in caller

### Useful Files / Links
#### Created Files
- [RichBanner.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Content/Promotions/RichBanner.swift) - Public enum and models

#### Modified Files
- [GomaModels+Promotions.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+Promotions.swift) - Internal RichBanner enum
- [GomaModelMapper+Promotions.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/Mappers/GomaModelMapper+Promotions.swift) - Mapper with enrichment
- [GomaHomeContentAPIClient.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/Subsets/ManagedHomeContent/GomaHomeContentAPIClient.swift) - API client methods
- [GomaHomeContentProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/Subsets/ManagedHomeContent/GomaHomeContentProvider.swift) - Provider with parallel fetch
- [ManagedContentProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/ManagedContentProvider.swift) - Protocol updates
- [EveryMatrixManagedContentProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixManagedContentProvider.swift) - Stub implementations
- [SportRadarManagedContentProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarManagedContentProvider.swift) - Stub implementations
- [EveryMatrixCasinoProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixCasinoProvider.swift) - Made getGameDetails non-optional
- [CasinoProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/CasinoProvider.swift) - Updated protocol signature
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift) - Public facade methods

### Architecture Details

#### 3-Layer Structure
```swift
// Layer 1: Internal Models (GomaModels)
enum GomaModels.RichBanner {
  case info(InfoBannerData)           // id, title, subtitle, cta fields, imageUrl
  case casinoGame(CasinoGameBannerData) // id, title, subtitle, casinoGameId, cta fields, imageUrl
  case sportEvent(SportEventBannerData) // id, sportEventId, sportEventMarketId, imageUrl, market IDs
}

// Layer 2: Public Models (ServicesProvider)
enum RichBanner {
  case info(InfoBanner)                    // Simple info banner
  case casinoGame(CasinoGameBanner)        // Contains full CasinoGame + metadata
  case sportEvent(SportEventBanner)        // Contains ImageHighlightedContent<Event> + market IDs
}

// Layer 3: Enrichment Flow
1. Fetch raw banners from API (GomaModels.RichBanners)
2. Extract IDs (casino game IDs or event IDs)
3. Fetch games/events in parallel (Publishers.MergeMany)
4. Map using GomaModelMapper.richBanners() which:
   - Iterates internalBanners in original order
   - Looks up games/events by ID
   - Creates enriched RichBanner enum cases
```

#### Order Preservation Strategy
```swift
// Order is NOT guaranteed by Publishers.MergeMany
// BUT order IS preserved by mapper iteration:
return internalBanners.compactMap { internalBanner in  // ← Iterates in order!
    switch internalBanner {
    case .casinoGame(let data):
        guard let game = casinoGames.first(where: { $0.id == data.casinoGameId }) else {
            return nil  // Skip if game not found
        }
        // Create enriched banner...
    }
}
```

### Next Steps
1. **Update ViewModels** to consume `RichBanners` and handle enum cases:
   ```swift
   client.getCasinoRichBanners()
       .sink { richBanners in
           richBanners.forEach { banner in
               switch banner {
               case .info(let info): // Show info banner
               case .casinoGame(let game): // Show casino game
               case .sportEvent: // Ignore in casino context
               }
           }
       }
   ```
2. **Remove old methods**: Delete `getCasinoCarouselGames()`, `getCarouselEvents()`, `getCasinoCarouselPointers()`, `getCarouselEventPointers()`
3. **Update BetssonCameroonApp** to use new rich banner API
4. **Test with real API** to verify all three banner types work correctly
5. **Consider caching strategy** for enriched banners to avoid re-fetching games/events

### Testing Notes
- Build verified with `xcodebuild -workspace Sportsbook.xcworkspace -scheme BetssonCameroonApp`
- All compile errors resolved
- API tested with cURL using anonymous auth token
- Confirmed "info" banner structure is identical between endpoints

### Migration Notes for Other Developers
**Breaking Changes:**
- `getCasinoCarouselGames()` → `getCasinoRichBanners()`
- `getCarouselEvents()` → `getSportRichBanners()`
- Return type changed from single-purpose arrays to unified `RichBanners` enum
- `CasinoProvider.getGameDetails()` now returns non-optional `CasinoGame` and throws errors

**New Capabilities:**
- Info banners now supported in both casino and sport contexts
- Type-safe banner handling with enum exhaustive switching
- Full enrichment with parallel fetching for better performance
