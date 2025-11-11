# Development Journal Entry

## Date
10 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Investigate keyboard behavior for betting amount text field in sports betslip
- Add Go/Done button to keyboard for dismissing keyboard and placing bets
- Wire up keyboard return key to trigger bet placement when valid

### Achievements
- [x] Changed keyboard type from `.decimalPad` to `.numbersAndPunctuation` in `MockBetInfoSubmissionViewModel`
- [x] Added `returnKeyType: .go` configuration to display Go button on keyboard
- [x] Implemented callback infrastructure in `MockBorderedTextFieldViewModel` for return key handling
- [x] Wired up return key callback to trigger bet placement when amount is valid
- [x] Added automatic keyboard dismissal in `BorderedTextFieldView.textFieldShouldReturn`
- [x] Implemented validation logic (amount not empty + valid tickets) before triggering bet placement

### Issues / Bugs Hit
- [x] Initial discovery: `.decimalPad` keyboard has no return key at all (only numbers 0-9, decimal point, delete)
- [x] User expected a Go button that didn't exist with decimal pad configuration

### Key Decisions
- **Keyboard Type**: Switched from `.decimalPad` to `.numbersAndPunctuation`
  - Reasoning: Supports decimal point (required for bet amounts) AND has native return key
  - Alternative considered: Input accessory toolbar (more complex, non-native UX)
- **Return Key Behavior**: Always dismiss keyboard, conditionally place bet
  - If amount is valid AND Place Bet button enabled → Place bet automatically
  - If amount invalid → Only dismiss keyboard (safe fallback)
- **Callback Pattern**: Used `onReturnKeyTappedCallback` in mock ViewModel
  - Maintains protocol-driven MVVM architecture
  - Allows flexible wiring at initialization time

### Experiments & Notes
- Discovered existing return key infrastructure already implemented but unused:
  - `BorderedTextFieldViewModelProtocol.onReturnKeyTapped()` method (line 98)
  - `BorderedTextFieldView.textFieldShouldReturn` delegate (lines 581-587)
  - `MockBorderedTextFieldViewModel.onReturnKeyTapped()` stub (lines 102-105)
- Infrastructure was functional but needed callback mechanism to wire to BetInfoSubmissionView
- Validation uses `hasValidTickets` flag to ensure bet placement only happens when all tickets are valid

### Useful Files / Links
- [BorderedTextFieldView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BorderedTextFieldView/BorderedTextFieldView.swift) - Core text field component
- [MockBorderedTextFieldViewModel](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BorderedTextFieldView/MockBorderedTextFieldViewModel.swift) - Mock implementation with callback support
- [BetInfoSubmissionView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetInfoSubmissionView/BetInfoSubmissionView.swift) - Bet submission UI component
- [MockBetInfoSubmissionViewModel](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetInfoSubmissionView/MockBetInfoSubmissionViewModel.swift) - Mock implementation with return key wiring
- [SportsBetslipViewController](../../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/SportsBetslipViewController.swift) - Production usage

### Technical Implementation Details

#### Modified Files
1. **MockBetInfoSubmissionViewModel.swift** (lines 81-82, 262-273)
   - Changed `keyboardType: .numbersAndPunctuation`
   - Added `returnKeyType: .go`
   - Created `setupReturnKeyCallback()` method to wire return key to bet placement

2. **MockBorderedTextFieldViewModel.swift** (lines 66, 105-108)
   - Added `onReturnKeyTappedCallback: (() -> Void)?` property
   - Updated `onReturnKeyTapped()` to trigger callback

3. **BorderedTextFieldView.swift** (lines 582-583)
   - Added `resignFirstResponder()` call before notifying ViewModel
   - Ensures keyboard dismisses immediately on return key press

#### User Flow
```
User enters amount → Taps Go button on keyboard
    ↓
textFieldShouldReturn called
    ↓
Keyboard dismissed (resignFirstResponder)
    ↓
viewModel.onReturnKeyTapped() called
    ↓
onReturnKeyTappedCallback triggered
    ↓
Validation: amount not empty + hasValidTickets
    ↓
onPlaceBetTapped?() invoked → Bet placed
```

### Next Steps
1. Test keyboard behavior in simulator with real betting flow
2. Verify keyboard dismissal works correctly across different iOS versions
3. Test edge cases: empty amount, invalid tickets, disabled state
4. Consider adding haptic feedback on successful bet placement
5. Update UI Component Guide documentation for keyboard return key patterns
