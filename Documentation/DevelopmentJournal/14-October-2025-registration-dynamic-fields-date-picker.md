# Development Journal

## Date
14 October 2025

### Project / Branch
BetssonCameroonApp / rr/bettingOfferSubscription

### Goals for this session
- Add 3 new dynamic registration fields (FirstName, LastName, BirthDate) from legislation server config
- Implement date picker for BirthDate field with min/max constraints
- Maintain clean MVVM architecture without UIViews in ViewModel

### Achievements
- [x] Extended `PhoneSignUpForm` with optional `firstName`, `lastName`, `birthDate` fields
- [x] Updated `EveryMatrixPlayerAPI.registerStep` to send fields dynamically (JSON-based body)
- [x] Added 3 validation helpers (`isValidFirstName`, `isValidLastName`, `isValidBirthDate`) with server-driven rules
- [x] Updated reactive validation to combine 5 fields + terms acceptance
- [x] Added `usesCustomInput: Bool` flag to `BorderedTextFieldData` (GomaUI)
- [x] Implemented `onRequestCustomInput` closure pattern in `BorderedTextFieldView`
- [x] Added `setCustomInputView(_:accessoryView:)` public method to GomaUI component
- [x] Created UIDatePicker with toolbar, min/max dates from legislation server (1905-10-09 to 2004-10-08 for age 21+)
- [x] Fixed race condition: moved date picker setup from lazy to eager (before field added to view)

### Issues / Bugs Hit
- [x] Race condition: keyboard appeared instead of date picker when tapping field
  - **Root cause**: textField's built-in tap handling made it first responder before custom inputView was set
  - **Solution**: Create and set date picker immediately in `setupComponentsLayout()` before adding field to view hierarchy

### Key Decisions
- **Closure-based pattern over protocol extension**: Used `onRequestCustomInput: (() -> Void)?` closure in `BorderedTextFieldView` matching existing patterns (`onTextChanged`, `onFocusChanged`)
- **Explicit flag over heuristics**: Added `usesCustomInput: Bool` instead of inferring from keyboard type or content type
- **Eager date picker setup**: Configure custom input view immediately (not lazily on tap) to prevent keyboard race condition
- **ViewController owns UI**: Date picker creation/presentation stays in ViewController, ViewModel only stores string dates and min/max values
- **Server-driven constraints**: Min/max dates from legislation API config, not hardcoded

### Experiments & Notes
- Initial attempt used lazy date picker creation in `showDatePickerForBirthDate()` → failed due to timing
- Considered disabling `textField.isUserInteractionEnabled` when `usesCustomInput=true` → rejected (breaks copy/paste, accessibility)
- Setting `textField.inputView` before field is added to view hierarchy works reliably regardless of tap source

### Useful Files / Links
- [PhoneSignUpForm](../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/User/User.swift) - Added 3 optional fields
- [EveryMatrixPlayerAPI](../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/PlayerAPI/EveryMatrixPlayerAPI.swift) - Dynamic field sending
- [BorderedTextFieldView](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BorderedTextFieldView/BorderedTextFieldView.swift) - Custom input support
- [PhoneRegistrationViewModel](../BetssonCameroonApp/App/Screens/Register/PhoneRegister/MockPhoneRegistrationViewModel.swift) - Field creation and validation
- [PhoneRegistrationViewController](../BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewController.swift) - Date picker implementation
- [API Development Guide](../Documentation/API_DEVELOPMENT_GUIDE.md) - 3-layer architecture reference

### API Integration Flow
```
Registration Config API Flow:
GET /v1/player/legislation/registration/config
↓
EveryMatrixPrivilegedAccessManager (SP layer)
↓
ServiceProviderModelMapper (SP → App models)
↓
PhoneRegistrationViewModel.handleRegistrationConfig()
↓
Dynamic field creation based on config.fields array
↓
Server-driven validation rules and constraints
```

```
Registration Submit Flow:
PhoneRegistrationViewController (user input)
↓
PhoneRegistrationViewModel.registerUser()
↓
PhoneSignUpForm(phone, password, firstName, lastName, birthDate)
↓
POST /v1/player/legislation/registration/step
  Body: { "RegisterUserDto": { [dynamic fields] } }
↓
PUT /v1/player/legislation/register
↓
Auto-login after success
```

### Architecture Pattern: Custom Input Views
```swift
// 1. GomaUI Component (reusable)
public struct BorderedTextFieldData {
    public let usesCustomInput: Bool  // Explicit flag
}

public class BorderedTextFieldView: UIView {
    public var onRequestCustomInput: (() -> Void)?  // Closure callback

    public func setCustomInputView(_ inputView: UIView?, accessoryView: UIView?)

    @objc private func containerTapped() {
        if viewModel.usesCustomInput {
            onRequestCustomInput?()  // Delegate to ViewController
        } else {
            textField.becomeFirstResponder()
        }
    }
}

// 2. ViewModel (data only)
var birthDateMinMax: (min: String, max: String)?  // From server config
var birthDate: String  // Stored as formatted string

// 3. ViewController (owns UI)
birthDateField.onRequestCustomInput = { [weak self] in
    self?.birthDateField?.becomeFirstResponder()  // inputView already set
}

// Setup BEFORE adding to view (prevents race condition)
datePicker.minimumDate = formatter.date(from: viewModel.birthDateMinMax.min)
datePicker.maximumDate = formatter.date(from: viewModel.birthDateMinMax.max)
birthDateField.setCustomInputView(datePicker, accessoryView: toolbar)
```

### Next Steps
1. Test full registration flow in simulator with new fields
2. Verify date picker constraints work correctly (min age 21)
3. Test field validation edge cases (empty fields, invalid names)
4. Verify API payload contains all fields with correct keys
5. Consider adding locale-aware date formatting for display
6. Add accessibility labels for date picker and toolbar
