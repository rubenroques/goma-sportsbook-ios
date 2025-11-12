# Development Journal Entry

## Date
11 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix keyboard "GO" button behavior in BetInfoSubmissionView
- Remove opinionated keyboard dismissal from BorderedTextFieldView component
- Implement proper MVVM architecture for return key handling
- Ensure BorderedTextFieldView remains reusable across different contexts

### Achievements
- [x] Removed automatic keyboard dismissal from BorderedTextFieldView component
- [x] Removed bet placement logic from return key callback in MockBetInfoSubmissionViewModel
- [x] Added `onAmountReturnKeyTapped` callback property to BetInfoSubmissionViewModelProtocol
- [x] Implemented proper callback chain: BorderedTextField → MockBetInfoSubmissionViewModel → BetInfoSubmissionView
- [x] Configured return key to only dismiss keyboard (no validation, no bet placement)
- [x] Maintained proper encapsulation - view only communicates with its view model

### Issues / Bugs Hit
- [x] Initial implementation had BetInfoSubmissionView reaching into child view models (architectural violation)
- [x] First attempt had keyboard dismissal hardcoded in BorderedTextFieldView (reduced reusability)
- [x] Previous implementation coupled return key to bet placement logic (inappropriate coupling)

### Key Decisions
- **Architecture Pattern**: View → ViewModel → Child ViewModel callback chain
  - Reasoning: Proper MVVM encapsulation, view only talks to its own view model
  - Alternative considered: Direct access to child view models (rejected - violates encapsulation)
- **Return Key Behavior**: Dismiss keyboard only, no business logic
  - Reasoning: Clean separation of concerns, keyboard control vs bet placement are separate concerns
  - Previous implementation conflated these concerns
- **Component Reusability**: BorderedTextFieldView only notifies, doesn't decide
  - Reasoning: Makes component reusable for any context (login, search, forms, betting)
  - Consumer configures behavior through callback

### Experiments & Notes
- Discovered existing return key infrastructure was already in place but poorly wired
- Original implementation from 10-November-2025 had return key triggering bet placement with validation
- New architecture allows different contexts to use return key differently:
  - Betslip: Dismiss keyboard
  - Login form: Navigate to next field
  - Search: Trigger search
  - etc.

### Useful Files / Links
- [BorderedTextFieldView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BorderedTextFieldView/BorderedTextFieldView.swift) - Reusable text field component
- [BorderedTextFieldViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BorderedTextFieldView/BorderedTextFieldViewModelProtocol.swift) - Protocol defining text field interface
- [MockBorderedTextFieldViewModel](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BorderedTextFieldView/MockBorderedTextFieldViewModel.swift) - Mock implementation with callback support
- [BetInfoSubmissionView](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetInfoSubmissionView/BetInfoSubmissionView.swift) - Bet submission UI component
- [BetInfoSubmissionViewModelProtocol](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetInfoSubmissionView/BetInfoSubmissionViewModelProtocol.swift) - Protocol with new return key callback
- [MockBetInfoSubmissionViewModel](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetInfoSubmissionView/MockBetInfoSubmissionViewModel.swift) - Implementation with internal wiring
- [SportsBetslipViewController](../../BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/SportsBetslipViewController.swift) - Production usage
- [Previous Session: 10-November-2025](./10-November-2025-betslip-keyboard-go-button.md) - Original return key implementation

### Technical Implementation Details

#### Architecture Flow
```
User taps "GO" → BorderedTextFieldView.textFieldShouldReturn()
    ↓
viewModel.onReturnKeyTapped() (protocol method)
    ↓
MockBorderedTextFieldViewModel.onReturnKeyTappedCallback?()
    ↓
MockBetInfoSubmissionViewModel.onAmountReturnKeyTapped?()
    ↓
BetInfoSubmissionView dismisses keyboard
```

#### Modified Files

1. **BorderedTextFieldView.swift** (line 581-585)
   - Removed `textField.resignFirstResponder()` call
   - Kept only `viewModel.onReturnKeyTapped()` notification
   - Component now makes no assumptions about return key behavior

2. **BetInfoSubmissionViewModelProtocol.swift** (line 86-87)
   - Added `var onAmountReturnKeyTapped: (() -> Void)? { get set }`
   - Provides callback point for view to configure behavior

3. **MockBetInfoSubmissionViewModel.swift** (lines 26, 103, 273-280)
   - Added `onAmountReturnKeyTapped` property
   - Created `setupReturnKeyCallback()` to wire child text field callback to parent callback
   - Removed all validation and bet placement logic from return key handling

4. **BetInfoSubmissionView.swift** (lines 110, 188-193)
   - Added `setupReturnKeyBehavior()` method in initialization
   - Configures `viewModel.onAmountReturnKeyTapped` to dismiss keyboard
   - View only communicates with its own view model

#### MVVM Best Practices Followed
- ✅ View only communicates with its view model (not child view models)
- ✅ View model coordinates internal child view models
- ✅ Protocol-driven interfaces enable flexibility
- ✅ Clear separation of concerns (keyboard control vs business logic)
- ✅ Component reusability maintained

### Next Steps
1. Test keyboard behavior in simulator with real betting flow
2. Verify keyboard dismissal works correctly across different iOS versions
3. Consider adding similar return key callback pattern to other form components
4. Update UI Component Guide documentation with return key callback pattern
5. Test that return key behavior doesn't interfere with bet placement button
