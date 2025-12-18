## Date
18 December 2025

### Project / Branch
BetssonCameroonApp / rr/cashout_fixes

### Goals for this session
- Investigate why `terms_and_conditions_register_checkbox_display_name` was not being localized in the registration screen
- Understand if the string is local or comes from server (legislation registration config)
- Fix Phrase SDK integration with in-app language switching

### Achievements
- [x] Identified that the key comes from EveryMatrix legislation API (`RegistrationField.displayName`)
- [x] Verified via cURL that server sends `"terms_and_conditions_register_checkbox_display_name"` as a localization key
- [x] Confirmed the key exists in Phrase (with full translated text including link placeholders)
- [x] Diagnosed root cause: custom bundle in `localized()` bypasses Phrase SDK's Bundle.main swizzling
- [x] Researched iOS in-app language switching approaches (Bundle swizzling, SwiftUI environment, OTA SDKs)
- [x] Implemented hybrid localization approach: Phrase OTA first, then local bundle fallback
- [x] Added debug logging to AppDelegate to verify Phrase sync status

### Issues / Bugs Hit
- [x] Phrase SDK `localeOverride` alone doesn't reliably handle in-app language switching
- [x] Using custom bundle (`Bundle(path: languageCode.lproj)`) bypasses Phrase's swizzling
- [x] `Phrase.shared.localizedString()` requires `forKey:value:table:` parameters (not just key)

### Key Decisions
- **Hybrid approach chosen**: Try Phrase OTA first via explicit API, fall back to local bundle
- This preserves both Phrase OTA strings AND in-app language switching capability
- Did NOT disable Phrase swizzling (`PhraseSDKMainBundleProxyDisabled`) - hybrid works without it

### Experiments & Notes
- Phrase SDK only downloads ONE language at a time based on `localeOverride`
- Known GitHub issues (#39, #16) document problems with `localeOverride` for runtime language switching
- When user commented out custom bundle logic, Phrase worked but splash screen broke (only English)
- The `terms_and_conditions_register_checkbox_display_name` translation in Phrase contains:
  - EN: "I am at least 21 years of age or older and that I have read, accepted and agreed to the {terms_and_conditions_link}, {privacy_policy_link} and {cookies_policy_link} published on this site."
  - FR: "J'ai au moins 21 ans et j'ai lu, accepté et consenti aux {terms_and_conditions_link}, {privacy_policy_link} et {cookies_policy_link} publiés sur ce site."

### Useful Files / Links
- [Localization.swift](../../BetssonCameroonApp/App/Tools/MiscHelpers/Localization.swift) - Main fix location
- [LanguageManager.swift](../../BetssonCameroonApp/App/Services/LanguageManager.swift) - Language switching logic
- [AppDelegate.swift](../../BetssonCameroonApp/App/Boot/AppDelegate.swift) - Phrase SDK initialization + debug logging
- [Bootstrap.swift](../../BetssonCameroonApp/App/Boot/Bootstrap.swift) - Phrase localeOverride on restart
- [RegistrationConfigResponse.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/User/RegistrationConfig/RegistrationConfigResponse.swift) - Registration field model
- [PhoneRegistrationViewModel.swift](../../BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewModel.swift) - Where displayName is used
- [Phrase iOS SDK GitHub](https://github.com/phrase/ios-sdk)
- [Phrase localeOverride Issue #39](https://github.com/phrase/ios-sdk/issues/39)

### Next Steps
1. Test the hybrid localization approach - verify registration checkbox shows full text
2. Test splash screen still shows correct language after language switch
3. Verify language switching works end-to-end (change language → restart → all strings correct)
4. Remove debug logging from AppDelegate once verified working
5. Consider cleaning up DependenciesBootstrapper debug code added during investigation
