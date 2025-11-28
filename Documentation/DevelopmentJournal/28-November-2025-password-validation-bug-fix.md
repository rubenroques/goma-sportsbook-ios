## Date
28 November 2025

### Project / Branch
sportsbook-ios / rr/bugfix/match_detail_blinks

### Goals for this session
- Investigate SPOR-6648: Password validation showing wrong error message in Phone Registration

### Achievements
- [x] Identified root cause: client-side `displayName.contains()` checks no longer matching server's actual displayName values
- [x] Traced validation flow from EveryMatrix API config to `RegisterConfigHelper.isValidPassword()` in `PhoneRegistrationViewModel.swift:569-597`
- [x] Verified bug exists in both STAGE and PROD EveryMatrix endpoints
- [x] Fixed client-side matching logic so correct regex rule is now used

### Issues / Bugs Hit
- Server sends multiple regex rules with outdated displayName values that don't match client's `contains("numerical")` / `contains("include")` checks
- Server PROD `errorMessage` for "MustIncludeNumber" rule says "Password should contain only numbers" instead of "must contain at least one number"

### Key Decisions
- **Client-side fix**: Updated the displayName matching logic to correctly identify the intended regex rule from server config
- **Remaining server issue**: EveryMatrix config still has incorrect `minLength: 4, maxLength: 8` - should be `minLength: 4, maxLength: 4` (password = 4 digits exactly)

### Experiments & Notes
- Tested EveryMatrix registration config endpoints:
  - STAGE: `https://betsson-api.stage.norway.everymatrix.com/v1/player/legislation/registration/config`
  - PROD: `https://betsson.nwacdn.com/v1/player/legislation/registration/config`
- Server sends multiple overlapping regex rules for password validation:
  ```json
  {
    "rule": "regex",
    "displayName": "include a number",
    "pattern": "^(?=.*\\d).+$",
    "errorMessage": "Password should contain only numbers",  // Wrong message
    "errorKey": "MustIncludeNumber"
  }
  ```

### Useful Files / Links
- [PhoneRegistrationViewModel](../../BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewModel.swift) - `isValidPassword()` at line 543-602
- [RegistrationConfigResponse](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/User/RegistrationConfig/RegistrationConfigResponse.swift) - API response models
- [JIRA SPOR-6648](https://gomagaming.atlassian.net/browse/SPOR-6648)

### Next Steps
1. Report to EveryMatrix: Fix `errorMessage` for MustIncludeNumber rule
2. Report to EveryMatrix: Correct minLength/maxLength values (both should be 4)
3. Test registration flow end-to-end after fix deployment
