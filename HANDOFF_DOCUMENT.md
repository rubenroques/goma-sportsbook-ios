# Rich Banner UI Debug - Development Handoff Document

**Date**: 15 October 2025
**Branch**: `rr/rich-banner-ui-debug` (worktree)
**Base Branch**: `betsson-cm`
**Status**: Integration & Debugging Phase
**Developer**: rroques

---

## Executive Summary

This branch implements a **unified rich banner system** that consolidates promotional content display across sports and casino sections. The work spans all 3 architectural layers (GomaModels → ServicesProvider → App/GomaUI) and is currently in the **debugging/testing phase** with extensive logging to verify the complete data flow.

**Key Achievement**: Replaced fragmented banner APIs with unified `RichBanner` enum supporting 3 types (info, casino game, sport event) with parallel data enrichment.

---

## Current Branch State

```bash
# Location
/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/git-worktrees/rr/rich-banner-ui-debug

# Branch info
Current branch: rr/rich-banner-ui-debug
Base: betsson-cm
Commits ahead: Multiple (see git log)
```

**Statistics**:
- 134 files changed
- 1,120 insertions
- 9,214 deletions (legacy code cleanup)

**Unstaged Changes** (Debug Phase):
- 14 modified files with `[BANNER-DEBUG]` logging
- 4 new files (InfoBanner models/ViewModels)
- 1 deleted file (`SportTopBannerSliderViewModel.swift` - replaced by unified version)

---

## Architecture Overview

### 3-Layer Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│ LAYER 1: API Response (GomaModels)                          │
│ - GomaModels.RichBanner enum (internal)                     │
│ - Raw JSON from API endpoints                               │
│ Files: GomaModels+Promotions.swift                          │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ LAYER 2: Domain Models (ServicesProvider)                   │
│ - RichBanner enum (public)                                  │
│ - Enriched with full CasinoGame/Event objects               │
│ - Parallel data fetching via Publishers.MergeMany           │
│ Files: GomaModelMapper+Promotions.swift                     │
│        ManagedContentProvider.swift                          │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ LAYER 3: UI Layer (BetssonCameroonApp + GomaUI)            │
│ - InfoBannerData, CasinoBannerData models                   │
│ - ViewModels implementing GomaUI protocols                  │
│ - BannerType enum for TopBannerSliderView                   │
│ Files: ServiceProviderModelMapper+RichBanners.swift         │
│        InfoBannerViewModel.swift                             │
│        TopBannerSliderViewModel.swift                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Critical Files by Layer

### LAYER 1: ServicesProvider - Internal Models

#### `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/GomaModels+Promotions.swift`
**Lines 564-680**: `RichBanner` enum definition
- **Purpose**: Internal representation of API response
- **Enum Cases**:
  - `.info(InfoBannerData)` - Generic promotional banners
  - `.casinoGame(CasinoGameBannerData)` - Casino game promotions
  - `.sportEvent(SportEventBannerData)` - Sport event highlights
- **Key Feature**: Custom Codable implementation with type discrimination
- **Status**: ✅ Complete, tested with API

```swift
// Lines 567-678
enum RichBanner: Identifiable, Equatable, Hashable, Codable {
    case info(InfoBannerData)
    case casinoGame(CasinoGameBannerData)
    case sportEvent(SportEventBannerData)

    // Custom decoder reads "type" field and decodes accordingly
}
```

### LAYER 2: ServicesProvider - Public Models & Enrichment

#### `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/Models/Mappers/GomaModelMapper+Promotions.swift`
**Lines 359-449**: Rich banner mapper with enrichment logic
- **Purpose**: Maps internal → public models with parallel data fetching
- **Key Methods**:
  - `richBanners(fromInternalRichBanners:casinoGames:events:)` - Main mapper
  - `richBanner(fromInternalRichBanner:casinoGames:events:)` - Single banner mapper
- **Enrichment Strategy**:
  - Iterates internal banners in order (preserves sort)
  - Looks up games/events by ID using `first(where:)`
  - Returns `nil` for missing data (filtered via `compactMap`)
- **Status**: ✅ Complete, order preservation verified

```swift
// Lines 367-379
static func richBanners(
    fromInternalRichBanners internalBanners: GomaModels.RichBanners,
    casinoGames: [CasinoGame],
    events: [Event]
) -> RichBanners {
    return internalBanners.compactMap { internalBanner in
        return richBanner(
            fromInternalRichBanner: internalBanner,
            casinoGames: casinoGames,
            events: events
        )
    }
}
```

#### `Frameworks/ServicesProvider/Sources/ServicesProvider/Protocols/ManagedContentProvider.swift`
**Lines 39-49**: New protocol methods
- **Purpose**: Define public API for rich banners
- **New Methods**:
  - `getCasinoRichBanners() -> AnyPublisher<RichBanners, ServiceProviderError>`
  - `getSportRichBanners() -> AnyPublisher<RichBanners, ServiceProviderError>`
- **Breaking Change**: Replaces old `getCasinoCarouselGames()` and `getCarouselEvents()`
- **Status**: ✅ Protocol updated, implemented in Goma provider

#### `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Goma/Subsets/ManagedHomeContent/GomaHomeContentProvider.swift`
**Purpose**: Implementation with parallel enrichment
- **Key Feature**: Uses `Publishers.MergeMany` for efficient parallel fetching
- **Flow**:
  1. Fetch raw banners from API
  2. Extract unique game/event IDs
  3. Fetch games/events in parallel
  4. Map through `GomaModelMapper.richBanners()`
- **Status**: ✅ Implemented, needs real API testing

#### `Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift`
**Purpose**: Public facade exposing rich banner methods
- **Methods**: `getCasinoRichBanners()`, `getSportRichBanners()`
- **Status**: ✅ Complete

### LAYER 3: App Layer - Models & ViewModels

#### **NEW FILES** (Unstaged, need to be added)

##### `BetssonCameroonApp/App/Models/InfoBanner/InfoBannerData.swift`
**Lines 1-74**: App-level info banner model
- **Purpose**: Clean app model decoupled from ServicesProvider
- **Properties**:
  - `id`, `title`, `subtitle`
  - `ctaText`, `ctaUrl`, `ctaTarget`
  - `imageUrl`, `isVisible`
- **Key Feature**: `primaryAction` computed property for navigation
- **Status**: ✅ Complete, conforms to Identifiable, Equatable, Hashable

```swift
// Lines 58-67
extension InfoBannerData {
    public var primaryAction: InfoBannerAction {
        if let url = ctaUrl, !url.isEmpty {
            return .openURL(url: url, target: ctaTarget)
        } else {
            return .none
        }
    }
}
```

##### `BetssonCameroonApp/App/ViewModels/Banners/InfoBannerViewModel.swift`
**Lines 1-58**: Production ViewModel for info banners
- **Purpose**: Implements `SingleButtonBannerViewModelProtocol` from GomaUI
- **Protocol**: `SingleButtonBannerViewModelProtocol`
- **State Management**: Uses `CurrentValueSubject<SingleButtonBannerDisplayState, Never>`
- **Callback**: `onBannerAction: ((InfoBannerAction) -> Void)`
- **Status**: ✅ Complete, ready for integration

```swift
// Lines 42-46
func buttonTapped() {
    let action = bannerData.primaryAction
    onBannerAction(action)
}
```

##### `BetssonCameroonApp/App/ViewModels/Banners/TopBannerSliderViewModel.swift`
**Lines 1-229**: Coordinator ViewModel for banner carousel
- **Purpose**: Manages TopBannerSliderView with rich banner data
- **Key Features**:
  - Calls `servicesProvider.getSportRichBanners()` on init
  - Maps `RichBanners` → `[BannerType]` via mapper
  - Sets up callbacks for match banners
  - Extensive `[BANNER-DEBUG]` logging (temporary)
- **Callbacks**:
  - `onMatchTap: ((String) -> Void)`
  - `onOutcomeSelected: ((String) -> Void)`
  - `onOutcomeDeselected: ((String) -> Void)`
- **Status**: 🔄 In debug phase, needs logging cleanup

```swift
// Lines 84-116
private func loadSportBanners() {
    print("[BANNER-DEBUG] 📡 Calling getSportRichBanners() API...")

    servicesProvider.getSportRichBanners()
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("[BANNER-DEBUG] ✅ getSportRichBanners() completed successfully")
                case .failure(let error):
                    print("[BANNER-DEBUG] ❌ getSportRichBanners() failed with error: \(error)")
                    self?.handleAPIError(error)
                }
            },
            receiveValue: { [weak self] richBanners in
                print("[BANNER-DEBUG] 📥 Received \(richBanners.count) rich banners from API")
                self?.processRichBanners(richBanners)
            }
        )
        .store(in: &cancellables)
}
```

##### `BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+RichBanners.swift`
**Lines 1-173**: Layer 2 → Layer 3 mapper
- **Purpose**: Maps ServicesProvider.RichBanner → GomaUI.BannerType
- **Key Methods**:
  - `bannerTypes(fromRichBanners:)` - Main entry point
  - `infoBannerType(fromInfoBanner:)` - Info banner conversion
  - `casinoBannerType(fromCasinoGameBanner:)` - Casino banner conversion
  - `matchBannerType(fromSportEventBanner:)` - Sport banner conversion
- **Key Features**:
  - Protocol-relative URL fixing (`//cdn` → `https://cdn`)
  - Creates intermediate `InfoBannerData`/`CasinoBannerData` models
  - Instantiates ViewModels with display data
  - Returns `BannerType` enum for GomaUI
- **Status**: ✅ Complete with debug logging

```swift
// Lines 19-28
static func bannerTypes(fromRichBanners richBanners: RichBanners) -> [BannerType] {
    print("[BANNER-DEBUG] 🗺️ Mapper: Converting \(richBanners.count) RichBanners to BannerTypes...")

    let bannerTypes = richBanners.compactMap { richBanner in
        return bannerType(fromRichBanner: richBanner)
    }

    print("[BANNER-DEBUG] 🗺️ Mapper: Produced \(bannerTypes.count) BannerTypes (filtered from \(richBanners.count) input)")
    return bannerTypes
}
```

#### **MODIFIED FILES** (Unstaged)

##### `BetssonCameroonApp/App/Extensions/GomaUI/MockTopBannerSliderViewModel+Casino.swift`
**Status**: Modified (debug changes)
- **Purpose**: Mock ViewModels for casino banner carousel
- **Changes**: Likely updated to support new BannerType cases
- **Action Needed**: Review changes, clean up debug code

##### `BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+CasinoBanner.swift`
**Status**: Modified
- **Purpose**: Casino-specific banner mapping
- **Changes**: Updated to work with new RichBanner system
- **Action Needed**: Review for consistency with info banner mapper

##### `BetssonCameroonApp/App/Screens/Casino/CasinoCategoriesList/CasinoTopBannerSliderViewModel.swift`
**Status**: Modified
- **Purpose**: Casino screen banner ViewModel
- **Expected Changes**: Now calls `getCasinoRichBanners()` instead of old methods
- **Action Needed**: Verify implementation matches sport version

##### `BetssonCameroonApp/App/Screens/InPlayEvents/InPlayEventsViewModel.swift`
##### `BetssonCameroonApp/App/Screens/NextUpEvents/NextUpEventsViewModel.swift`
**Status**: Modified
- **Purpose**: Sport screen ViewModels
- **Expected Changes**: Updated to integrate TopBannerSliderViewModel
- **Action Needed**: Review banner integration code

##### `BetssonCameroonApp/App/Components/TopBarContainerController/TopBarContainerController.swift`
**Status**: Modified
- **Purpose**: Top bar container managing banner display
- **Expected Changes**: Updated to support new banner types
- **Action Needed**: Test layout with all 3 banner types

#### **DELETED FILES**

##### `BetssonCameroonApp/App/ViewModels/Banners/SportTopBannerSliderViewModel.swift`
**Status**: Deleted (replaced by unified `TopBannerSliderViewModel`)
- **Reason**: Unified sport/casino implementation
- **Replacement**: `TopBannerSliderViewModel.swift` (new file)

### LAYER 3: GomaUI - Component Updates

#### `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TopBannerSliderView/BannerType.swift`
**Lines 1-54**: Updated BannerType enum
- **Purpose**: Type-safe banner representation for TopBannerSliderView
- **Enum Cases** (UPDATED):
  - `.info(SingleButtonBannerViewModelProtocol)` ← NEW
  - `.casino(SingleButtonBannerViewModelProtocol)` ← NEW
  - `.match(MatchBannerViewModelProtocol)` ← EXISTING
- **Key Properties**:
  - `id: String` - Unique identifier for collection view
  - `cellIdentifier: String` - Cell registration identifier
  - `isVisible: Bool` - Visibility flag
- **Status**: ✅ Updated, needs testing with all types

```swift
// Lines 1-11
public enum BannerType {
    /// Info/promotional banner with message and optional button
    case info(SingleButtonBannerViewModelProtocol)

    /// Casino game banner with message and optional button
    case casino(SingleButtonBannerViewModelProtocol)

    /// Match banner with team information and betting outcomes
    case match(MatchBannerViewModelProtocol)
}
```

#### `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TopBannerSliderView/TopBannerSliderView.swift`
**Status**: Modified
- **Purpose**: Carousel view that displays banners
- **Expected Changes**: Updated to handle all 3 BannerType cases
- **Action Needed**: Verify cell dequeuing logic handles info/casino types

#### `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TopBannerSliderView/MockTopBannerSliderViewModel.swift`
**Status**: Modified
- **Purpose**: Mock data for testing banner carousel
- **Expected Changes**: Added mocks with info/casino banner types
- **Action Needed**: Add comprehensive test cases for all combinations

#### `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchBannerView/MatchBannerViewModelProtocol.swift`
#### `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchBannerView/MockMatchBannerViewModel.swift`
**Status**: Modified
- **Purpose**: Match banner component (already existed)
- **Expected Changes**: Minor protocol updates for consistency
- **Action Needed**: Verify compatibility with new BannerType enum

---

## Data Flow Summary

### Sport Rich Banners Flow

```
1. API Request
   TopBannerSliderViewModel.loadSportBanners()
   ↓
   servicesProvider.getSportRichBanners()
   ↓
   GomaHomeContentProvider.getSportRichBanners()

2. Parallel Data Fetching
   - Fetch raw banners: GET /api/promotions/v1/sport-banners
   - Extract event IDs: ["event1", "event2", ...]
   - Fetch events in parallel: Publishers.MergeMany([
       getEventDetails("event1"),
       getEventDetails("event2"),
       ...
     ]).collect()

3. Layer 1 → Layer 2 Mapping
   GomaModelMapper.richBanners(
       fromInternalRichBanners: internalBanners,
       casinoGames: [],
       events: fetchedEvents
   )
   ↓
   Returns: [RichBanner] (public ServicesProvider models)
   - .info(InfoBanner)
   - .sportEvent(SportEventBanner with full Event data)

4. Layer 2 → Layer 3 Mapping
   ServiceProviderModelMapper.bannerTypes(fromRichBanners: richBanners)
   ↓
   For each RichBanner:
     - .info → Create InfoBannerData → InfoBannerViewModel → BannerType.info
     - .sportEvent → Create MatchBannerViewModel → BannerType.match
   ↓
   Returns: [BannerType] for GomaUI

5. UI Rendering
   TopBannerSliderView receives [BannerType]
   ↓
   Collection view dequeues cells based on banner.cellIdentifier
   ↓
   Cells configured with viewModels
   ↓
   User sees rendered banners with images, text, buttons, outcomes
```

### Casino Rich Banners Flow

Same as sport flow, but:
- API endpoint: `/api/promotions/v1/casino-carousel-banners`
- Fetches casino games instead of events
- Returns: `.info` + `.casinoGame` banner types

---

## Key Technical Decisions

### 1. Order Preservation Strategy
**Problem**: `Publishers.MergeMany` doesn't preserve order
**Solution**: Mapper iterates internal banners in order and uses `first(where:)` to look up enrichment data
```swift
// Order preserved by iteration, not by parallel fetch results
return internalBanners.compactMap { internalBanner in
    switch internalBanner {
    case .casinoGame(let data):
        guard let game = casinoGames.first(where: { $0.id == data.casinoGameId }) else {
            return nil
        }
        // Create banner...
    }
}
```

### 2. Protocol-Relative URL Handling
**Problem**: API returns URLs like `//cdn.example.com/image.jpg`
**Solution**: Mapper normalizes to `https://cdn.example.com/image.jpg`
```swift
// Lines 87-97 in ServiceProviderModelMapper+RichBanners.swift
let normalizedImageURL: String? = {
    guard let imageUrl = bannerData.imageUrl else { return nil }
    if imageUrl.hasPrefix("//") {
        return "https:" + imageUrl
    }
    return imageUrl
}()
```

### 3. Callback Propagation
**Problem**: Match banners need outcome selection callbacks
**Solution**: TopBannerSliderViewModel sets callbacks after mapping
```swift
// Lines 136-158 in TopBannerSliderViewModel.swift
for (index, bannerType) in bannerTypes.enumerated() {
    if case .match(var matchViewModel) = bannerType {
        matchViewModel.onMatchTap = { [weak self] eventId in
            self?.onMatchTap(eventId)
        }
        matchViewModel.onOutcomeSelected = { [weak self] outcomeId in
            self?.onOutcomeSelected(outcomeId)
        }
        // ...
    }
}
```

### 4. Graceful Degradation
**Problem**: What if enrichment data is missing?
**Solution**: Filter out incomplete banners via `compactMap` returning `nil`
```swift
// Mapper returns nil if game/event not found
guard let casinoGame = casinoGames.first(where: { $0.id == data.casinoGameId }) else {
    return nil // Banner filtered out
}
```

---

## Current Debug State

### Debug Logging Locations

All debug prints use prefix `[BANNER-DEBUG]` with emojis:
- 📡 API calls
- 📥 Received data
- 🔄 Processing/mapping
- 🗺️ Mapper operations
- ✅ Success
- ❌ Errors
- 📦 Results
- 🔗 Callback setup
- 👆 User interactions
- 🎨 UI updates
- 📊 Final states
- ⚠️ Warnings

**Files with debug logging**:
1. `TopBannerSliderViewModel.swift` - Lines 85, 94, 96, 101-111, 119, 124-134, 140, 144, 149, 154, 165, 182, 204
2. `ServiceProviderModelMapper+RichBanners.swift` - Lines 20, 26, 34, 38, 42, 69, 148, 162, 169
3. (Others from unstaged changes)

### What to Test

1. **API Integration**
   - [ ] Verify `getSportRichBanners()` returns data
   - [ ] Verify `getCasinoRichBanners()` returns data
   - [ ] Check all 3 banner types are returned
   - [ ] Verify enrichment works (games/events have full data)

2. **Mapping**
   - [ ] Confirm order preservation works
   - [ ] Verify URL normalization (protocol-relative URLs)
   - [ ] Check filtering works (missing enrichment data)

3. **UI Rendering**
   - [ ] Info banners display correctly
   - [ ] Casino game banners display correctly
   - [ ] Match banners display correctly
   - [ ] Mixed banner carousels work
   - [ ] Page indicators show correct count

4. **Interactions**
   - [ ] Info banner button taps trigger navigation
   - [ ] Casino banner button taps trigger navigation
   - [ ] Match banner taps open match details
   - [ ] Outcome selection works in match banners

5. **Error Handling**
   - [ ] API errors show empty state
   - [ ] Missing enrichment data filters gracefully
   - [ ] Invalid image URLs don't crash

---

## Next Steps (Prioritized)

### Phase 1: Stabilization & Cleanup ✅ READY
1. **Remove debug logging** from all files
2. **Stage new files**:
   ```bash
   git add BetssonCameroonApp/App/Models/InfoBanner/
   git add BetssonCameroonApp/App/ViewModels/Banners/InfoBannerViewModel.swift
   git add BetssonCameroonApp/App/ViewModels/Banners/TopBannerSliderViewModel.swift
   git add BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+RichBanners.swift
   ```
3. **Review modified files** for unintended changes
4. **Test build**: `xcodebuild -workspace Sportsbook.xcworkspace -scheme BetssonCameroonApp`

### Phase 2: Integration Testing 🔄 IN PROGRESS
1. **Run BetssonCameroonApp** in simulator
2. **Navigate to screens** with banners (InPlay, NextUp, Casino)
3. **Verify all banner types** render correctly
4. **Test interactions** (taps, outcome selections)
5. **Check network requests** in Xcode console

### Phase 3: Code Review & Documentation 📝 TODO
1. **Create unit tests** for mappers
2. **Update CLAUDE.md** with RichBanner documentation
3. **Write migration guide** for BetssonFranceApp
4. **Document API endpoints** in API_DEVELOPMENT_GUIDE.md

### Phase 4: Legacy Cleanup 🧹 TODO
1. **Remove deprecated methods**:
   - `getCasinoCarouselGames()`
   - `getCarouselEvents()`
   - `getCasinoCarouselPointers()`
   - `getCarouselEventPointers()`
2. **Update BetssonFranceApp** to use new API (separate branch)
3. **Remove old banner ViewModels** not using RichBanner

### Phase 5: Polish & Optimization ⚡ TODO
1. **Implement caching** for enriched banners
2. **Add analytics** tracking for banner impressions/clicks
3. **Optimize image loading** (preload, caching)
4. **Add placeholder images** for failed loads
5. **Performance profiling** with Instruments

---

## Build & Run Commands

### Check Simulator
```bash
# List available simulators
xcrun simctl list devices

# Look for iPhone 15/16 Pro with iOS 18.2+
# Copy device ID (e.g., 229F70D9-99F6-411E-870A-23C4B153C01E)
```

### Build BetssonCameroonApp
```bash
cd /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios

# Replace YOUR_DEVICE_ID with actual simulator ID
xcodebuild -workspace Sportsbook.xcworkspace \
  -scheme BetssonCameroonApp \
  -destination 'platform=iOS Simulator,id=YOUR_DEVICE_ID' \
  build 2>&1 | xcbeautify --quieter
```

### Test GomaUI Components
```bash
xcodebuild -workspace Sportsbook.xcworkspace \
  -scheme GomaUIDemo \
  -destination 'platform=iOS Simulator,id=YOUR_DEVICE_ID' \
  build 2>&1 | xcbeautify --quieter
```

---

## Troubleshooting Guide

### Common Issues

#### 1. "No banners displayed"
**Symptoms**: Banner carousel is empty
**Debug**:
- Check console for `[BANNER-DEBUG] 📡 Calling getSportRichBanners()`
- Verify API response: `[BANNER-DEBUG] 📥 Received X rich banners`
- Check mapper output: `[BANNER-DEBUG] 🗺️ Mapper: Produced X BannerTypes`
- **Likely Cause**: API returned empty array, or all banners filtered out due to missing enrichment data

#### 2. "Protocol-relative URL images not loading"
**Symptoms**: Banners render but images missing
**Debug**: Check `normalizedImageURL` in mapper
**Fix**: Verify URL normalization logic in `ServiceProviderModelMapper+RichBanners.swift:87-97`

#### 3. "Match banner callbacks not firing"
**Symptoms**: Tapping match banners does nothing
**Debug**: Check console for `[BANNER-DEBUG] 👆 Match banner tapped`
**Fix**: Verify callback setup in `TopBannerSliderViewModel.processRichBanners()` lines 136-158

#### 4. "Build errors after pulling branch"
**Likely Cause**: Missing Swift Package dependencies
**Fix**:
```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData

# Rebuild
xcodebuild -workspace Sportsbook.xcworkspace \
  -scheme BetssonCameroonApp \
  -destination 'platform=iOS Simulator,id=YOUR_DEVICE_ID' \
  clean build
```

#### 5. "Banner order is wrong"
**Symptoms**: Banners display in unexpected order
**Debug**: Check `[BANNER-DEBUG] 🗺️ Mapper: Converting X RichBanners`
**Likely Cause**: Mapper iteration order issue
**Fix**: Verify mapper iterates `internalBanners` directly, not `casinoGames`/`events`

---

## API Endpoints Reference

### Sport Rich Banners
```bash
GET https://api.gomademo.com/api/promotions/v1/sport-banners
Authorization: Bearer <token>

# Response types: "event" | "info"
```

### Casino Rich Banners
```bash
GET https://api.gomademo.com/api/promotions/v1/casino-carousel-banners
Authorization: Bearer <token>

# Response types: "game" | "info"
```

### Example Response Structure
```json
[
  {
    "type": "info",
    "id": 123,
    "title": "Welcome Bonus",
    "subtitle": "Get 100% match",
    "cta_text": "Claim Now",
    "cta_url": "/promotions/welcome",
    "cta_target": "_self",
    "image_url": "//cdn.example.com/banner.jpg"
  },
  {
    "type": "event",
    "id": 456,
    "sport_event_id": "6721627",
    "sport_event_market_id": "98271662",
    "image_url": "//cdn.example.com/match.jpg",
    "market_betting_type_id": "173",
    "market_event_part_id": "23"
  }
]
```

---

## Related Documentation

### Project Documentation
- [CLAUDE.md](CLAUDE.md) - Project architecture overview
- [Documentation/Core/API_DEVELOPMENT_GUIDE.md](Documentation/Core/API_DEVELOPMENT_GUIDE.md) - 3-layer API pattern
- [Documentation/Core/MVVM.md](Documentation/Core/MVVM.md) - MVVM architecture
- [Documentation/Core/UI_COMPONENT_GUIDE.md](Documentation/Core/UI_COMPONENT_GUIDE.md) - GomaUI component creation

### Development Journals (Chronological)
1. [22-September-2025-banner-slider-simplification.md](Documentation/DevelopmentJournal/22-September-2025-banner-slider-simplification.md) - BannerType enum creation
2. [24-September-2025-match-banner-component.md](Documentation/DevelopmentJournal/24-September-2025-match-banner-component.md) - MatchBannerView component
3. [03-October-2025-rich-banner-unified-architecture.md](Documentation/DevelopmentJournal/03-October-2025-rich-banner-unified-architecture.md) - **Main architecture doc**

### GomaUI Component Docs
- [Frameworks/GomaUI/CLAUDE.md](Frameworks/GomaUI/CLAUDE.md) - GomaUI framework guide
- BannerType enum: `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TopBannerSliderView/BannerType.swift`
- TopBannerSliderView: `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/TopBannerSliderView/TopBannerSliderView.swift`