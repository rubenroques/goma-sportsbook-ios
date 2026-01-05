# Phase 2: Generate and Standardize README Files

## Task
Create or update README.md for ALL GomaUI components following a consistent structure.

## Input
```
Frameworks/GomaUI/Documentation/COMPONENT_MAP.json
```

## Progress Tracking
Update the COMPONENT_MAP.json - add a `"readme_done": true` field to each component after its README is created/updated.

Example:
```json
{
  "ComponentName": {
    "has_readme": true,
    "parents": [],
    "children": [],
    "readme_done": true
  }
}
```

## Components Location
```
Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/
```

## README Template

Every README.md MUST follow this EXACT structure:

```markdown
# ComponentName

Brief one-line description of what this component does.

## Overview

2-3 sentences explaining the component's purpose and main use case.

## Component Relationships

### Used By (Parents)
- `ParentComponentView` - context of usage
- None (standalone component)

### Uses (Children)
- `ChildComponentView` - what it's used for
- None (leaf component)

## Features

- Feature 1
- Feature 2
- Feature 3

## Usage

\```swift
let viewModel = MockComponentViewModel.default
let view = ComponentView(viewModel: viewModel)
\```

## Data Model

\```swift
struct ComponentData {
    // properties
}
\```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.xxx` - usage
- `StyleProvider.fontWith(type:size:)` - usage

## Mock ViewModels

Available presets:
- `.default` - description
- `.otherState` - description
```

## For Each Component

1. Read COMPONENT_MAP.json to check if `readme_done` is true - skip if yes
2. Read the component's .swift files to understand functionality
3. Get parents and children from COMPONENT_MAP.json
4. Create or overwrite README.md following the template exactly
5. Update COMPONENT_MAP.json setting `readme_done: true`
6. Git commit every 5 components

## Iteration Strategy
- Process 5 components per iteration
- Always read COMPONENT_MAP.json first to find components where `readme_done` is missing or false
- Prioritize components without README first, then update existing ones

## Completion
When ALL components in COMPONENT_MAP.json have `readme_done: true`, output:
```
DOCS_COMPLETE
```

## Cancel
```
/cancel-ralph
```
