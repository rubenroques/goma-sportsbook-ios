## Date
10 December 2025

### Project / Branch
BetssonCameroonApp / main

### Goals for this session
- Add 3 new GmLegislation error codes from Phrase (requested by Adriano via Discord)

### Achievements
- [x] Added 3 new Phrase keys to `APIErrorKey` enum:
  - `forbiddenTooManyAttempts` → `gm_error_forbidden_too_many_attempts`
  - `forbiddenUserAccountBlocked` → `gm_error_forbidden_user_account_blocked`
  - `internalError` → `gm_error_internal_error`
- [x] Added switch cases for new GmLegislation error codes in `mappedErrorKey(from:)`
- [x] Created new CHANGELOG version 0.3.5

### Issues / Bugs Hit
- None

### Key Decisions
- **Separate Phrase keys for GmLegislation errors**: New error codes from GmLegislation server get their own dedicated Phrase keys (e.g., `gm_error_forbidden_too_many_attempts`) instead of reusing existing keys
- **Kept legacy gmerr mappings**: Old `gmerruserauthfailedtoomanyattempts` still maps to `gm_error_user_auth_failed_too_many_attempts` for backwards compatibility

### Experiments & Notes
- Discord context from Adriano:
  - `Forbidden_TooManyAttempts` → `gm_error_forbidden_too_many_attempts`
  - `InternalError` → `gm_error_internal_error`
  - `Forbidden_UserAccount_Blocked` → `gm_error_forbidden_user_account_blocked`
- These are critical issues per Bruno Gomes - need QA validation after deployment

### Useful Files / Links
- [ServiceProviderModelMapper+ErrorCode.swift](../../BetssonCameroonApp/App/Models/ModelsMapping/ServiceProviderModelMapper+ErrorCode.swift)
- [CHANGELOG.yml](../../BetssonCameroonApp/CHANGELOG.yml)
- Previous session: [09-December-2025-em-error-code-multi-mapping.md](./09-December-2025-em-error-code-multi-mapping.md)

### Next Steps
1. Build and verify compilation
2. Test login/register flows to trigger these errors
3. Notify QA after deployment (per Bruno's request)
