# GomaPlatform Migration Guide

## Overview

This document captures the architecture decisions and migration plan for extracting shared screens from `BetssonCameroonApp` into the new `GomaPlatform` Swift Package, enabling multi-client white-label support.

## Goal

Convert the current architecture:
```
BetssonCameroonApp (monolithic) → Extract 80% shared code → GomaPlatform package
                                                          ↓
                                              ┌───────────┼───────────┐
                                              ↓           ↓           ↓
                                      BetssonCameroon  BetssonFrance  BetAtHome
                                      (thin app)       (thin app)     (thin app)
```

Each thin app owns ONLY:
- `AppDelegate` / boot sequence
- `DependencyContainer` (service wiring)
- `Coordinators/` (navigation decisions)
- `Theme/` (colors, fonts, styling)
- `Assets.xcassets` (images, icons)
- `Config/` (Info.plist, Firebase, xcconfig, supported languages)

---

## Key Architectural Decisions

### 1. Package Structure - Feature-Based Organization
- **One big `GomaPlatform` package** to start (can split later)
- **Feature-based folder structure** - each feature gets its own folder under `Features/`
- Within each feature: `Protocols/`, `ViewModels/`, `ViewControllers/`, `Mocks/` subfolders
- No re-export file needed - Swift Package auto-exports `public` types
- Depends on `GomaUI` which already has `StyleProvider`, `LocalizationProvider`, and preview helpers

### 2. Theming Solution
Already solved via GomaUI:
- **Colors**: `StyleProvider.Color.xxx` - client calls `StyleProvider.customize(colors:)` at boot
- **Fonts**: `StyleProvider.fontWith(type:size:)` - client calls `StyleProvider.setFontProvider(:)` at boot
- **Localization**: `LocalizationProvider.string()` - client calls `LocalizationProvider.configure { localized($0) }` at boot

### 3. Dependency Injection Pattern
- Use **protocols** for client-specific services (e.g., `LanguageManagerProtocol`)
- Client apps provide concrete implementations
- ViewModels accept protocols via `init()` - **no singletons in GomaPlatform**
- **Client-configurable data** (like supported languages) must be injected, never hardcoded

### 4. Flow Communication
- Use **closures** instead of delegates for navigation callbacks
- Closures must be defined in **protocols**, not just concrete implementations
- Example: `var onDismiss: (() -> Void)?`, `var onLanguageSelected: ((LanguageModel) -> Void)?`

### 5. Preview Helpers
- **Public in GomaUI** at `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Helpers/PreviewsHelper/`
- `PreviewUIViewController` and `PreviewUIView` are now `public` for use in GomaPlatform
- DELETE duplicates in BetssonCameroonApp, use `import GomaUI`

### 6. Protocol-First Callbacks (Lesson Learned)
- **All callback closures must be in the protocol definition**, not just concrete implementations
- This prevents type downcasting (`as? ConcreteType`) which breaks mock support
- Example: `LanguageSelectorViewModelProtocol` now includes `var onLanguageSelected: ((LanguageModel) -> Void)? { get set }`

---

## GomaPlatform Folder Structure

```
Frameworks/GomaPlatform/
├── Package.swift
├── Sources/GomaPlatform/
│   └── Features/
│       ├── LanguageSelector/           # ✅ COMPLETE
│       │   ├── Protocols/
│       │   │   ├── LanguageManagerProtocol.swift
│       │   │   └── LanguageSelectorFullScreenViewModelProtocol.swift
│       │   ├── ViewModels/
│       │   │   ├── LanguageSelectorViewModel.swift
│       │   │   └── LanguageSelectorFullScreenViewModel.swift
│       │   ├── ViewControllers/
│       │   │   └── LanguageSelectorFullScreenViewController.swift
│       │   └── Mocks/
│       │       └── MockLanguageSelectorFullScreenViewModel.swift
│       │
│       └── Casino/                     # 🔄 NEXT - In Progress
│           ├── Protocols/
│           ├── ViewModels/
│           ├── ViewControllers/
│           └── Mocks/
│
└── Tests/GomaPlatformTests/
    └── GomaPlatformTests.swift
```

---

## Extraction Pattern (For All Screens)

### Step 1: ViewController Changes
```swift
// Before (in BetssonCameroonApp)
view.backgroundColor = UIColor.App.backgroundTertiary
let title = localized("screen_title")
let navBarVM = BetssonCameroonNavigationBarViewModel(...)

// After (in GomaPlatform)
view.backgroundColor = StyleProvider.Color.backgroundTertiary
let title = LocalizationProvider.string("screen_title")
// Inject navBarVM via init
```

### Step 2: ViewModel Changes
```swift
// Before
init() {
    let code = LanguageManager.shared.currentLanguageCode
}

// After - inject ALL dependencies and configurable data
init(
    languageManager: LanguageManagerProtocol,
    supportedLanguages: [LanguageModel]  // Client-configurable!
) {
    self.languageManager = languageManager
    self.supportedLanguages = supportedLanguages
}
```

### Step 3: Add Public Modifiers
- `public` on class/struct/enum/protocol
- `public` on init
- `public` on properties exposed via protocol
- `public` on methods exposed via protocol

### Step 4: Add Callbacks to Protocols
```swift
// In protocol (not just concrete class!)
public protocol SomeViewModelProtocol {
    var onSomethingHappened: ((Result) -> Void)? { get set }  // Must be in protocol!
}
```

### Step 5: Update Coordinator (in client app)
```swift
import GomaPlatform
import GomaUI

func showScreen() {
    let viewModel = ScreenViewModel(
        languageManager: LanguageManager.shared,
        supportedLanguages: AppSupportedLanguages.all  // Client config
    )
    let navBarVM = ClientNavigationBarViewModel(...)  // Client-specific
    let vc = ScreenViewController(
        viewModel: viewModel,
        navigationBarViewModel: navBarVM,
        imageResolver: ClientImageResolver()  // Client-specific
    )
    navigationController.pushViewController(vc, animated: true)
}
```

---

## Migration Progress

### ✅ LanguageSelector Feature - COMPLETE (8 Dec 2025)

**GomaPlatform files created:**
- `Features/LanguageSelector/Protocols/LanguageManagerProtocol.swift`
- `Features/LanguageSelector/Protocols/LanguageSelectorFullScreenViewModelProtocol.swift`
- `Features/LanguageSelector/ViewModels/LanguageSelectorViewModel.swift`
- `Features/LanguageSelector/ViewModels/LanguageSelectorFullScreenViewModel.swift`
- `Features/LanguageSelector/ViewControllers/LanguageSelectorFullScreenViewController.swift`
- `Features/LanguageSelector/Mocks/MockLanguageSelectorFullScreenViewModel.swift`

**BetssonCameroonApp files created/modified:**
- `App/Config/AppSupportedLanguages.swift` - NEW: Client-specific language configuration
- `LanguageManager.swift` - Added `extension LanguageManager: LanguageManagerProtocol {}`
- `LanguageSelectorCoordinator.swift` - Updated to inject dependencies from GomaPlatform
- `TopBarContainerViewModel.swift` - Updated to use new init with dependencies

**GomaUI modifications:**
- `PreviewUIViewController.swift` - Made `public` for GomaPlatform access
- `PreviewUIView.swift` - Made `public` for GomaPlatform access
- `LanguageSelectorViewModelProtocol.swift` - Added `onLanguageSelected` callback to protocol
- `MockLanguageSelectorViewModel.swift` - Updated to expose `onLanguageSelected` as public property

**Files deleted from BetssonCameroonApp:**
- `App/Screens/LanguageSelector/` folder (4 files)
- `App/ViewModels/LanguageSelectorViewModel.swift`

### 🔄 Casino Feature - NEXT

Priority for next extraction session.

### 📋 TODO - Cleanup
- [ ] Delete duplicate `BetssonCameroonApp/App/Tools/PreviewsHelper/PreviewUIView.swift`
- [ ] Delete duplicate `BetssonCameroonApp/App/Tools/PreviewsHelper/PreviewUIViewController.swift`

### 📋 TODO - Future Features
Priority order for extraction:
1. ~~LanguageSelector~~ ✅ COMPLETE
2. **Casino** ← NEXT
3. Splash
4. Maintenance
5. VersionUpdate
6. ProfileWallet
7. TransactionHistory
8. PhoneLogin / Register / RecoverPassword
9. InPlayEvents / NextUpEvents
10. MatchDetailsTextual
11. Betslip / MyBets

---

## Client-Specific Files (Stay in BetssonCameroonApp)

These files are client-specific and should NOT be moved to GomaPlatform:

| File | Reason |
|------|--------|
| `AppSupportedLanguages.swift` | Client-specific language configuration |
| `BetssonCameroonNavigationBarViewModel.swift` | Client-specific navigation bar styling |
| `AppLanguageFlagImageResolver.swift` | Client-specific flag images in Assets |
| `LanguageManager.swift` | Client service (conforms to GomaPlatform protocol) |
| `LanguageSelectorCoordinator.swift` | Client navigation flow |
| `PreviewModelsHelper.swift` | App-specific mock data for previews |
| `PreviewCollectionViewController.swift` | App-specific preview helper |

---

## Lessons Learned

### 1. Never Hardcode Client-Configurable Data
**Problem**: LanguageSelector hardcoded `["en", "fr"]` languages.
**Solution**: Accept configurable data via init: `init(supportedLanguages: [LanguageModel])`

### 2. Callbacks Must Be in Protocols
**Problem**: `onLanguageSelected` was only in concrete `LanguageSelectorViewModel`, requiring type downcasting.
**Solution**: Add callback closures to the protocol with `{ get set }` so mocks can also use them.

### 3. Use `public private(set) var` for Protocol Properties That Need Internal Mutation
When a protocol property needs to be set internally but also exposed publicly:
```swift
public private(set) var languageSelectorViewModel: LanguageSelectorViewModelProtocol
```

---

## Known Issues

### GomaUI Dependency Chain
GomaUI depends on SharedModels which has a relative path. When building GomaPlatform standalone with `swift build`, it fails because the path resolution is different.

**Solution**: Build via Xcode workspace which handles path resolution correctly.

---

## Related Documents
- Development Journal: `Documentation/DevelopmentJournal/08-December-2025-gomaplatform-package-creation.md`
- Extraction Plan: `Documentation/MigrateToGomaPlatform/EXTRACTION_PLAN.md`
