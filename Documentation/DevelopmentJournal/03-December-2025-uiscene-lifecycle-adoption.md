## Date
03 December 2025

### Project / Branch
BetssonCameroonApp / rr/fix/double_toggle_outcome

### Goals for this session
- Fix UIScene lifecycle warning: "`UIScene` lifecycle will soon be required. Failure to adopt will result in an assert in the future."
- Migrate from legacy UIApplicationDelegate lifecycle to modern UIScene-based lifecycle

### Achievements
- [x] Created `SceneDelegate.swift` with window creation, Bootstrap initialization, and lifecycle handling
- [x] Updated `AppDelegate.swift` to remove window/bootstrap properties and add scene configuration method
- [x] Added `UIApplicationSceneManifest` configuration to both STG and PROD Info.plist files
- [x] Moved universal links handling from AppDelegate to SceneDelegate
- [x] Added helper property to access SceneDelegate from AppDelegate for push notification routing
- [x] App builds and runs without the UIScene lifecycle warning

### Issues / Bugs Hit
- None - clean migration

### Key Decisions
- **UIApplicationSupportsMultipleScenes set to false** - avoids iPad multi-window complexity, keeps single-window behavior
- **Orientation handling stays in AppDelegate** - the `application(_:supportedInterfaceOrientationsFor:)` delegate method still works with UIScene and minimizes changes
- **App-level setup stays in AppDelegate** - Firebase, XtremePush, Phrase SDK, IQKeyboardManager initialization remains in `didFinishLaunchingWithOptions`
- **Scene-level setup moves to SceneDelegate** - window creation, Bootstrap/AppCoordinator init, foreground/background lifecycle, universal links

### Experiments & Notes
- Explored BetssonFranceApp and GomaUIDemo - neither has adopted UIScene yet (same warning applies)
- Bootstrap and AppCoordinator patterns unchanged - just initialized from SceneDelegate instead of AppDelegate

### Useful Files / Links
- [SceneDelegate.swift](../../BetssonCameroonApp/App/Boot/SceneDelegate.swift) - New file
- [AppDelegate.swift](../../BetssonCameroonApp/App/Boot/AppDelegate.swift) - Updated
- [Bootstrap.swift](../../BetssonCameroonApp/App/Boot/Bootstrap.swift) - Unchanged (receives window, passes to AppCoordinator)
- [BetssonCM-STG-Info.plist](../../BetssonCameroonApp/App/SupportingFiles/Misc-Stg/BetssonCM-STG-Info.plist) - Added UIApplicationSceneManifest
- [BetssonCM-PROD-Info.plist](../../BetssonCameroonApp/App/SupportingFiles/Misc-Prod/BetssonCM-PROD-Info.plist) - Added UIApplicationSceneManifest

### Architecture Change Summary
```
BEFORE (Legacy):
AppDelegate.didFinishLaunchingWithOptions()
  → window = UIWindow()
  → Bootstrap(window).boot()
  → AppCoordinator.start()

AFTER (UIScene):
AppDelegate.didFinishLaunchingWithOptions()
  → Firebase, XtremePush, SDK setup only (no window)

SceneDelegate.scene(_:willConnectTo:options:)
  → window = UIWindow(windowScene:)
  → Bootstrap(window).boot()
  → AppCoordinator.start()
```

### Next Steps
1. Consider migrating BetssonFranceApp to UIScene lifecycle (same warning)
2. Consider migrating GomaUIDemo to UIScene lifecycle (same warning)
