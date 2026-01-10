# Phase 1: GomaUI Component Dependency Mapping

## Task
Analyze all GomaUI components and produce a JSON file mapping parent/child relationships.

## Components Location
```
Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/
```

## Output File
```
Frameworks/GomaUI/Documentation/COMPONENT_MAP.json
```

## Output Format
```json
{
  "ComponentName": {
    "has_readme": true,
    "parents": ["ParentComponentA", "ParentComponentB"],
    "children": ["ChildComponentX", "ChildComponentY"]
  }
}
```

## For Each Component Folder

1. Check if `README.md` exists in the folder
2. Find parents: grep for `ComponentNameView` in other component folders
3. Find children: read the main `.swift` file, look for other GomaUI view instantiations like `private let someView = OtherGomaUIView()`

## Iteration Strategy
- Process 10 components per iteration
- Update the JSON file after each batch
- Read the JSON first to know which components are already mapped

## Completion
When all ~141 components are mapped in the JSON file, output:
```
MAPPING_COMPLETE
```

## Cancel
```
/cancel-ralph
```
