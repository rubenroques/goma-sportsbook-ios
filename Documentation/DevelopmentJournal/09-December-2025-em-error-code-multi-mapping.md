## Date
09 December 2025

### Project / Branch
BetssonCameroonApp / rr/bet-at-home

### Goals for this session
- Support translation for EveryMatrix `Forbidden_TooManyAttempts` error on login
- Allow multiple EM error codes to map to a single Phrase localization key

### Achievements
- [x] Refactored `ServiceProviderModelMapper+ErrorCode.swift` to use switch-based pattern matching
- [x] Removed `APIErrorCode` enum (no longer needed with switch approach)
- [x] Added support for `Forbidden_TooManyAttempts` → maps to existing `gm_error_user_auth_failed_too_many_attempts` Phrase key
- [x] Maintained all existing error code mappings
- [x] Added documentation comments explaining the multi-format support

### Issues / Bugs Hit
- None

### Key Decisions
- **Switch over enum raw values**: Replaced enum-based matching with switch pattern matching to support multiple EM error codes mapping to the same Phrase key
- **Normalization strategy**: Input is lowercased and underscores removed before matching (e.g., `Forbidden_TooManyAttempts` → `forbiddentoomanyattempts`)
- **Reuse existing Phrase key**: `Forbidden_TooManyAttempts` maps to existing `gm_error_user_auth_failed_too_many_attempts` rather than creating a new key

### Experiments & Notes
- EveryMatrix returns error codes in different formats depending on the source:
  - Old format: `gmerruser4tscheckexists` (from PlayerAPI)
  - New format: `Forbidden_TooManyAttempts` (from GmLegislation server)
- Phrase SDK handles translations at runtime - keys don't need to be in local `Localizable.strings`

### Useful Files / Links
- [ServiceProviderModelMapper+ErrorCode.swift](../../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+ErrorCode.swift)
- [EveryMatrixRESTConnector.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Connectors/EveryMatrixRESTConnector.swift)
- [PhoneLoginViewController.swift](../../BetssonCameroonApp/App/Screens/PhoneLogin/PhoneLoginViewController.swift)

### Next Steps
1. Build and verify no compilation errors
2. Test login flow with invalid credentials to trigger `Forbidden_TooManyAttempts`
3. Add more EM error code variants as they're discovered from API responses
