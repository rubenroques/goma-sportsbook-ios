# Task: Implement ClassicMatchCardHeaderBarView

## Objective

Create a new GomaUI component `ClassicMatchCardHeaderBarView` - a header bar for the Classic Match Card family.

## Steps

1. **Read the specification**: `SPECIFICATION.md`
   - Understand the visual layout and all variants
   - Note the element positions and conditional visibility

2. **Read the implementation guide**: `IMPLEMENTATION_GUIDE.md`
   - Follow GomaUI patterns from referenced files
   - Use `MatchHeaderView` as the primary code reference
   - Create proper file structure

3. **Check legacy code if needed**: `LEGACY_REFERENCE.md`
   - Verify behavior matches original implementation
   - Find specific code sections for edge cases

4. **Implement the component** in GomaUI:
   - Location: `Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/MatchCards/ClassicMatchCardHeaderBarView/`
   - Follow one-file-per-type rule
   - Include SwiftUI previews
   - Create comprehensive mock presets

5. **Test the build**:
   ```bash
   # Get simulator ID first
   xcrun simctl list devices available | grep iPhone

   # Build
   xcodebuild -workspace Sportsbook.xcworkspace -scheme GomaUICatalog -destination 'platform=iOS Simulator,id=YOUR_DEVICE_ID' build 2>&1 | xcbeautify --quieter
   ```

6. **Register in Catalog** (optional but recommended):
   - Add to `ComponentRegistry.swift`
   - Create demo ViewController

## Deliverables

- [ ] `ClassicMatchCardHeaderBarView.swift`
- [ ] `ClassicMatchCardHeaderBarViewModelProtocol.swift`
- [ ] `ClassicMatchCardHeaderBadgeType.swift`
- [ ] `MockClassicMatchCardHeaderBarViewModel.swift`
- [ ] `README.md` (component documentation)
- [ ] SwiftUI previews showing all 4 variants
- [ ] Successful GomaUICatalog build

## Key Requirements

- Must support synchronous state access (`currentDisplayState`)
- Must use `MatchHeaderImageResolver` for images
- Must implement `prepareForReuse()` for cell recycling
- Fixed height: 17pt
- All styling via `StyleProvider`
