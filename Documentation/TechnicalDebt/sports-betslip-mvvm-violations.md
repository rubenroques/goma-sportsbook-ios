# SportsBetslipViewController MVVM Violations Analysis
**Date:** 17 October 2025
**Author:** Claude Code
**Status:** 🔴 Critical Architectural Issues Detected

---

## Executive Summary

The `SportsBetslipViewController` implementation contains **multiple critical MVVM violations** that break the established architectural patterns. The most severe issue is that the **ViewController is creating ViewModels and performing data transformation** – a fundamental violation of MVVM separation of concerns.

**Severity Breakdown:**
- 🔴 **CRITICAL**: 3 violations (require immediate refactoring)
- 🟠 **HIGH**: 5 violations (should be fixed soon)
- 🟡 **MEDIUM**: 4 violations (technical debt)

---

## 🔴 CRITICAL VIOLATIONS

### 1. ViewController Creating ViewModels (Lines 522-531)
**File:** `SportsBetslipViewController.swift:522-531`

```swift
let ticketViewModel = MockBetslipTicketViewModel(
    leagueName: ticket.competition ?? "Unknown League",
    startDate: formatTicketDate(ticket.date) ?? "Unknown Date",
    homeTeam: ticket.homeParticipantName ?? "Home Team",
    awayTeam: ticket.awayParticipantName ?? "Away Team",
    selectedTeam: ticket.outcomeDescription,
    oddsValue: String(format: "%.2f", ticket.decimalOdd),
    oddsChangeState: .none
)
cell.configure(with: ticketViewModel)
```

**Problems:**
1. ✗ ViewController is instantiating ViewModels (should be injected from parent ViewModel)
2. ✗ Using `MockBetslipTicketViewModel` in production code (mocks are for tests/previews only)
3. ✗ Performing data transformation (formatting, nil-coalescing, string interpolation)
4. ✗ Business logic in ViewController (`formatTicketDate`, odds formatting)

**Expected Pattern:**
```swift
// ViewModel should provide child ViewModels:
var ticketViewModels: [BetslipTicketViewModelProtocol] { get }

// ViewController should only pass them through:
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(...)
    let ticketViewModel = viewModel.ticketViewModels[indexPath.row]
    cell.configure(with: ticketViewModel)
    return cell
}
```

**Impact:** 🔴 **BLOCKER** - Violates fundamental MVVM principle of separation of concerns

---

### 2. Business Logic in ViewController (Lines 545-552)
**File:** `SportsBetslipViewController.swift:545-552`

```swift
private func formatTicketDate(_ date: Date?) -> String? {
    guard let date = date else { return nil }
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMMM, HH:mm"
    return formatter.string(from: date)
}
```

**Problems:**
1. ✗ Date formatting logic belongs in ViewModel (business logic)
2. ✗ DateFormatter creation is expensive and should be cached
3. ✗ Format string is hardcoded (should be configurable/localized)

**Expected Location:**
- In ViewModel or a dedicated `DateFormatterService`
- Injected formatter or extension on Date

**Impact:** 🔴 **HIGH** - Business logic leaking into presentation layer

---

### 3. Type Casting Protocol to Concrete Type (Line 119)
**File:** `SportsBetslipViewModel.swift:119-121`

```swift
if let mockViewModel = self.suggestedBetsViewModel as? MockSuggestedBetsExpandedViewModel {
    mockViewModel.updateMatches(items)
}
```

**Problems:**
1. ✗ Type casting from protocol to concrete type indicates architectural failure
2. ✗ Protocol `SuggestedBetsExpandedViewModelProtocol` is missing `updateMatches` method
3. ✗ Production code depends on Mock implementation

**Expected Pattern:**
```swift
// Add to protocol:
protocol SuggestedBetsExpandedViewModelProtocol {
    func updateMatches(_ matches: [TallOddsMatchCardViewModelProtocol])
}

// Use directly:
self.suggestedBetsViewModel.updateMatches(items)
```

**Impact:** 🔴 **HIGH** - Protocol contract is incomplete, breaks polymorphism

---

## 🟠 HIGH SEVERITY VIOLATIONS

### 4. Callback-Based State Management (Lines 340-360)
**File:** `SportsBetslipViewController.swift:340-360`

```swift
viewModel.betslipLoggedState = { [weak self] betslipLoggedState in
    switch betslipLoggedState {
    case .noTicketsLoggedOut:
        self?.betInfoSubmissionView.isHidden = true
        self?.codeInputView.isHidden = true
        self?.loginButtonContainerView.isHidden = true
    // ... more cases
    }
}
```

**Problems:**
1. ✗ Using callbacks instead of Combine publishers (inconsistent with architecture)
2. ✗ ViewModel indirectly controlling UI visibility (should be ViewController's decision)
3. ✗ ViewController has detailed switch logic instead of simple rendering

**Expected Pattern:**
```swift
// In ViewModelProtocol:
var betslipStatePublisher: AnyPublisher<BetslipState, Never> { get }

// In ViewController:
viewModel.betslipStatePublisher
    .receive(on: DispatchQueue.main)
    .sink { [weak self] state in
        self?.render(state: state)
    }
    .store(in: &cancellables)

private func render(state: BetslipState) {
    // Render based on state
}
```

**Impact:** 🟠 **HIGH** - Inconsistent architecture, harder to test and debug

---

### 5. Mutable Child ViewModels in Protocol (Lines 21-28)
**File:** `SportsBetslipViewModelProtocol.swift:21-28`

```swift
var bookingCodeButtonViewModel: ButtonIconViewModelProtocol { get set }
var clearBetslipButtonViewModel: ButtonIconViewModelProtocol { get set }
// ... more { get set } properties
```

**Problems:**
1. ✗ Child ViewModels should be immutable from outside (`{ get }` only)
2. ✗ External mutation breaks encapsulation
3. ✗ Makes state management unpredictable

**Expected Pattern:**
```swift
var bookingCodeButtonViewModel: ButtonIconViewModelProtocol { get }
var clearBetslipButtonViewModel: ButtonIconViewModelProtocol { get }
```

**Impact:** 🟠 **HIGH** - Breaks encapsulation, allows uncontrolled state mutation

---

### 6. Mutable Publisher Exposed in Protocol (Line 34)
**File:** `SportsBetslipViewModelProtocol.swift:34`

```swift
var isLoadingSubject: CurrentValueSubject<Bool, Never> { get set }
```

**Problems:**
1. ✗ Exposing `CurrentValueSubject` instead of `AnyPublisher`
2. ✗ External code can call `.send()` on the subject
3. ✗ Violates information hiding principle

**Expected Pattern:**
```swift
var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
```

**Impact:** 🟠 **HIGH** - Exposes internal implementation, breaks encapsulation

---

### 7. Direct Property Access Instead of Publishers (Line 406)
**File:** `SportsBetslipViewController.swift:406`

```swift
let hasMatches = !viewModel.suggestedBetsViewModel.matchCardViewModels.isEmpty
```

**Problems:**
1. ✗ Direct property access instead of observing publisher
2. ✗ Could be stale data (race condition)
3. ✗ Inconsistent with reactive architecture

**Expected Pattern:**
```swift
// Already has publisher at line 375-380, should use that consistently
viewModel.suggestedBetsViewModel.matchCardViewModelsPublisher
    .map { !$0.isEmpty }
    .receive(on: DispatchQueue.main)
    .sink { [weak self] hasMatches in
        self?.suggestedBetsView.isHidden = !hasMatches
    }
    .store(in: &cancellables)
```

**Impact:** 🟠 **MEDIUM** - Potential race conditions, inconsistent architecture

---

## 🟡 MEDIUM SEVERITY VIOLATIONS

### 8. Using Mock ViewModels in Production (Lines 58-88)
**File:** `SportsBetslipViewModel.swift:58-88`

```swift
self.bookingCodeButtonViewModel = MockButtonIconViewModel(...)
self.clearBetslipButtonViewModel = MockButtonIconViewModel(...)
self.emptyStateViewModel = MockEmptyStateActionViewModel(...)
// ... all using Mock* implementations
```

**Problems:**
1. ✗ Mock ViewModels should only be used in tests and SwiftUI previews
2. ✗ Production should use real implementations (e.g., `ButtonIconViewModel`)
3. ✗ "Mock" in production code is a code smell

**Expected Pattern:**
```swift
self.bookingCodeButtonViewModel = ButtonIconViewModel(
    title: "Booking Code",
    icon: "doc.text",
    layoutType: .iconLeft
)
```

**Impact:** 🟡 **MEDIUM** - Misleading naming, potential for confusion

---

### 9. Print Statements in Production Code (Multiple locations)
**File:** `SportsBetslipViewModel.swift:106, 232-235, 246, 255, etc.`

```swift
print("RECOMMENDED ERROR: \(error)")
print("[BET_PLACEMENT] 📋 Placing bet with \(placedTickets.count) tickets")
```

**Problems:**
1. ✗ Print statements shouldn't be in production code
2. ✗ Should use proper logging framework (e.g., OSLog, CocoaLumberjack)
3. ✗ No log levels, filtering, or structured logging

**Expected Pattern:**
```swift
Logger.betting.error("Failed to load recommended matches: \(error)")
Logger.betting.info("Placing bet with \(placedTickets.count) tickets")
```

**Impact:** 🟡 **LOW** - Technical debt, poor debugging experience in production

---

### 10. String-Based Number Conversion Utility (Lines 328-337)
**File:** `SportsBetslipViewModel.swift:328-337`

```swift
func convertToDouble(_ string: String) -> Double {
    let trimmed = string.trimmingCharacters(in: .whitespaces)
    let normalizedString = trimmed.replacingOccurrences(of: ",", with: ".")
    return Double(normalizedString) ?? 0.0
}
```

**Problems:**
1. ✗ Utility function in ViewModel (should be extension or injected service)
2. ✗ Locale-specific logic (comma vs decimal) hardcoded
3. ✗ Silent failure (returns 0.0 on parse error)

**Expected Pattern:**
```swift
// In Extensions or NumberFormatter service
extension String {
    func toDouble(locale: Locale = .current) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        return formatter.number(from: self)?.doubleValue
    }
}
```

**Impact:** 🟡 **MEDIUM** - Localization issues, poor error handling

---

### 11. Direct Environment Dependency (Line 17)
**File:** `SportsBetslipViewModel.swift:17`

```swift
private var environment: Environment
```

**Problems:**
1. ✗ Using concrete `Environment` type instead of protocol
2. ✗ Harder to test and mock
3. ✗ Tight coupling to specific Environment implementation

**Expected Pattern:**
```swift
protocol SportsBetslipEnvironment {
    var betslipManager: BetslipManagerProtocol { get }
    var userSessionStore: UserSessionStoreProtocol { get }
    var servicesProvider: ServicesProviderProtocol { get }
}

private let environment: SportsBetslipEnvironment
```

**Impact:** 🟡 **MEDIUM** - Testability and flexibility concerns

---

## 🟢 POSITIVE OBSERVATIONS

Despite the violations, the code has some good patterns:

1. ✓ **Combine Integration**: Uses publishers for most reactive updates
2. ✓ **Weak Self References**: Proper memory management with `[weak self]`
3. ✓ **Protocol-Driven**: Most components use protocol abstractions
4. ✓ **GomaUI Integration**: Consistent use of shared UI components
5. ✓ **Separation of Cell Logic**: `BetslipTicketTableViewCell` is well-structured

---

## RECOMMENDED REFACTORING PRIORITY

### Phase 1: Critical Fixes (Must Do)
1. **Move ViewModel creation to ViewModel** (Issue #1)
   - Add `ticketViewModels: [BetslipTicketViewModelProtocol]` to `SportsBetslipViewModelProtocol`
   - Create production `BetslipTicketViewModel` (not Mock)
   - Map `BettingTicket` → `BetslipTicketViewModel` in parent ViewModel

2. **Fix Protocol Contracts** (Issue #3)
   - Add `updateMatches` to `SuggestedBetsExpandedViewModelProtocol`
   - Remove type casting from production code

3. **Move Business Logic to ViewModel** (Issue #2)
   - Create `DateFormatterService` or use extension
   - Move all formatting logic out of ViewController

### Phase 2: Architecture Consistency (Should Do)
4. **Replace Callbacks with Publishers** (Issue #4)
   - Convert `betslipLoggedState` callback to `betslipStatePublisher`
   - Simplify ViewController rendering logic

5. **Fix Protocol Mutability** (Issues #5, #6)
   - Make child ViewModels `{ get }` only
   - Expose `AnyPublisher` instead of `CurrentValueSubject`

### Phase 3: Quality Improvements (Nice to Have)
6. **Replace Mock ViewModels** (Issue #8)
7. **Implement Proper Logging** (Issue #9)
8. **Extract Utility Functions** (Issue #10)
9. **Use Protocol Dependencies** (Issue #11)

---

## ARCHITECTURAL GUIDELINES REFERENCE

From `CLAUDE.md`:
> **ViewControllers should NEVER create Coordinators - that's the parent coordinator's job**

The same principle applies to ViewModels:
> **ViewControllers should NEVER create ViewModels - that's the parent ViewModel's job**

### Expected Data Flow:
```
BettingTicket (Model)
    ↓
SportsBetslipViewModel (transforms to)
    ↓
BetslipTicketViewModel (child ViewModel)
    ↓
SportsBetslipViewController (passes to)
    ↓
BetslipTicketTableViewCell (renders)
```

### Current Broken Flow:
```
BettingTicket (Model)
    ↓
SportsBetslipViewController (WRONG: transforms AND creates ViewModel)
    ↓
MockBetslipTicketViewModel (WRONG: Mock in production)
    ↓
BetslipTicketTableViewCell (renders)
```

---

## IMPACT ASSESSMENT

**Testing Impact:**
- ✗ ViewModels cannot be properly unit tested (business logic in ViewController)
- ✗ Mock detection in production code breaks test isolation
- ✗ Type casting makes protocol contracts untestable

**Maintenance Impact:**
- ✗ Changes to ticket display require ViewController modification
- ✗ Inconsistent patterns confuse developers
- ✗ Technical debt accumulates quickly

**Runtime Impact:**
- ✗ DateFormatter created on every cell (performance issue)
- ✗ Potential race conditions with direct property access
- ✗ Memory leaks possible with improper callback cleanup

---

## CONCLUSION

The SportsBetslipViewController implementation requires **significant refactoring** to align with MVVM-C principles. The most critical issue is the **ViewController creating and configuring ViewModels**, which fundamentally breaks the separation between View and ViewModel layers.

**Recommended Action:**
1. ⛔ **Block new feature work** until critical violations (#1, #2, #3) are fixed
2. 📋 **Create refactoring task** with Phase 1 items
3. 🔄 **Apply learnings** to prevent similar violations in other screens

---

## FILES ANALYZED

- `BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/SportsBetslipViewController.swift` (554 lines)
- `BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/SportsBetslipViewModelProtocol.swift` (48 lines)
- `BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/SportsBetslipViewModel.swift` (351 lines)
- `BetssonCameroonApp/App/Screens/Betslip/SportsBetslip/BetslipOddsBoostHeaderViewModel.swift` (134 lines)
- `BetssonCameroonApp/App/Screens/Betslip/Cells/BetslipTicketTableViewCell.swift` (110 lines)

**Total Lines Analyzed:** 1,197 lines
**Violations Found:** 11 distinct issues
**Critical Issues:** 3
