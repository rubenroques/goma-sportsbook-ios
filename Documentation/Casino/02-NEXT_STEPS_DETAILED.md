# Casino Implementation - Detailed Next Steps

## Overview
This document provides a comprehensive, prioritized task list for completing the casino feature implementation. Each task includes specific deliverables, acceptance criteria, and estimated effort.

## Current Status
✅ **Foundation Complete (60%)**: Models, protocols, DTOs, mappers, API investigation  
🚧 **Implementation Phase**: API client, provider, integration  
⏳ **Testing Phase**: Unit tests, integration tests, validation

---

## Phase 2: Core Implementation (Weeks 2-3)

### Task 1: EveryMatrix Casino API Client
**Priority**: HIGH  
**Estimated Effort**: 4-6 hours  
**Dependencies**: Foundation complete

#### Subtasks:
1. **Create API Environment Configuration**
   - [ ] `EveryMatrixCasinoAPIEnvironment.swift`
   - [ ] Stage/Production base URLs
   - [ ] Platform parameter mapping (iOS vs PC)
   - [ ] Language locale handling

2. **Create Casino API Endpoints**
   - [ ] `EveryMatrixCasinoAPI.swift` enum with all endpoints
   - [ ] Template variable replacement system (`{{categoryId}}`, `{{gameId}}`, `{{playerId}}`)
   - [ ] Query parameter construction
   - [ ] URL encoding for complex filters

3. **Implement Request Building**
   - [ ] URL construction with base URL + endpoint + parameters
   - [ ] Query parameter serialization
   - [ ] Template variable substitution
   - [ ] Platform-specific parameter injection

#### Acceptance Criteria:
- [ ] All 4 endpoints properly constructed
- [ ] Template variables correctly replaced
- [ ] URL encoding handles special characters
- [ ] Platform parameters inject correctly
- [ ] Environment switching works (stage/prod)

#### Files to Create:
- `/Providers/Everymatrix/CasinoAPI/EveryMatrixCasinoAPI.swift`
- `/Providers/Everymatrix/CasinoAPI/EveryMatrixCasinoAPIEnvironment.swift`

---

### Task 2: EveryMatrix Casino Connector
**Priority**: HIGH  
**Estimated Effort**: 6-8 hours  
**Dependencies**: Task 1 complete

#### Subtasks:
1. **Create Casino Connector Class**
   - [ ] `EveryMatrixCasinoConnector.swift` implementing `Connector`
   - [ ] REST-based HTTP client (different from WAMP used for sports)
   - [ ] Session management and cookie handling
   - [ ] Connection state management

2. **Implement Session Handling**
   - [ ] SessionId cookie management
   - [ ] User ID extraction and validation
   - [ ] Authentication state tracking
   - [ ] Session timeout handling

3. **Add Request/Response Interceptors**
   - [ ] Request interceptor for session cookies
   - [ ] Response interceptor for error handling
   - [ ] Retry logic for network failures
   - [ ] Rate limiting handling

4. **Connection State Management**
   - [ ] Connection state publisher
   - [ ] Network reachability monitoring
   - [ ] Reconnection logic
   - [ ] Error state handling

#### Acceptance Criteria:
- [ ] HTTP requests work with proper session cookies
- [ ] Connection state accurately reflects API availability
- [ ] Authentication errors properly detected and handled
- [ ] Network failures trigger appropriate retry logic
- [ ] Rate limiting handled gracefully

#### Files to Create:
- `/Providers/Everymatrix/CasinoAPI/EveryMatrixCasinoConnector.swift`

---

### Task 3: EveryMatrix Casino Provider Implementation
**Priority**: HIGH  
**Estimated Effort**: 8-10 hours  
**Dependencies**: Tasks 1, 2 complete

#### Subtasks:
1. **Create Provider Class**
   - [ ] `EveryMatrixCasinoProvider.swift` implementing `CasinoProvider`
   - [ ] Constructor with connector dependency
   - [ ] Connection state delegation

2. **Implement Core API Methods**
   - [ ] `getCasinoCategories()` with category filtering
   - [ ] `getGamesByCategory()` with pagination
   - [ ] `getGameDetails()` with single game lookup
   - [ ] `getRecentlyPlayedGames()` with authentication check

3. **Add Data Processing**
   - [ ] API response to DTO parsing
   - [ ] DTO to public model mapping
   - [ ] Error handling and conversion
   - [ ] Data validation and sanitization

4. **Implement Game Launch Logic**
   - [ ] `buildGameLaunchUrl()` with mode handling
   - [ ] Session parameter injection
   - [ ] Language parameter handling
   - [ ] Platform-specific URL construction

5. **Add Helper Methods**
   - [ ] `filterCategoriesWithGames()` implementation
   - [ ] `supportsGameMode()` validation
   - [ ] Authentication requirement checking

#### Acceptance Criteria:
- [ ] All CasinoProvider protocol methods implemented
- [ ] Category filtering removes empty categories
- [ ] Pagination works correctly with hasMore calculation
- [ ] Game launch URLs generated correctly for all modes
- [ ] Authentication properly validated for protected endpoints
- [ ] Errors mapped to appropriate CasinoError types

#### Files to Create:
- `/Providers/Everymatrix/EveryMatrixCasinoProvider.swift`

---

### Task 4: Client Integration
**Priority**: HIGH  
**Estimated Effort**: 4-6 hours  
**Dependencies**: Task 3 complete

#### Subtasks:
1. **Extend Client Class**
   - [ ] Add `casinoProvider: (any CasinoProvider)?` property
   - [ ] Initialize casino provider in `connect()` method
   - [ ] Add casino connection state publisher

2. **Add Public API Methods**
   - [ ] `getCasinoCategories()` delegation
   - [ ] `getGamesByCategory()` delegation  
   - [ ] `getGameDetails()` delegation
   - [ ] `getRecentlyPlayedGames()` delegation
   - [ ] `buildGameLaunchUrl()` delegation

3. **Error Handling Integration**
   - [ ] Add casino errors to `ServiceProviderError`
   - [ ] Proper error conversion and propagation
   - [ ] Fallback handling for missing provider

4. **Configuration Updates**
   - [ ] Add casino base URL to configuration
   - [ ] Platform parameter configuration
   - [ ] Language/locale handling

#### Acceptance Criteria:
- [ ] Client class exposes all casino functionality
- [ ] Provider initialization works for EveryMatrix
- [ ] Error handling consistent with existing patterns
- [ ] Connection state properly published
- [ ] Configuration supports casino-specific settings

#### Files to Modify:
- `/ServicesProvider/Sources/ServicesProvider/Client.swift`
- Configuration files for casino settings

---

## Phase 3: Testing & Validation (Week 4)

### Task 5: Unit Testing
**Priority**: MEDIUM  
**Estimated Effort**: 6-8 hours  
**Dependencies**: Core implementation complete

#### Subtasks:
1. **Model Tests**
   - [ ] Casino model serialization/deserialization
   - [ ] Pagination calculation logic
   - [ ] Game mode validation
   - [ ] Error type conversions

2. **Mapper Tests**
   - [ ] DTO to model mapping accuracy
   - [ ] Edge case handling (nil values, malformed data)
   - [ ] Tag extraction from href URLs
   - [ ] Vendor mapping with missing fields

3. **API Client Tests**
   - [ ] URL construction accuracy
   - [ ] Template variable replacement
   - [ ] Query parameter encoding
   - [ ] Platform parameter injection

4. **Provider Tests**
   - [ ] Mock connector integration
   - [ ] Response processing accuracy
   - [ ] Error handling scenarios
   - [ ] Authentication validation

#### Files to Create:
- `/Tests/ServicesProviderTests/Casino/` (directory with test files)

---

### Task 6: Integration Testing
**Priority**: MEDIUM  
**Estimated Effort**: 4-6 hours  
**Dependencies**: Unit tests complete

#### Subtasks:
1. **Live API Testing**
   - [ ] Test against actual EveryMatrix staging API
   - [ ] Validate all endpoint responses
   - [ ] Check authentication flows
   - [ ] Verify game launch URLs

2. **Error Scenario Testing**
   - [ ] Network failure handling
   - [ ] Invalid session scenarios
   - [ ] Rate limiting responses
   - [ ] Malformed API responses

3. **Performance Testing**
   - [ ] Large category responses
   - [ ] Pagination performance
   - [ ] Memory usage validation
   - [ ] Response time measurements

#### Files to Create:
- Integration test files with live API validation

---

## Phase 4: Advanced Features (Week 5)

### Task 7: Authentication Enhancement
**Priority**: MEDIUM  
**Estimated Effort**: 4-6 hours

#### Subtasks:
- [ ] Session validation before API calls
- [ ] Automatic session refresh handling
- [ ] Guest mode fallback logic
- [ ] User context integration

### Task 8: Caching Strategy
**Priority**: LOW  
**Estimated Effort**: 4-6 hours

#### Subtasks:
- [ ] Category caching implementation
- [ ] Game details caching
- [ ] Cache invalidation strategy
- [ ] Memory management

### Task 9: Platform Optimization
**Priority**: LOW  
**Estimated Effort**: 3-4 hours

#### Subtasks:
- [ ] iOS-specific platform parameters
- [ ] Mobile image optimization
- [ ] WebView launch URL optimization
- [ ] Network condition handling

---

## Task Dependencies

```
Phase 1 (Complete) → Phase 2 Tasks 1-4 → Phase 3 Tasks 5-6 → Phase 4 Tasks 7-9

Task 1 (API Client) → Task 2 (Connector) → Task 3 (Provider) → Task 4 (Integration)
                                                           ↓
                                         Task 5 (Unit Tests) → Task 6 (Integration Tests)
                                                           ↓
                                         Task 7-9 (Advanced Features)
```

---

## Risk Assessment & Mitigation

### High Risk Items:
1. **Authentication Requirements**: Recently played games need session validation
   - **Mitigation**: Implement comprehensive session management
   - **Fallback**: Graceful degradation to guest mode

2. **API Response Variations**: Optional fields may vary by environment
   - **Mitigation**: Extensive use of optionals in DTOs
   - **Testing**: Validate against multiple environments

3. **Game Launch URLs**: Platform-specific URL construction
   - **Mitigation**: Thorough testing of URL generation
   - **Validation**: Test actual game launches in WebView

### Medium Risk Items:
1. **Performance**: Large game catalogs may impact performance
   - **Mitigation**: Implement pagination and caching
   - **Monitoring**: Add performance metrics

2. **Network Reliability**: Mobile network conditions vary
   - **Mitigation**: Robust retry logic and offline handling
   - **UX**: Clear loading and error states

---

## Success Criteria

### Technical Success:
- [ ] All casino provider methods implemented and tested
- [ ] 95%+ unit test coverage
- [ ] Integration tests pass against live API
- [ ] Memory usage within acceptable limits
- [ ] Response times < 3 seconds average

### Functional Success:  
- [ ] Categories load and display correctly
- [ ] Games paginate properly
- [ ] Game details accessible
- [ ] Recently played works for authenticated users
- [ ] Game launch URLs generate correctly
- [ ] Error states handled gracefully

### Quality Success:
- [ ] Code follows existing ServicesProvider patterns
- [ ] Comprehensive documentation
- [ ] No breaking changes to existing functionality
- [ ] Performance regression tests pass

---

## Estimated Timeline

**Total Remaining Effort**: 30-40 hours  
**Timeline**: 3-4 weeks (assuming 10-12 hours/week)

- **Week 2**: Tasks 1-2 (API Client + Connector)
- **Week 3**: Tasks 3-4 (Provider + Integration)  
- **Week 4**: Tasks 5-6 (Testing + Validation)
- **Week 5**: Tasks 7-9 (Advanced Features) - Optional

This timeline accounts for testing, debugging, and documentation alongside implementation.