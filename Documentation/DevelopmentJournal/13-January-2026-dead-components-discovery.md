## Date
13 January 2026

### Project / Branch
sportsbook-ios / wip/manual-distribute-refactor

### Goals for this session
- Review snapshot test results from Ralph loop
- Investigate dark mode rendering issues in FilterOptionCell snapshots
- Trace component usage to understand why BetssonCameroon works correctly

### Achievements
- [x] Identified dark mode bug in FilterOptionCell and SportSelectorCell (hardcoded `.white` background)
- [x] Traced full component hierarchy from FilterOptionCell → GeneralFilterBarView → NextUpEventsViewModel
- [x] Discovered that GeneralFilterBarView/FilterOptionCell/SportSelectorCell are **dead code** - not used in any production app
- [x] Confirmed BetssonCameroon uses PillSelectorBarView + PillItemView instead (which handles dark mode correctly)
- [x] Created `Frameworks/GomaUI/Documentation/Chores/DEAD_COMPONENTS.md` to track unused components
- [x] Discovered MainFilterPillView has same bug pattern (`allWhite` background + `textPrimary` text = invisible in dark mode)
- [x] Researched dead code detection techniques and algorithms
- [x] Documented hybrid approach: Grep + COMPONENT_MAP traversal + Periphery verification
- [x] Added detection methodology to DEAD_COMPONENTS.md for future use

### Issues / Bugs Hit
- [x] FilterOptionCell.swift:9 - `backgroundColor = .white` hardcoded (should use StyleProvider)
- [x] SportSelectorCell.swift:9 - same hardcoded `.white` bug
- [x] MainFilterPillView.swift:10 - `StyleProvider.Color.allWhite` (always white) + line 37 `textPrimary` (white in dark mode)
- [x] All cause invisible text in dark mode (white text on white background)

### Key Decisions
- **Do not fix the bugs** - components are dead code, not worth maintaining
- Created tracking doc for dead components instead of immediate deletion
- Recommend full deletion of GeneralFilterBarView, FilterOptionCell, SportSelectorCell, MainFilterPillView in future cleanup
- Documented detection techniques for finding more dead components systematically

### Experiments & Notes

**Component usage audit results:**

| Component | BetssonCameroon | BetssonFrance | BetssonFranceLegacy | Showcase | GomaUI Catalog | Status |
|-----------|-----------------|---------------|---------------------|----------|----------------|--------|
| `GeneralFilterBarView` | ViewModel only | - | - | - | - | DEAD |
| `FilterOptionCell` | - | - | - | - | Demo only | DEAD |
| `SportSelectorCell` | - | - | - | - | Demo only | DEAD |
| `MainFilterPillView` | - | - | - | - | Demo only | DEAD |

**Why BetssonCameroon works:**
- Uses `PillSelectorBarView` + `PillItemView` (line 12 in NextUpEventsViewController.swift)
- PillItemView uses `StyleProvider.Color.pills` for background (adapts to dark mode)
- PillItemStyle.swift provides proper defaultSelected/defaultUnselected styles

**Dead code remnants in BetssonCameroon:**
- `NextUpEventsViewModel.swift:69` - `generalFiltersBarViewModel: GeneralFilterBarViewModelProtocol`
- `NextUpEventsViewModel.swift:139` - creates MockGeneralFilterBarViewModel
- But the View is never instantiated or added to UI

**Dead Code Detection Techniques Researched:**

| Technique | Best For | Handles Transitive? |
|-----------|----------|---------------------|
| Periphery (AST) | Unused public classes | Partial |
| Grep patterns | Quick elimination | Needs post-processing |
| COMPONENT_MAP traversal | Dead component trees | Yes, native |
| Xcode Call Hierarchy | Manual verification | No automation |

**Recommended Hybrid Approach:**
1. Stage 1: Grep for `ComponentName(` in all production apps
2. Stage 2: Compute transitive closure (dead parent = dead children)
3. Stage 3: Periphery verification for edge cases

**Transitive Deadness Algorithm:**
```
If component not used in apps → CANDIDATE_DEAD
If CANDIDATE_DEAD has no parents → INDEPENDENTLY_DEAD
If all parents of CANDIDATE_DEAD are also dead → TRANSITIVELY_DEAD
```

### Useful Files / Links
- [FilterOptionCell.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Filters/FilterOptionCell/FilterOptionCell.swift) - buggy component
- [SportSelectorCell.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Filters/SportSelectorCell/SportSelectorCell.swift) - buggy component
- [MainFilterPillView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Filters/MainFilterPillView/MainFilterPillView.swift) - buggy component
- [PillItemView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Filters/PillItemView/PillItemView.swift) - correct implementation
- [PillItemStyle.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Filters/PillItemView/PillItemStyle.swift) - StyleProvider usage example
- [DEAD_COMPONENTS.md](../../Frameworks/GomaUI/Documentation/Chores/DEAD_COMPONENTS.md) - tracking doc with detection techniques
- [NextUpEventsViewController.swift](../../BetssonCameroonApp/App/Screens/NextUpEvents/NextUpEventsViewController.swift) - uses PillSelectorBarView

### Next Steps
1. Decide whether to delete dead components or leave for future cleanup
2. Run detection techniques on full GomaUI Components folder to find more dead code
3. Remove `generalFiltersBarViewModel` from NextUpEventsViewModel (dead code remnant)
4. Update GeneralFilterViewController.swift in Catalog to use PillSelectorBarView
5. Consider creating automated script in `tools/` for dead component detection
