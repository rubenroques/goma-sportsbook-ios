## Date
16 October 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Deep dive into EveryMatrix provider architecture
- Understand connector refactor plan and create phase documentation
- Create comprehensive CLAUDE.md for EveryMatrix provider folder

### Achievements
- [x] Comprehensive exploration of EveryMatrix architecture (WAMP, EntityStore, Builders, Mappers)
- [x] Created 4-phase migration plan for connector refactor (Documentation/Features/EveryMatrixConnectorRefactor/)
  - Phase 1: Extract authentication strategy pattern
  - Phase 2: Introduce unified connector (additive only)
  - Phase 3: Gradual provider migration with feature flags
  - Phase 4: Legacy cleanup
- [x] Documented complete testing strategy across all phases
- [x] Created CLAUDE.md for EveryMatrix provider (556 lines)
- [x] Clarified critical distinction between WebSocket vs REST data flows

### Issues / Bugs Hit
- None - this was an architectural documentation and planning session

### Key Decisions

**1. Connector Refactor Strategy**
- Keep EveryMatrixBaseConnector intact (complex retry logic that works)
- Use composition over inheritance (wrapper pattern)
- Feature flags per API type for safe gradual rollout
- Migration order: Recsys → OddsMatrix → PlayerAPI → Casino (risk-based)

**2. Documentation Structure**
- Separate documentation file per phase (for independent LLM implementation)
- Complete file references with line numbers for each phase
- No code templates (LLMs generate their own implementations)
- Comprehensive testing requirements per phase

**3. CLAUDE.md Architecture Explanation**
- Two completely different data flows: WebSocket (4 layers) vs REST (2 layers)
- **Critical insight**: "DTO" term is EXCLUSIVE to WebSocket entities
- REST APIs send hierarchical data → no DTOs, no Builders, no EntityStore needed
- WebSocket sends normalized data → requires full 4-layer transformation

### Experiments & Notes

**EntityStore Architecture Discovery**:
- In-memory relational store with reactive publishers
- Change record system for delta updates (CREATE/UPDATE/DELETE)
- Property merging via JSON encoding for efficient partial updates
- Store isolation pattern for market groups (independent lifecycle)

**WAMP Protocol Patterns**:
- Initial dump + continuous updates pattern
- 60+ route definitions in WAMPRouter enum
- Subscription managers orchestrate complex multi-step flows
- EntityStore serves as temporary storage for RPC responses

**Model Transformation Pipeline**:
- WebSocket: DTO → Builder (EntityStore lookup) → Hierarchical Internal → Mapper → Domain
- REST: Internal Model (already hierarchical) → Mapper → Domain
- Builders exist ONLY because WebSocket sends flat, normalized data

**Why EveryMatrix Uses Two Protocols**:
- WebSocket (WAMP) for real-time sports data: Efficient for continuous odds updates
- REST for transactions: Betting, authentication, payments (one-time operations)
- Different teams built different APIs at different times

### Useful Files / Links

**Migration Documentation**:
- [Migration Overview](/Documentation/Features/EveryMatrixConnectorRefactor/00_OVERVIEW.md)
- [Phase 1: Auth Strategy](/Documentation/Features/EveryMatrixConnectorRefactor/PHASE_1_Auth_Strategy.md)
- [Phase 2: Unified Connector](/Documentation/Features/EveryMatrixConnectorRefactor/PHASE_2_Unified_Connector.md)
- [Phase 3: Provider Migration](/Documentation/Features/EveryMatrixConnectorRefactor/PHASE_3_Provider_Migration.md)
- [Phase 4: Legacy Cleanup](/Documentation/Features/EveryMatrixConnectorRefactor/PHASE_4_Legacy_Cleanup.md)
- [Testing Strategy](/Documentation/Features/EveryMatrixConnectorRefactor/TESTING_STRATEGY.md)

**Provider Documentation**:
- [EveryMatrix CLAUDE.md](/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CLAUDE.md)
- [Token Refresh Architecture](/Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Documentation/TokenRefreshArchitecture.md)

**Key Architecture Files**:
- EntityStore: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Store/EntityStore.swift`
- WAMPRouter: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Libs/WAMPClient/WAMPRouter.swift`
- Base Connector: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixBaseConnector.swift`
- Session Coordinator: `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/EveryMatrixSessionCoordinator.swift`

**Exploration Agent Findings**:
- 136 Swift files in EveryMatrix provider
- 14 DTO entity types (WebSocket only)
- 8 hierarchical internal models (Composed)
- 9 subscription managers
- 4 REST API connectors (OddsMatrix, PlayerAPI, CasinoAPI, RecsysAPI)

### Next Steps

**Connector Refactor Implementation** (when ready):
1. Implement Phase 1: Extract authentication strategies (1-2 days)
2. Implement Phase 2: Create unified connector alongside existing ones (2-3 days)
3. Implement Phase 3: Migrate providers with feature flags (3-5 days, staged rollout)
4. Implement Phase 4: Clean up legacy code after 1 week stability (1 day)

**Documentation Improvements**:
1. Consider trimming CLAUDE.md from 556 lines to ~300 lines if needed
2. Add concrete code examples to phase documentation if LLMs need them
3. Create visual architecture diagrams for WebSocket vs REST flows

**Testing Preparation**:
1. Set up staging environment access for integration tests
2. Prepare test credentials for all 4 APIs
3. Create monitoring dashboard for Phase 3 rollout metrics

**Knowledge Transfer**:
1. Share connector refactor plan with team for review
2. Validate migration timeline with stakeholders
3. Document rollback procedures for production deployment

---

## Session Summary

This session provided deep architectural understanding of the EveryMatrix provider, the most complex integration in the codebase. The hybrid WebSocket/REST architecture, 4-layer vs 2-layer model transformation, and EntityStore pattern are now fully documented.

Key deliverable: Complete 4-phase migration plan with independent LLM-executable documentation, enabling future refactoring without breaking production betting, authentication, or payment flows.

**Total Documentation Created**: ~3,600 lines across 7 files
**Critical Architectural Insight**: DTOs exist ONLY for WebSocket - REST APIs bypass that entire complexity
