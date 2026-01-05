# Ralph Task: Generate Snapshot Tests for GomaUI Components

## Objective
Create snapshot tests for ALL GomaUI components that don't have them yet, following the established two-file pattern.

## Documentation Reference
Read and follow the patterns in:
```
Frameworks/GomaUI/GomaUI/Documentation/SNAPSHOT_TESTING_GUIDE.md
```

## Progress Tracking
Update `Frameworks/GomaUI/Documentation/COMPONENT_MAP.json` - add `"has_snapshot_tests": true` after creating tests for each component.

## Example Implementation (MUST READ FIRST)
Study these files as the reference implementation:

**SnapshotViewController** (in Sources):
```
Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/OutcomeItemView/OutcomeItemViewSnapshotViewController.swift
```

**Test File** (in Tests):
```
Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/OutcomeItemView/OutcomeItemViewSnapshotTests.swift
```

**Config**:
```
Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/SnapshotTestConfig.swift
```

## File Structure to Create

For each component `{ComponentName}`:

1. **SnapshotViewController** at:
```
Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/{ComponentName}/{ComponentName}SnapshotViewController.swift
```

2. **Test File** at:
```
Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/{ComponentName}/{ComponentName}SnapshotTests.swift
```

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
```
Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/
```

## For Each Component

1. Check COMPONENT_MAP.json - skip if `has_snapshot_tests: true`
2. Read the component's Swift files to understand:
   - Available states from MockViewModel
   - Configuration options
   - Visual variants
3. Determine appropriate categories (1-6)
4. Create SnapshotViewController with categories and variants
5. Create Test file with Light/Dark tests per category
6. Update COMPONENT_MAP.json: `has_snapshot_tests: true`
7. Git commit every 3 components

## Iteration Strategy
- Process 3 components per iteration
- Read COMPONENT_MAP.json first to find components without `has_snapshot_tests`
- Prioritize simpler components first (fewer files in folder)
- Always read the MockViewModel to find available preset states

## Build Verification (MANDATORY)

After creating tests for each batch of 3 components, you MUST verify the code compiles.

### Simulator ID
Use this simulator for all commands:
```
4C2C3F29-3F1E-4BEC-A397-C5A54256ADC7
```

### Step 1: Build the GomaUI scheme (checks compilation)
```bash
xcodebuild build-for-testing -workspace Sportsbook.xcworkspace -scheme GomaUI -destination 'platform=iOS Simulator,id=4C2C3F29-3F1E-4BEC-A397-C5A54256ADC7' 2>&1 | xcbeautify --quieter
```

**If build fails:**
1. Read the error messages carefully
2. Fix the syntax/compilation errors in the files you created
3. Re-run the build command
4. Do NOT proceed to the next batch until build succeeds

### Step 2: Run the snapshot tests for the new components
```bash
xcodebuild test -workspace Sportsbook.xcworkspace -scheme GomaUI -destination 'platform=iOS Simulator,id=4C2C3F29-3F1E-4BEC-A397-C5A54256ADC7' -only-testing:GomaUITests/{ComponentName}SnapshotTests 2>&1 | xcbeautify --quieter
```

**Expected behavior:**
- Tests will show as "failed" because `SnapshotTestConfig.record = true` (recording mode)
- This is NORMAL - the tests are generating reference images
- A "failure" with message "Record mode is on" means SUCCESS
- Only actual compilation errors or crashes are real failures

### Step 3: Git commit after successful build
```bash
git add -A && git commit -m "test(GomaUI): add snapshot tests for ComponentA, ComponentB, ComponentC"
```

### Workflow Per Iteration
1. Create SnapshotViewController for 3 components
2. Create Test files for 3 components
3. Run build-for-testing command
4. If build fails → fix errors → rebuild
5. If build succeeds → run tests → commit
6. Update COMPONENT_MAP.json with `has_snapshot_tests: true`
7. Proceed to next iteration

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
SNAPSHOTS_COMPLETE
```

## Cancel
```
/cancel-ralph
```
