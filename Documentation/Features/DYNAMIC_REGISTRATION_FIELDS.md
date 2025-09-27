# Dynamic Registration Fields Implementation Plan

**Component**: PhoneRegistration Feature
**Goal**: Make registration screen completely dynamic based on server configuration
**Status**: Planning Phase

## Current State

The PhoneRegistration screen is hardcoded to handle exactly 3 fields:
- Mobile phone number
- Password
- Terms and Conditions checkbox

This creates maintenance overhead and prevents server-side control of registration flows.

## Target Architecture

A completely dynamic registration system where:
- Field count, types, and validation are server-controlled
- UI adapts automatically to any field configuration
- No code changes needed for new registration requirements
- Full validation support based on server rules

---

## Implementation Plan

### Step 1: Create Dynamic Field Models
**Goal**: Replace hardcoded field handling with dynamic field representation

**New Files to Create**:
```
BetssonCameroonApp/App/Screens/Register/PhoneRegister/
├── FieldViewModels/
│   ├── RegistrationFieldViewModel.swift           # Protocol
│   ├── TextFieldRegistrationViewModel.swift       # Text inputs
│   ├── CheckboxRegistrationViewModel.swift        # Terms/checkboxes
│   └── DropdownRegistrationViewModel.swift        # Future dropdowns
├── RegistrationFieldFactory.swift                 # Factory pattern
└── RegistrationFieldType.swift                    # Field type enum
```

**Core Protocol**:
```swift
protocol RegistrationFieldViewModel {
    var fieldName: String { get }
    var fieldType: RegistrationFieldType { get }
    var isValid: Bool { get }
    var errorMessage: String? { get }
    var value: Any? { get }

    func validate() -> (Bool, String?)
    func setValue(_ value: Any)
}
```

**Field Types Based on API `inputType`**:
```swift
enum RegistrationFieldType: String, CaseIterable {
    case tel = "Tel"
    case password = "Password"
    case checkbox = "Checkbox"
    case email = "Email"
    case select = "Select"
    case date = "Date"
    case text = "Text"
}
```

### Step 2: Modify PhoneRegistrationViewModelProtocol
**Goal**: Replace specific field properties with dynamic collection

**Remove These Properties**:
```swift
// ❌ Remove hardcoded field references
var phoneFieldViewModel: BorderedTextFieldViewModelProtocol? { get }
var passwordFieldViewModel: BorderedTextFieldViewModelProtocol? { get }
var termsViewModel: TermsAcceptanceViewModelProtocol? { get }
```

**Add Dynamic Properties**:
```swift
// ✅ Add dynamic field system
var registrationFields: [RegistrationFieldViewModel] { get }
var fieldValues: [String: Any] { get } // field name -> value mapping
var allFieldsValid: AnyPublisher<Bool, Never> { get }
```

### Step 3: Update PhoneRegistrationViewModel Implementation
**Goal**: Build UI fields dynamically from API response

**Replace `handleRegistrationConfig()` Logic**:
```swift
func handleRegistrationConfig(_ config: RegistrationConfigContent) {
    self.registrationConfig = config

    // ✅ Dynamic field creation
    self.registrationFields = config.fields.compactMap { field in
        return RegistrationFieldFactory.createField(from: field)
    }

    setupDynamicPublishers()
    isLoadingSubject.send(false)
    isLoadingConfigSubject.send(false)
}
```

**Factory Implementation**:
```swift
class RegistrationFieldFactory {
    static func createField(from apiField: RegistrationField) -> RegistrationFieldViewModel? {
        let fieldType = RegistrationFieldType(rawValue: apiField.inputType)

        switch fieldType {
        case .tel, .text:
            return TextFieldRegistrationViewModel(apiField: apiField)
        case .password:
            return TextFieldRegistrationViewModel(apiField: apiField, isSecure: true)
        case .checkbox:
            return CheckboxRegistrationViewModel(apiField: apiField)
        case .select:
            return DropdownRegistrationViewModel(apiField: apiField)
        default:
            return nil // Unsupported field type
        }
    }
}
```

### Step 4: Refactor Validation System
**Goal**: Make validation completely data-driven

**Replace Field-Specific Validators**:
```swift
// ❌ Remove these methods
static func isValidPhoneNumber(phoneText: String, registrationConfig: RegistrationConfigContent) -> (Bool, String)
static func isValidPassword(passwordText: String, registrationConfig: RegistrationConfigContent) -> (Bool, String)
```

**Add Generic Validator**:
```swift
// ✅ Add universal field validator
static func validateField(fieldName: String, value: String, apiField: RegistrationField) -> (Bool, String) {
    // Check mandatory requirement
    if apiField.validate.mandatory && value.isEmpty {
        return (false, "This field is required")
    }

    // Check length constraints
    if let minLength = apiField.validate.minLength, value.count < minLength {
        return (false, "Minimum \(minLength) characters required")
    }

    if let maxLength = apiField.validate.maxLength, value.count > maxLength {
        return (false, "Maximum \(maxLength) characters allowed")
    }

    // Check custom validation rules
    for customRule in apiField.validate.custom {
        if let pattern = customRule.pattern,
           let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(location: 0, length: value.utf16.count)
            let isValid = regex.firstMatch(in: value, options: [], range: range) != nil

            if !isValid {
                return (false, customRule.errorMessage)
            }
        }
    }

    return (true, "")
}
```

### Step 5: Update UI Binding Logic
**Goal**: Dynamic reactive binding for any number of fields

**Replace Hardcoded Publishers**:
```swift
private func setupDynamicPublishers() {
    // Create publishers for all field validations
    let fieldValidationPublishers = registrationFields.map { field in
        field.valuePublisher
            .map { _ in field.isValid }
            .eraseToAnyPublisher()
    }

    // Combine all field validations
    let allFieldsValidPublisher = Publishers.CombineLatest(fieldValidationPublishers)
        .map { validationResults in
            return validationResults.allSatisfy { $0 }
        }
        .eraseToAnyPublisher()

    // Update button state
    allFieldsValidPublisher
        .receive(on: DispatchQueue.main)
        .sink { [weak self] isEnabled in
            self?.buttonViewModel.setEnabled(isEnabled)
            self?.isRegisterDataComplete.send(isEnabled)
        }
        .store(in: &cancellables)
}
```

### Step 6: Modify PhoneRegistrationViewController
**Goal**: Render UI dynamically based on field collection

**Replace Hardcoded UI Setup**:
```swift
private func setupDynamicFields() {
    // Clear existing field views
    fieldStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    // Add dynamic fields
    for fieldViewModel in viewModel.registrationFields {
        let fieldView = createFieldView(for: fieldViewModel)
        fieldStackView.addArrangedSubview(fieldView)
    }
}

private func createFieldView(for fieldViewModel: RegistrationFieldViewModel) -> UIView {
    switch fieldViewModel.fieldType {
    case .tel, .text, .password:
        let textFieldVM = fieldViewModel as! TextFieldRegistrationViewModel
        return BorderedTextFieldView(viewModel: textFieldVM.borderTextFieldViewModel)

    case .checkbox:
        let checkboxVM = fieldViewModel as! CheckboxRegistrationViewModel
        return TermsAcceptanceView(viewModel: checkboxVM.termsViewModel)

    case .select:
        let dropdownVM = fieldViewModel as! DropdownRegistrationViewModel
        return DropdownView(viewModel: dropdownVM.dropdownViewModel)

    default:
        return UIView() // Fallback for unsupported types
    }
}
```

### Step 7: Update Data Collection for Registration
**Goal**: Submit registration with dynamic field data

**Dynamic Registration Submission**:
```swift
func registerUser() {
    isLoadingSubject.send(true)

    let registrationId = registrationConfig?.registrationID ?? ""

    // Collect all field values dynamically
    var registrationData: [String: Any] = [:]

    for field in registrationFields {
        if let value = field.value {
            registrationData[field.fieldName] = value
        }
    }

    // Map to API expected format
    let phoneSignUpForm = PhoneSignUpForm(
        phone: registrationData["Mobile"] as? String ?? "",
        phonePrefix: registrationData["MobilePrefix"] as? String ?? phonePrefixText,
        password: registrationData["Password"] as? String ?? "",
        registrationId: registrationId
    )

    let signUpFormType = SignUpFormType.phone(phoneSignUpForm)

    // Continue with existing registration flow...
}
```

### Step 8: Add Support for New Field Types
**Goal**: Extensible system for future field types

**Supported Field Types**:

| API `inputType` | iOS Implementation | UI Component |
|-----------------|-------------------|--------------|
| `"Tel"` | TextFieldRegistrationViewModel | BorderedTextFieldView |
| `"Password"` | TextFieldRegistrationViewModel (secure) | BorderedTextFieldView |
| `"Checkbox"` | CheckboxRegistrationViewModel | TermsAcceptanceView |
| `"Email"` | TextFieldRegistrationViewModel | BorderedTextFieldView |
| `"Select"` | DropdownRegistrationViewModel | Custom DropdownView |
| `"Date"` | DateRegistrationViewModel | Custom DatePickerView |
| `"Text"` | TextFieldRegistrationViewModel | BorderedTextFieldView |

**Field Configuration Examples**:
```swift
// Phone field
{
    "name": "Mobile",
    "inputType": "Tel",
    "defaultValue": "+237",
    "validate": {
        "mandatory": true,
        "minLength": 8,
        "maxLength": 15,
        "custom": [{
            "rule": "regex",
            "pattern": "^6[0-9]{8}$",
            "errorMessage": "Invalid phone format"
        }]
    }
}

// Email field (future)
{
    "name": "Email",
    "inputType": "Email",
    "validate": {
        "mandatory": true,
        "custom": [{
            "rule": "regex",
            "pattern": "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$",
            "errorMessage": "Invalid email format"
        }]
    }
}

// Country selection (future)
{
    "name": "Country",
    "inputType": "Select",
    "data": "GET /api/countries",
    "validate": {
        "mandatory": true
    }
}
```

### Step 9: Enhanced Error Handling
**Goal**: Dynamic error display per field

**Field-Level Error Management**:
```swift
protocol RegistrationFieldViewModel {
    var errorState: CurrentValueSubject<String?, Never> { get }
    var isValid: Bool { get }

    func validateAndUpdateError()
    func clearError()
    func setError(_ message: String)
}
```

**Real-Time Validation**:
```swift
// In TextFieldRegistrationViewModel
func setupValidation() {
    valuePublisher
        .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
        .sink { [weak self] value in
            self?.validateAndUpdateError()
        }
        .store(in: &cancellables)
}

func validateAndUpdateError() {
    let validation = RegisterConfigHelper.validateField(
        fieldName: fieldName,
        value: currentValue,
        apiField: apiField
    )

    if validation.0 {
        clearError()
    } else {
        setError(validation.1)
    }
}
```

### Step 10: Testing & Validation
**Goal**: Ensure system works with different registration configs

**Test Scenarios**:

1. **Minimal Config** (only required fields):
   ```json
   {
     "fields": [
       {"name": "Mobile", "inputType": "Tel", "validate": {"mandatory": true}},
       {"name": "Password", "inputType": "Password", "validate": {"mandatory": true}},
       {"name": "TermsAndConditions", "inputType": "Checkbox", "validate": {"mandatory": true}}
     ]
   }
   ```

2. **Extended Config** (additional fields):
   ```json
   {
     "fields": [
       {"name": "FirstName", "inputType": "Text", "validate": {"mandatory": true}},
       {"name": "LastName", "inputType": "Text", "validate": {"mandatory": true}},
       {"name": "Email", "inputType": "Email", "validate": {"mandatory": false}},
       {"name": "Mobile", "inputType": "Tel", "validate": {"mandatory": true}},
       {"name": "Password", "inputType": "Password", "validate": {"mandatory": true}},
       {"name": "Country", "inputType": "Select", "validate": {"mandatory": true}},
       {"name": "TermsAndConditions", "inputType": "Checkbox", "validate": {"mandatory": true}}
     ]
   }
   ```

3. **Validation Edge Cases**:
   - Empty required fields
   - Invalid regex patterns
   - Length constraint violations
   - Mixed valid/invalid field states

**Testing Checklist**:
- [ ] Dynamic field generation from API
- [ ] Correct UI component rendering per field type
- [ ] Real-time validation with API rules
- [ ] Error message display from server
- [ ] Form submission with all field values
- [ ] Button enable/disable logic
- [ ] Registration flow completion
- [ ] Error handling for unsupported field types

---

## Benefits

### For Development
- **Zero Code Changes**: New registration requirements handled server-side
- **Consistent Validation**: All validation logic driven by API rules
- **Maintainable**: Single source of truth for field definitions
- **Testable**: Easy to test different registration configurations

### For Business
- **A/B Testing**: Server-controlled registration flows
- **Market Adaptation**: Different fields per country/regulation
- **Quick Iteration**: No app deployment for registration changes
- **Compliance**: Dynamic required fields for legal requirements

### For Users
- **Consistent Experience**: Same validation behavior across platforms
- **Localized Forms**: Server-controlled field labels and errors
- **Optimal Flow**: Only required fields shown per market

---

## Migration Strategy

### Phase 1: Foundation (Week 1)
- Implement Step 1-3 (field models and protocol changes)
- Maintain backward compatibility with hardcoded fields

### Phase 2: Validation (Week 2)
- Implement Step 4-5 (dynamic validation and binding)
- Test with existing registration config

### Phase 3: UI Rendering (Week 3)
- Implement Step 6-7 (dynamic UI and data collection)
- Full end-to-end testing

### Phase 4: Enhancement (Week 4)
- Implement Step 8-10 (new field types and testing)
- Remove backward compatibility code

This approach ensures the registration screen becomes completely server-driven while maintaining a robust, extensible architecture for future requirements.