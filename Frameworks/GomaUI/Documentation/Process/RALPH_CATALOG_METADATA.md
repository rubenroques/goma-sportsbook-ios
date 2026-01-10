# Ralph Task: Enrich GomaUI Catalog Metadata

## Objective

**ONE component at a time.** Deeply investigate each GomaUI component to understand:
- What it does and how it works
- Where it's actually used in production apps
- Its visual states and configurations
- How it relates to other components

Then fill accurate metadata in `catalog-metadata.json`.

## CRITICAL: Deep Investigation Required

**DO NOT RUSH.** Each component requires:
1. Reading ALL source files in the component folder
2. Searching for ACTUAL USAGE in BetssonCameroonApp
3. Understanding the component's role in the app
4. Only THEN filling metadata based on real understanding

---

## Progress Tracking

```
Frameworks/GomaUI/Documentation/catalog-metadata.json
```

Status field:
- `"pending"` - Not yet analyzed
- `"complete"` - Fully analyzed

---

## Step 1: Find Next Pending Component

```bash
node -e "const m=require('./Frameworks/GomaUI/Documentation/catalog-metadata.json'); const p=Object.entries(m.components).find(([_,v])=>v.status==='pending'); console.log(p?p[0]:'ALL_COMPLETE');"
```

Pick ONE component. Do not batch.

---

## Step 2: Locate Component Source

```bash
# Find the component folder
find Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components -type d -name "{ComponentName}"

# List ALL files in component folder
ls -la <path_from_above>
```

---

## Step 3: Read ALL Component Files (MANDATORY)

You MUST read every file in the component folder. Do not skip any.

**Files to read in order:**
1. `{ComponentName}.swift` - Main implementation
2. `{ComponentName}ViewModelProtocol.swift` - Protocol definition (shows states, methods)
3. `Mock{ComponentName}ViewModel.swift` - Mock (shows available configurations)
4. `Documentation/README.md` - If exists
5. **ALL other .swift files** - Helper views, enums, models

**What to look for:**
- What data does the ViewModel provide?
- What user interactions are supported? (taps, swipes, selections)
- What visual states exist? (look for enums, boolean flags, optional properties)
- Does it compose other GomaUI components?

---

## Step 4: Search for Usage in BetssonCameroonApp (MANDATORY)

This is critical. Find where this component is ACTUALLY used.

```bash
# Search for imports/usage in BetssonCameroonApp
grep -r "{ComponentName}" BetssonCameroonApp/ --include="*.swift" -l

# If found, read those files to understand context
```

**Questions to answer:**
- Which screens use this component?
- What ViewModel implementations exist in the app?
- How is it configured in real usage?

---

## Step 5: Check COMPONENT_MAP.json Relationships

```bash
node -e "const m=require('./Frameworks/GomaUI/Documentation/COMPONENT_MAP.json'); console.log(JSON.stringify(m['{ComponentName}'], null, 2));"
```

This shows:
- `parents` - Components that USE this component
- `children` - Components this component USES

For each parent/child, understand WHY they're related.

---

## Step 6: Fill Metadata Based on Investigation

Only NOW fill the metadata. Every field should be based on what you learned.

### Fields to Fill

```json
{
  "status": "complete",
  "displayName": "ExactClassName",
  "category": "Already set",
  "subcategory": "Specific or null",
  "summary": "One line, max 100 chars, based on actual purpose",
  "description": "2-3 sentences from your investigation",
  "complexity": "simple|composite|complex",
  "maturity": "stable|beta|deprecated",
  "tags": ["based", "on", "actual", "usage"],
  "states": ["from", "viewmodel", "protocol"],
  "similarTo": ["similar", "components"],
  "oftenUsedWith": ["from", "parent", "child", "relationships"]
}
```

### Field Guidelines

**summary** - Based on what you saw in the code and usage
- What's the ONE thing this component does?
- Example: "Horizontal bar of category filter pills with selection state"

**description** - From your investigation
- What does it display?
- What interactions does it support?
- Where is it typically used?

**complexity**
| Value | Evidence |
|-------|----------|
| `simple` | Few files, no child components, simple ViewModel |
| `composite` | Uses other GomaUI components (check imports) |
| `complex` | Many files, multiple child components, complex state |

**maturity** - Default `stable` unless you found:
- TODO/FIXME comments → `beta`
- Deprecated markers → `deprecated`
- Incomplete mocks → `beta`

**tags** - From actual usage context
- Domain: betting, casino, wallet, match, user, transaction
- UI type: card, button, list, input, banner, slider, tab, filter
- Behavior: interactive, selectable, scrollable, expandable, animated
- Purpose: display, input, navigation, filter, status

**states** - From ViewModel protocol and Mock
- Look for enums, boolean properties, optional values
- Common: default, selected, loading, error, disabled, expanded

**similarTo** - Components with similar purpose
- Same category, similar function
- Could be confused with this component

**oftenUsedWith** - From relationships
- Parents (components that contain this one)
- Children (components this one contains)
- Siblings in same screens

---

## Step 7: Update catalog-metadata.json

Edit the file directly. Set `"status": "complete"`.

---

## Step 8: Validate JSON

```bash
# Validate JSON
node -e "require('./Frameworks/GomaUI/Documentation/catalog-metadata.json'); console.log('JSON valid')"
```

Proceed to the next component.

---

## Committing (Every 5 Components)

After analyzing 5 components, commit the batch:

```bash
git add Frameworks/GomaUI/Documentation/catalog-metadata.json && git commit -m "docs(catalog): enrich metadata for ComponentA, ComponentB, ComponentC, ComponentD, ComponentE"
```

---

## Iteration Summary

After completing ONE component, report:

```
Component: {ComponentName}
- Files read: X
- Used in BetssonCameroonApp: Yes/No (list screens if yes)
- Parents: [list]
- Children: [list]
- Key insight: What you learned about this component

Remaining pending: N components
```

Then proceed to the next component.

---

## Quality Standards

Before marking complete, verify:
- [ ] Read ALL files in component folder
- [ ] Searched BetssonCameroonApp for usage
- [ ] Checked COMPONENT_MAP.json relationships
- [ ] summary reflects actual component purpose
- [ ] description based on code investigation
- [ ] states from actual ViewModel/Mock analysis
- [ ] tags relevant to actual usage context
- [ ] JSON validates without errors

---

## Example Investigation Output

```
Investigating: OutcomeItemView

Files read:
- OutcomeItemView.swift (main view)
- OutcomeItemViewModelProtocol.swift (protocol)
- MockOutcomeItemViewModel.swift (mock with 5 presets)

BetssonCameroonApp usage:
- SportsMatchDetailViewController.swift - displays in match markets
- BetslipViewController.swift - shows selected outcomes

COMPONENT_MAP relationships:
- Parents: MarketOutcomesLineView, CompactOutcomesLineView
- Children: none

States found in protocol:
- isSelected (Bool)
- isSuspended (Bool)
- oddsChangeDirection (enum: up, down, none)

Filling metadata with this understanding...
```

---

## Completion

When ALL components have `"status": "complete"`:

```
<promise>CATALOG_METADATA_COMPLETE</promise>
```

---

## Cancel

```
/cancel-ralph
```
