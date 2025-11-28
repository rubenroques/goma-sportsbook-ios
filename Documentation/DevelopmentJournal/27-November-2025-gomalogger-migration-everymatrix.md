## Date
27 November 2025

### Project / Branch
sportsbook-ios / rr/feature/SPOR-6622-new-casino-layout

### Goals for this session
- Migrate all print() statements in EveryMatrix provider to GomaLogger
- Use proper log levels (debug/info/error) and granular categories
- Remove all emojis from production logs per CLAUDE.md guidelines
- Phased approach by category: REST → WAMP → SSE → Providers → Parsing

### Achievements
- [x] **Phase 1 (REST) - 2 files, ~56 prints:**
  - `EveryMatrixRESTConnector.swift` - migrated to category `EM_REST`
  - `EveryMatrixCasinoConnector.swift` - migrated to category `EM_REST_CASINO`
- [x] **Phase 2 (WAMP) - 4 files, ~116 prints:**
  - `WAMPManager.swift` - migrated ~95 prints to category `EM_WAMP`
  - `SSWampSession.swift` - migrated ~8 active prints to category `EM_WAMP`
  - `WebSocketSSWampTransport.swift` - migrated ~4 prints to category `EM_WAMP`
  - `EveryMatrixSocketConnector.swift` - migrated ~9 prints to category `EM_WAMP`

### Issues / Bugs Hit
- None encountered during migration

### Key Decisions
- **Granular categories:** `EM_REST`, `EM_REST_CASINO`, `EM_WAMP`, `EM_SSE`, etc.
- **Subsystems mapping:**
  - REST APIs → `.networking`
  - WAMP/WebSocket → `.realtime`
  - SSE streaming → `.realtime`
  - Betting → `.betting`
  - Authentication → `.authentication`
- **Log level guidelines:**
  - `.debug` - Request/response bodies, cURL commands, detailed state
  - `.info` - Connection lifecycle, subscription start/stop, important state changes
  - `.error` - HTTP errors (401/403/404), decoding failures, connection failures
- **Removed all emojis** from log messages per project guidelines

### Experiments & Notes
- GomaLogger only has 3 levels: `debug`, `info`, `error` (NO `.warning()`)
- Pattern: `GomaLogger.<level>(<subsystem>, category: "<CATEGORY>", "<message>")`
- Verbose logs (request/response bodies, cURL) kept at `.debug` level for filtering

### Useful Files / Links
- [GomaLogger Implementation](../../Frameworks/GomaLogger/Sources/GomaLogger/GomaLogger.swift)
- [EveryMatrixRESTConnector](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Connectors/EveryMatrixRESTConnector.swift)
- [EveryMatrixCasinoConnector](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/CasinoAPI/EveryMatrixCasinoConnector.swift)
- [WAMPManager](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/OddsMatrixSocketAPI/WAMPManager.swift)
- [Migration Plan](../../.claude/plans/snoopy-hatching-wall.md)

### Next Steps
1. **Phase 3 (SSE)** - 3 files, ~92 prints:
   - `UserInfoStreamManager.swift`
   - `EveryMatrixSSEConnector.swift`
   - `SSEEventHandlerAdapter.swift`
2. **Phase 4 (Providers)** - 9 files, ~115 prints:
   - `EveryMatrixEventsProvider.swift`
   - `SingleOutcomeSubscriptionManager.swift`
   - `EveryMatrixBettingProvider.swift`
   - Plus: CasinoProvider, PAMProvider, SessionCoordinator, Paginators, etc.
3. **Phase 5 (Parsing & Low-Volume)** - 11 files, ~69 prints:
   - ModelMappers, EntityStore, etc.
4. **Verify build compiles** after all migrations

### Progress Summary
| Phase | Status | Files | Prints |
|-------|--------|-------|--------|
| Phase 1 (REST) | Complete | 2 | ~56 |
| Phase 2 (WAMP) | Complete | 4 | ~116 |
| Phase 3 (SSE) | Pending | 3 | ~92 |
| Phase 4 (Providers) | Pending | 9 | ~115 |
| Phase 5 (Parsing) | Pending | 11 | ~69 |
| **Total** | **~36%** | **6/29** | **~172/476** |
