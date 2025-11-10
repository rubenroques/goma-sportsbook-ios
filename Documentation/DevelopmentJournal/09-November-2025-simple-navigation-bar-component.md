# Development Journal Entry

## Date
09 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Research and consolidate 8+ hardcoded back button implementations across BetssonCameroonApp
- Create a reusable GomaUI navigation bar component following framework patterns
- Implement hybrid approach: Protocol-based (GomaUI consistency) + Callback simplicity (no Combine complexity)

### Achievements
- [x] Analyzed existing back button implementations (8 files with inconsistent patterns)
- [x] Studied GomaUI component architecture (CapsuleView, CustomNavigationView, MatchDateNavigationBarView)
- [x] Designed hybrid protocol approach (3 files: Protocol, View, Mock - no data struct wrapper)
- [x] Created `SimpleNavigationBarViewModelProtocol.swift` with direct properties (no data struct)
- [x] Created `MockSimpleNavigationBarViewModel.swift` with 6 factory methods for common states
- [x] Created `SimpleNavigationBarView.swift` with container-based back button for larger touch target
- [x] Fixed back button container width issue (removed 100pt cap, now sizes to content)
- [x] Implemented priority-based constraint system to prevent title from crushing back label
- [x] Added SwiftUI previews showing 6 variants (icon-only, with text, with title, long title, etc.)

### Issues / Bugs Hit
- [x] ~~Back button container had fixed 100pt max width, cutting off "Back" label in long title variant~~
  - **Solution**: Removed `widthAnchor` constraint, container now sizes to fit content dynamically
- [x] ~~Long titles were pushing into/crushing the back button label~~
  - **Solution**: Implemented constraint priority system:
    - Back label: `setContentCompressionResistancePriority(.required)` (never compresses)
    - Title centerX: `.defaultHigh` priority (breaks when needed)
    - Title leading: `.required` priority (never overlaps back button)
    - Title compression resistance: `.defaultLow` (truncates first)

### Key Decisions

**Hybrid Architecture Approach**:
- ✅ **Protocol-based** (matches GomaUI pattern, testability)
- ✅ **Callback property** (`var onBackTapped: () -> Void` instead of Combine publishers)
- ✅ **Direct properties** (no data struct wrapper - less boilerplate)
- ✅ **Immutable** (configured once at init, no reactivity/bindings)
- ✅ **3 files** instead of 4 (Protocol, View, Mock - no separate data model file)

**Why Hybrid vs Pure GomaUI**:
- Simpler than full Combine/reactive pattern for navigation callbacks
- Still maintains protocol abstraction for testability
- Consistent with GomaUI file structure and patterns
- Direct properties reduce boilerplate while keeping flexibility

**Container View for Back Button**:
- Larger touch target (44pt height per iOS HIG)
- User can tap anywhere in "← Back" area (not just icon/label individually)
- Easier layout management (icon + label inside single container)

**Priority-Based Layout Strategy**:
```
Priority Hierarchy (High → Low):
1. Back label never compresses (1000/Required)
2. Title must not overlap back (1000/Required)
3. Title prefers centering (750/DefaultHigh)
4. Title compresses/truncates (250/DefaultLow)
```

### Experiments & Notes

**Studied Existing Components**:
- `CapsuleView`: Simple protocol + Combine + convenience init
- `CustomNavigationView`: Protocol + publisher + default mock in init
- `MatchDateNavigationBarView`: Complex with enum state (preMatch/live)

**Pattern Comparison**:
| Pattern | Files | Reactivity | Complexity |
|---------|-------|------------|------------|
| Pure GomaUI | 4 | Combine publishers | High |
| Our Hybrid | 3 | Callback property | Medium |
| User's Original | 2 | Direct callback | Low |

**Chosen Middle Ground**: Protocol (consistency) + Callbacks (simplicity)

**Constraint Priority Values**:
- `.required` = 1000 (never breaks)
- `.defaultHigh` = 750 (breaks when needed)
- `.defaultLow` = 250 (first to compress)

### Useful Files / Links

**Created Files**:
- [SimpleNavigationBarViewModelProtocol.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SimpleNavigationBarView/SimpleNavigationBarViewModelProtocol.swift)
- [SimpleNavigationBarView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SimpleNavigationBarView/SimpleNavigationBarView.swift)
- [MockSimpleNavigationBarViewModel.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/SimpleNavigationBarView/MockSimpleNavigationBarViewModel.swift)

**Files to Replace** (future migration task):
- [MyBetDetailViewController.swift:272-282](../../BetssonCameroonApp/App/Screens/MyBetDetail/MyBetDetailViewController.swift) - createBackButton()
- [TransactionHistoryViewController.swift:436-446](../../BetssonCameroonApp/App/Screens/TransactionHistory/TransactionHistoryViewController.swift) - createBackButton()
- [NotificationsViewController.swift:240-250](../../BetssonCameroonApp/App/Screens/Notifications/NotificationsViewController.swift) - createBackButton()
- [CasinoCategoryGamesListViewController.swift:35-42](../../BetssonCameroonApp/App/Screens/Casino/CasinoCategoryGamesList/CasinoCategoryGamesListViewController.swift) - hardcoded "Back" text
- [CasinoGamePrePlayViewController.swift:45-51](../../BetssonCameroonApp/App/Screens/Casino/CasinoGamePrePlay/CasinoGamePrePlayViewController.swift) - icon only
- [PromotionsViewController.swift:252-267](../../BetssonCameroonApp/App/Screens/Promotions/PromotionsViewController.swift) - custom backContainerView pattern
- [CasinoGamePlayViewController.swift:171-178](../../BetssonCameroonApp/App/Screens/Casino/CasinoGamePlay/CasinoGamePlayViewController.swift) - exitButton (similar)

**Documentation References**:
- [GomaUI Component Creation Guide](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Documentation/ComponentCreationGuide.md)
- [UIKit Code Organization Guide](../../Frameworks/GomaUI/UIKIT_CODE_ORGANIZATION_GUIDE.md)
- [CLAUDE.md - GomaUI Section](../../Frameworks/GomaUI/CLAUDE.md)

### Next Steps

**Immediate** (before merging):
1. ✅ Test SwiftUI preview in Xcode (verify all 6 variants render correctly)
2. Add component to GomaUIDemo app with demo ViewController
3. Build GomaUI framework to verify no compilation errors
4. Test in simulator with light/dark mode themes

**Future Migration** (separate PRs):
1. Create migration plan document
2. Replace hardcoded back buttons one file at a time
3. Create production ViewModel in BetssonCameroonApp following protocol
4. Add integration tests in demo app
5. Document usage patterns in UI Component Guide

**Enhancement Ideas** (optional):
- Add optional separator visibility toggle
- Support custom tint colors via protocol
- Add optional right-side action button support
- Create Xcode code snippet for quick usage

---

## Session Summary

**What We Built**: A simple, reusable navigation bar component for GomaUI that consolidates 8+ hardcoded back button implementations using a hybrid architecture approach (protocol-based but callback-driven).

**Key Win**: Found the sweet spot between GomaUI's protocol pattern (consistency/testability) and simple callback navigation (avoiding Combine complexity for a basic navigation bar).

**Technical Highlight**: Implemented priority-based constraint system ensuring back button label **always** has maximum priority, preventing title text from crushing it even with very long titles.

**Pattern Established**: 3-file hybrid approach can be template for other simple GomaUI components that don't need full reactive state management.
