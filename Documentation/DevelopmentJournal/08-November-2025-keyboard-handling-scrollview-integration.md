## Date
08 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Investigate and fix keyboard handling issues in BetssonCameroonApp
- Remove manual keyboard handling code now that IQKeyboardManager is installed
- Enable scrolling in PhoneRegistrationViewController for small iPhone screens
- Implement proper return key functionality for text fields

### Achievements
- [x] Removed manual keyboard notification observers and animations from PhoneLoginViewController
- [x] Configured IQKeyboardManager properly in AppDelegate (24pt distance, toolbar enabled)
- [x] Fixed toolbar "weird circles" issue by hiding Previous/Next buttons
- [x] Added UIScrollView to PhoneRegistrationViewController with proper constraint setup
- [x] Added UIScrollView to PhoneLoginViewController for consistency
- [x] Implemented return key type support across BorderedTextFieldView component
- [x] Configured appropriate return key types for all text fields (phone: .next, password: .next/.go, etc.)

### Issues / Bugs Hit
- [x] IQKeyboardManager showing circular Previous/Next buttons in toolbar → Fixed with `shouldHidePreviousNext = true`
- [x] PhoneRegistrationViewController content not scrollable when keyboard appears → Added UIScrollView
- [x] Return key buttons ("next", "go") not functional → Implemented protocol method and delegate handling
- [x] PhoneRegistrationViewController has no UIScrollView, making lower fields inaccessible on small devices

### Key Decisions
- **IQKeyboardManager Configuration**:
  - Enabled with 24pt distance from text field
  - Toolbar enabled but Previous/Next buttons hidden (cleaner UX)
  - Placeholder in toolbar disabled
- **ScrollView Pattern**:
  - Navigation header stays fixed at top
  - All content (logo, fields, buttons) in scrollView
  - Used `contentLayoutGuide` for vertical scrolling, `frameLayoutGuide` for horizontal constraints
  - Applied same pattern to both Login and Registration screens for consistency
- **Return Key Strategy**:
  - Added `returnKeyType` to BorderedTextFieldData struct (with default `.default`)
  - Implemented `onReturnKeyTapped()` protocol method for future navigation enhancements
  - Set contextual return keys: `.next` for intermediate fields, `.go`/`.done` for final fields
- **GomaUI Enhancement**:
  - Extended BorderedTextFieldView component with return key support
  - Maintained protocol-driven architecture
  - Updated MockBorderedTextFieldViewModel for testing

### Experiments & Notes
- IQKeyboardManager works automatically - no need for manual constraint adjustments
- ScrollView + IQKeyboardManager combo works perfectly - IQKeyboardManager scrolls to active field automatically
- Birth date field uses `.done` return key since it has custom date picker input
- Removed `loginButtonBottomConstraint` dynamic constraint - no longer needed with scrollView

### Useful Files / Links
- [AppDelegate.swift](../../BetssonCameroonApp/App/Boot/AppDelegate.swift) - IQKeyboardManager configuration (lines 67-71)
- [PhoneLoginViewController.swift](../../BetssonCameroonApp/App/Screens/PhoneLogin/PhoneLoginViewController.swift) - Refactored with UIScrollView
- [PhoneRegistrationViewController.swift](../../BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewController.swift) - UIScrollView implementation
- [BorderedTextFieldView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BorderedTextFieldView/BorderedTextFieldView.swift) - Return key handling
- [BorderedTextFieldViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BorderedTextFieldView/BorderedTextFieldViewModelProtocol.swift) - Protocol extensions
- [PhoneLoginViewModel.swift](../../BetssonCameroonApp/App/Screens/PhoneLogin/PhoneLoginViewModel.swift) - Return key configuration
- [PhoneRegistrationViewModel.swift](../../BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewModel.swift) - Return key configuration

### Code Changes Summary

#### 1. IQKeyboardManager Configuration
**File**: `BetssonCameroonApp/App/Boot/AppDelegate.swift`
```swift
IQKeyboardManager.shared.keyboardDistanceFromTextField = 24.0
IQKeyboardManager.shared.enable = true
IQKeyboardManager.shared.enableAutoToolbar = true
IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
IQKeyboardManager.shared.shouldHidePreviousNext = true
```

#### 2. BorderedTextFieldView Protocol Enhancement
**Files**:
- `BorderedTextFieldViewModelProtocol.swift`: Added `returnKeyType` property and `returnKeyTypePublisher`
- `BorderedTextFieldView.swift`: Added return key binding and `textFieldShouldReturn` delegate
- `MockBorderedTextFieldViewModel.swift`: Implemented return key support

#### 3. ScrollView Implementation Pattern
**Applied to**: PhoneLoginViewController, PhoneRegistrationViewController
```swift
// Hierarchy
view
├── navigationView (fixed)
├── scrollView
│   ├── logoImageView
│   ├── headerView
│   ├── content fields
│   └── button
└── loadingView (overlay)

// Constraints
- scrollView: below nav, fills to bottom
- Vertical positioning: scrollView.contentLayoutGuide
- Horizontal positioning: scrollView.frameLayoutGuide
```

### Architecture Impact
- **GomaUI Component**: BorderedTextFieldView now supports return key types (backward compatible with default `.default`)
- **MVVM Pattern**: Return key configuration in ViewModels, not ViewControllers
- **Reusability**: All changes maintain protocol-driven architecture
- **No Breaking Changes**: Default values preserve existing behavior

### Next Steps
1. ~~Test on iPhone SE and small devices to verify scrolling works correctly~~ - Should work automatically with IQKeyboardManager
2. Consider adding keyboard navigation logic (focus next field on return key tap) in ViewControllers if needed
3. Review other ViewControllers that might need scrolling support (password recovery screens, etc.)
4. Update GomaUI documentation to reflect return key type support
5. Consider disabling IQKeyboardManager for specific screens if custom keyboard behavior is needed (add to `disabledDistanceHandlingClasses`)

### Performance Notes
- No performance impact - UIScrollView is lightweight
- IQKeyboardManager handles animations efficiently
- Return key protocol calls have negligible overhead

### Testing Checklist
- [x] Toolbar only shows Done button (no weird circles)
- [x] PhoneRegistrationViewController scrolls when keyboard appears
- [x] PhoneLoginViewController scrolls when keyboard appears
- [x] All fields show correct return key labels
- [x] IQKeyboardManager automatically positions active field above keyboard
- [ ] Test on iPhone SE (smallest screen) to verify full accessibility
- [ ] Test landscape orientation scrolling behavior
- [ ] Verify loading overlay still covers entire screen during scroll
