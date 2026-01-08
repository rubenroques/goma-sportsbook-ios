# Ralph Task: Enrich GomaUI Catalog Metadata

## Objective

Deeply understand each GomaUI component - its purpose, where it's used, its visual states, parent components, and child components - then fill in accurate, high-quality metadata in `catalog-metadata.json` for the web-based component catalog.

## Progress Tracking

The metadata file tracks progress via the `status` field:
- `"pending"` - Not yet analyzed (find these)
- `"partial"` - Some fields filled, needs completion
- `"complete"` - Fully analyzed and verified

```
Frameworks/GomaUI/Documentation/catalog-metadata.json
```

## Finding the Next Component

```bash
# Find first pending component
node -e "const m=require('./Frameworks/GomaUI/Documentation/catalog-metadata.json'); const p=Object.entries(m.components).find(([_,v])=>v.status==='pending'); console.log(p?p[0]:'ALL_COMPLETE');"
```

Or read the file and find the first entry with `"status": "pending"`.

## Component Source Locations

Components are at:
```
Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/{Category}/{ComponentName}/
```

For ContentBlocks components:
```
Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Promotions/ContentBlocks/{ComponentName}/
```

### Files to Read (in order)

1. **Main View** - `{ComponentName}.swift` - Core implementation
2. **ViewModel Protocol** - `{ComponentName}ViewModelProtocol.swift` - Interface definition
3. **Mock ViewModel** - `Mock{ComponentName}ViewModel.swift` - Usage examples, available states
4. **README** - `Documentation/README.md` - Component documentation (if exists)
5. **Supporting files** - Any other `.swift` files in the folder

### Locating Components

```bash
# Find component folder
find Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components -type d -name "{ComponentName}"

# List all files in component
ls -la Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/{Category}/{ComponentName}/
```

## Metadata Fields to Fill

For each component, analyze the source code and fill:

```json
{
  "ComponentName": {
    "status": "complete",

    "displayName": "Component Name (exact class name for clarity)",
    "category": "Already set from bootstrap",
    "subcategory": "Specific subcategory or null",

    "summary": "One-line description (max 100 chars)",
    "description": "2-3 sentences explaining purpose, features, and key behaviors",

    "complexity": "simple | composite | complex",
    "maturity": "stable | beta | deprecated",

    "tags": ["relevant", "searchable", "keywords"],
    "states": ["default", "selected", "loading", "error"],

    "similarTo": ["OtherComponentName", "AnotherSimilar"],
    "oftenUsedWith": ["RelatedComponent", "CommonCompanion"]
  }
}
```

### Field Guidelines

#### displayName
- Use the exact class name for technical accuracy
- Designers and programmers both need the precise Swift class name
- Example: `"OutcomeItemView"`, `"BetslipTypeSelectorView"`, `"MarketOutcomesLineView"`

#### summary
- One line, max 100 characters
- Start with verb or noun, no "A" or "The" prefix
- Focus on primary purpose
- Example: `"Single betting outcome with odds and selection state"`

#### description
- 2-3 complete sentences
- Explain: what it displays, key features, notable behaviors
- Mention states, animations, or special configurations if present
- Example: `"Displays an individual betting market outcome. Supports selection states (unselected, selected, suspended), odds change animations with up/down indicators, and configurable layouts. Used within market outcome lines and match cards."`

#### complexity
| Value | Criteria |
|-------|----------|
| `simple` | Single-purpose, few states, no child components |
| `composite` | Uses other GomaUI components, moderate state management |
| `complex` | Multiple child components, complex state, many configurations |

Determine by checking:
- Number of files in the component folder
- Whether it imports/uses other GomaUI components
- Size of the Mock ViewModel (number of static presets)

#### maturity
| Value | Criteria |
|-------|----------|
| `stable` | Well-tested, actively used, complete documentation |
| `beta` | Functional but may have rough edges |
| `deprecated` | Should not be used for new development |

Default to `"stable"` unless you find evidence otherwise (TODO comments, incomplete mocks, etc.)

#### tags
- 5-10 relevant keywords for search
- Include: category-related terms, functionality, UI type
- Examples: `["betting", "odds", "selection", "interactive", "animation", "toggle"]`

Tag categories to consider:
- **Domain**: betting, casino, wallet, profile, match
- **UI Type**: card, button, list, input, banner, slider, tab
- **Behavior**: interactive, animated, scrollable, expandable, selectable
- **Purpose**: display, input, navigation, filter, status

#### states
- List visual states from ViewModel/Mock
- Look for: enums, state properties, static mock presets
- Common states: `default`, `selected`, `unselected`, `loading`, `error`, `disabled`, `highlighted`, `expanded`, `collapsed`

#### similarTo
- Other GomaUI components with similar purpose or appearance
- Components that might be confused or compared
- Example: `OutcomeItemView` similar to `QuickAddButtonView`

Check COMPONENT_MAP.json for components in same category.

#### oftenUsedWith
- Components commonly composed together
- Look at `parents` and `children` in COMPONENT_MAP.json
- Example: `OutcomeItemView` often used with `MarketOutcomesLineView`, `MatchHeaderCompactView`

## Analysis Process

### Step 1: Locate and Read
```bash
# Find the component
find Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components -type d -name "{ComponentName}"

# Read main files
cat Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/{Category}/{ComponentName}/{ComponentName}.swift
cat Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/{Category}/{ComponentName}/{ComponentName}ViewModelProtocol.swift
cat Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/{Category}/{ComponentName}/Mock{ComponentName}ViewModel.swift
```

### Step 2: Analyze
- What does this component display?
- What user interactions does it support?
- What states can it be in?
- What other components does it use or get used by?
- How complex is the implementation?

### Step 3: Check Relationships

Read COMPONENT_MAP.json to understand relationships:
```bash
node -e "const m=require('./Frameworks/GomaUI/Documentation/COMPONENT_MAP.json'); console.log(JSON.stringify(m['{ComponentName}'], null, 2));"
```

### Step 4: Update Metadata

Edit `catalog-metadata.json` directly:
1. Find the component entry
2. Fill all null fields with accurate values
3. Set `"status": "complete"`

### Step 5: Validate JSON

```bash
# Check JSON is valid
node -e "require('./Frameworks/GomaUI/Documentation/catalog-metadata.json'); console.log('JSON valid')"
```

## Iteration Strategy

**Process 5 components per iteration:**

1. Find 5 pending components
2. For each:
   - Read all source files
   - Analyze thoroughly
   - Fill metadata
   - Set status to complete
3. Validate JSON syntax
4. Git commit:
   ```bash
   git add Frameworks/GomaUI/Documentation/catalog-metadata.json && git commit -m "docs(catalog): enrich metadata for ComponentA, ComponentB, ComponentC, ComponentD, ComponentE"
   ```
5. Proceed to next iteration

## Quality Checklist

Before marking a component complete:
- [ ] displayName matches the exact Swift class name
- [ ] summary is under 100 characters and descriptive
- [ ] description has 2-3 informative sentences
- [ ] complexity accurately reflects component structure
- [ ] tags include 5-10 relevant keywords
- [ ] states match what's in the ViewModel/Mock
- [ ] similarTo references actual existing components
- [ ] oftenUsedWith references actual existing components
- [ ] JSON is valid (no syntax errors)

## Example: Complete Entry

```json
"OutcomeItemView": {
  "status": "complete",
  "displayName": "OutcomeItemView",
  "category": "Betting",
  "subcategory": "Outcomes",
  "summary": "Single betting outcome with odds and selection state",
  "description": "Displays an individual betting market outcome. Supports selection states (unselected, selected, suspended), odds change animations with up/down indicators, and configurable layouts. Commonly used within market lines and match cards.",
  "complexity": "simple",
  "maturity": "stable",
  "tags": ["betting", "odds", "outcome", "selection", "interactive", "animation", "toggle"],
  "states": ["unselected", "selected", "suspended", "oddsUp", "oddsDown"],
  "similarTo": ["QuickAddButtonView"],
  "oftenUsedWith": ["MarketOutcomesLineView", "CompactOutcomesLineView", "MatchHeaderCompactView"]
}
```

## Progress Report

After each iteration, report:
```
Iteration X complete:
- Analyzed: ComponentA, ComponentB, ComponentC, ComponentD, ComponentE
- Remaining pending: N components
```

## Completion

When all components have `"status": "complete"`, output:

```
<promise>CATALOG_METADATA_COMPLETE</promise>
```

## Cancel

```
/cancel-ralph
```
