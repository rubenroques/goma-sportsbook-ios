# GomaPlatform Package Creation & LanguageSelector Extraction

## Overview
Create the GomaPlatform Swift Package and extract LanguageSelector as the first proof-of-concept screen, establishing the pattern for future extractions.

## Key Findings from Exploration

1. **Preview Helpers already exist in GomaUI** (`Frameworks/GomaUI/GomaUI/Sources/GomaUI/Helpers/PreviewsHelper/`)
   - DELETE duplicates in BetssonCameroonApp, don't move them
   - Use `import GomaUI` to access `PreviewUIViewController`, `PreviewUIView`

2. **No re-export file needed** - Swift Package auto-exports all `public` types

3. **LanguageSelectorViewModel dependency**: The BetssonCameroonApp `LanguageSelectorViewModel` (which implements GomaUI's `LanguageSelectorViewModelProtocol`) depends on:
   - `LanguageManager.shared` (singleton for language switching)
   - `localized()` function

## Phase 1: Create GomaPlatform Package Structure

### 1.1 Create folder structure
```
Frameworks/GomaPlatform/
├── Package.swift
├── Sources/
│   └── GomaPlatform/
│       ├── Protocols/
│       │   └── LanguageManagerProtocol.swift
│       ├── ViewModels/
│       │   └── LanguageSelectorViewModel.swift
│       └── Screens/
│           └── LanguageSelector/
│               ├── LanguageSelectorFullScreenViewController.swift
│               ├── LanguageSelectorFullScreenViewModelProtocol.swift
│               ├── LanguageSelectorFullScreenViewModel.swift
│               └── MockLanguageSelectorFullScreenViewModel.swift
└── Tests/
    └── GomaPlatformTests/
        └── GomaPlatformTests.swift
```

NOTE: No PreviewHelpers folder - use GomaUI's existing helpers via `import GomaUI`

### 1.2 Create Package.swift
- Platform: iOS 15+
- Dependencies: GomaUI (already has LocalizationProvider, StyleProvider, PreviewHelpers)
- Single library target: GomaPlatform

## Phase 2: Extract LanguageSelector Screen

### 2.1 Files to CREATE in GomaPlatform

**New Protocol File:**
- `Frameworks/GomaPlatform/Sources/GomaPlatform/Protocols/LanguageManagerProtocol.swift`

```swift
public protocol LanguageManagerProtocol {
    var currentLanguageCode: String { get }
    func setLanguage(_ languageCode: String)
}
```

**New ViewModel (moved from BetssonCameroonApp):**
- `Frameworks/GomaPlatform/Sources/GomaPlatform/ViewModels/LanguageSelectorViewModel.swift`
  - Find original at: `BetssonCameroonApp/App/ViewModels/LanguageSelectorViewModel.swift` (search for it)
  - Refactor to accept `LanguageManagerProtocol` via init instead of using `LanguageManager.shared`

### 2.2 Files to MOVE from BetssonCameroonApp

From `BetssonCameroonApp/App/Screens/LanguageSelector/`:
- `LanguageSelectorFullScreenViewController.swift` → `GomaPlatform/Sources/GomaPlatform/Screens/LanguageSelector/`
- `LanguageSelectorFullScreenViewModelProtocol.swift` → `GomaPlatform/Sources/GomaPlatform/Screens/LanguageSelector/`
- `LanguageSelectorFullScreenViewModel.swift` → `GomaPlatform/Sources/GomaPlatform/Screens/LanguageSelector/`
- `MockLanguageSelectorFullScreenViewModel.swift` → `GomaPlatform/Sources/GomaPlatform/Screens/LanguageSelector/`

### 2.3 Files to DELETE (duplicates of GomaUI)

From `BetssonCameroonApp/App/Tools/PreviewsHelper/`:
- `PreviewUIView.swift` - DELETE (exists in GomaUI)
- `PreviewUIViewController.swift` - DELETE (exists in GomaUI)
- `PreviewTableViewController.swift` - DELETE (exists in GomaUI)
- `PreviewCollectionViewController.swift` - DELETE (exists in GomaUI)

### 2.4 Required modifications to extracted files

**LanguageSelectorFullScreenViewController.swift:**
1. Add `public` to class and init
2. Replace `UIColor.App.backgroundTertiary` → `StyleProvider.Color.backgroundTertiary`
3. Replace `localized("change_language")` → `LocalizationProvider.string("change_language")`
4. Inject `navigationBarViewModel: SimpleNavigationBarViewModelProtocol` via init
5. Inject `flagImageResolver: LanguageFlagImageResolver` via init
6. Remove direct creation of `BetssonCameroonNavigationBarViewModel` and `AppLanguageFlagImageResolver`
7. Update preview to use `import GomaUI` for `PreviewUIViewController`

**LanguageSelectorFullScreenViewModelProtocol.swift:**
1. Add `public` to protocol and all members
2. Add `public` to `LanguageSelectorFullScreenDisplayState` struct
3. Replace `localized()` → `LocalizationProvider.string()`

**LanguageSelectorFullScreenViewModel.swift:**
1. Add `public` to class, init, and exposed properties/methods
2. Accept `languageManager: LanguageManagerProtocol` via init
3. Pass `languageManager` to internal `LanguageSelectorViewModel`

**LanguageSelectorViewModel.swift (moved to GomaPlatform):**
1. Add `public` modifiers
2. Change `init()` to `init(languageManager: LanguageManagerProtocol)`
3. Replace `LanguageManager.shared.currentLanguageCode` → `languageManager.currentLanguageCode`
4. Replace `LanguageManager.shared.setLanguage()` → `languageManager.setLanguage()`
5. Replace `localized()` → `LocalizationProvider.string()`

**MockLanguageSelectorFullScreenViewModel.swift:**
1. Add `public` to class and static mocks
2. Replace `localized()` → `LocalizationProvider.string()`

## Phase 3: Update BetssonCameroonApp

### 3.1 Add GomaPlatform dependency
In Xcode project settings, add local package dependency to `Frameworks/GomaPlatform`

### 3.2 Make LanguageManager conform to protocol
Add extension in `BetssonCameroonApp/App/Services/LanguageManager.swift`:
```swift
import GomaPlatform

extension LanguageManager: LanguageManagerProtocol {
    // Already implements required properties and methods
}
```

### 3.3 Update LanguageSelectorCoordinator.swift
```swift
import GomaPlatform
import GomaUI

private func showLanguageSelector() {
    // Create VM with injected dependencies
    let viewModel = LanguageSelectorFullScreenViewModel(
        languageManager: LanguageManager.shared
    )

    // Create client-specific nav bar VM
    let navBarVM = BetssonCameroonNavigationBarViewModel(
        title: LocalizationProvider.string("change_language"),
        onBackTapped: { [weak viewModel] in viewModel?.didTapBack() }
    )

    let viewController = LanguageSelectorFullScreenViewController(
        viewModel: viewModel,
        navigationBarViewModel: navBarVM,
        flagImageResolver: AppLanguageFlagImageResolver()
    )
    // ... rest unchanged
}
```

### 3.4 Keep client-specific files in BetssonCameroonApp
These stay in the app (NOT extracted):
- `BetssonCameroonNavigationBarViewModel.swift` - client-specific nav bar
- `LanguageFlagImageResolver.swift` - client-specific image resolver
- `LanguageManager.swift` - client-specific (conforms to GomaPlatform protocol)

### 3.5 Delete extracted files from BetssonCameroonApp
After extraction is verified working:
- Delete `BetssonCameroonApp/App/Screens/LanguageSelector/` folder
- Delete `BetssonCameroonApp/App/ViewModels/LanguageSelectorViewModel.swift`
- Delete `BetssonCameroonApp/App/Tools/PreviewsHelper/` folder (duplicates of GomaUI)

## Phase 4: Workspace Integration

### 4.1 Update Sportsbook.xcworkspace
Add GomaPlatform package reference to workspace

### 4.2 Verify build
```bash
xcodebuild -workspace Sportsbook.xcworkspace \
  -scheme BetssonCameroonApp \
  -destination 'platform=iOS Simulator,id=<DEVICE_ID>' \
  build
```

## Key Files to Modify

| File | Action |
|------|--------|
| `Frameworks/GomaPlatform/Package.swift` | CREATE |
| `Frameworks/GomaPlatform/Sources/GomaPlatform/Protocols/LanguageManagerProtocol.swift` | CREATE |
| `Frameworks/GomaPlatform/Sources/GomaPlatform/ViewModels/LanguageSelectorViewModel.swift` | CREATE (move + refactor) |
| `Frameworks/GomaPlatform/Sources/GomaPlatform/Screens/LanguageSelector/*.swift` | CREATE (move + modify) |
| `BetssonCameroonApp/App/Services/LanguageManager.swift` | MODIFY (add protocol conformance) |
| `BetssonCameroonApp/App/Coordinators/LanguageSelectorCoordinator.swift` | MODIFY (inject dependencies) |
| `BetssonCameroonApp/App/Screens/LanguageSelector/` | DELETE (after verified) |
| `BetssonCameroonApp/App/ViewModels/LanguageSelectorViewModel.swift` | DELETE (after verified) |
| `BetssonCameroonApp/App/Tools/PreviewsHelper/` | DELETE (duplicates GomaUI) |

## Extraction Pattern (For Future Screens)

This establishes the pattern for all future extractions:

1. **VC changes**:
   - `public` modifiers
   - `StyleProvider.Color.xxx` for colors
   - `LocalizationProvider.string()` for strings
   - Inject client-specific dependencies (nav bars, image resolvers) via init

2. **VM Protocol changes**:
   - `public` modifiers on protocol + associated types

3. **VM Implementation**:
   - `public` modifiers
   - Closure-based callbacks for flow (onDismiss, onComplete, etc.)

4. **Coordinator updates**:
   - Import GomaPlatform
   - Create client-specific VMs/resolvers
   - Inject into VC init

## Success Criteria

- [ ] GomaPlatform package builds independently
- [ ] BetssonCameroonApp builds with GomaPlatform dependency
- [ ] LanguageSelector screen works at runtime (navigation, language selection)
- [ ] Pattern is documented for future extractions
