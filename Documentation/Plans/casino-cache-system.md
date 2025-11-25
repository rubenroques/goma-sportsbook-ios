# Casino Caching System - Architecture & Implementation Plan

## Status: TODO

**Created:** 25 November 2025
**Last Updated:** 25 November 2025
**Project:** BetssonCameroonApp
**Feature:** Advanced caching system for casino feature to improve UX

### Status Legend
- **TODO**: Plan approved, ready to start implementation
- **IN PROGRESS**: Implementation underway
- **DONE**: Implementation complete, tested, and merged

---

## Problem Statement

### Current State
Casino feature suffers from poor user experience due to slow API response times:
- **Categories API**: 2-5 second load time
- **Games List API**: 2-5 second load time per category
- **No caching**: Every screen load requires fresh API calls
- **Poor UX**: Users see loading spinners on every navigation

### Business Impact
- High bounce rate on casino tab
- User frustration with loading times
- Competitive disadvantage vs faster casino apps
- Reduced engagement and revenue

### User Requirements
1. **Instant UI on app launch**: Show content immediately, no waiting
2. **Persist data between sessions**: Cache survives app restart
3. **Background refresh**: Update stale data without loading spinners
4. **Offline-capable**: Show cached data when network unavailable

---

## Architecture Design

### High-Level Strategy

**"Stale data is better than slow data"**

**3-Tier Fallback System:**
1. **Fresh cached data** (within TTL) → Serve immediately, no network call
2. **Stale cached data** (expired) → Serve immediately + background refresh
3. **No cached data** → Serve bundled placeholders + fetch real data

### Layer Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│           CasinoViewModel (existing)                    │
│                                                         │
│  - Uses CasinoCacheProvider (new wrapper)              │
│  - Subscribes to cache update publishers               │
└────────────────┬────────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────────┐
│        CasinoCacheProvider (new)                        │
│                                                         │
│  - Implements CasinoProvider protocol                   │
│  - Checks cache before API call                        │
│  - Manages background refresh                          │
│  - Publishers for silent updates                       │
└────────┬──────────────────────┬─────────────────────────┘
         │                      │
         │                      │
┌────────▼─────────┐   ┌────────▼──────────────────┐
│  CasinoCacheStore│   │ EveryMatrixCasinoProvider │
│                  │   │      (existing)            │
│  - Disk cache    │   │                           │
│  - Memory cache  │   │  - Real API calls         │
│  - TTL logic     │   │                           │
│  - Bundled data  │   └───────────────────────────┘
└──────────────────┘
```

---

## Data Flow Sequences

### First Launch (No Cache)
```
User opens Casino
    ↓
CasinoCacheProvider.getCasinoCategories()
    ↓
CasinoCacheStore.get(key: "categories")
    ↓
Cache MISS → Load bundled JSON
    ↓
Return bundled data immediately (~200ms)
    ↓
Trigger background fetch from API
    ↓
EveryMatrixCasinoProvider.getCasinoCategories()
    ↓
Save real data to cache (disk + memory)
    ↓
Publish silent update via Combine
    ↓
ViewModel receives update → UI refreshes gracefully
```

**User sees:** Instant placeholder content → Smooth transition to real data

### Subsequent Launch (Fresh Cache)
```
User opens Casino
    ↓
CasinoCacheProvider.getCasinoCategories()
    ↓
CasinoCacheStore.get(key: "categories")
    ↓
Cache HIT + Fresh (within TTL)
    ↓
Return cached data immediately (~50ms)
    ↓
No network call needed
```

**User sees:** Instant real content, no loading

### Subsequent Launch (Stale Cache)
```
User opens Casino
    ↓
CasinoCacheProvider.getCasinoCategories()
    ↓
CasinoCacheStore.get(key: "categories")
    ↓
Cache HIT + Stale (expired TTL)
    ↓
Return stale data immediately (~200ms)
    ↓
Trigger background refresh
    ↓
Fetch from API → Update cache → Publish update
    ↓
ViewModel receives update → UI refreshes silently
```

**User sees:** Instant content (slightly outdated) → Silent refresh to latest

---

## Implementation Requirements

### Configuration
- **Target Project:** BetssonCameroonApp only
- **TTL:** Configurable hours (default: 6 hours)
- **Persistence:** UserDefaults + Documents directory (app-level, NOT iCloud)
- **Initial Data:** Bundled static JSON placeholders
- **Cache Scope:** Global (survives logout, not per-user)
- **Screens Cached:** Home (categories) + Game lists per category

### What Gets Cached
| Data Type | Cache Strategy | TTL | Pagination |
|-----------|---------------|-----|------------|
| **Categories** | Full list | 6 hours | N/A |
| **Game Lists** | Per category + offset | 6 hours | Cache first 5 pages |
| Game Details | NOT cached | N/A | N/A |
| Search Results | NOT cached | N/A | N/A |
| Recommended Games | NOT cached | N/A | N/A |

**Rationale:**
- Categories: Rarely change, safe to cache long-term
- Game Lists: Category-specific, paginated, can cache multiple pages
- Game Details: Change frequently (availability, promotions), fetch fresh
- Search: Query-dependent, not worth caching
- Recommended: Personalized, future per-user cache needed

---

## File Structure

### New Files to Create

```
BetssonCameroonApp/App/Services/CasinoCache/
├── CasinoCacheProvider.swift              # Main caching wrapper (implements CasinoProvider)
├── CasinoCacheStore.swift                 # Disk + memory cache management
├── CasinoCacheConfiguration.swift         # TTL and cache settings
└── BundledCasinoData/
    ├── bundled_casino_categories.json     # Placeholder categories
    └── bundled_casino_games_slots.json    # Placeholder games (per category)
```

### Files to Modify

```
BetssonCameroonApp/App/Services/
├── Environment.swift                      # Add casinoCacheProvider property

BetssonCameroonApp/App/Screens/Casino/
├── CasinoCategoriesList/
│   └── CasinoCategoriesListViewModel.swift   # Use cache provider + subscribe to updates
└── CasinoCategoryGamesList/
    └── CasinoCategoryGamesListViewModel.swift # Use cache provider + subscribe to updates
```

---

## Detailed Implementation

### 1. CasinoCacheConfiguration.swift

**Purpose:** Centralized configuration for cache behavior

```swift
// BetssonCameroonApp/App/Services/CasinoCache/CasinoCacheConfiguration.swift

import Foundation

struct CasinoCacheConfiguration {
    /// Time-to-live for cached data (in seconds)
    let ttl: TimeInterval

    /// Maximum number of game list pages to cache per category
    let maxCachedPagesPerCategory: Int

    /// Whether to use bundled data as fallback
    let useBundledDataFallback: Bool

    /// Default configuration (production)
    static let `default` = CasinoCacheConfiguration(
        ttl: 3600 * 6,  // 6 hours
        maxCachedPagesPerCategory: 5,
        useBundledDataFallback: true
    )

    /// Debug configuration (shorter TTL for testing)
    static let debug = CasinoCacheConfiguration(
        ttl: 60 * 5,  // 5 minutes
        maxCachedPagesPerCategory: 3,
        useBundledDataFallback: true
    )
}
```

**Key Decisions:**
- Default TTL: 6 hours (balance between freshness and network reduction)
- Max pages: 5 per category (covers 50 games, sufficient for most users)
- Bundled fallback: Always enabled for best UX

---

### 2. CasinoCacheStore.swift

**Purpose:** Thread-safe disk + memory cache with TTL management

**Key Components:**

#### Cache Entry Structure
```swift
private struct CacheEntry<T: Codable>: Codable {
    let data: T
    let timestamp: Date
    let version: Int  // For cache invalidation on app updates

    func isValid(ttl: TimeInterval) -> Bool {
        return Date().timeIntervalSince(timestamp) < ttl
    }

    func isStale(ttl: TimeInterval) -> Bool {
        return !isValid(ttl: ttl)
    }
}
```

#### Cache Keys Strategy
```swift
private enum CacheKey: String {
    case categories = "casino_categories"

    // Game lists keyed by category ID and pagination offset
    static func gameList(categoryId: String, offset: Int) -> String {
        return "casino_games_\(categoryId)_offset_\(offset)"
    }
}
```

**Why this approach?**
- Categories: Single global key (same for all users)
- Games: Separate key per category + offset (enables per-page caching)
- Version field: Allows cache invalidation on major changes

#### Cache Result Types
```swift
enum CacheResult<T> {
    case fresh(T)        // Data within TTL, use immediately
    case stale(T)        // Data expired but available, trigger refresh
    case bundled(T)      // Bundled placeholder data
    case miss            // No cached data available

    var data: T? {
        switch self {
        case .fresh(let data), .stale(let data), .bundled(let data):
            return data
        case .miss:
            return nil
        }
    }

    var needsRefresh: Bool {
        switch self {
        case .stale, .bundled, .miss:
            return true
        case .fresh:
            return false
        }
    }
}
```

**Why enum vs boolean flags?**
- Type-safe: Compiler ensures all cases handled
- Self-documenting: Clear intent (fresh vs stale vs bundled)
- Convenience: `needsRefresh` computed property simplifies logic

#### Thread Safety
```swift
private let queue = DispatchQueue(label: "com.betsson.casino.cache", attributes: .concurrent)

// Read operations: concurrent (multiple simultaneous reads)
func getCachedCategories() -> CacheResult<[CasinoCategory]> {
    return queue.sync {
        // Read from memory/disk
    }
}

// Write operations: barrier (exclusive access)
func saveCachedCategories(_ categories: [CasinoCategory]) {
    queue.async(flags: .barrier) { [weak self] in
        // Write to memory + disk
    }
}
```

**Pattern:** Same as `ViewModelCache.swift` in BetssonFranceApp (proven pattern)

#### Cache Lookup Order
```
1. Memory cache (fastest, ~5ms)
   ↓ (miss)
2. Disk cache (fast, ~50-200ms)
   ↓ (miss)
3. Bundled JSON (fallback, ~200ms)
   ↓ (miss)
4. Return .miss (trigger API call)
```

#### Disk Persistence
- **Location:** `Documents/CasinoCache/` (survives app restart)
- **Format:** JSON files named by cache key
- **Encoding:** JSONEncoder with `.atomic` write (crash-safe)
- **Version Control:** Increment `currentCacheVersion` to invalidate old cache

#### Bundled Data Loading
```swift
private func loadBundledCategories() -> [CasinoCategory]? {
    guard let url = Bundle.main.url(forResource: "bundled_casino_categories", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let categories = try? JSONDecoder().decode([CasinoCategory].self, from: data) else {
        return nil
    }
    return categories
}
```

**Integration:** Bundle JSON files in Xcode target → Copied to app bundle

---

### 3. CasinoCacheProvider.swift

**Purpose:** Decorator wrapper around `CasinoProvider` that adds caching behavior

**Key Features:**

#### Protocol Conformance
```swift
final class CasinoCacheProvider: CasinoProvider {
    private let underlyingProvider: CasinoProvider  // EveryMatrixCasinoProvider
    private let cacheStore: CasinoCacheStore
    private let configuration: CasinoCacheConfiguration
```

**Pattern:** Decorator design pattern (wrap without modifying original)

#### Silent Update Publishers
```swift
private let categoriesUpdateSubject = PassthroughSubject<[CasinoCategory], Never>()
private let gamesUpdateSubject = PassthroughSubject<(categoryId: String, offset: Int, response: CasinoGamesResponse), Never>()

public var categoriesUpdatePublisher: AnyPublisher<[CasinoCategory], Never> {
    categoriesUpdateSubject.eraseToAnyPublisher()
}

public var gamesUpdatePublisher: AnyPublisher<(categoryId: String, offset: Int, response: CasinoGamesResponse), Never> {
    gamesUpdateSubject.eraseToAnyPublisher()
}
```

**Usage:** ViewModels subscribe to these publishers for silent background updates

#### Main Logic: getCasinoCategories()
```swift
func getCasinoCategories(
    language: String?,
    platform: String?,
    lobbyType: CasinoLobbyType?
) -> AnyPublisher<[CasinoCategory], ServiceProviderError> {

    let cacheResult = cacheStore.getCachedCategories()

    switch cacheResult {
    case .fresh(let categories):
        // Cache is fresh, return immediately without network call
        return Just(categories)
            .setFailureType(to: ServiceProviderError.self)
            .eraseToAnyPublisher()

    case .stale(let categories), .bundled(let categories):
        // Cache exists but stale, or using bundled data
        // Return cached data immediately AND trigger background refresh
        triggerBackgroundCategoriesRefresh(language: language, platform: platform, lobbyType: lobbyType)

        return Just(categories)
            .setFailureType(to: ServiceProviderError.self)
            .eraseToAnyPublisher()

    case .miss:
        // No cache available, fetch from network
        return fetchAndCacheCategories(language: language, platform: platform, lobbyType: lobbyType)
    }
}
```

**Flow:**
- Fresh cache: Return immediately, no network
- Stale/bundled: Return immediately + background fetch
- Miss: Blocking fetch

#### Background Refresh Pattern
```swift
private func triggerBackgroundCategoriesRefresh(
    language: String?,
    platform: String?,
    lobbyType: CasinoLobbyType?
) {
    fetchAndCacheCategories(language: language, platform: platform, lobbyType: lobbyType)
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("⚠️ CasinoCacheProvider: Background categories refresh failed: \(error)")
                    // Don't throw - background refresh failure is non-fatal
                }
            },
            receiveValue: { [weak self] categories in
                // Publish silent update for UI to refresh
                self?.categoriesUpdateSubject.send(categories)
            }
        )
        .store(in: &cancellables)
}
```

**Key Insight:** Background refresh failures are logged but don't affect UX (user still has cached data)

#### What Gets Cached vs Not Cached

| Method | Cached? | Reason |
|--------|---------|--------|
| `getCasinoCategories()` | ✅ Yes | Rarely changes, global data |
| `getGamesByCategory()` | ✅ Yes | Per-category, paginated |
| `getGameDetails()` | ❌ No | Changes frequently (promotions) |
| `searchGames()` | ❌ No | Query-dependent |
| `getRecommendedGames()` | ❌ No | Personalized (future: per-user cache) |
| `buildGameLaunchUrl()` | N/A | Passthrough to underlying provider |

---

### 4. Integration with Existing App

#### 4.1 Environment.swift Changes

```swift
// BetssonCameroonApp/App/Services/Environment.swift

struct Environment {
    let servicesProvider: Client
    let userSessionStore: UserSessionStore
    let betslipManager: BetslipManager

    // ADD: Casino cache provider
    let casinoCacheProvider: CasinoCacheProvider

    static func create() -> Environment {
        let servicesProvider = Client(...)
        let userSessionStore = UserSessionStore(...)
        let betslipManager = BetslipManager(...)

        // Wrap the underlying casino provider with caching
        let casinoCacheProvider = CasinoCacheProvider(
            underlyingProvider: servicesProvider.casinoProvider!,
            cacheStore: CasinoCacheStore(configuration: .default),
            configuration: .default
        )

        return Environment(
            servicesProvider: servicesProvider,
            userSessionStore: userSessionStore,
            betslipManager: betslipManager,
            casinoCacheProvider: casinoCacheProvider  // NEW
        )
    }
}
```

**Migration Path:**
1. Add `casinoCacheProvider` property to Environment
2. Create instance in `Environment.create()`
3. Update all casino ViewModels to use `environment.casinoCacheProvider`
4. Done - no changes to ServicesProvider framework

#### 4.2 CasinoCategoriesListViewModel.swift Changes

**BEFORE:**
```swift
init(environment: Environment, ...) {
    self.environment = environment
    loadCategoriesFromAPI()
}

private func loadCategoriesFromAPI() {
    environment.servicesProvider.casinoProvider?.getCasinoCategories(...)
        .sink { ... }
        .store(in: &cancellables)
}
```

**AFTER:**
```swift
init(environment: Environment, ...) {
    self.environment = environment

    // Subscribe to silent cache updates
    setupCacheUpdateSubscriptions()

    // Load categories (will use cache if available)
    loadCategoriesFromAPI()
}

private func setupCacheUpdateSubscriptions() {
    // Listen for background refresh updates
    environment.casinoCacheProvider.categoriesUpdatePublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] updatedCategories in
            // Silently update UI without showing loading spinner
            self?.handleSilentCategoriesUpdate(updatedCategories)
        }
        .store(in: &cancellables)
}

private func loadCategoriesFromAPI() {
    isLoading = true

    // CHANGE: Use casinoCacheProvider instead of servicesProvider.casinoProvider
    environment.casinoCacheProvider.getCasinoCategories(
        language: "en",
        platform: "iPhone",
        lobbyType: .casino
    )
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.handleError(error)
            }
        },
        receiveValue: { [weak self] categories in
            self?.isLoading = false
            self?.handleCategoriesLoaded(categories)
        }
    )
    .store(in: &cancellables)
}

private func handleSilentCategoriesUpdate(_ categories: [CasinoCategory]) {
    // Update categories without showing loading state
    // This is called when background refresh completes

    // Check if data actually changed to avoid unnecessary UI updates
    guard !categories.isEmpty else { return }

    // Update category sections with new data (reuse existing method)
    handleCategoriesLoaded(categories, silent: true)
}
```

**Key Changes:**
1. Subscribe to `categoriesUpdatePublisher` in init
2. Handle silent updates separately (no loading spinner)
3. Switch from `servicesProvider.casinoProvider` to `casinoCacheProvider`

#### 4.3 CasinoCategoryGamesListViewModel.swift Changes

Similar pattern:
1. Subscribe to `gamesUpdatePublisher` (filter by categoryId)
2. Handle silent updates for matching category
3. Switch to `casinoCacheProvider.getGamesByCategory()`

---

## Bundled Placeholder Data

### Strategy
- **Realistic but generic**: Use plausible game names/categories without actual branding
- **Placeholder images**: Generic slot machine/casino icons from Assets.xcassets
- **Empty launch URLs**: Will be replaced with real URLs on first API fetch
- **4-5 categories**: Slots, Live Casino, Table Games, Jackpot (most common)
- **10 games per category**: Sufficient for home screen preview

### Example: bundled_casino_categories.json
```json
[
  {
    "id": "slots",
    "name": "Slots",
    "href": "/casino/slots",
    "gamesTotal": 250
  },
  {
    "id": "live-casino",
    "name": "Live Casino",
    "href": "/casino/live-casino",
    "gamesTotal": 45
  },
  {
    "id": "table-games",
    "name": "Table Games",
    "href": "/casino/table-games",
    "gamesTotal": 80
  },
  {
    "id": "jackpot",
    "name": "Jackpot",
    "href": "/casino/jackpot",
    "gamesTotal": 30
  }
]
```

### Example: bundled_casino_games_slots.json
```json
{
  "count": 10,
  "total": 250,
  "games": [
    {
      "id": "placeholder-slot-1",
      "name": "Mega Spin",
      "launchUrl": "",
      "thumbnail": "placeholder_game_thumb_1",
      "backgroundImageUrl": "placeholder_game_bg_1",
      "description": "Classic slot game",
      "slug": "mega-spin",
      "hasFunMode": true,
      "hasAnonymousFunMode": true,
      "platforms": ["iPhone", "iPad"],
      "popularity": 4.5,
      "isNew": false
    },
    {
      "id": "placeholder-slot-2",
      "name": "Lucky Reels",
      "launchUrl": "",
      "thumbnail": "placeholder_game_thumb_2",
      "backgroundImageUrl": "placeholder_game_bg_2",
      "description": "Fortune awaits in this exciting slot",
      "slug": "lucky-reels",
      "hasFunMode": true,
      "hasAnonymousFunMode": true,
      "platforms": ["iPhone", "iPad"],
      "popularity": 4.3,
      "isNew": false
    }
    // ... 8 more placeholder games
  ],
  "pagination": null
}
```

### Asset Requirements
Create placeholder images in `Assets.xcassets`:
- `placeholder_game_thumb_1` through `placeholder_game_thumb_10` (200x200px)
- `placeholder_game_bg_1` through `placeholder_game_bg_10` (800x600px)
- Generic slot machine/casino graphics (no brand logos)

### Xcode Integration
1. Add JSON files to project: `BetssonCameroonApp/App/Services/CasinoCache/BundledCasinoData/`
2. Ensure "Copy Bundle Resources" includes JSON files in Build Phases
3. Verify JSON files appear in app bundle at runtime

---

## Performance Impact Analysis

### Before (No Cache)
```
App Launch → Casino Tab → API Call → 2-5s wait → UI renders
User taps category → API Call → 2-5s wait → Games list renders
User scrolls → Load more → API Call → 2-5s wait → More games render
```

**Total time for 3 interactions:** 6-15 seconds of loading

### After (With Cache)

**First Launch:**
```
App Launch → Casino Tab → Bundled data → ~200ms → UI renders
Background API call → 2-5s → Silent update → Seamless refresh
User taps category → Bundled data → ~200ms → Games list renders
Background API call → 2-5s → Silent update → Seamless refresh
```

**Total perceived time:** ~400ms (95% improvement)

**Subsequent Launch (Fresh Cache):**
```
App Launch → Casino Tab → Memory cache → ~50ms → UI renders
User taps category → Memory cache → ~50ms → Games list renders
User scrolls → Load more → Memory cache (if cached) → ~50ms → More games render
```

**Total perceived time:** ~150ms (98% improvement)

**Subsequent Launch (Stale Cache):**
```
App Launch → Casino Tab → Disk cache → ~200ms → UI renders
Background API call → 2-5s → Silent update → Seamless refresh
User taps category → Disk cache → ~200ms → Games list renders
Background API call → 2-5s → Silent update → Seamless refresh
```

**Total perceived time:** ~400ms (95% improvement)

### Network Request Reduction

**Assumptions:**
- Average user: 5 app sessions per day
- Average session: Opens casino 1x, views 2 categories
- TTL: 6 hours
- Sessions distributed throughout day

**Without Cache:**
- 5 sessions × 3 API calls = **15 API calls per day per user**

**With Cache (6-hour TTL):**
- First session (cold start): 3 API calls
- Sessions 2-4 (within 6h): 0 API calls (fresh cache)
- Session 5 (after 6h): 3 API calls (background refresh)
- Total: **6 API calls per day per user** (60% reduction)

**Backend Impact:**
- 1000 users: 15,000 → 6,000 requests/day (60% reduction)
- 10,000 users: 150,000 → 60,000 requests/day (60% reduction)
- Reduced server costs, improved API reliability

---

## Testing Strategy

### Unit Tests

Create `BetssonCameroonAppTests/Services/CasinoCache/CasinoCacheStoreTests.swift`:

```swift
import XCTest
@testable import BetssonCameroonApp
import ServicesProvider

class CasinoCacheStoreTests: XCTestCase {

    var cacheStore: CasinoCacheStore!

    override func setUp() {
        super.setUp()
        cacheStore = CasinoCacheStore(configuration: .debug)
        cacheStore.clearCache()  // Start with clean state
    }

    override func tearDown() {
        cacheStore.clearCache()
        cacheStore = nil
        super.tearDown()
    }

    func testCacheMiss_ReturnsMiss() {
        // Given: Empty cache
        // When: Request categories
        let result = cacheStore.getCachedCategories()

        // Then: Returns .miss or .bundled (if bundled data exists)
        switch result {
        case .miss, .bundled:
            XCTAssert(true)
        case .fresh, .stale:
            XCTFail("Should not have cache on first access")
        }
    }

    func testCacheFresh_ReturnsFresh() {
        // Given: Recently saved categories (within TTL)
        let mockCategories = [
            CasinoCategory(id: "test", name: "Test", href: "/test", gamesTotal: 10)
        ]
        cacheStore.saveCachedCategories(mockCategories)

        // When: Request categories immediately
        let result = cacheStore.getCachedCategories()

        // Then: Returns .fresh with data
        guard case .fresh(let categories) = result else {
            XCTFail("Expected fresh cache")
            return
        }
        XCTAssertEqual(categories.count, 1)
        XCTAssertEqual(categories.first?.id, "test")
    }

    func testCacheStale_ReturnsStale() {
        // Given: Old cached categories (expired TTL)
        // This test requires mocking Date or waiting TTL duration
        // For now, use debug config with 5-minute TTL

        let mockCategories = [
            CasinoCategory(id: "test", name: "Test", href: "/test", gamesTotal: 10)
        ]
        cacheStore.saveCachedCategories(mockCategories)

        // Wait for TTL to expire (not practical in unit tests)
        // Alternative: Use dependency injection for Date provider
        // For manual testing: Set debug TTL to 1 second, wait 2 seconds
    }

    func testMemoryCache_FasterThanDisk() {
        // Given: Data in both memory and disk
        let mockCategories = [
            CasinoCategory(id: "test", name: "Test", href: "/test", gamesTotal: 10)
        ]
        cacheStore.saveCachedCategories(mockCategories)

        // When: Request same data twice
        let start1 = Date()
        _ = cacheStore.getCachedCategories()
        let duration1 = Date().timeIntervalSince(start1)

        let start2 = Date()
        _ = cacheStore.getCachedCategories()
        let duration2 = Date().timeIntervalSince(start2)

        // Then: Second request should be faster (memory hit)
        // Note: This test may be flaky due to scheduling
        print("First request: \(duration1)s, Second request: \(duration2)s")
    }

    func testVersionMismatch_TreatsAsInvalid() {
        // Given: Cached data with old version
        // Manually create cache entry with old version
        // This requires accessing private members or creating test helper

        // For now, increment currentCacheVersion in CasinoCacheStore
        // Then verify old cache is ignored
    }

    func testGameListCache_PerCategoryAndOffset() {
        // Given: Different game lists for different categories/offsets
        let slotsGames = CasinoGamesResponse(count: 10, total: 100, games: [], pagination: nil)
        let liveGames = CasinoGamesResponse(count: 10, total: 50, games: [], pagination: nil)

        cacheStore.saveCachedGameList(slotsGames, categoryId: "slots", offset: 0)
        cacheStore.saveCachedGameList(liveGames, categoryId: "live", offset: 0)

        // When: Request specific game lists
        let slotsResult = cacheStore.getCachedGameList(categoryId: "slots", offset: 0)
        let liveResult = cacheStore.getCachedGameList(categoryId: "live", offset: 0)

        // Then: Returns correct cached data per category
        guard case .fresh(let slotsResponse) = slotsResult else {
            XCTFail("Expected fresh slots cache")
            return
        }
        guard case .fresh(let liveResponse) = liveResult else {
            XCTFail("Expected fresh live cache")
            return
        }

        XCTAssertEqual(slotsResponse.total, 100)
        XCTAssertEqual(liveResponse.total, 50)
    }
}
```

### Integration Tests

Create `BetssonCameroonAppUITests/CasinoCacheIntegrationTests.swift`:

```swift
import XCTest

class CasinoCacheIntegrationTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
    }

    func testFirstLaunch_ShowsBundledDataThenUpdates() {
        // Given: Fresh app install (delete app first)
        app.launch()

        // When: Navigate to Casino tab
        app.tabBars.buttons["Casino"].tap()

        // Then: Casino categories appear immediately (bundled data)
        let categoriesCollection = app.collectionViews.firstMatch
        XCTAssertTrue(categoriesCollection.waitForExistence(timeout: 1))

        // Then: After background fetch, real data replaces placeholders
        // (Verify by checking category names change after 3-5 seconds)
        sleep(6)  // Wait for API call
        // Add assertions for real data appearing
    }

    func testSubsequentLaunch_InstantLoad() {
        // Given: App already launched once (cache exists)
        app.launch()
        app.tabBars.buttons["Casino"].tap()
        sleep(2)  // Ensure data cached
        app.terminate()

        // When: Relaunch app and navigate to Casino
        app.launch()
        let startTime = Date()
        app.tabBars.buttons["Casino"].tap()

        // Then: Categories appear within 500ms (cached data)
        let categoriesCollection = app.collectionViews.firstMatch
        XCTAssertTrue(categoriesCollection.waitForExistence(timeout: 0.5))
        let loadTime = Date().timeIntervalSince(startTime)
        XCTAssertLessThan(loadTime, 1.0)
    }

    func testOfflineMode_ShowsCachedData() {
        // Given: App with cached data + airplane mode enabled
        app.launch()
        app.tabBars.buttons["Casino"].tap()
        sleep(2)  // Ensure data cached
        app.terminate()

        // Enable airplane mode (manual step or use settings app)
        // Re-launch app

        app.launch()
        app.tabBars.buttons["Casino"].tap()

        // Then: Cached categories still appear
        let categoriesCollection = app.collectionViews.firstMatch
        XCTAssertTrue(categoriesCollection.waitForExistence(timeout: 1))

        // Disable airplane mode (manual step)
    }
}
```

### Manual Testing Checklist

- [ ] **First Launch (No Cache)**
  1. Delete app from simulator
  2. Install and launch app
  3. Navigate to Casino tab
  4. ✅ Verify: Categories appear instantly (bundled data)
  5. ✅ Verify: Loading indicator shows briefly in background
  6. ✅ Verify: Real categories replace placeholders after 2-5s
  7. ✅ Verify: No error messages

- [ ] **Fresh Cache Test**
  1. Launch app
  2. Navigate to Casino tab (loads cache)
  3. Kill app
  4. Relaunch within 6 hours
  5. Navigate to Casino tab
  6. ✅ Verify: Categories appear instantly (<500ms)
  7. ✅ Verify: No loading indicator
  8. ✅ Verify: No network activity (check Network Link Conditioner)

- [ ] **Stale Cache Test**
  1. Launch app
  2. Navigate to Casino tab (loads cache)
  3. Kill app
  4. Modify system time +7 hours (or wait 6 hours in debug mode)
  5. Relaunch app
  6. Navigate to Casino tab
  7. ✅ Verify: Categories appear instantly (stale cache)
  8. ✅ Verify: No loading indicator initially
  9. ✅ Verify: Data refreshes silently in background
  10. ✅ Verify: UI updates smoothly without jarring transition

- [ ] **Game List Cache Test**
  1. Launch app
  2. Navigate to Casino → Select category (e.g., Slots)
  3. ✅ Verify: Games appear instantly (bundled data)
  4. Wait for real data to load
  5. Kill app and relaunch
  6. Navigate to same category
  7. ✅ Verify: Games appear instantly (cached data)
  8. ✅ Verify: No loading indicator

- [ ] **Offline Test**
  1. Launch app with cache
  2. Enable airplane mode
  3. Navigate to Casino tab
  4. ✅ Verify: Categories appear from cache
  5. ✅ Verify: No error messages
  6. Tap category
  7. ✅ Verify: Games appear from cache (if cached)
  8. Disable airplane mode
  9. ✅ Verify: Background refresh triggers automatically

- [ ] **Cache Invalidation Test**
  1. Launch app with cache
  2. Increment `currentCacheVersion` in code
  3. Rebuild and launch
  4. Navigate to Casino tab
  5. ✅ Verify: Old cache is ignored
  6. ✅ Verify: Bundled data appears
  7. ✅ Verify: Fresh API call made

---

## Implementation Checklist

### Phase 1: Core Infrastructure (Est. 4 hours)

- [ ] Create `CasinoCacheConfiguration.swift`
  - [ ] Define default and debug configurations
  - [ ] Document TTL values

- [ ] Create `CasinoCacheStore.swift`
  - [ ] Implement `CacheEntry<T>` struct
  - [ ] Implement `CacheResult<T>` enum
  - [ ] Create cache directory in Documents
  - [ ] Implement `getCachedCategories()` method
  - [ ] Implement `saveCachedCategories()` method
  - [ ] Implement `getCachedGameList()` method
  - [ ] Implement `saveCachedGameList()` method
  - [ ] Add memory cache layer
  - [ ] Add disk persistence layer
  - [ ] Implement bundled data loading
  - [ ] Add thread safety (concurrent queue)
  - [ ] Implement cache version management
  - [ ] Add `clearCache()` method

- [ ] Create unit tests `CasinoCacheStoreTests.swift`
  - [ ] Test cache miss scenario
  - [ ] Test fresh cache scenario
  - [ ] Test stale cache scenario (if possible)
  - [ ] Test bundled data fallback
  - [ ] Test memory vs disk performance
  - [ ] Test concurrent access (stress test)

### Phase 2: Cache Provider Wrapper (Est. 2 hours)

- [ ] Create `CasinoCacheProvider.swift`
  - [ ] Implement `CasinoProvider` protocol
  - [ ] Add `underlyingProvider` property
  - [ ] Add silent update publishers
  - [ ] Implement `getCasinoCategories()` with cache logic
  - [ ] Implement `getGamesByCategory()` with cache logic
  - [ ] Implement background refresh for categories
  - [ ] Implement background refresh for games
  - [ ] Passthrough non-cached methods (details, search, recommended)
  - [ ] Add `clearCache()` public method

### Phase 3: Bundled Placeholder Data (Est. 1.5 hours)

- [ ] Create placeholder images in Assets.xcassets
  - [ ] 10x game thumbnails (200x200px)
  - [ ] 10x game backgrounds (800x600px)
  - [ ] Generic casino/slot graphics (no branding)

- [ ] Create `bundled_casino_categories.json`
  - [ ] 4-5 realistic categories (Slots, Live Casino, Table Games, Jackpot)
  - [ ] Realistic game counts

- [ ] Create `bundled_casino_games_slots.json`
  - [ ] 10 placeholder games with realistic properties
  - [ ] Reference placeholder images
  - [ ] Empty launch URLs

- [ ] Create similar JSON files for other categories
  - [ ] `bundled_casino_games_live-casino.json`
  - [ ] `bundled_casino_games_table-games.json`
  - [ ] `bundled_casino_games_jackpot.json`

- [ ] Add JSON files to Xcode project
  - [ ] Ensure "Copy Bundle Resources" includes JSON files
  - [ ] Verify files appear in app bundle

### Phase 4: App Integration (Est. 2 hours)

- [ ] Update `Environment.swift`
  - [ ] Add `casinoCacheProvider: CasinoCacheProvider` property
  - [ ] Create instance in `Environment.create()`
  - [ ] Wire up underlying provider

- [ ] Update `CasinoCategoriesListViewModel.swift`
  - [ ] Add cache update subscription in init
  - [ ] Implement `setupCacheUpdateSubscriptions()`
  - [ ] Implement `handleSilentCategoriesUpdate()`
  - [ ] Replace `servicesProvider.casinoProvider` with `casinoCacheProvider`
  - [ ] Handle silent updates without loading spinner

- [ ] Update `CasinoCategoryGamesListViewModel.swift`
  - [ ] Add cache update subscription in init
  - [ ] Implement `setupGamesUpdateSubscriptions()`
  - [ ] Implement `handleSilentGamesUpdate()`
  - [ ] Replace `servicesProvider.casinoProvider` with `casinoCacheProvider`
  - [ ] Filter updates by categoryId

### Phase 5: Testing & Validation (Est. 2 hours)

- [ ] Run unit tests
  - [ ] All tests pass
  - [ ] Code coverage >80%

- [ ] Manual testing
  - [ ] First launch test (bundled data → real data)
  - [ ] Fresh cache test (instant load, no network)
  - [ ] Stale cache test (instant load + background refresh)
  - [ ] Game list cache test
  - [ ] Offline test (cached data works)
  - [ ] Cache invalidation test

- [ ] Performance validation
  - [ ] Measure first launch time
  - [ ] Measure subsequent launch time
  - [ ] Verify network request reduction
  - [ ] Profile memory usage
  - [ ] Profile disk space usage

- [ ] Bug fixes and polish
  - [ ] Fix any issues found during testing
  - [ ] Add logging/analytics
  - [ ] Update documentation

### Phase 6: Code Review & Deployment (Est. 1 hour)

- [ ] Self code review
  - [ ] Check thread safety
  - [ ] Verify error handling
  - [ ] Ensure proper resource cleanup
  - [ ] Check for memory leaks

- [ ] Create PR
  - [ ] Write comprehensive PR description
  - [ ] Link to this design doc
  - [ ] Add screenshots/videos of before/after

- [ ] Address review feedback

- [ ] Merge and monitor
  - [ ] Watch for crash reports
  - [ ] Monitor network request metrics
  - [ ] Collect user feedback

**Total Estimated Time:** ~12-14 hours

---

## Future Enhancements (Phase 2)

### Per-User Cache (For Personalized Content)
When recommended games or favorites are added:
- Add `userId` to cache keys: `casino_games_user_{userId}_recommended`
- Clear user-specific cache on logout
- Keep global cache (categories, game lists) intact

### Cache Analytics
Track cache effectiveness:
- Cache hit/miss rates
- Average load times (cached vs non-cached)
- Network request reduction percentage
- Optimize TTL based on data

### Intelligent Prefetching
Improve perceived performance:
- Pre-cache popular categories in background (after app launch)
- Prefetch next page when user scrolls to 80%
- Predict user's next action based on navigation patterns

### Compression
Reduce storage footprint:
- Compress JSON before writing to disk (gzip)
- Decompress on read (transparent to caller)
- Trade CPU time for storage space

### Differential Updates
Minimize UI disruption on silent updates:
- Compare old vs new data (by game ID)
- Only update changed items
- Preserve scroll position
- Animate new items in

### Image Cache Integration
Coordinate with Kingfisher:
- When caching game list, trigger prefetch of thumbnails
- Preload images for cached games
- Clear image cache when game cache is cleared
- Unified cache management

### Smart TTL
Dynamic TTL based on content type:
- Categories: 24 hours (rarely change)
- Popular games: 6 hours (frequent updates)
- New games: 1 hour (promotions change often)
- Live casino: 30 minutes (availability changes)

---

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| **Stale data confuses users** | Medium | Show last updated timestamp in UI |
| **Cache corruption** | High | Versioning + graceful degradation to bundled data |
| **Excessive storage usage** | Low | Limit cached pages, clear old cache versions |
| **Memory pressure** | Medium | Only cache first 5 pages per category |
| **Background refresh failures** | Low | Log silently, keep stale cache |
| **Race conditions** | High | Concurrent queue with barriers (proven pattern) |
| **TTL too short/long** | Medium | Make configurable, A/B test optimal value |

---

## Success Metrics

### User Experience Metrics
- **Casino tab TTI** (Time to Interactive): Target <500ms (currently 2-5s)
- **Category list TTI**: Target <500ms (currently 2-5s)
- **Perceived performance improvement**: >90% reduction in loading time

### Technical Metrics
- **Network request reduction**: Target 60-70%
- **Cache hit rate**: Target >80% (after first session)
- **Storage usage**: Target <5MB (categories + 5 pages × 4 categories)
- **Memory usage**: Target <2MB (in-memory cache)

### Business Metrics
- **Casino engagement**: Increase time spent in casino tab
- **Casino conversions**: Increase betting conversion rate
- **Session length**: Increase average session duration
- **Retention**: Reduce bounce rate on casino tab

---

## References

### Existing Patterns in Codebase
- **ViewModelCache** (`BetssonFranceApp/Core/Tools/MiscHelpers/ViewModelCache.swift`)
  - Thread-safe concurrent queue pattern
  - Generic cache implementation
  - Comprehensive test coverage

- **PresentationConfigurationStore** (`BetssonCameroonApp/App/Services/PresentationConfigurationStore.swift`)
  - TTL-based cache with UserDefaults
  - Background refresh pattern
  - Graceful fallback to stale cache

- **LinksManagementService** (`BetssonCameroonApp/App/Services/LinksProvider/LinksManagementService.swift`)
  - Dynamic URL caching
  - Debug vs release TTL configuration
  - Version-based cache invalidation

- **BetslipManager** (`BetssonCameroonApp/App/Services/BetslipManager.swift`)
  - UserDefaults persistence
  - Combine publishers for updates
  - Auto-save on changes

### Design Patterns Used
- **Decorator Pattern**: CasinoCacheProvider wraps CasinoProvider
- **Repository Pattern**: CasinoCacheStore abstracts storage details
- **Observer Pattern**: Combine publishers for silent updates
- **Strategy Pattern**: CacheResult enum for different cache states

### Apple Documentation
- [URLCache Documentation](https://developer.apple.com/documentation/foundation/urlcache)
- [FileManager Documentation](https://developer.apple.com/documentation/foundation/filemanager)
- [Combine Framework](https://developer.apple.com/documentation/combine)
- [Grand Central Dispatch](https://developer.apple.com/documentation/dispatch)

---

## Questions for Review

### Architecture
- ✅ Is the 3-tier fallback strategy (fresh → stale → bundled → miss) appropriate?
- ✅ Should we use Decorator pattern or modify existing provider directly?
- ✅ Is 6-hour TTL reasonable, or should we A/B test different values?

### Implementation
- ✅ Should game details be cached (currently not planned)?
- ✅ Should search results be cached (currently not planned)?
- ✅ Is 5 pages per category sufficient, or should we cache more?

### Testing
- ✅ Do we need integration tests, or are unit tests sufficient?
- ✅ Should we add performance tests to CI/CD pipeline?
- ✅ Do we need A/B testing infrastructure for TTL optimization?

### Future
- ✅ When should we implement per-user cache (for personalized content)?
- ✅ Should we track cache analytics from day 1, or add later?
- ✅ Do we need a cache management UI for debugging?

---

## Implementation Notes

When starting implementation:
1. Update status from TODO → IN PROGRESS
2. Check off items in the Implementation Checklist as you complete them
3. Document any deviations from the plan in a new "Changes from Plan" section
4. Update status to DONE when all phases complete and tests pass

---

## Plan Metadata

**Version:** 1.0
**Owner:** @rroques
**Estimated Effort:** 12-14 hours
**Priority:** High (User Experience Impact)
