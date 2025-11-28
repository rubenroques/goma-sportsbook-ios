## Date
28 November 2025

### Project / Branch
sportsbook-ios / rr/bugfix/match_detail_blinks

### Goals for this session
- Explore EveryMatrix Casino API to understand available image assets
- Fix casino game cards displaying cropped/distorted images
- Use correct image types for different UI contexts (grid, preview, background)

### Achievements
- [x] Explored EM Casino API and documented 3 distinct image types:
  - `icons["114"]` - Square 114x114 icons for grid cards
  - `thumbnail` - Rectangular preview images for center display
  - `backgroundImageUrl` - Large 1280x720 landscape for backgrounds
- [x] Updated GomaUI data models to use context-specific image fields:
  - `CasinoGameCardData`: `imageURL` → `iconURL`
  - `CasinoGameImageData`: `imageURL` → `iconURL`
  - `CasinoGameSearchedData`: `imageURL` → `iconURL`
  - `CasinoGamePlayModeSelectorGameData`: `imageURL` → `thumbnailURL` + `backgroundURL`
- [x] Updated GomaUI components:
  - `CasinoGameCardView`, `CasinoGameImageView`, `CasinoGameSearchedView` → use `iconURL`
  - `CasinoGamePlayModeSelectorView` → use `thumbnailURL`
- [x] Updated all GomaUI mock view models to use new field names
- [x] Refactored `ServiceProviderModelMapper+Casino.swift` with new helper methods:
  - `squareIconURL(from:)` - extracts square icons (114 > 88 > 72)
  - `thumbnailURL(from:)` - extracts rectangular thumbnail
  - `backgroundURL(from:)` - extracts large background image
  - `bestIconURL(from:)` - falls back gracefully
- [x] Updated `CasinoGamePrePlayViewController` to use `backgroundURL` for full-screen background
- [x] Updated `CasinoGamePrePlayViewModel` to provide both `thumbnailURL` and `backgroundURL`

### Issues / Bugs Hit
- None - straightforward refactoring with clear scope

### Key Decisions
- **Replace imageURL** instead of adding new fields alongside - breaking change but cleaner API
- **Icon priority**: 114 > 88 > 72 (prefer highest quality square)
- **Fallback**: If no icons available, fall back to thumbnail for grid cards
- Made `thumbnailURL(from:)` and `backgroundURL(from:)` static (not private) so ViewModel can access them directly

### Experiments & Notes
- Tested EM Casino API with cURL:
  ```bash
  # Categories
  curl "https://betsson.nwacdn.com/v2/casino/groups/Lobby1?language=en&platform=iPhone"

  # Games for category
  curl "https://betsson.nwacdn.com/v2/casino/groups/Lobby1/Lobby1\$video-slots?language=en&platform=iPhone&expand=games"
  ```
- API returns `icons` as dictionary with string keys: `{"114": "url", "88": "url", ...}`
- `thumbnails` field exists but is always empty in prod data

### Useful Files / Links
- [ServiceProviderModelMapper+Casino.swift](../../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+Casino.swift)
- [CasinoGameCardViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CasinoGameCardView/CasinoGameCardViewModelProtocol.swift)
- [CasinoGameImageData.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CasinoGameImageView/CasinoGameImageData.swift)
- [CasinoGamePlayModeSelectorViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CasinoGamePlayModeSelectorView/CasinoGamePlayModeSelectorViewModelProtocol.swift)
- [CasinoGamePrePlayViewController.swift](../../BetssonCameroonApp/App/Screens/Casino/CasinoGamePrePlay/CasinoGamePrePlayViewController.swift)
- [CasinoGamePrePlayViewModel.swift](../../BetssonCameroonApp/App/Screens/Casino/CasinoGamePrePlay/CasinoGamePrePlayViewModel.swift)

### Next Steps
1. Build and verify GomaUIDemo compiles
2. Build and verify BetssonCameroonApp compiles
3. Run app to verify:
   - Casino home grid displays square icons (no cropping)
   - Pre-play screen shows rectangular thumbnail in center
   - Pre-play screen shows large background image
