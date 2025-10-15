# Development Journal

## Date
15 October 2025

### Project / Branch
BetssonCameroonApp / rr/register_fields_fix

### Goals for this session
- Verify registration screen implementation matches EveryMatrix API expectations
- Compare field names, formats, and validation rules between iOS app and API config
- Ensure date formatting is correct for BirthDate field

### Achievements
- [x] Retrieved registration config from staging API (`/v1/player/legislation/registration/config`)
- [x] Verified all field names match API expectations perfectly
- [x] Confirmed date format (`yyyy-MM-dd`) matches API requirements
- [x] Validated field mapping in `EveryMatrixPlayerAPI.registerStep()` is correct
- [x] Documented complete field-to-API mapping verification

### Issues / Bugs Hit
- None - Implementation from 14-October session was already correct

### Key Decisions
- **No code changes required**: Previous implementation (14-October-2025-registration-dynamic-fields-date-picker.md) already matches API spec exactly
- **Verification approach**: Used cURL to fetch live API config, then compared with iOS implementation
- **Field mapping confirmed**: `FirstnameOnDocument` and `LastNameOnDocument` (not `FirstName`/`LastName`) are correct

### API Field Mapping Verification

#### Required Fields from API Config
```json
{
  "Mobile": "699198921",
  "MobilePrefix": "+237",
  "Password": "1234",
  "FirstnameOnDocument": "John",
  "LastNameOnDocument": "Doe",
  "BirthDate": "2004-10-14",
  "TermsAndConditions": true
}
```

#### iOS Implementation (EveryMatrixPlayerAPI.swift:173-190)
```swift
var registerUserDto: [String: Any] = [
    "Mobile": form.phone,
    "MobilePrefix": form.phonePrefix,
    "Password": form.password,
    "TermsAndConditions": true
]

// Optional fields
if let firstName = form.firstName {
    registerUserDto["FirstnameOnDocument"] = firstName  // ✅ Correct field name
}
if let lastName = form.lastName {
    registerUserDto["LastNameOnDocument"] = lastName    // ✅ Correct field name
}
if let birthDate = form.birthDate {
    registerUserDto["BirthDate"] = birthDate            // ✅ yyyy-MM-dd format
}
```

#### Date Format Verification
**API Expects:**
- Format: `"yyyy-MM-dd"` (ISO 8601 date only)
- Min: `"1905-10-15"` (server config)
- Max: `"2004-10-14"` (must be 21+ years old)

**iOS Sends:**
```swift
// PhoneRegistrationViewController.swift:396
formatter.dateFormat = "yyyy-MM-dd"
formatter.locale = Locale(identifier: "en_US_POSIX")  // ✅ Prevents locale issues
```

### API Validation Rules

**Mobile (required)**
- Regex: `^6((((5[0-4]|7\d|8[0-3])|(9\d|58|57|56|55))\d{6})|(595|594|593|592|591|590)\d{5})$`
- Length: 8-15 characters
- Error: "Only MTN and Orange phone numbers are supported."

**Password (required)**
- Regex: `^[0-9]+$` (numeric only)
- Length: 4-8 characters
- Must include at least one number

**FirstnameOnDocument (required)**
- Regex: `^[A-Za-z'-]+$` (alphabetic + apostrophe + hyphen)
- Length: 1-50 characters

**LastNameOnDocument (required)**
- Regex: `^[A-Za-z'-]+$`
- Length: 1-50 characters

**BirthDate (required)**
- Type: DateTime string
- Validation: min-age rule (21 years old)
- Range: 1905-10-15 to 2004-10-14

**TermsAndConditions (required)**
- Type: Checkbox (boolean)
- Must be `true`

### Useful Files / Links
- [PhoneSignUpForm Model](../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/User/User.swift) - Lines 340-359
- [EveryMatrixPlayerAPI](../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/PlayerAPI/EveryMatrixPlayerAPI.swift) - Lines 173-200
- [PhoneRegistrationViewModel](../BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewModel.swift) - Date validation
- [PhoneRegistrationViewController](../BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewController.swift) - Date picker setup
- [Previous Session Journal](./14-October-2025-registration-dynamic-fields-date-picker.md) - Original implementation

### API Endpoints Used
```bash
# Registration config (GET)
GET https://betsson-api.stage.norway.everymatrix.com/v1/player/legislation/registration/config

# Registration step (POST)
POST https://betsson-api.stage.norway.everymatrix.com/v1/player/legislation/registration/step

# Final registration (PUT)
PUT https://betsson-api.stage.norway.everymatrix.com/v1/player/legislation/register
```

### Next Steps
1. Test end-to-end registration flow in simulator with real API
2. Verify API accepts payload successfully (no validation errors)
3. Test edge cases:
   - Minimum age boundary (exactly 21 years old)
   - Invalid phone numbers (non-MTN/Orange)
   - Special characters in names (apostrophes, hyphens)
4. Add error handling for API validation responses
5. Consider adding client-side phone number validation matching API regex
