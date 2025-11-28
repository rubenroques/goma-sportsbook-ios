## Date
28 November 2025

### Project / Branch
BetssonCameroonApp / rr/bugfix/match_detail_blinks

### Goals for this session
- Fix betslip stake field accepting all characters (SPOR-6614)
- Fix registration displayName localization for config fields
- Add new PromoCode field to registration form

### Achievements
- [x] **SPOR-6614 Fix**: Restricted betslip stake input to digits and decimal separators only
  - Added `allowedCharacters: CharacterSet(charactersIn: "0123456789.,")` to `AmountBorderedTextFieldViewModel.amountInput()`
  - Changed keyboard type from `.numbersAndPunctuation` to `.decimalPad`
- [x] **Registration displayName localization**: Config endpoint now returns localization keys instead of display text
  - Updated 5 field placeholders to use `localized((field.displayName ?? "fallback").lowercased())`
  - Updated TermsAndConditions HTML extraction to localize the key first
- [x] **PromoCode field**: Added new optional field to registration
  - Added `promoCode: String?` to `PhoneSignUpForm` model
  - Added "PromoCode" to API request body in `EveryMatrixPlayerAPI`
  - Added `promoCodeFieldViewModel` and `promoCode` to protocol and ViewModel
  - Added UI field positioned after TermsAndConditions checkbox

### Issues / Bugs Hit
- None

### Key Decisions
- **Decimal separators**: Support both period (.) and comma (,) for international locale support
- **PromoCode position**: Placed after TermsAndConditions per config JSON field order
- **PromoCode validation**: No validation required (optional field, maxLength: 50 from config)

### Useful Files / Links
- [AmountBorderedTextFieldViewModel](../../BetssonCameroonApp/App/Screens/Betslip/AmountBorderedTextFieldViewModel.swift) - Stake input configuration
- [PhoneRegistrationViewModel](../../BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewModel.swift) - Registration form logic
- [PhoneRegistrationViewController](../../BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewController.swift) - Registration UI
- [PhoneSignUpForm](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/User/User.swift) - Registration model
- [EveryMatrixPlayerAPI](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/PlayerAPI/EveryMatrixPlayerAPI.swift) - API request body

### Files Modified
1. `BetssonCameroonApp/App/Screens/Betslip/AmountBorderedTextFieldViewModel.swift`
2. `BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewModel.swift`
3. `BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewModelProtocol.swift`
4. `BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewController.swift`
5. `Frameworks/ServicesProvider/Sources/ServicesProvider/Models/User/User.swift`
6. `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/PlayerAPI/EveryMatrixPlayerAPI.swift`

### Next Steps
1. Test stake field input validation (typing + paste)
2. Test registration form with new PromoCode field
3. Verify API request includes PromoCode when filled
4. Add localization keys to Localizable.strings if missing
