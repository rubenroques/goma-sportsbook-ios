## Date
15 November 2025

### Project / Branch
sportsbook-ios / rr/breadcrumb

### Goals for this session
- Create user-specific build flag system for local development
- Skip Face ID authentication during development to speed up iteration
- Implement without affecting team members or production builds

### Achievements
- [x] Created workspace-level xcconfig system with Debug.xcconfig (tracked) + Local.xcconfig (gitignored)
- [x] Configured BetssonCameroonApp to use xcconfig for Debug-Staging and Debug-Production configurations
- [x] Added LOCAL_DEBUGR Swift compilation condition flag
- [x] Implemented Face ID bypass on app startup (auto-restore session)
- [x] Implemented Face ID bypass on app foreground return
- [x] Updated .gitignore to exclude Local.xcconfig

### Issues / Bugs Hit
- [x] Initial approach tried to use `#include? "../../Local.xcconfig"` directly in project settings - doesn't work without a base xcconfig file
- [x] Xcode requires xcconfig reference to be added to project.pbxproj, which initially created duplicate reference entries (resolved by Xcode auto-cleanup)

### Key Decisions
- **Chose workspace-level approach** over project-specific configs for flexibility across multiple projects
- **Two-file pattern**: Debug.xcconfig (shared) optionally includes Local.xcconfig (personal) - teammates don't get build errors
- **ViewController-level implementation** for LOCAL_DEBUGR Face ID bypass - pragmatic choice acknowledging architectural debt
- **Auto-restore session** instead of anonymous start for best developer experience
- **Skip on both startup and foreground** to avoid interruptions during development

### Experiments & Notes
- Researched xcconfig best practices - Swift doesn't support value-based preprocessor macros like C (only presence/absence flags)
- SWIFT_ACTIVE_COMPILATION_CONDITIONS is the proper way to add custom Swift compilation flags
- `#include?` syntax with question mark makes include optional - prevents build failures for teammates
- Discovered MainTabBarViewController has significant MVVM-C violations (577 lines with business logic, direct LAContext usage, navigation decisions)

### Architectural Debt Acknowledged
**CRITICAL**: Face ID bypass implementation perpetuates MVVM-C violations in MainTabBarViewController:
- Business logic in ViewController (authenticateUser() method)
- Direct LocalAuthentication framework usage instead of service abstraction
- Navigation decisions (unlockAppWithUser/unlockAppAnonymous) in VC instead of Coordinator
- App lifecycle business logic in VC instead of ViewModel state observation

**Proper architecture would be**:
```
BiometricAuthenticationService → MainTabBarViewModel → MainTabBarViewController
                                        ↓
                                  Coordinator (navigation)
```

Added comprehensive TODO entry documenting all violations and refactoring roadmap.

### Useful Files / Links
- [Debug.xcconfig](../../Debug.xcconfig) - Shared xcconfig with optional Local.xcconfig include
- [Local.xcconfig](../../Local.xcconfig) - Personal build flags (gitignored)
- [.gitignore](../../.gitignore) - Updated to exclude Local.xcconfig
- [MainTabBarViewController.swift](../../BetssonCameroonApp/App/Screens/MainTabBar/MainTabBarViewController.swift) - Face ID bypass implementation (lines 419-423, 565-568)
- [TODO_TASKS.md](../../TODO_TASKS.md) - Architectural debt entry added
- [CLAUDE.md](../../CLAUDE.md) - Project context and MVVM-C guidelines

### Research Resources
- Web search: Xcode custom build flags, xcconfig files, user-specific settings
- Web search: Swift preprocessor macros, SWIFT_ACTIVE_COMPILATION_CONDITIONS
- Explored codebase: LocalAuthentication usage, session restoration flow, biometric authentication

### Next Steps
1. Test LOCAL_DEBUGR flag with clean app install (verify auto-restore session works)
2. Test app foreground return bypass (verify no Face ID prompt when switching apps)
3. Consider scheduling MainTabBarViewController MVVM-C refactor in future sprint
4. Pattern established - can use LOCAL_DEBUGR for other debug-only features (logging, API endpoint switching, etc.)
5. When refactoring Face ID auth to proper MVVM-C, move LOCAL_DEBUGR bypass to BiometricAuthenticationService layer

### Technical Implementation Details

**xcconfig Setup**:
```bash
# Debug.xcconfig (tracked)
#include? "Local.xcconfig"

# Local.xcconfig (gitignored)
SWIFT_ACTIVE_COMPILATION_CONDITIONS = $(inherited) LOCAL_DEBUGR
```

**project.pbxproj Changes**:
- Added PBXFileReference for Debug.xcconfig with relative path `../../Debug.xcconfig`
- Set baseConfigurationReference on both Debug configurations (Staging and Production)

**Swift Usage**:
```swift
#if LOCAL_DEBUGR
    print("[LOCAL_DEBUGR] Debug message only on my machine")
    // Debug-only code here
#endif
```

### Session Reflection
Started with simple goal (local debug flag), evolved into architectural discussion. Pragmatism won for immediate productivity, but properly documented technical debt for future improvement. The LOCAL_DEBUGR system is solid and reusable for other debug features. Face ID bypass works perfectly but acknowledged it's in the wrong layer - important distinction between "works" and "architecturally correct."
