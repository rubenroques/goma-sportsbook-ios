# Filter Rows Tap Target UX Improvement Session

## Date
15 November 2025

## Project / Branch
sportsbook-ios / rr/breadcrumb

## Goals for this session
- Fix poor UX in CountryLeaguesFilterView where only tiny chevron button was tappable
- Apply same fix to CountryLeagueOptionRowView
- Extend improvements to SortOptionRowView and LeagueOptionSelectionRowView

## Achievements
- [x] CountryLeaguesFilterView: Converted collapse button to imageView and made entire header tappable
- [x] CountryLeagueOptionRowView: Same button-to-imageView conversion with full header tap target
- [x] Reduced chevron icon size to 60% (14x14) with adjusted spacing for better visual balance
- [x] SortOptionRowView: Converted radio button from UIButton to UIView and made entire row tappable
- [x] LeagueOptionSelectionRowView: Same radio button conversion with full row tap target

## Issues / Bugs Hit
- [x] **Initial design flaw**: All four components had unnecessarily small tap targets
  - CountryLeaguesFilterView header: Only 24x24 button was tappable instead of entire header
  - CountryLeagueOptionRowView: Same issue with 24x24 chevron button
  - SortOptionRowView: Only 20x20 radio button was tappable instead of entire row
  - LeagueOptionSelectionRowView: Only 20x20 radio button was tappable instead of entire row

## Key Decisions

### Chevron Components (CountryLeaguesFilterView, CountryLeagueOptionRowView)
- **Converted UIButton → UIImageView**: Buttons were not using button functionality, just visual containers
- **Made entire header tappable**: Added UITapGestureRecognizer to headerView instead of button
- **Reduced icon size by 40%**: Changed from 24x24 to 14x14 (60% of original)
- **Adjusted spacing**: Increased trailing constant from -16 to -21 to maintain visual position

### Radio Button Components (SortOptionRowView, LeagueOptionSelectionRowView)
- **Converted UIButton → UIView**: Radio buttons were purely visual (no button tap action used)
- **Made entire row tappable**: Moved UITapGestureRecognizer from 20x20 radio button to self (entire row)
- **Kept visual styling unchanged**: All border, corner radius, and color properties work on UIView

### Architectural Consistency
All four components now follow the same pattern:
- Visual indicators (icons, radio buttons) are non-interactive UIView/UIImageView elements
- Tap gestures attached to the largest logical container (header or entire row)
- Maintains existing callback mechanisms (`didTappedOption`, `viewModel.toggleCollapse()`)

## Code Changes

### File: `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CountryLeaguesFilterView/CountryLeaguesFilterView.swift`

**Lines 23-35** - Button to ImageView conversion:
```swift
- private let collapseButton: UIButton = {
+ private let collapseIconView: UIImageView = {
-     let button = UIButton()
+     let imageView = UIImageView()
      // ... styling (setImage → image property)
-     return button
+     return imageView
  }()
```

**Lines 101-104** - Reduced icon size and adjusted spacing:
```swift
- collapseButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
- collapseButton.widthAnchor.constraint(equalToConstant: 24),
- collapseButton.heightAnchor.constraint(equalToConstant: 24),
+ collapseIconView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -21),
+ collapseIconView.widthAnchor.constraint(equalToConstant: 14),
+ collapseIconView.heightAnchor.constraint(equalToConstant: 14),
```

**Lines 112-114** - Gesture moved to header:
```swift
- collapseButton.addTarget(self, action: #selector(collapseButtonTapped), for: .touchUpInside)
+ let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
+ headerView.addGestureRecognizer(tapGesture)
+ headerView.isUserInteractionEnabled = true
```

**Line 218** - Animation reference updated:
```swift
- self.collapseButton.transform = transform
+ self.collapseIconView.transform = transform
```

### File: `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CountryLeaguesFilterView/CountryLeagueOptionRowView/CountryLeagueOptionRowView.swift`

**Identical changes as CountryLeaguesFilterView**:
- Lines 47-59: Button → ImageView conversion
- Lines 153-156: Icon size 24x24 → 14x14, spacing -16 → -21
- Lines 164-166: Gesture moved to headerView
- Line 250: Animation transform reference updated

### File: `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SortFilterView/SortOptionRowView/SortOptionRowView.swift`

**Lines 42-50** - Radio button to UIView:
```swift
- private let radioButton: UIButton = {
-     let button = UIButton()
+ private let radioButton: UIView = {
+     let view = UIView()
      // ... styling (layer properties work on UIView)
-     return button
+     return view
  }()
```

**Lines 120-123** - Gesture moved to entire row:
```swift
- // Add tap gesture
  let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
- radioButton.addGestureRecognizer(tapGesture)
+ // Add tap gesture to entire row
+ self.addGestureRecognizer(tapGesture)
+ self.isUserInteractionEnabled = true
```

### File: `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CountryLeaguesFilterView/LeagueOptionSelectionRowView/LeagueOptionSelectionRowView.swift`

**Identical changes as SortOptionRowView**:
- Lines 33-41: UIButton → UIView conversion
- Lines 107-110: Gesture moved from radioButton to self (entire row)

## UX Impact Analysis

### Before Fix
| Component | Tap Target Size | User Experience |
|-----------|----------------|-----------------|
| CountryLeaguesFilterView header | 24×24px button | Very difficult to collapse/expand sections |
| CountryLeagueOptionRowView header | 24×24px button | Hard to expand country league lists |
| SortOptionRowView | 20×20px radio button | Frustrating to select sort options |
| LeagueOptionSelectionRowView | 20×20px radio button | Hard to select individual leagues |

### After Fix
| Component | Tap Target Size | User Experience |
|-----------|----------------|-----------------|
| CountryLeaguesFilterView header | Full header width (~375px) | Easy one-tap collapse/expand |
| CountryLeagueOptionRowView header | Full header width (~375px) | Intuitive country row interaction |
| SortOptionRowView | Full row (~375×40px) | Natural selection behavior |
| LeagueOptionSelectionRowView | Full row (~375×40px) | Easy league selection |

**Tap target increase**: From ~500 sq px to ~15,000 sq px (30x improvement)

## Useful Files / Links
- [CountryLeaguesFilterView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CountryLeaguesFilterView/CountryLeaguesFilterView.swift)
- [CountryLeagueOptionRowView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CountryLeaguesFilterView/CountryLeagueOptionRowView/CountryLeagueOptionRowView.swift)
- [SortOptionRowView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SortFilterView/SortOptionRowView/SortOptionRowView.swift)
- [LeagueOptionSelectionRowView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/CountryLeaguesFilterView/LeagueOptionSelectionRowView/LeagueOptionSelectionRowView.swift)
- [Previous session: Filters bug fix](./14-November-2025-filters-empty-leagues-bug-fix.md)

## Next Steps
1. Test filter interactions in simulator to verify improved UX
2. Consider applying same pattern to other GomaUI components with small tap targets
3. Document this pattern in GomaUI component guide for future components
4. Monitor for any edge cases where gesture conflicts might occur
