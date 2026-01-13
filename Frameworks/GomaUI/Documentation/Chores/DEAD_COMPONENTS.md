# Dead Components - Candidates for Deletion or Rework

Last updated: 2026-01-13

## Summary Table

| Component | BetssonCameroon | BetssonFrance | BetssonFranceLegacy | Showcase | GomaUI Catalog | Status |
|-----------|-----------------|---------------|---------------------|----------|----------------|--------|
| `GeneralFilterBarView` | ViewModel only | - | - | - | - | DEAD |
| `FilterOptionCell` | - | - | - | - | Demo only | DEAD |
| `SportSelectorCell` | - | - | - | - | Demo only | DEAD |
| `MainFilterPillView` | - | - | - | - | Demo only | DEAD |

---

## Details

### GeneralFilterBarView + FilterOptionCell + SportSelectorCell

**Discovered:** 2026-01-13 during snapshot test review

**Replaced by:** `PillSelectorBarView` + `PillItemView`

**Known bugs:**
- `FilterOptionCell.swift:9` - hardcoded `.white` background (should use `StyleProvider.Color.pills`)
- `SportSelectorCell.swift:9` - hardcoded `.white` background (should use `StyleProvider.Color.pills`)
- Both cause white-on-white text in dark mode (invisible labels)

**Files affected:**
```
Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Filters/
├── GeneralFilterBarView/
│   ├── GeneralFilterBarView.swift
│   ├── GeneralFilterBarViewModelProtocol.swift
│   ├── MockGeneralFilterBarViewModel.swift
│   └── README.md
├── FilterOptionCell/
│   ├── FilterOptionCell.swift
│   ├── FilterOptionCellViewModel.swift
│   ├── FilterOptionCellSnapshotViewController.swift
│   └── README.md
└── SportSelectorCell/
    ├── SportSelectorCell.swift
    ├── SportSelectorCellViewModel.swift
    └── README.md
```

**Current usage:**
- `GeneralFilterBarView` - Not instantiated anywhere
- `FilterOptionCell` / `SportSelectorCell` - Only in `Frameworks/GomaUI/Catalog/Components/Betting/GeneralFilterViewController.swift` (demo)

**BetssonCameroon remnant:**
- `NextUpEventsViewModel.swift:69` has `generalFiltersBarViewModel: GeneralFilterBarViewModelProtocol`
- `NextUpEventsViewModel.swift:139` creates `MockGeneralFilterBarViewModel`
- But the View is never created or added to UI
- The actual UI uses `PillSelectorBarView` instead

**Recommended action:**
1. Delete `GeneralFilterBarView`, `FilterOptionCell`, `SportSelectorCell`, `MainFilterPillView` and their supporting files
2. Remove `generalFiltersBarViewModel` from `NextUpEventsViewModel`
3. Update `GeneralFilterViewController.swift` in Catalog to use `PillSelectorBarView` instead
4. Remove from COMPONENT_MAP.json and catalog.json

---

### MainFilterPillView

**Discovered:** 2026-01-13 during snapshot test review

**Used by:** `GeneralFilterBarView` (which is dead code)

**Known bugs:**
- `MainFilterPillView.swift:10` - uses `StyleProvider.Color.allWhite` for background (always white in both modes)
- `MainFilterPillView.swift:37` - uses `StyleProvider.Color.textPrimary` for label (white in dark mode)
- Result: white text on white background in dark mode (invisible labels)

**Files affected:**
```
Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Filters/MainFilterPillView/
├── MainFilterPillView.swift
├── MainFilterPillViewModelProtocol.swift
├── MockMainFilterPillViewModel.swift
├── MainFilterPillViewSnapshotViewController.swift
└── README.md
```

**Current usage:**
- Only used by `GeneralFilterBarView.swift` (dead code)
- Catalog demo in `GeneralFilterViewController.swift`
- Snapshot tests

**Recommended action:**
- Delete along with `GeneralFilterBarView` and related components

---

## How to Add Entries

When you discover dead components:

1. Add to summary table with production usage status
2. Document what replaced it (if applicable)
3. List known bugs (helps justify deletion)
4. List all affected files
5. Document any remnants in production code
6. Recommend specific cleanup actions

---

## Detection Techniques & Algorithms

### Technique Comparison

| Technique | How It Works | Pros | Cons | Handles Transitive |
|-----------|-------------|------|------|-------------------|
| **Periphery** | Swift AST static analysis | Finds unused classes/types; multi-scheme support | False positives with protocols; slow on large codebases | Partial |
| **Grep Patterns** | Text search for `ComponentName(` | Fast, flexible | Context-blind; high false positives | Requires post-processing |
| **COMPONENT_MAP Traversal** | Follow parent/child edges in JSON | Graph-based; knows true dependencies | Requires maintaining map | Yes, native |
| **Xcode Call Hierarchy** | IDE "Find Call Hierarchy" | Accurate for symbols | Manual; doesn't scale | No automation |

### Recommended Hybrid Approach

**Stage 1: Grep Discovery**
```bash
# For each component, check if instantiated in production apps
for component in $(ls Components/); do
  if ! grep -r "${component}(" BetssonCameroonApp BetssonFrance Showcase \
      --include="*.swift" -q 2>/dev/null; then
    echo "$component: CANDIDATE_DEAD"
  fi
done
```

**Stage 2: Transitive Closure Computation**
```
For each CANDIDATE_DEAD component:
  - If no parents → INDEPENDENTLY_DEAD (root of dead tree)
  - If all parents are also dead → TRANSITIVELY_DEAD
  - Children of dead parents → AT_RISK
```

**Stage 3: Periphery Verification**
```bash
periphery scan \
  --project Frameworks/GomaUI/GomaUI.xcodeproj \
  --schemes GomaUI \
  --format json
```

### Transitive Deadness Algorithm

```
Algorithm: ComputeDeadTransitive(comp_map, dead_set)

Input:
  - comp_map: {ComponentName -> {children: [], parents: []}}
  - dead_set: {ComponentName} (initially detected dead components)

Steps:
1. Find roots: components with no parents OR all parents in dead_set
2. Identify living_roots: roots that are NOT in dead_set
3. BFS from living_roots to find all reachable components
4. Transitively dead = dead_set - reachable

Example:
  Components: A → B → C → D, E (standalone)
  Dead from grep: {A, B, C}

  Living roots: {E}
  Reachable from E: {E}
  Transitively dead: {A, B, C} (entire tree is dead)
```

### Confidence Scoring

| Score | Meaning | Action |
|-------|---------|--------|
| 0 | No matches anywhere | REMOVE (safe) |
| 1 | Only Mock/Snapshot references | REMOVE (safe) |
| 2 | Only in comments/docs | REVIEW with team |
| 3 | Only in COMPONENT_MAP as child | REVIEW with team |
| 4 | Only in tests/previews | KEEP (likely used) |
| 5 | Found in production code | KEEP |

### Tools Available

- **Periphery 3.4.0** - installed at `/opt/homebrew/bin/periphery`
- **COMPONENT_MAP.json** - tracks parent/child relationships at `Documentation/Catalog/COMPONENT_MAP.json`
- **grep/ripgrep** - fast text search

### Common False Positives

1. **Protocol-only components** - referenced via protocol, not concrete class
2. **DI/Reflection registration** - `factory.register("ComponentName") { ... }`
3. **Mock-only usage** - MockComponent used but real Component isn't
4. **Storyboard/XIB** - check `.storyboard` and `.xib` files too

### Quick Commands

```bash
# Check if component is used in any production app
grep -r "ComponentName(" BetssonCameroonApp BetssonFrance Showcase --include="*.swift"

# Find all components with zero production usage
for dir in Frameworks/GomaUI/.../Components/*/; do
  comp=$(basename "$dir")
  count=$(grep -r "${comp}(" BetssonCameroonApp BetssonFrance Showcase --include="*.swift" 2>/dev/null | wc -l)
  [ "$count" -eq 0 ] && echo "$comp: DEAD"
done

# Run Periphery on GomaUI
periphery scan --project Frameworks/GomaUI/GomaUI.xcodeproj --schemes GomaUI
```
