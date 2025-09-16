## Date
11 September 2025

### Project / Branch
sportsbook-ios / rr/deposit

### Goals for this session
- Debug BetssonCameroonApp stuck on splash screen
- Add strategic logging to understand initialization flow
- Implement proper error handling for maintenance mode scenarios
- Replace hardcoded operator ID with dynamic discovery

### Achievements
- [x] Added comprehensive logging throughout app initialization flow (AppDelegate → Bootstrap → AppStateManager → AppCoordinator)
- [x] Identified root cause: EveryMatrix staging server in maintenance mode causing WAMP subscription hang
- [x] Confirmed issue using cWAMP tool - server returning "We're sorry, our system is in maintenance now"
- [x] Implemented health check system with `checkServicesHealth()` method across provider chain
- [x] Added `maintenanceMode(message: String)` error case to ServiceProviderError
- [x] Created dynamic operator ID discovery replacing hardcoded "4093" value
- [x] Fixed compilation errors by implementing proper dependency injection pattern
- [x] Eliminated singleton anti-pattern (`.shared`) throughout EveryMatrix components

### Issues / Bugs Hit
- [x] App hanging indefinitely on splash screen during EveryMatrix maintenance periods
- [x] WAMP subscriptions don't receive error callbacks during server maintenance (only RPC calls do)
- [x] Hardcoded operator ID "4093" preventing multi-client flexibility
- [x] Compilation errors from `EveryMatrixSessionCoordinator.shared` usage after refactoring

### Key Decisions
- **Health check before subscription**: Implemented RPC-based health check that properly receives maintenance errors before attempting subscriptions
- **Dynamic operator ID discovery**: Health check extracts operator ID from `/sports#operatorInfo` response and stores it in session coordinator
- **Dependency injection over singletons**: Replaced all `.shared` usage with proper constructor-based dependency injection following MVVM-C pattern
- **Error propagation to UI layer**: Maintenance mode errors now bubble up through the service provider chain to enable user-friendly error messages

### Experiments & Notes
- **RPC vs Subscription behavior**: RPC calls receive proper error responses during maintenance, but subscriptions hang without callbacks
- **cWAMP tool validation**: Confirmed web tools and command-line tools can detect maintenance mode while iOS subscriptions cannot
- **Architecture patterns**: Successfully implemented dependency injection maintaining testability and avoiding singleton anti-patterns

### Useful Files / Links
- [AppStateManager.swift](../../BetssonCameroonApp/App/Managers/AppStateManager.swift) - Central state management with health check integration
- [EveryMatrixProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixProvider.swift) - Health check implementation and operator ID discovery
- [EveryMatrixSessionCoordinator.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Managers/EveryMatrixSessionCoordinator.swift) - Operator ID storage and session management
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift) - Dependency injection implementation
- [cWAMP Tool Documentation](../../tools/wamp-client/) - WebSocket WAMP debugging tool
- [ServiceProviderError.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Errors.swift) - Maintenance mode error handling

### Next Steps
1. Test the complete fix on device/simulator during next EveryMatrix maintenance window
2. Implement user-friendly maintenance mode UI in splash screen coordinator
3. Consider adding retry mechanism with exponential backoff for health checks
4. Document the health check pattern for other provider implementations (SportRadar, Goma)
5. Add unit tests for maintenance mode scenarios and operator ID discovery