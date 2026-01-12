## Date
12 January 2026

### Project / Branch
BetssonCameroonApp / main (SPOR-7113)

### Goals for this session
- Investigate betslip stake field accepting invalid characters
- Implement input validation to restrict to digits and single decimal separator
- Ensure maximum 2 decimal places for currency

### Achievements
- [x] Identified root cause: `shouldChangeCharactersIn` only validates individual characters, not format
- [x] Added `shouldAllowTextChange(from:to:)` method to `BorderedTextFieldViewModelProtocol`
- [x] Added default implementation via protocol extension (backward compatible)
- [x] Updated `BorderedTextFieldView` to call new validation method
- [x] Implemented decimal validation in `AmountBorderedTextFieldViewModel`:
  - Rejects multiple decimal separators (e.g., "12.34.56")
  - Treats `,` and `.` as equivalent separators
  - Limits to 2 decimal places for currency

### Issues / Bugs Hit
- None encountered during implementation

### Key Decisions
- **Protocol extension for default**: Used Swift protocol extension to provide default `return true` implementation, ensuring backward compatibility with all existing ViewModels
- **Normalize separators**: Both `,` and `.` treated as decimal separators to support different locales
- **Max 2 decimal places**: Standard currency precision enforced at input level

### Experiments & Notes
- The `allowedCharacters` approach (CharacterSet filtering) only prevents individual bad characters but can't enforce format rules
- David's Jira comment confirmed the specific issue: "amount input field allows multiple ',' characters"

### Useful Files / Links
- [BorderedTextFieldViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Forms/BorderedTextFieldView/BorderedTextFieldViewModelProtocol.swift) - Added `shouldAllowTextChange` method
- [BorderedTextFieldView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/Forms/BorderedTextFieldView/BorderedTextFieldView.swift) - Calls validation in delegate
- [AmountBorderedTextFieldViewModel](../../BetssonCameroonApp/App/Screens/Betslip/AmountBorderedTextFieldViewModel.swift) - Implements decimal validation
- [JIRA SPOR-7113](https://gomagaming.atlassian.net/browse/SPOR-7113) - Bug ticket

### Next Steps
1. Build GomaUI and BetssonCameroonApp to verify compilation
2. Manual test: add selection to betslip, verify stake field rejects invalid input
3. Consider adding unit tests for `shouldAllowTextChange` validation logic
