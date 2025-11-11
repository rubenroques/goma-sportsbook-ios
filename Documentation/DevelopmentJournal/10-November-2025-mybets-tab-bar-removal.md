## Date
10 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Hide Sports/Virtuals tab bar in MyBets screen (Virtuals not supported at launch)
- Snap PillSelector bar (Open/Cash Out/Won/Settled) to top of screen
- Preserve all code for easy re-enablement when Virtuals support is added

### Achievements
- [x] Explored MyBets screen architecture and UI hierarchy
- [x] Analyzed impact of hiding tab bar across coordinators and navigation
- [x] Commented out `MarketGroupSelectorTabView` initialization (lines 27-40)
- [x] Commented out tab view UI setup and constraints (lines 208-228)
- [x] Updated `PillSelectorBarView` top constraint to snap to `safeAreaLayoutGuide.topAnchor` (line 231)
- [x] Commented out tab selection publisher binding (lines 270-279)
- [x] Added clear MARK comments and TODO reminders for future Virtuals support

### Issues / Bugs Hit
- None - clean implementation with no breaking changes

### Key Decisions
- **Chose "hide with comments" approach** over complete removal
  - Keeps `MyBetsTabBarViewModel`, `MyBetsTabType`, `MyBetsTabsImageResolver` intact
  - All ViewModel logic preserved (defaults to `.sports`)
  - Easy to re-enable by uncommenting 3 blocks and reverting 1 constraint
- **No coordinator changes needed** - tab selection is self-contained in MyBets screen
- **No navigation/routing impact** - no external references to Sports/Virtuals distinction

### Experiments & Notes
- Discovered Virtuals feature is already stubbed out in `MyBetsViewModel.swift` (lines 186-191)
  - Returns empty array immediately if `.virtuals` selected
  - No API call made - placeholder for future implementation
- Impact analysis showed zero risk:
  - Coordinators: no references to `MyBetsTabType`
  - Navigation: no deep linking or routing dependencies
  - API calls: continue working with Sports as default
  - Cache keys: still use format `"\(selectedTabType.rawValue)_\(selectedStatusType.rawValue)"`

### Useful Files / Links
- [MyBetsViewController.swift](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewController.swift) - Main changes
- [MyBetsViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/MyBetsViewModel.swift) - Virtuals stub (lines 186-191)
- [MyBetsTabBarViewModel.swift](../../BetssonCameroonApp/App/Screens/MyBets/ViewModels/MyBetsTabBarViewModel.swift) - Preserved for future
- [MyBetsTabType.swift](../../BetssonCameroonApp/App/Screens/MyBets/Models/MyBetsTabType.swift) - Preserved for future

### UI Layout Changes
**Before:**
```
┌─────────────────────────────────┐
│  MarketGroupSelectorTabView     │ ← Sports/Virtuals (42pt)
├─────────────────────────────────┤
│  PillSelectorBarView            │ ← Status filters (60pt)
├─────────────────────────────────┤
│  TableView / Content            │
└─────────────────────────────────┘
```

**After:**
```
┌─────────────────────────────────┐
│  PillSelectorBarView (at top)   │ ← Status filters (60pt)
├─────────────────────────────────┤
│  TableView / Content            │
└─────────────────────────────────┘
```

### Next Steps
1. ✅ Test build to ensure no compilation errors
2. ✅ Verify MyBets screen displays correctly with PillSelector at top
3. When Virtuals support is ready:
   - Uncomment 3 blocks marked "DISABLED: Sports/Virtuals"
   - Revert line 231: `pillSelectorBarView.topAnchor.constraint(equalTo: marketGroupSelectorTabView.bottomAnchor)`
