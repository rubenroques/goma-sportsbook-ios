## Date
11 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Investigate how phone registration validates against EveryMatrix provider regex
- Add input length enforcement to match EveryMatrix API config

### Achievements
- [x] Documented complete validation flow from EM API to UI
- [x] Added `maxLength` enforcement to phone registration field using API config
- [x] Added `allowedCharacters: .decimalDigits` to restrict input to numbers only

### Key Decisions
- **Use dynamic API config for maxLength** instead of hardcoding (unlike Login screen which hardcodes 9)
- **Enforce limits upfront** via BorderedTextFieldView properties rather than only showing validation errors after input
- **Follow Login screen pattern** but with dynamic values from EveryMatrix registration config

### Investigation Summary

**4-Stage Validation Flow:**

1. **EveryMatrix API Config** (`RegistrationConfigResponse`)
   - Contains field validation rules including regex patterns, min/max length
   - Example: `minLength: 8, maxLength: 15, pattern: "^6((((5[0-4]|7\\d|8[0-3])|(9\\d|58|57|56|55))\\d{6})|(595|594|593|592|591|590)\\d{5})$"`

2. **PhoneRegistrationViewModel** fetches config
   - `getRegistrationConfig()` at line 73-98
   - Stores in `registrationConfig` property
   - Extracts field-specific rules in `handleRegistrationConfig()` at line 101-215

3. **RegisterConfigHelper validation**
   - `isValidPhoneNumber()` at line 504-539
   - Extracts regex pattern from `validate.custom.first(where: { $0.rule == "regex" })`
   - Creates `NSRegularExpression` from EM pattern
   - Returns validation result and EM's error message

4. **Real-time UI feedback**
   - Reactive binding via `phoneFieldViewModel.textPublisher` at line 282-299
   - Validates on every keystroke
   - Shows/clears errors dynamically

**Problem Found:**
- Login screen enforces 9-character limit via `maxLength: 9` parameter
- Register screen was NOT enforcing the 15-character limit from API
- Users could type unlimited characters and only see validation error after

**Solution:**
Added two parameters to phone field config in `PhoneRegistrationViewModel.swift:123-124`:
```swift
maxLength: phoneConfig?.validate.maxLength,      // Enforces 15 char limit
allowedCharacters: .decimalDigits                 // Only 0-9 allowed
```

### Useful Files / Links
- [PhoneRegistrationViewModel](../../BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewModel.swift) - Main validation logic
- [BorderedTextFieldViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BorderedTextFieldView/BorderedTextFieldViewModelProtocol.swift) - maxLength/allowedCharacters support
- [RegistrationConfigResponse](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/User/RegistrationConfig/RegistrationConfigResponse.swift) - API response models
- [EveryMatrix CLAUDE.md](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CLAUDE.md) - Provider architecture docs

### Architecture Notes

**EveryMatrix Registration Config Flow:**
- REST API (not WebSocket) - uses 2-layer model transformation
- `EveryMatrix.RegistrationConfigResponse` (internal) → `RegistrationConfigResponse` (domain)
- No DTOs, no EntityStore, no Builders (only WebSocket data uses those)
- Config is dynamic per operator/country

**Validation Pattern Used:**
- Protocol-driven MVVM with Combine publishers
- GomaUI `BorderedTextFieldView` component handles UI + enforcement
- ViewModel handles business logic validation via `RegisterConfigHelper`
- Same helper validates firstName, lastName, birthDate, password using their respective API configs

### Next Steps
1. Consider applying same pattern to other registration fields (firstName, lastName) if they have maxLength in config
2. Test registration flow with various phone number formats to ensure regex validation works correctly
3. Verify error messages from EM are user-friendly and localized
