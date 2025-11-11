## Date
07 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix compilation errors after git merge conflict resolution
- Restore missing Route enum cases that were accidentally removed

### Achievements
- [x] Identified root cause: Router.swift was deleted during merge conflict, but actual issue was missing Route enum cases
- [x] Added missing Route cases: `.promotions`, `.bonus`, `.event(id: String)`, `.competition(id: String)`
- [x] Fixed 8 compilation errors in MainTabBarCoordinator.swift related to Route type members

### Issues / Bugs Hit
- [x] User accidentally removed Router.swift thinking it was just a merge conflict artifact
- [x] Real issue: Route enum definition in Routes.swift was missing cases that André's branch expected
- [x] Git merge from commit `91acbadc8` brought in MainTabBarCoordinator changes that referenced Route cases not in current Routes.swift

### Key Decisions
- Investigated git history to find original Route enum definition with full cases
- Used `git log --all --full-history -p` to trace Route enum evolution
- Discovered Route enum was simplified at some point, removing cases like `event(id:)`, `competition(id:)`, `bonus`, `promotions`
- André's merge re-introduced code using the old Route cases without updating the enum definition

### Experiments & Notes
- Router.swift exists but is never actually used (see comment at top of file - AppCoordinator is used instead)
- The merge added Router.swift but it's not the source of compilation errors
- MainTabBarCoordinator parseRoute() and handleRoute() methods expect:
  - `.promotions` - line 603, 625
  - `.bonus` - line 605, 627
  - `.event(id:)` - line 608, 629
  - `.competition(id:)` - line 612, 631

### Useful Files / Links
- [Routes.swift](../../BetssonCameroonApp/App/Models/Configs/Routes.swift) - Route enum definition
- [MainTabBarCoordinator.swift:595-636](../../BetssonCameroonApp/App/Coordinators/MainTabBarCoordinator.swift) - parseRoute() and handleRoute() methods
- [Router.swift](../../BetssonCameroonApp/App/Boot/Router.swift) - Legacy router (not actively used)

### Next Steps
1. Verify build succeeds with restored Route cases
2. Consider if Router.swift should be removed entirely (it's marked as unused)
3. Review André's bonus/promotions coordinator integration for completeness
