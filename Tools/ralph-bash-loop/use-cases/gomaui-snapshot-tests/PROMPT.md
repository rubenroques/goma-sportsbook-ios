# GomaUI Snapshot Tests - Ralph Loop Task

You are creating comprehensive snapshot tests for GomaUI components. Each iteration you complete ONE component fully, then exit.

## Your Mission

1. Find the next component without snapshot tests
2. Deeply understand that component (read ALL its files)
3. Create snapshot tests covering all themes and meaningful states
4. Verify everything compiles and snapshots are generated
5. Mark it done and exit

---

## Step 1: Find Next Component

Read `Frameworks/GomaUI/Documentation/Catalog/COMPONENT_MAP.json` and find the first component where `has_snapshot_tests` is `false` or missing.

If ALL components already have snapshot tests, output:
```
<promise>COMPLETE</promise>
```
And stop immediately.

---

## Step 2: Deeply Understand the Component

### 2.1 Read ALL files in the component folder

Find the component's folder under `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/` and read EVERY file:
- The main View file (`{ComponentName}.swift`)
- The ViewModel Protocol (`{ComponentName}ViewModelProtocol.swift`)
- The Mock ViewModel (`Mock{ComponentName}ViewModel.swift`)
- Any helper views, enums, or supporting files

You need complete context to create meaningful snapshots.

### 2.2 Understand available states

From the MockViewModel and Protocol, identify:
- Different display states (default, loading, error, empty, etc.)
- Selection states (selected, unselected, highlighted)
- Configuration variants (different sizes, styles, content lengths)
- Any presets or factory methods in the Mock

### 2.3 For complex components, check real usage

If the component seems complex or you're unsure how it's used, search for its usage in BetssonCameroonApp:
- How is it instantiated?
- What ViewModel implementations exist?
- What states does the app actually use?

This helps you understand which states matter in practice.

---

## Step 3: Study Reference Implementation

Before writing, read these files to understand the exact pattern:

**SnapshotViewController example:**
`Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Betting/OutcomeItemView/OutcomeItemViewSnapshotViewController.swift`

**Test file example:**
`Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/OutcomeItemView/OutcomeItemViewSnapshotTests.swift`

**Config:**
`Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/SnapshotTestConfig.swift`

Key patterns to follow:
- Category enum grouping related states
- Each category has multiple variants shown in a vertical stack
- Tests run each category in BOTH Light and Dark themes
- Use `SnapshotTestConfig.device`, `.size`, `.lightTraits`, `.darkTraits`

---

## Step 4: Create the Files

### 4.1 SnapshotViewController

**Location:** Same folder as the component (inside Sources)
`Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/{Category}/{ComponentName}/{ComponentName}SnapshotViewController.swift`

**Requirements:**
- Category enum covering all meaningful state groups
- Each category method adds labeled variants to a stack
- Use ALL relevant Mock presets
- Include `#Preview` macros for each category
- Follow the exact structure from OutcomeItemViewSnapshotViewController

### 4.2 Test File

**Location:** In Tests (flat structure, no category subfolder)
`Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/{ComponentName}/{ComponentName}SnapshotTests.swift`

**Requirements:**
- Create the directory if it doesn't exist
- One test method per category
- EACH category needs BOTH Light AND Dark test
- Use SnapshotTestConfig consistently
- Follow the exact structure from OutcomeItemViewSnapshotTests

---

## Step 5: Verify

### 5.1 Build the GomaUI scheme

Build with `xcodebuild build-for-testing` using scheme `GomaUI` (NOT GomaUICatalog).

If build fails, read the errors, fix them, rebuild. Do not proceed with broken code.

### 5.2 Run the specific tests

Run with `xcodebuild test -only-testing:GomaUITests/{ComponentName}SnapshotTests`

"Record mode" test "failures" are expected - they mean snapshots are being generated.

### 5.3 Verify snapshots exist

Check that `.png` files were created in the `__Snapshots__` folder. If no images exist, something went wrong.

---

## Step 6: Mark Complete

Update `Frameworks/GomaUI/Documentation/Catalog/COMPONENT_MAP.json`:
- Set `has_snapshot_tests: true` for this component

---

## Step 7: Exit

After completing ONE component, output a summary like:
```
Completed: {ComponentName}
Categories: {list of categories}
Tests: {number} (Light + Dark)
```

Then exit. The loop will call you again for the next one.

---

## Quality Guidelines

### Theme Coverage
Every category MUST be tested in:
- Light mode (`.lightTraits`)
- Dark mode (`.darkTraits`)

### State Coverage
Aim for comprehensive coverage:
- All states from MockViewModel presets
- Edge cases (empty content, very long text, etc.)
- Interactive states if applicable (pressed, disabled)

### Category Organization
Group related variants logically:
- "Basic States" - default, selected, unselected
- "Display States" - loading, error, empty, locked
- "Content Variants" - short text, long text, with/without icons
- "Size Variants" - if the component supports different sizes

Minimum 1 category, maximum 6 categories depending on component complexity.

---

## Reference Documentation

For full details on patterns and examples:
`Frameworks/GomaUI/Documentation/Process/RALPH_SNAPSHOT_TESTS.md`

---

## Output Signals

- Completed one component → exit normally (loop continues)
- ALL components done → `<promise>COMPLETE</promise>`
- Unrecoverable error after multiple attempts → `<promise>FAILED</promise>`
