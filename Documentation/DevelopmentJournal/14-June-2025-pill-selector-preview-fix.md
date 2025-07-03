## Date
14 June 2025

### Project / Branch
GomaUI / PillSelectorBarView SwiftUI Preview Investigation

### Goals for this session
- Investigate why PillSelectorBarView SwiftUI previews show grey bars instead of pill components
- Fix the preview rendering issue without breaking production behavior
- Maintain dynamic sizing for production use

### Achievements
- [x] Identified root cause: SwiftUI PreviewUIView doesn't properly communicate width constraints to UIKit components
- [x] Fixed by switching from PreviewUIView to PreviewUIViewController with explicit constraints
- [x] Refactored all 5 preview blocks to use consistent PreviewUIViewController pattern
- [x] Removed all temporary debug code and hardcoded constraints
- [x] Maintained component's dynamic sizing for production (UIView.noIntrinsicMetric for width)

### Issues / Bugs Hit
- [x] PillSelectorBarView rendered as grey bars in SwiftUI previews
- [x] ScrollView had zero width due to constraint issues in preview environment
- [x] Individual PillItemView rendered correctly, but PillSelectorBarView container failed

### Key Decisions
- **Used PreviewUIViewController instead of PreviewUIView**: More reliable for complex UIKit components requiring proper constraint setup
- **Kept intrinsic content size as UIView.noIntrinsicMetric for width**: Maintains production behavior where parent provides width constraints
- **Applied consistent preview pattern across all previews**: Ensures reliability and maintainability

### Experiments & Notes
- Initial assumption about color/styling issues was wrong - problem was layout constraints
- Debug logging revealed scrollView frame: `(16.0, 0.0, 0.0, 60.0)` - zero width!
- Hardcoded width constraint of 200pt proved the root cause was width calculation
- PreviewUIView + frame modifiers don't translate properly to UIKit constraint system
- PreviewUIViewController + explicit NSLayoutConstraint setup works reliably

### Useful Files / Links
- [PillSelectorBarView](../GomaUI/GomaUI/Sources/GomaUI/Components/PillSelectorBarView/PillSelectorBarView.swift)
- [PillItemView](../GomaUI/GomaUI/Sources/GomaUI/Components/PillItemView/PillItemView.swift)
- [PreviewUIView Helper](../GomaUI/GomaUI/Sources/GomaUI/Helpers/PreviewsHelper/PreviewUIView.swift)
- [PreviewUIViewController Helper](../GomaUI/GomaUI/Sources/GomaUI/Helpers/PreviewsHelper/PreviewUIViewController.swift)
- [Component Creation Guide](../GomaUI/GomaUI/Sources/GomaUI/Documentation/ComponentCreationGuide.md)

### Debug Process Used
1. Added debug background colors (red, blue, green, orange) to identify which views were visible
2. Added debug logging to track render flow and view creation
3. Added frame logging to identify zero-width views
4. Tested hardcoded constraints to isolate the width constraint issue
5. Systematically removed debug elements to find minimal working solution

### Next Steps
1. Update ComponentCreationGuide.md to recommend PreviewUIViewController over PreviewUIView for complex components
2. Consider creating a standardized preview helper function to reduce boilerplate
3. Apply this pattern to other GomaUI components that might have similar preview issues