# Casino Feature Migration to GomaPlatform

## Status: NOT STARTED (Aborted initial attempt)

**Date**: 8 December 2025
**Complexity**: HIGH (19 files, heavy refactoring required)

---

## Overview

The Casino feature is significantly more complex than LanguageSelector and requires careful planning before migration.

### File Count Comparison

| Feature | Files | Complexity |
|---------|-------|------------|
| LanguageSelector | 5 | Low - minimal dependencies |
| Casino | 19 | High - heavy singleton usage, many interdependencies |

---

## Files to Migrate

### ViewControllers (5)
| File | Path | Dependencies |
|------|------|--------------|
| CasinoCategoriesListViewController | `Screens/Casino/CasinoCategoriesList/` | GomaUI, GomaPerformanceKit, Combine |
| CasinoCategoryGamesListViewController | `Screens/Casino/CasinoCategoryGamesList/` | GomaUI, BetssonCameroonNavigationBarViewModel |
| CasinoGamePrePlayViewController | `Screens/Casino/CasinoGamePrePlay/` | GomaUI, BetssonCameroonNavigationBarViewModel |
| CasinoGamePlayViewController | `Screens/Casino/CasinoGamePlay/` | WebKit, CasinoJavaScriptBridge, Env.userSessionStore |
| CasinoSearchViewController | `Screens/CasinoSearch/` | GomaUI, AppFont, StyleProvider |

### ViewModels (7)
| File | Path | Client Dependencies |
|------|------|---------------------|
| CasinoCategoriesListViewModel | `Screens/Casino/CasinoCategoriesList/` | CasinoCacheProvider, Env.userSessionStore, localized() |
| CasinoCategoryGamesListViewModel | `Screens/Casino/CasinoCategoryGamesList/` | CasinoCacheProvider, localized() |
| CasinoGamePrePlayViewModel | `Screens/Casino/CasinoGamePrePlay/` | ServicesProvider, UserSessionStore, localized() |
| CasinoGamePlayModeSelectorViewModel | (in CasinoGamePrePlayViewModel.swift) | ServicesProvider, UserSessionStore, localized() |
| CasinoGamePlayViewModel | `Screens/Casino/CasinoGamePlay/` | ServicesProvider, Env.userSessionStore, localized() |
| CasinoTopBannerSliderViewModel | `Screens/Casino/CasinoCategoriesList/` | ServicesProvider, LanguageManager.shared |
| CasinoSearchViewModel | `Screens/CasinoSearch/` | ServicesProvider, Env.userSessionStore, Env.servicesProvider |
| CasinoGameImageViewModel | `ViewModels/Casino/` | GomaUI only (clean) |

### Protocols (1)
| File | Path |
|------|------|
| CasinoSearchViewModelProtocol | `Screens/CasinoSearch/` |

### Models (1)
| File | Path |
|------|------|
| CasinoSearchConfig | `Screens/CasinoSearch/` |

### Utilities (2)
| File | Path | Notes |
|------|------|-------|
| CasinoJavaScriptBridge | `Screens/Casino/CasinoGamePlay/` | Already public, minimal changes needed |
| ServiceProviderModelMapper+Casino | `Models/ModelsMapping/` | Uses localized() |

### Services (stays in client)
| File | Path | Notes |
|------|------|-------|
| CasinoCacheProvider | `Services/CasinoCache/` | Client-specific caching logic |

### Coordinators (stays in client)
| File | Path |
|------|------|
| CasinoCoordinator | `Coordinators/` |
| CasinoSearchCoordinator | `Coordinators/` |

---

## Client-Specific Patterns Requiring Refactoring

### 1. Singleton Access (MOST PROBLEMATIC)

**`Env.userSessionStore`** - Used in 5+ files
```swift
// Current (client-specific)
Env.userSessionStore.userProfilePublisher
Env.userSessionStore.isUserLogged()
Env.userSessionStore.forceRefreshUserWallet()

// Required (protocol-based)
userSessionStore.userProfilePublisher  // injected via init
```

**`LanguageManager.shared`** - Used in 2 files
```swift
// Current
LanguageManager.shared.currentLanguageCode

// Required
languageManager.currentLanguageCode  // injected via init
```

### 2. Localization (PERVASIVE)

**`localized("key")`** - Used in ALL ViewModels and ViewControllers
```swift
// Current
localized("casino_loading")
localized("current_language_code")

// Required
LocalizationProvider.string("casino_loading")
```

### 3. Client-Specific UI Components

**`BetssonCameroonNavigationBarViewModel`** - Used in 2 ViewControllers
```swift
// Current
let navViewModel = BetssonCameroonNavigationBarViewModel(title: nil, onBackTapped: { ... })

// Required - inject via init
init(viewModel: VM, navigationBarViewModel: SimpleNavigationBarViewModelProtocol)
```

**`AppFont.with(type:size:)`** - Used in CasinoSearchViewController
```swift
// Current
AppFont.with(type: .regular, size: 12)

// Required
StyleProvider.Font.regular(size: 12)  // or similar
```

### 4. Image Resources

**`UIImage(resource: .navbarExitIcon)`** - Used in CasinoGamePlayViewController
```swift
// Current
exitButton.setImage(UIImage(resource: .navbarExitIcon), for: .normal)

// Required - inject via init or use SF Symbols
init(exitIcon: UIImage)
// or
UIImage(systemName: "xmark")
```

### 5. Notification Names

**`.landscapeOrientationRequested`** / **`.portraitOrientationRequested`** - Used in CasinoGamePlayViewController
```swift
// Current
NotificationCenter.default.post(name: .landscapeOrientationRequested, object: nil)

// Required - define in GomaPlatform or inject
public extension Notification.Name {
    static let landscapeOrientationRequested = Notification.Name("landscapeOrientationRequested")
}
```

---

## Protocols to Create in GomaPlatform

### CasinoCacheProviderProtocol
```swift
public protocol CasinoCacheProviderProtocol {
    var categoriesUpdatePublisher: AnyPublisher<[CasinoCategory], Never> { get }
    var gamesUpdatePublisher: AnyPublisher<CasinoGamesUpdateData, Never> { get }

    func getCasinoCategories(language: String, platform: String, lobbyType: CasinoLobbyType)
        -> AnyPublisher<[CasinoCategory], ServiceProviderError>
    func getGamesByCategory(categoryId: String, language: String, platform: String,
        lobbyType: CasinoLobbyType?, pagination: CasinoPaginationParams)
        -> AnyPublisher<CasinoGamesResponse, ServiceProviderError>
}
```

### UserSessionStoreProtocol
```swift
public protocol UserSessionStoreProtocol: AnyObject {
    var userProfilePublisher: CurrentValueSubject<UserProfile?, Never> { get }
    var userProfileStatusPublisher: AnyPublisher<GomaPlatformUserProfileStatus, Never> { get }
    func isUserLogged() -> Bool
    func forceRefreshUserWallet()
}
```

---

## Recommended Migration Strategy

### Option A: Incremental (Recommended)

Migrate one screen at a time, starting with the simplest:

1. **CasinoGameImageViewModel** - No client dependencies (already clean)
2. **CasinoJavaScriptBridge** - Already public, minimal changes
3. **CasinoGamePrePlay** (VC + VM) - Moderate complexity
4. **CasinoGamePlay** (VC + VM) - WebKit complexity but isolated
5. **CasinoCategoryGamesList** (VC + VM) - Depends on cache protocol
6. **CasinoCategoriesList** (VC + VM) - Most complex, do last
7. **CasinoSearch** (VC + VM + Protocol + Config) - Independent feature

### Option B: All at Once (Not Recommended)

The initial attempt showed this is error-prone due to:
- Many interdependencies between files
- Hard to track all `localized()` replacements
- Compiler errors cascade across files

---

## Lessons Learned from Initial Attempt

1. **Copy then edit is safer** - Using `cp` preserves original code exactly
2. **Build early and often** - Compiler feedback is more reliable than manual checking
3. **localized() is pervasive** - Almost every file uses it, need systematic replacement
4. **Protocol creation first** - Create all protocols before moving any files
5. **Consider code generation** - A script to add `public` modifiers might be faster

---

## Estimated Effort

| Task | Estimate |
|------|----------|
| Create protocols | 1 hour |
| Migrate utilities (2 files) | 30 min |
| Migrate ViewModels (7 files) | 3-4 hours |
| Migrate ViewControllers (5 files) | 2-3 hours |
| Update coordinators | 1 hour |
| Testing & fixes | 2-3 hours |
| **Total** | **10-12 hours** |

---

## Package.swift Update (DONE)

The GomaPlatform Package.swift has been updated with required dependencies:
```swift
dependencies: [
    .package(path: "../GomaUI/GomaUI"),
    .package(path: "../GomaPerformanceKit"),
    .package(path: "../ServicesProvider"),
]
```

---

## Next Steps

1. Decide on migration strategy (incremental vs all-at-once)
2. If incremental, start with `CasinoGameImageViewModel` as proof of concept
3. Create a checklist for each file's required changes
4. Consider creating a helper script for common transformations
