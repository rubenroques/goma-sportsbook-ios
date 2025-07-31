# Casino Implementation - Testing Requirements

## Files Requiring Unit Tests

### 1. **Core Models** (`/ServicesProvider/Models/Casino/`)
- [ ] `CasinoCategory.swift` - Category data model
- [ ] `CasinoGame.swift` - Game data model and CasinoGamesResponse
- [ ] `CasinoGameVendor.swift` - Vendor information model
- [ ] `CasinoGameMode.swift` - Game mode enum and related structs
- [ ] `CasinoPagination.swift` - Pagination utilities and response structures
- [ ] `CasinoError.swift` - Error handling and conversion

### 2. **Protocol Definition** (`/ServicesProvider/Protocols/`)
- [ ] `CasinoProvider.swift` - Protocol compliance and method signatures

### 3. **EveryMatrix DTOs** (`/Providers/Everymatrix/Models/DataTransferObjects/Casino/`)
- [ ] `CasinoCategoryDTO.swift` - API response structure
- [ ] `CasinoGameDTO.swift` - Complex game response with nested objects
- [ ] `CasinoRecentlyPlayedDTO.swift` - Recently played wrapper structure
- [ ] `CasinoCategoriesResponseDTO.swift` - Categories response wrapper
- [ ] `CasinoGamesResponseDTO.swift` - Games response wrapper
- [ ] `CasinoRecentlyPlayedResponseDTO.swift` - Recently played response wrapper

### 4. **EveryMatrix Mappers** (`/Providers/Everymatrix/Models/Mappers/`)
- [ ] `EveryMatrixModelMapper+Casino.swift` - DTO→Model conversion logic

### 5. **EveryMatrix API Layer** (`/Providers/Everymatrix/CasinoAPI/`)
- [ ] `EveryMatrixCasinoAPIEnvironment.swift` - Environment configuration
- [ ] `EveryMatrixCasinoAPI.swift` - Endpoint definitions and URL construction
- [ ] `EveryMatrixCasinoConnector.swift` - HTTP client and session management

### 6. **EveryMatrix Provider** (`/Providers/Everymatrix/`)
- [ ] `EveryMatrixCasinoProvider.swift` - Provider implementation

### 7. **Client Integration** (`/ServicesProvider/`)
- [ ] `Client.swift` (Casino methods section) - Public API methods

---

## Unit Test Categories

### **A. Model Tests**
```swift
// Test files to create:
- CasinoCategoryTests.swift
- CasinoGameTests.swift
- CasinoGameVendorTests.swift
- CasinoGameModeTests.swift
- CasinoPaginationTests.swift
- CasinoErrorTests.swift
```

**Test Coverage:**
- [ ] Codable serialization/deserialization
- [ ] Hashable and Equatable conformance
- [ ] Computed properties (hasMore, displayName, etc.)
- [ ] Initializer validation
- [ ] Edge cases with nil/empty values

### **B. DTO Tests**
```swift
// Test files to create:
- CasinoCategoryDTOTests.swift
- CasinoGameDTOTests.swift
- CasinoRecentlyPlayedDTOTests.swift
- CasinoResponseDTOTests.swift
```

**Test Coverage:**
- [ ] JSON parsing with real API responses
- [ ] Handling of optional fields
- [ ] Malformed JSON handling
- [ ] Nested object parsing
- [ ] Array parsing edge cases

### **C. Mapper Tests**
```swift
// Test files to create:
- EveryMatrixCasinoMapperTests.swift
```

**Test Coverage:**
- [ ] DTO to Model mapping accuracy
- [ ] Tag extraction from href URLs
- [ ] Vendor mapping with fallbacks
- [ ] Optional field handling strategies
- [ ] Array mapping with empty/nil arrays
- [ ] Complex nested object mapping

### **D. API Layer Tests**
```swift
// Test files to create:
- EveryMatrixCasinoAPITests.swift
- EveryMatrixCasinoAPIEnvironmentTests.swift
- EveryMatrixCasinoConnectorTests.swift
```

**Test Coverage:**
- [ ] URL construction accuracy
- [ ] Template variable replacement
- [ ] Query parameter encoding
- [ ] Platform parameter injection
- [ ] Environment switching (staging/production)
- [ ] HTTP request building
- [ ] Session cookie handling
- [ ] Error response handling
- [ ] Connection state management

### **E. Provider Tests**
```swift
// Test files to create:
- EveryMatrixCasinoProviderTests.swift
```

**Test Coverage:**
- [ ] All CasinoProvider protocol methods
- [ ] Parameter validation and defaults
- [ ] Authentication requirement handling
- [ ] Response processing accuracy
- [ ] Error handling scenarios
- [ ] Game mode support validation
- [ ] Category filtering logic
- [ ] URL launch construction

### **F. Client Integration Tests**
```swift
// Test files to create:
- ClientCasinoMethodsTests.swift
```

**Test Coverage:**
- [ ] Parameter passthrough accuracy
- [ ] Provider delegation
- [ ] Error propagation
- [ ] Optional parameter handling
- [ ] Method signature compliance

---

## Integration Test Categories

### **A. Live API Tests**
```swift
// Test files to create:
- CasinoAPIIntegrationTests.swift
```

**Test Coverage:**
- [ ] Categories endpoint with real API
- [ ] Games endpoint with real API
- [ ] Game details endpoint with real API
- [ ] Recently played endpoint (authenticated)
- [ ] Authentication flow validation
- [ ] Rate limiting handling
- [ ] Network failure scenarios

### **B. End-to-End Tests**
```swift
// Test files to create:
- CasinoE2ETests.swift
```

**Test Coverage:**
- [ ] Full flow: Categories → Games → Details → Launch URL
- [ ] Authentication state changes
- [ ] Pagination across multiple pages
- [ ] Game mode switching
- [ ] Error recovery scenarios

### **C. Performance Tests**
```swift
// Test files to create:
- CasinoPerformanceTests.swift
```

**Test Coverage:**
- [ ] Large category responses (500+ items)
- [ ] Pagination performance
- [ ] Memory usage validation
- [ ] Response time measurements
- [ ] Concurrent request handling

---

## Mock Data Requirements

### **JSON Test Files** (`/Tests/Resources/Casino/`)
- [ ] `categories_response.json` - Sample categories API response
- [ ] `games_response.json` - Sample games API response
- [ ] `game_details_response.json` - Sample game details response
- [ ] `recently_played_response.json` - Sample recently played response
- [ ] `empty_categories_response.json` - Edge case: no categories
- [ ] `empty_games_response.json` - Edge case: no games
- [ ] `malformed_response.json` - Error case: invalid JSON
- [ ] `partial_fields_response.json` - Edge case: missing optional fields

### **Mock Objects**
- [ ] `MockEveryMatrixCasinoConnector` - Network layer mock
- [ ] `MockCasinoProvider` - Provider protocol mock
- [ ] `CasinoTestHelpers` - Test data generation utilities

---

## Test Structure Organization

```
Tests/
├── ServicesProviderTests/
│   ├── Casino/
│   │   ├── Models/
│   │   │   ├── CasinoCategoryTests.swift
│   │   │   ├── CasinoGameTests.swift
│   │   │   └── ...
│   │   ├── DTOs/
│   │   │   ├── CasinoCategoryDTOTests.swift
│   │   │   └── ...
│   │   ├── Mappers/
│   │   │   └── EveryMatrixCasinoMapperTests.swift
│   │   ├── API/
│   │   │   ├── EveryMatrixCasinoAPITests.swift
│   │   │   └── EveryMatrixCasinoConnectorTests.swift
│   │   ├── Provider/
│   │   │   └── EveryMatrixCasinoProviderTests.swift
│   │   ├── Integration/
│   │   │   ├── CasinoAPIIntegrationTests.swift
│   │   │   └── CasinoE2ETests.swift
│   │   └── Performance/
│   │       └── CasinoPerformanceTests.swift
│   └── Resources/
│       └── Casino/
│           ├── categories_response.json
│           └── ...
```

---

## Priority Testing Order

### **Phase 1: Foundation (High Priority)**
1. Model tests (basic functionality)
2. DTO parsing tests (API contract validation)
3. Mapper tests (transformation accuracy)

### **Phase 2: Integration (Medium Priority)**
4. API layer tests (network functionality)
5. Provider tests (business logic)
6. Client tests (public API)

### **Phase 3: Validation (Low Priority)**
7. Integration tests (real API validation)
8. Performance tests (optimization validation)
9. E2E tests (complete flow validation)

---

## Success Criteria

- [ ] **95%+ code coverage** on all casino-related files
- [ ] **All unit tests pass** consistently
- [ ] **Integration tests pass** against staging API
- [ ] **Performance tests** meet benchmarks (<3s response time)
- [ ] **Zero memory leaks** in casino functionality
- [ ] **Error scenarios** properly handled and tested