## Date
03 September 2025

### Project / Branch
sportsbook-ios / rr/mybets_profile_features

### Goals for this session
- Complete ButtonViewModel extension factory methods
- Research comprehensive Mock ViewModel usage in production code
- Analyze architectural anti-patterns and prioritize refactoring strategy
- Document systematic approach for replacing GomaUI Mocks with concrete implementations

### Achievements
- [x] Fixed ButtonViewModel extension compilation errors (UIKit import + correct constructor pattern)
- [x] Added depositButton() and withdrawButton() factory methods to ButtonViewModel extension
- [x] Updated WalletStatusViewModel to use ButtonViewModel factory methods (cleaner code)
- [x] Completed comprehensive Mock ViewModel audit across BetssonCameroonApp
- [x] Identified 15+ different GomaUI Mock ViewModels used in production code
- [x] Research completed for all critical infrastructure components and their protocol requirements
- [x] Created priority matrix and implementation roadmap for systematic refactoring

### Issues / Bugs Hit
- [x] ButtonViewModel extension had compilation errors (wrong constructor pattern)
- [x] Missing UIKit import for UIColor usage in ButtonViewModel extension

### Key Decisions
- **Proven refactoring pattern established**: MultiWidgetToolbarViewModel → WalletStatusViewModel → ButtonViewModel sequence demonstrates successful approach
- **Systematic research methodology**: Use `grep -r "Mock.*ViewModel" BetssonCameroonApp` to identify all anti-patterns
- **Priority classification system**: CRITICAL (core infrastructure) → HIGH (business features) → MEDIUM (UI components) → LOW (development screens)
- **Phase-based implementation approach**: Foundation → Core Infrastructure → Filtering System (15-24 day total effort)

### Experiments & Notes
- **Search strategy effectiveness**: Regex pattern `Mock.*ViewModel` successfully identified all cases
- **Anti-pattern severity analysis**: RootTabBarViewModel contains 3 critical mock dependencies in constructor defaults
- **Architectural risk assessment**: Production app fundamentally built on GomaUI testing infrastructure
- **Protocol complexity analysis**: AdaptiveTabBarViewModel and BetslipFloatingViewModel require complex state management

### Useful Files / Links
- [ButtonViewModel](../App/ViewModels/ButtonViewModel.swift) - Factory methods for common button types
- [WalletStatusViewModel](../App/ViewModels/WalletStatusViewModel.swift) - Uses concrete ButtonViewModel implementations  
- [RootTabBarViewModel](../App/Screens/Root/RootTabBarViewModel.swift) - Contains 3 critical mock dependencies (lines 50-52)
- [AdaptiveTabBarViewModelProtocol](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/AdaptiveTabBarView/AdaptiveTabBarViewModelProtocol.swift) - Complex navigation state management
- [FloatingOverlayViewModelProtocol](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/FloatingOverlay/FloatingOverlayViewModelProtocol.swift) - Simple overlay state management
- [BetslipFloatingViewModelProtocol](../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipFloatingView/BetslipFloatingViewModelProtocol.swift) - Complex betting state integration

### Key Research Findings

#### Critical Infrastructure Anti-Patterns Identified:
- **RootTabBarViewModel**: MockAdaptiveTabBarViewModel, MockFloatingOverlayViewModel, MockBetslipFloatingViewModel
- **Navigation Systems**: MockQuickLinksTabBarViewModel (4 different screens)  
- **Filter Architecture**: MockGeneralFilterBarViewModel + 4 specialized filter mocks
- **Business Components**: MockScoreViewModel, MockOddsAcceptanceViewModel, MockThemeSwitcherViewModel

#### Implementation Complexity Assessment:
- **MEDIUM Complexity**: FloatingOverlayViewModel (simple state), QuickLinksTabBarViewModel (static content)
- **HIGH Complexity**: AdaptiveTabBarViewModel (complex navigation), BetslipFloatingViewModel (betting integration), Filter System (API-driven dynamic creation)

#### Protocol Requirements Documented:
- All critical protocols analyzed with data structures, publisher requirements, and callback patterns
- Dependency patterns mapped (e.g., BetslipFloatingViewModel integrates with Env.betslipManager.bettingTicketsPublisher)
- Usage contexts identified across multiple view models and coordinators

### Next Steps
1. **Phase 1 Implementation** (Week 1): Create FloatingOverlayViewModel and QuickLinksTabBarViewModel concrete implementations
2. **Phase 2 Implementation** (Week 2-3): Tackle AdaptiveTabBarViewModel and BetslipFloatingViewModel complex state management
3. **Phase 3 Implementation** (Week 4-5): Implement GeneralFilterBarViewModel and specialized filter components
4. **Follow established pattern**: Create protocol-based concrete implementations maintaining exact same interfaces
5. **Update RootTabBarViewModel constructor**: Remove mock defaults and inject concrete implementations

### Current Status
✅ **Wallet Display Issue**: Completely resolved with concrete MultiWidgetToolbarViewModel, WalletStatusViewModel, and ButtonViewModel implementations
✅ **Research Phase**: Comprehensive analysis completed, roadmap established
🚀 **Next**: Begin systematic refactoring following proven pattern, starting with foundational components

**Total Mock ViewModels Identified**: 15+ GomaUI mocks + multiple local mocks
**Estimated Refactoring Effort**: 15-24 days across 3 phases
**Architecture Impact**: Will eliminate production dependency on GomaUI testing infrastructure