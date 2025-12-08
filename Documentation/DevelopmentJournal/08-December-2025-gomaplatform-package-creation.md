## Date
08 December 2025

### Project / Branch
sportsbook-ios / rr/new_client_structure

### Goals for this session
- Brainstorm architecture for scaling white-label iOS app to 4+ clients
- Create GomaPlatform Swift Package for shared screens
- Extract LanguageSelector as first proof-of-concept

### Achievements
- [x] Defined modular architecture: 80% shared code in GomaPlatform, 20% client-specific
- [x] Created `Frameworks/GomaPlatform/` package structure
- [x] Created `Package.swift` with GomaUI dependency
- [x] Created `LanguageManagerProtocol` for dependency injection
- [x] Refactored `LanguageSelectorViewModel` with protocol injection (no more singletons)
- [x] Discovered PreviewHelpers already exist in GomaUI (no need to duplicate)
- [x] Created comprehensive migration documentation
- [x] **COMPLETE: Extracted LanguageSelector feature to GomaPlatform**
- [x] Moved all 4 screen files with proper modifications
- [x] Updated BetssonCameroonApp to use GomaPlatform dependency
- [x] Made GomaUI PreviewHelpers public for GomaPlatform access
- [x] Organized GomaPlatform with feature-based folder structure

### Issues / Bugs Hit
- [x] GomaUI has nested SharedModels dependency with relative path - causes `swift build` to fail standalone
  - **Solution**: Build via Xcode workspace instead of standalone `swift build`
- [x] GomaUI PreviewHelpers were internal, not accessible from GomaPlatform
  - **Solution**: Made `PreviewUIViewController` and `PreviewUIView` public in GomaUI

### Key Decisions
1. **One big GomaPlatform package** to start (can split later if needed)
2. **Feature-based folder organization** within GomaPlatform:
   ```
   Features/LanguageSelector/
   ├── Protocols/
   ├── ViewModels/
   ├── ViewControllers/
   └── Mocks/
   ```
3. **Protocol-based DI** for all client-specific services (e.g., `LanguageManagerProtocol`)
4. **Closures over delegates** for flow communication (e.g., `onDismiss`, `onLanguageSelected`)
5. **Use GomaUI's existing theming**: `StyleProvider.Color.xxx` and `LocalizationProvider.string()`
6. **Public PreviewHelpers** - Made GomaUI's preview helpers public for cross-package use
7. **Inject all client-specific dependencies** via ViewController init:
   - `navigationBarViewModel: SimpleNavigationBarViewModelProtocol`
   - `flagImageResolver: LanguageFlagImageResolver`

### Experiments & Notes
- Explored 3 approaches for client scaling: xcconfig+schemes (rejected - too many IFs), separate targets (current - nightmare), modular packages (chosen)
- Found `StyleProvider` already handles all color theming via `StyleProvider.customize(colors:)`
- Found `LocalizationProvider.configure()` handles all string localization

### Useful Files / Links
- [GomaPlatform Package.swift](../../Frameworks/GomaPlatform/Package.swift)
- [LanguageManagerProtocol](../../Frameworks/GomaPlatform/Sources/GomaPlatform/Features/LanguageSelector/Protocols/LanguageManagerProtocol.swift)
- [LanguageSelectorViewModel](../../Frameworks/GomaPlatform/Sources/GomaPlatform/Features/LanguageSelector/ViewModels/LanguageSelectorViewModel.swift)
- [LanguageSelectorFullScreenViewController](../../Frameworks/GomaPlatform/Sources/GomaPlatform/Features/LanguageSelector/ViewControllers/LanguageSelectorFullScreenViewController.swift)
- [Migration README](../MigrateToGomaPlatform/README.md)
- [GomaUI PreviewHelpers](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Helpers/PreviewsHelper/)

### Next Steps
1. ~~Fix build issue (use workspace, not standalone swift build)~~ ✅
2. ~~Move 4 LanguageSelector screen files to GomaPlatform~~ ✅
3. ~~Add `public` modifiers, replace `UIColor.App` → `StyleProvider.Color`~~ ✅
4. ~~Update BetssonCameroonApp: add package dependency, protocol conformance~~ ✅
5. ~~Update LanguageSelectorCoordinator to inject dependencies~~ ✅
6. Delete old files from BetssonCameroonApp (cleanup)
7. Delete duplicate PreviewHelpers from BetssonCameroonApp
8. Extract more screens (Splash, Maintenance, etc.)
