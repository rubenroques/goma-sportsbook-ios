## Date
16 June 2025

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Investigate production ViewModel protocol implementations for OutcomeItemView, MarketOutcomesLineView, and MarketOutcomesMultiLineView
- Understand data flow from Env.servicesProvider through UI components
- Verify protocol conformance after recent OutcomeItemViewModel refactor
- Document the complete ViewModel architecture with Mermaid diagrams

### Achievements
- [x] Completed deep investigation of all ViewModel protocol implementations
- [x] Traced complete data flow from ServicesProvider → ViewModels → UI
- [x] Identified critical performance issue: MarketGroupCardsViewModel recreates entire ViewModel hierarchy every 1-5 seconds
- [x] Created comprehensive Mermaid diagrams documenting:
  - High-level architecture overview
  - Real-time subscription chain
  - ViewModel hierarchy & factory patterns
  - Data transformation pipeline
  - ViewModel creation vs recreation analysis
  - Complete function reference for all recreation triggers
- [x] Discovered OutcomeItemViewModel missing new unified state management features from protocol refactor
- [x] Fixed Mermaid syntax errors for HackMD compatibility

### Issues / Bugs Hit
- [ ] **CRITICAL PERFORMANCE**: MarketGroupCardsViewModel.updateMatches() recreates ALL child ViewModels on every market update (1-5 sec frequency)
- [ ] **PROTOCOL COMPLIANCE**: OutcomeItemViewModel missing displayStatePublisher and unified state actions (setDisplayState, setLoading, setLocked, setUnavailable, setBoosted)
- [ ] No caching mechanism in MarketGroupCardsViewModel despite ViewModelCache infrastructure being available
- [ ] Memory churn from constant ViewModel recreation and subscription re-establishment

### Key Decisions
- Documented all ViewModel recreation triggers with exact file locations and line numbers
- Identified MarketOutcomesLineViewModel.updateOutcomeViewModels() as best practice example (smart diffing)
- Recommended implementing ViewModelCache<String, TallOddsMatchCardViewModel> in MarketGroupCardsViewModel
- Created comprehensive documentation for new developer onboarding

### Experiments & Notes
- Found that real-time data flows through 3 subscription layers:
  1. InPlayEventsViewModel: subscribeLiveMatches()
  2. MarketOutcomesLineViewModel: subscribeToEventOnListsMarketUpdates()
  3. OutcomeItemViewModel: subscribeToEventOnListsOutcomeUpdates()
- Discovered ServiceProviderModelMapper handles all data transformations
- Identified recreation cascade: single updateMatches() call recreates 6+ levels of ViewModel hierarchy
- Good patterns exist in codebase (smart diffing in MarketOutcomesLineViewModel) but not consistently applied

### Useful Files / Links
- [OutcomeItemViewModel](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Core/ViewModels/OutcomeItemViewModel.swift)
- [MarketOutcomesLineViewModel](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Core/ViewModels/MarketOutcomesLineViewModel.swift)
- [MarketGroupCardsViewModel](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Core/Screens/NextUpEvents/MarketGroupCardsViewModel.swift)
- [InPlayEventsViewModel](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Core/Screens/InPlayEvents/InPlayEventsViewModel.swift)
- [Complete Data Flow Diagrams](/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios-data-flow-diagrams.md)

### Next Steps
1. **PRIORITY**: Fix MarketGroupCardsViewModel recreation pattern - implement caching mechanism
2. Update OutcomeItemViewModel to implement missing protocol requirements (displayStatePublisher, unified state actions)
3. Create updateWithNewData() method for TallOddsMatchCardViewModel to enable reuse instead of recreation
4. Implement diffing algorithm in createMatchCardData() before recreating ViewModels
5. Monitor performance improvements after implementing caching
6. Consider creating a ViewModel lifecycle best practices guide based on findings