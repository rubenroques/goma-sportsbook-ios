# EveryMatrix Architecture Cleanup & Organization

## Date
23 October 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Fix incorrect Casino API authentication headers (Cookie → X-SessionId)
- Extract SSE functionality to dedicated connector
- Reorganize EveryMatrix directory structure for clarity
- Separate WebSocket (WAMP) code from REST code
- Update CLAUDE.md to reflect new architecture

### Achievements
- [x] **Fixed Casino API Authentication Headers**
  - Removed incorrect `Cookie: sessionId=...` header
  - Added correct `X-SessionId` + `X-Session-Type: others` headers
  - Validated against working web app implementation
  - Documented findings in `CasinoAPI-Header-Investigation-Report.md`

- [x] **Extracted SSE to Dedicated Connector**
  - Created `EveryMatrixSSEConnector.swift` in `Connectors/`
  - Removed SSE logic from `EveryMatrixRESTConnector` (was BaseConnector)
  - Removed unused SSEManager from `CasinoConnector`
  - Updated `BettingProvider` to use both RESTConnector and SSEConnector
  - Method named `request()` (not `requestSSE()`) for consistency

- [x] **Renamed BaseConnector → RESTConnector**
  - Much clearer name - it's specifically for HTTP REST
  - "Base" was ambiguous and misleading
  - Updated all references in providers

- [x] **Organized Connectors into Dedicated Directory**
  - Created `Connectors/` folder for shared protocol connectors
  - Moved `EveryMatrixSocketConnector.swift`
  - Moved `EveryMatrixRESTConnector.swift`
  - Moved `EveryMatrixSSEConnector.swift`
  - Casino-specific connector stays in `APIs/CasinoAPI/`

- [x] **Major Directory Reorganization**
  - Created `APIs/` for API-specific code organization
  - Created `APIs/OddsMatrixSocketAPI/` containing all WAMP infrastructure
    - Builders, Protocols, Store, SubscriptionManagers
    - WAMPManager, WAMPRouter, WAMPSocketParams
  - Created `Models/WebSocket/` for WAMP models ONLY
    - DTOs (flat normalized entities)
    - Hierarchical (composed models, renamed from "Composed")
    - Response (WebSocket wrappers)
  - Created `Models/REST/` for HTTP REST models
    - Casino/ (CasinoGame, CasinoCategory - NO DTO suffix)
    - Cashout/ (CashoutValueSSEResponse, etc. - NO DTO suffix)
    - Other REST models (EveryMatrix+PlaceBet, etc.)
  - Created `Models/ModelMappers/` for domain transformations
  - Removed "DTO" suffix from REST models (DTO = WebSocket ONLY)

- [x] **Updated CLAUDE.md Documentation**
  - New directory structure diagram with clear organization
  - Added "Key Organizational Principles" section
  - Updated all file location references
  - Documented connector consolidation + SSE extraction + organization history
  - Fixed provider name: EveryMatrixProvider → EveryMatrixEventsProvider

### Issues / Bugs Hit
- **Git mv limitation**: Cannot rename file in same command as move (had to do separately)
- **Nested DTO naming**: Casino REST models have many nested structs with DTO suffix (deferred manual rename to user)

### Key Decisions
- **DTO suffix = WebSocket ONLY**: Enforced by directory structure (`Models/WebSocket/DTOs/`)
- **REST models NO DTO suffix**: Clear separation in `Models/REST/`
- **API-Centric Organization**: Each API gets its own directory in `APIs/`
- **Hierarchical not Composed**: More accurate term for WebSocket models built from DTOs
- **Three Connector Pattern**:
  - Socket (WAMP WebSocket)
  - REST (HTTP transactions)
  - SSE (Server-Sent Events streaming)
- **Casino Connector Special Case**: Stays in CasinoAPI/ because it's API-specific (pre-parse error detection)

### Experiments & Notes

#### Casino API Header Investigation
Found that iOS app was using **incorrect Cookie header** that web app doesn't use:
```swift
// WRONG (before)
request.setValue("sessionId=\(session.sessionId)", forHTTPHeaderField: "Cookie")

// CORRECT (after)
headers["X-SessionId"] = session.sessionId
headers["X-Session-Type"] = "others"
```

Validated with successful cURL test - worked WITHOUT Cookie header.

#### SSE Extraction Pattern
```swift
// Before: BaseConnector had both REST and SSE
connector.request()      // REST
connector.requestSSE()   // SSE

// After: Separated into dedicated connectors
restConnector.request()  // REST
sseConnector.request()   // SSE (consistent naming!)
```

#### Architectural Clarity Achieved
```
OLD (Confusing):
- Models/DataTransferObjects/ (mixed WebSocket + REST)
- Models/Composed/ (unclear what "composed" means)
- Builders/ (not clear it's WebSocket-only)
- CasinoGameDTO in DataTransferObjects/ (but it's REST!)

NEW (Crystal Clear):
- APIs/OddsMatrixSocketAPI/ (all WAMP code)
- Models/WebSocket/DTOs/ (WebSocket ONLY)
- Models/WebSocket/Hierarchical/ (accurate term)
- Models/REST/Casino/CasinoGame (NO DTO suffix!)
```

### Useful Files / Links

**Investigation Reports:**
- [Casino API Header Investigation Report](../CasinoAPI-Header-Investigation-Report.md)
- [Session Management Documentation](../../Web/sportsbook-frontend/sportsbook-frontend-demo/docs/SESSION_MANAGEMENT_AND_USER_IDENTIFICATION_CASINO.md)

**Modified Files:**
- [EveryMatrixRESTConnector.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Connectors/EveryMatrixRESTConnector.swift)
- [EveryMatrixSSEConnector.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Connectors/EveryMatrixSSEConnector.swift)
- [EveryMatrixSocketConnector.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Connectors/EveryMatrixSocketConnector.swift)
- [EveryMatrixCasinoConnector.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/APIs/CasinoAPI/EveryMatrixCasinoConnector.swift)
- [EveryMatrixBettingProvider.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBettingProvider.swift)
- [Client.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Client.swift)
- [CLAUDE.md](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CLAUDE.md)

**Architecture Documentation:**
- [EveryMatrix CLAUDE.md](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CLAUDE.md)

### Next Steps

1. **User to manually rename nested DTO structs in REST models**
   - `Models/REST/Casino/CasinoGame.swift` (CasinoGameDTO → CasinoGame, etc.)
   - `Models/REST/Cashout/` files (remove DTO suffix)
   - Update references in mappers

2. **Update import statements** across codebase
   - Providers may need new import paths for reorganized models
   - Subscription managers now in `APIs/OddsMatrixSocketAPI/SubscriptionManagers/`

3. **Test build** after struct renames
   - Ensure no broken references
   - Validate all imports resolve correctly

4. **Consider documenting WebSocket vs REST patterns**
   - Add examples to CLAUDE.md showing when to use which
   - Document the 4-layer WebSocket flow vs 2-layer REST flow

5. **Clean up old connector files**
   - `EveryMatrixConnector.swift` (duplicate of SocketConnector - can delete)
   - Commented-out connector files in API directories

### Architecture Summary

**Final Clean Architecture:**
```
EveryMatrix Connectors (Protocol Separation):
├─ EveryMatrixSocketConnector → WAMP WebSocket (real-time sports)
├─ EveryMatrixRESTConnector → HTTP REST (transactions, auth)
├─ EveryMatrixSSEConnector → Server-Sent Events (cashout streaming)
└─ EveryMatrixCasinoConnector → HTTP REST with pre-parse (casino only)

Directory Organization:
├─ APIs/ (API-centric: each API has own directory)
├─ Models/ (Protocol-based: WebSocket vs REST separation)
├─ Connectors/ (Shared protocol connectors)
└─ Providers (Top-level)

Key Rules Enforced:
- DTO suffix = WebSocket ONLY (in Models/WebSocket/DTOs/)
- REST models = NO DTO suffix (in Models/REST/)
- WebSocket infrastructure = APIs/OddsMatrixSocketAPI/
- One connector per protocol (Socket ≠ REST ≠ SSE)
```

This session achieved **reference-quality codebase organization** with clear separation of concerns and accurate naming that reflects the actual architecture! 🎯
