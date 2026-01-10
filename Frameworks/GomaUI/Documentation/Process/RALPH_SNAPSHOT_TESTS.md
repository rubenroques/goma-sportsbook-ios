# Ralph Task: Generate Snapshot Tests for GomaUI Components

## Objective
Create snapshot tests for ALL GomaUI components that don't have them yet, following the established two-file pattern.

## Documentation Reference
Read and follow the patterns in:
```
Frameworks/GomaUI/Documentation/Guides/SNAPSHOT_TESTING.md
```

## Progress Tracking
Update `Frameworks/GomaUI/Documentation/Catalog/COMPONENT_MAP.json` - add `"has_snapshot_tests": true` after creating tests for each component.

## Example Implementation (MUST READ FIRST)
Study these files as the reference implementation:

**SnapshotViewController** (in Sources, inside category folder):
```
Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Betting/OutcomeItemView/OutcomeItemViewSnapshotViewController.swift
```

**Test File** (in Tests, flat structure):
```
Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/OutcomeItemView/OutcomeItemViewSnapshotTests.swift
```

**Config**:
```
Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/SnapshotTestConfig.swift
```

## File Structure to Create

For each component `{ComponentName}` in category `{Category}`:

1. **SnapshotViewController** at (same folder as the component):
```
Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/{Category}/{ComponentName}/{ComponentName}SnapshotViewController.swift
```

Example: `Components/Betting/OutcomeItemView/OutcomeItemViewSnapshotViewController.swift`

2. **Test File** at (flat structure in Tests, no category subfolder):
```
Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/{ComponentName}/{ComponentName}SnapshotTests.swift
```

Example: `Tests/GomaUITests/SnapshotTests/OutcomeItemView/OutcomeItemViewSnapshotTests.swift`

## How to Determine Categories

Read the component's main `.swift` file and `MockViewModel` to identify:

### State-Based Categories
- **Basic States**: selected, unselected, default
- **Display States**: loading, locked, disabled, unavailable, error
- **Interactive States**: pressed, highlighted, focused

### Visual Categories
- **Styling Variants**: different colors, borders, backgrounds
- **Size Variants**: compact, standard, large, custom dimensions
- **Content Variants**: short text, long text, with/without icon

### Behavior Categories
- **Animation States**: odds up/down, expanding/collapsing
- **Configuration Options**: different init parameters

### Rules for Categories
- Minimum 1 category (simple components)
- Maximum 6 categories (complex components)
- Each category should have 3-6 variants
- Name categories clearly: "Basic States", "Display States", "Size Variants"

## SnapshotViewController Template

```swift
import UIKit

enum {ComponentName}SnapshotCategory: String, CaseIterable {
    case basicStates = "Basic States"
    // Add more based on component complexity
}

final class {ComponentName}SnapshotViewController: UIViewController {

    private let category: {ComponentName}SnapshotCategory

    init(category: {ComponentName}SnapshotCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        setupUI()
    }

    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "{ComponentName} - \(category.rawValue)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 16)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        addVariants(to: stackView)
    }

    private func addVariants(to stackView: UIStackView) {
        switch category {
        case .basicStates:
            addBasicStatesVariants(to: stackView)
        }
    }

    private func addBasicStatesVariants(to stackView: UIStackView) {
        // Use MockViewModel presets to create variants
        stackView.addArrangedSubview(createLabeledVariant(
            label: "Default",
            view: {ComponentName}View(viewModel: Mock{ComponentName}ViewModel.defaultMock)
        ))
    }

    private func createLabeledVariant(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = StyleProvider.fontWith(type: .medium, size: 12)
        labelView.textColor = StyleProvider.Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview("Basic States") {
    {ComponentName}SnapshotViewController(category: .basicStates)
}
#endif
```

## Test File Template

```swift
import XCTest
import SnapshotTesting
@testable import GomaUI

final class {ComponentName}SnapshotTests: XCTestCase {

    // MARK: - Basic States

    func test{ComponentName}_BasicStates_Light() throws {
        let vc = {ComponentName}SnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func test{ComponentName}_BasicStates_Dark() throws {
        let vc = {ComponentName}SnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
```

## Components Location

Components are organized into category folders:
```
Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/
├── Betting/          (26 components - OutcomeItemView, BetslipTicketView, etc.)
├── Casino/           (9 components)
├── Filters/          (14 components)
├── Forms/            (12 components)
├── MatchCards/       (11 components - TallOddsMatchCardView, etc.)
├── Navigation/       (6 components)
├── Profile/          (5 components)
├── Promotions/       (10 + 12 ContentBlocks)
├── Status/           (9 components)
├── UIElements/       (15 components - ButtonView, CapsuleView, etc.)
└── Wallet/           (9 components)
```

## For Each Component

### Finding Components
To locate a component, search in the category folders:
```bash
find Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components -type d -name "{ComponentName}"
```

Or list all components in a category:
```bash
ls Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Betting/
```

### Process
1. Check COMPONENT_MAP.json - skip if `has_snapshot_tests: true`
2. Find the component's category folder using the find command above
3. Read the component's Swift files to understand:
   - Available states from MockViewModel
   - Configuration options
   - Visual variants
4. Determine appropriate snapshot categories (1-6)
5. Create SnapshotViewController in the component's category folder
6. Create Test file in Tests/GomaUITests/SnapshotTests/{ComponentName}/
7. Build and run tests (see Build Verification section)
8. Update COMPONENT_MAP.json: `has_snapshot_tests: true`
9. Git commit every 3 components

## Iteration Strategy
- Process 3 components per iteration
- Read COMPONENT_MAP.json first to find components without `has_snapshot_tests`
- Prioritize simpler components first (fewer files in folder)
- Always read the MockViewModel to find available preset states

## Build Verification (MANDATORY)

After creating tests for each batch of 3 components, you MUST verify the code compiles.

### IMPORTANT: Scheme Selection
```
CORRECT SCHEME: GomaUI
WRONG SCHEME:   GomaUICatalog  ← DO NOT USE THIS
```

GomaUI is the Swift Package library with the test target.
GomaUICatalog is a separate demo app - do NOT build or test with it.

### Simulator ID (Dynamic Lookup)

**IMPORTANT**: Do NOT use hardcoded simulator IDs. They become stale when simulators are recreated.

At the START of the task, get a valid simulator ID:
```bash
xcrun simctl list devices available | grep -E "iPhone.*(18\.[0-9]|19\.)" | head -1
```

Extract the UUID from the output and use it for all subsequent commands. Store it mentally as `SIMULATOR_ID`.

Example output: `iPhone 16 Pro (ABC12345-...) (Booted)` → use `ABC12345-...`

If no iOS 18+ simulator exists, the task cannot proceed - notify the user.

### Step 1: Build the GomaUI scheme (checks compilation)

ALWAYS use `-scheme GomaUI` (NOT GomaUICatalog):

```bash
xcodebuild build-for-testing -workspace Sportsbook.xcworkspace -scheme GomaUI -destination 'platform=iOS Simulator,id=SIMULATOR_ID' 2>&1 | xcbeautify --quieter
```

Replace `SIMULATOR_ID` with the UUID obtained from the dynamic lookup above.

**If build fails:**
1. Read the error messages carefully
2. Fix the syntax/compilation errors in the files you created
3. Re-run the build command
4. Do NOT proceed to the next batch until build succeeds

### Step 2: Run the snapshot tests for the new components

ALWAYS use `-scheme GomaUI` (NOT GomaUICatalog):

```bash
xcodebuild test -workspace Sportsbook.xcworkspace -scheme GomaUI -destination 'platform=iOS Simulator,id=SIMULATOR_ID' -only-testing:GomaUITests/{ComponentName}SnapshotTests 2>&1 | xcbeautify --quieter
```

Replace `SIMULATOR_ID` with the UUID obtained from the dynamic lookup.

**Expected behavior:**
- Tests will show as "failed" because `SnapshotTestConfig.record = true` (recording mode)
- This is NORMAL - the tests are generating reference images
- A "failure" with message "Record mode is on" means SUCCESS
- Only actual compilation errors or crashes are real failures

### Step 3: Git commit after successful build
```bash
git add -A && git commit -m "test(GomaUI): add snapshot tests for ComponentA, ComponentB, ComponentC"
```

### Workflow Per Iteration (ALL STEPS ARE MANDATORY)

DO NOT SKIP ANY STEP. Each step MUST be executed.

1. Create SnapshotViewController for 3 components
2. Create Test files for 3 components
3. **RUN** build-for-testing command ← MANDATORY
   - If build fails → fix errors → rebuild
   - Do NOT proceed until build succeeds
4. **RUN** test command for each new component ← MANDATORY, DO NOT SKIP
   ```bash
   xcodebuild test -workspace Sportsbook.xcworkspace -scheme GomaUI -destination 'platform=iOS Simulator,id=SIMULATOR_ID' -only-testing:GomaUITests/ComponentASnapshotTests 2>&1 | xcbeautify --quieter
   ```
5. **VERIFY** snapshots were created ← MANDATORY, DO NOT SKIP
   ```bash
   ls Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/{ComponentName}/__Snapshots__/{ComponentName}SnapshotTests/
   ```
   - You MUST see .png files for each test (Light and Dark)
   - If no .png files exist, the test did not run correctly - investigate and re-run
6. Git commit after verification
7. Update COMPONENT_MAP.json with `has_snapshot_tests: true`
8. Proceed to next iteration

### CRITICAL: Do Not Skip Tests

You MUST run `xcodebuild test` for EVERY component you create tests for.
You MUST verify the __Snapshots__ folder contains .png files.
Creating files without running tests is NOT acceptable.
If you skip running tests, the iteration is INCOMPLETE.

## Skip These Components
Components that already have snapshot tests:
- ButtonView
- OutcomeItemView
- CapsuleView
- PillItemView
- InlineScoreView
- CashoutAmountView
- BetDetailRowView
- BetSummaryRowView

## Quality Checklist
Before marking a component done:
- [ ] SnapshotViewController has category enum
- [ ] All MockViewModel presets are used as variants
- [ ] Each category has 3-6 meaningful variants
- [ ] Test file has Light + Dark test per category
- [ ] SwiftUI #Preview for each category
- [ ] Code compiles (no syntax errors)

## Completion
When all components in COMPONENT_MAP.json have `has_snapshot_tests: true`, output:
```
<promise>SNAPSHOTS_COMPLETE</promise>
```

## Cancel
```
/cancel-ralph
```
