## Date
13 January 2026

### Project / Branch
sportsbook-ios / wip/manual-distribute-refactor

### Goals for this session
- Research New Relic iOS integration capabilities
- Understand what reports/dashboards New Relic generates for mobile apps
- Brainstorm how to maximize New Relic subscription value from iOS perspective
- Create comprehensive documentation for the team

### Achievements
- [x] Researched New Relic iOS SDK capabilities via official documentation
- [x] Identified existing New Relic integration in BetssonCameroonApp (basic `start()` call in AppDelegate)
- [x] Discovered GomaPerformanceKit's pluggable destination architecture - ideal for New Relic bridge
- [x] Created comprehensive guide: `Documentation/NEW_RELIC_IOS_GUIDE.md` (~600 lines)
- [x] Documented all key APIs: `recordCustomEvent`, `recordBreadcrumb`, `recordError`, `startInteraction`, `setUserId`, `setAttribute`, `noticeNetworkRequest`, `noticeNetworkFailure`
- [x] Included 15+ ready-to-use NRQL queries for dashboards
- [x] Added sports-betting contextualized code examples (bet placement, deposits, WebSocket tracking)

### Issues / Bugs Hit
- None - research and documentation session

### Key Decisions
- Document focused on "maximizing value" rather than installation/setup (user-directed)
- Prioritized network observability, performance tracking, and action-based events (user priorities)
- All code examples use sports-betting context for immediate applicability
- Included WebSocket/WAMP tracking patterns for EveryMatrix real-time connections

### Experiments & Notes
- Current integration is minimal: just `NewRelic.start(withApplicationToken:)` in AppDelegate:30
- GomaPerformanceKit's `PerformanceDestination` protocol is perfect for creating a `NewRelicPerformanceDestination`
- This would unify local performance tracking with New Relic dashboards
- Distributed tracing (iOS 7.3.0+) enables mobile-to-backend correlation

### Useful Files / Links
- [NEW_RELIC_IOS_GUIDE.md](../NEW_RELIC_IOS_GUIDE.md) - The comprehensive guide created this session
- [AppDelegate.swift](../../BetssonCameroonApp/App/Boot/AppDelegate.swift) - Current New Relic initialization
- [PerformanceTracker.swift](../../Frameworks/GomaPerformanceKit/Sources/GomaPerformanceKit/PerformanceTracker.swift) - Existing performance tracking
- [PerformanceDestination.swift](../../Frameworks/GomaPerformanceKit/Sources/GomaPerformanceKit/Destinations/PerformanceDestination.swift) - Protocol for New Relic bridge
- [New Relic iOS Docs](https://docs.newrelic.com/docs/mobile-monitoring/new-relic-mobile-ios/get-started/introduction-new-relic-mobile-ios/)
- [New Relic Best Practices](https://docs.newrelic.com/docs/new-relic-solutions/best-practices-guides/full-stack-observability/mobile-monitoring-best-practices-guide/)

### Next Steps
1. Create `NewRelicPerformanceDestination` to bridge GomaPerformanceKit → New Relic
2. Add `setUserId()` call on user login for session correlation
3. Configure dSYM upload in CI/CD for crash symbolication
4. Implement breadcrumbs at critical navigation points (bet slip, checkout, deposit)
5. Create initial NRQL dashboards in New Relic UI
6. Set up critical alerts (crash rate spike, API degradation)
