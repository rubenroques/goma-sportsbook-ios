## Date
04 December 2025

### Project / Branch
BetssonCameroonApp / rr/feature/lang-switcher

### Goals for this session
- Investigate why sport banners display in English even after switching to French
- Fix banner localization to respect app language setting

### Achievements
- [x] Identified root cause: CMS `/api/promotions/v1/sport-banners` endpoint supports `?language=fr` parameter but iOS app wasn't passing it
- [x] Verified CMS correctly returns French content with `?language=fr` query parameter
- [x] Added language parameter support to `sportBanners` and `casinoCarouselBanners` endpoints
- [x] Updated full chain: Schema → APIClient → Provider → Protocol → Client → ViewModel
- [x] Fixed both sport banners (TopBannerSliderViewModel) and casino banners (CasinoTopBannerSliderViewModel)

### Issues / Bugs Hit
- None - straightforward implementation following existing footer endpoints pattern

### Key Decisions
- Followed existing pattern from `footerLinks(language:)` implementation
- Used `LanguageManager.shared.currentLanguageCode` as language source (not `localized()` which uses device language)
- Made language parameter optional (`String?`) to maintain backward compatibility

### Files Modified

**ServicesProvider Framework (API Layer):**
- `GomaHomeContentAPISchema.swift` - Added language associated value to `sportBanners` and `casinoCarouselBanners` enum cases
- `GomaHomeContentAPIClient.swift` - Updated methods to accept and pass language parameter
- `GomaHomeContentProvider.swift` - Updated provider methods with language parameter
- `ManagedContentProvider.swift` - Updated protocol definitions
- `EveryMatrixManagedContentProvider.swift` - Protocol conformance updates
- `SportRadarManagedContentProvider.swift` - Protocol conformance updates
- `Client.swift` - Updated public API methods

**BetssonCameroonApp (Consumer Layer):**
- `TopBannerSliderViewModel.swift` - Pass language from LanguageManager when fetching sport banners
- `CasinoTopBannerSliderViewModel.swift` - Pass language from LanguageManager when fetching casino banners

### Technical Details

**API Change Verification:**
```bash
# Without language - returns English
curl ".../sport-banners" → "Welcome - EN Version"

# With language=fr - returns French
curl ".../sport-banners?language=fr" → "Cashout - Prends le contrôle de tes paris"
```

**Code Pattern (following footer endpoints):**
```swift
// Schema
case sportBanners(language: String?)

// Query builder
case .sportBanners(let language):
    if let language {
        queryItems.append(URLQueryItem(name: "language", value: language))
    }

// ViewModel usage
let language = LanguageManager.shared.currentLanguageCode
servicesProvider.getSportRichBanners(language: language)
```

### Next Steps
1. Test banner display in French after language switch
2. Consider adding language support to other promotional endpoints if needed (stories, hero cards, etc.)
