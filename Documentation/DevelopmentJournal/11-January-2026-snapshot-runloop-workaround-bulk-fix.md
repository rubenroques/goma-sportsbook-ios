## Date
11 January 2026

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Investigate why ~80% of GomaUI snapshot tests show incomplete/empty renders
- Apply RunLoop workaround to all affected test files
- Re-record all snapshots with proper rendering

### Achievements
- [x] Added `waitForCombineRendering(_:)` helper method to `SnapshotTestConfig.swift`
- [x] Updated 77 test files with workaround + TODO comment for future migration
- [x] Preserved 10 files already properly fixed (ButtonView, PillItemView, InlineScoreView, OutcomeItemView, ToasterView, etc.)
- [x] Re-recorded 295 snapshot images - all now render correctly
- [x] All 287 tests pass (in record mode, "failures" are expected)

### Issues / Bugs Hit
- [x] Bash `!` character in grep pattern caused shell history expansion error - fixed by using file-based approach
- [x] ToasterView was incorrectly flagged for workaround (already has scheduler injection) - manually fixed

### Key Decisions
- **RunLoop workaround as quick fix** - Add `SnapshotTestConfig.waitForCombineRendering(vc)` before each `assertSnapshot` call
- **TODO comments for tracking** - Each file needing proper fix has: `// TODO: Migrate component to currentDisplayState + dropFirst() or scheduler injection`
- **Helper method approach** - Centralized workaround in `SnapshotTestConfig` for consistency and documentation

### Experiments & Notes
- Root cause: `.receive(on: DispatchQueue.main)` always schedules for NEXT run loop iteration, even when already on main thread
- Even `CurrentValueSubject` with ready value delivers asynchronously with `.receive(on:)`
- RunLoop workaround: `viewController.loadViewIfNeeded()` + `RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))`
- Proper fixes documented in `SNAPSHOT_TESTING.md`:
  1. **Scheduler injection** (ToasterView pattern) - cleanest but requires protocol/mock/view changes
  2. **currentDisplayState + dropFirst()** (BorderedTextFieldView pattern) - less invasive

### Useful Files / Links
- [SnapshotTestConfig.swift](../../Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTestConfig.swift) - Helper method added
- [SNAPSHOT_TESTING.md](../../Frameworks/GomaUI/Documentation/Guides/SNAPSHOT_TESTING.md) - Comprehensive documentation
- [06-January-2026-combine-scheduler-injection-snapshot-fix.md](./06-January-2026-combine-scheduler-injection-snapshot-fix.md) - ToasterView migration reference
- [ToasterViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Status/ToasterView/ToasterViewModelProtocol.swift) - Scheduler injection example

### Next Steps
1. Commit all changes (77 test files + SnapshotTestConfig + 295 snapshot images)
2. Gradually migrate components to proper `currentDisplayState + dropFirst()` pattern
3. Find components needing migration: `grep -r "TODO: Migrate component" Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/`
4. Consider adding scheduler injection to GomaUI component template for new components
