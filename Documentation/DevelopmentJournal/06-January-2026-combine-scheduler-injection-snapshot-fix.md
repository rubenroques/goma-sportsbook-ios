## Date
06 January 2026

### Project / Branch
sportsbook-ios / rw/snapshot_tests

### Goals for this session
- Investigate why ~60% of snapshot tests show half-rendered/empty views
- Research Point-Free's solution to Combine async scheduling issues
- Implement proof of concept using ImmediateScheduler on ToasterView
- Document findings for future component migrations

### Achievements
- [x] Identified root cause: `.receive(on: DispatchQueue.main)` always schedules to next run loop, even on main thread
- [x] Researched Point-Free's combine-schedulers library and ImmediateScheduler approach
- [x] Added combine-schedulers dependency to GomaUI Package.swift
- [x] Migrated ToasterView to scheduler injection pattern (protocol, mock, view, production VM)
- [x] Successfully tested ToasterView snapshot - all variants render correctly
- [x] Documented comprehensive migration guide in SNAPSHOT_TESTING_GUIDE.md
- [x] Updated Components Status section showing ToasterView as reference implementation

### Issues / Bugs Hit
- [x] AppToasterViewModel (production implementation in BetssonCameroonApp) failed compilation after protocol change - fixed by adding scheduler property with `.main` default

### Key Decisions
- **Scheduler injection is the recommended approach for new components** - cleaner architecture, Point-Free endorsed
- **currentDisplayState + dropFirst() remains valid** for existing components - less invasive refactor
- Mock ViewModels default to `.immediate` scheduler (synchronous) - no test code changes needed
- Production ViewModels default to `.main` scheduler - existing app behavior unchanged

### Experiments & Notes
- Confirmed that Swift 6 / async-await would NOT fix this - same deferred execution issue exists with `Task { @MainActor in }`
- Point-Free's `.wait()` strategy in swift-snapshot-testing doesn't reliably work with async code
- The issue is fundamental to deferred execution, not Combine specifically

### Useful Files / Links
- [ToasterView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Status/ToasterView/ToasterView.swift) - View using injected scheduler
- [ToasterViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Status/ToasterView/ToasterViewModelProtocol.swift) - Protocol with scheduler property
- [MockToasterViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Status/ToasterView/MockToasterViewModel.swift) - Mock with `.immediate` default
- [AppToasterViewModel.swift](../../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/AppToasterViewModel.swift) - Production VM with `.main` default
- [SNAPSHOT_TESTING_GUIDE.md](../../Frameworks/GomaUI/GomaUI/Documentation/SNAPSHOT_TESTING_GUIDE.md) - Full documentation
- [pointfreeco/combine-schedulers](https://github.com/pointfreeco/combine-schedulers) - Library providing ImmediateScheduler
- [Discussion #669](https://github.com/pointfreeco/swift-snapshot-testing/discussions/669) - Known framework limitation

### Next Steps
1. Migrate ScoreView using scheduler injection pattern (or currentDisplayState + dropFirst)
2. Audit remaining components with empty snapshots and apply appropriate fix
3. Consider adding scheduler injection to component template for new GomaUI components
4. Re-record snapshot tests for fixed components
