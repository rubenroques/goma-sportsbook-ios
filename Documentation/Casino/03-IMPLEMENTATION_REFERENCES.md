# Casino Implementation - Essential References

## Overview
This document provides a comprehensive reference guide to all files, documentation, classes, and patterns that must be understood before implementing the next phases of the casino feature. Use this as a checklist to ensure you have the proper context.

---

## 🎯 Before Starting Next Tasks - Must Read

### **Critical Foundation Files Created**
These files establish the architecture and patterns you must follow:

#### **1. Casino Public Models** (`/ServicesProvider/Models/Casino/`)
- 📁 `CasinoCategory.swift` - Category structure, games count handling
- 📁 `CasinoGame.swift` - Complete game model with all properties
- 📁 `CasinoGameVendor.swift` - Provider information structure
- 📁 `CasinoGameMode.swift` - Launch modes enum and restrictions
- 📁 `CasinoPagination.swift` - Pagination utilities and responses
- 📁 `CasinoError.swift` - Error handling and conversion methods

#### **2. CasinoProvider Protocol** (`/ServicesProvider/Protocols/`)
- 📁 `CasinoProvider.swift` - **CRITICAL**: All methods you must implement
  - Core API methods signatures
  - Game launch URL building requirements
  - Helper method implementations
  - Default implementations and extensions

#### **3. EveryMatrix DTOs** (`/Providers/Everymatrix/Models/DataTransferObjects/Casino/`)
- 📁 `CasinoCategoryDTO.swift` - API response structure for categories
- 📁 `CasinoGameDTO.swift` - **COMPLEX**: Game response with nested objects
- 📁 `CasinoRecentlyPlayedDTO.swift` - Recently played wrapper structure

#### **4. EveryMatrix Mappers** (`/Providers/Everymatrix/Models/Mappers/Casino/`)
- 📁 `EveryMatrixCasinoMapper.swift` - **REFERENCE**: DTO→Model conversion patterns
  - Tag extraction from href URLs
  - Vendor mapping with fallbacks
  - Optional field handling strategies

---

## 📚 Documentation References

### **Casino-Specific Documentation**
- 📄 `Documentation/Casino/00-CASINO_IMPLEMENTATION_JOURNAL.md` - Progress tracking and decisions
- 📄 `Documentation/Casino/01-API_INVESTIGATION.md` - **ESSENTIAL**: Actual API responses
- 📄 `Documentation/Casino/02-NEXT_STEPS_DETAILED.md` - Task breakdown and dependencies

### **Web Implementation References** (External)
- 📄 `/Users/rroques/Desktop/GOMA/Web/sportsbook-frontend/sportsbook-frontend-demo/DocFeatureExtraction/Casino/CASINO_API_SPECIFICATION.md`
- 📄 `/Users/rroques/Desktop/GOMA/Web/sportsbook-frontend/sportsbook-frontend-demo/DocFeatureExtraction/Casino/CASINO_STATE_ARCHITECTURE.md`
- 📄 `/Users/rroques/Desktop/GOMA/Web/sportsbook-frontend/sportsbook-frontend-demo/DocFeatureExtraction/Casino/CASINO_GAME_INTEGRATION.md`

---

## 🏗️ Existing ServicesProvider Architecture References

### **Current Provider Implementations** (Study Patterns)

#### **EveryMatrix Sports Provider** (Pattern Reference)
- 📁 `Providers/Everymatrix/EveryMatrixProvider.swift`
  - **Study**: Constructor pattern with connector dependency
  - **Study**: Connection state delegation
  - **Study**: Manager instantiation patterns

- 📁 `Providers/Everymatrix/EveryMatrixConnector.swift`
  - **Study**: WAMP connection management (casino uses REST instead)
  - **Study**: Connection state publisher pattern
  - **Study**: Error handling and reconnection logic

#### **EveryMatrix Player API** (Authentication Patterns)
- 📁 `Providers/Everymatrix/PlayerAPI/EveryMatrixPlayerAPI.swift`
  - **Study**: Endpoint enum pattern
  - **Study**: URL construction methods
  - **Study**: Parameter handling

- 📁 `Providers/Everymatrix/PlayerAPI/EveryMatrixPlayerAPIConnector.swift`
  - **Study**: REST-based connector pattern (**IMPORTANT**: Casino will use similar)
  - **Study**: Session management
  - **Study**: Request/response handling

- 📁 `Providers/Everymatrix/Managers/EveryMatrixPrivilegedAccessManager.swift`
  - **Study**: API client usage patterns
  - **Study**: Error handling and mapping
  - **Study**: Publisher return patterns

### **Main Client Integration** (Integration Patterns)
- 📁 `ServicesProvider/Sources/ServicesProvider/Client.swift`
  - **Study**: Provider initialization in `connect()` method (lines 70-176)
  - **Study**: Provider property declarations (lines 24-34)
  - **Study**: Public method delegation patterns (lines 200+)
  - **Study**: Connection state management
  - **Study**: Error handling patterns

### **Model Mapping Patterns**
- 📁 `Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper.swift`
  - **Study**: Base mapper structure and patterns
  - **Study**: Extension organization
  - **Study**: Error handling in mapping

- 📁 `Providers/Everymatrix/Models/Mappers/EveryMatrixModelMapper+Events.swift`
  - **Study**: Complex object mapping patterns
  - **Study**: Optional field handling
  - **Study**: Array mapping techniques

---

## 🔍 Key Code Patterns to Follow

### **1. Endpoint Definition Pattern**
**Reference**: `Providers/Everymatrix/PlayerAPI/EveryMatrixPlayerAPI.swift`
```swift
enum EveryMatrixPlayerAPI {
    case login(username: String, password: String)
    case getRegistrationConfig
    // ... more cases
}

extension EveryMatrixPlayerAPI: Endpoint {
    var url: String { /* base URL */ }
    var endpoint: String { /* path construction */ }
    var method: HTTPMethod { /* method */ }
    // ... more properties
}
```

### **2. Connector Pattern**
**Reference**: `Providers/Everymatrix/PlayerAPI/EveryMatrixPlayerAPIConnector.swift`
```swift
class EveryMatrixPlayerAPIConnector: Connector {
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never>
    
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError>
    // Implementation details
}
```

### **3. Provider Implementation Pattern**
**Reference**: `Providers/Everymatrix/Managers/EveryMatrixPrivilegedAccessManager.swift`
```swift
class EveryMatrixPrivilegedAccessManager: PrivilegedAccessManagerProvider {
    var connector: EveryMatrixPlayerAPIConnector
    
    func someMethod() -> AnyPublisher<SomeType, ServiceProviderError> {
        let endpoint = EveryMatrixPlayerAPI.someEndpoint
        let publisher: AnyPublisher<DTO, ServiceProviderError> = self.connector.request(endpoint)
        
        return publisher.flatMap { dto -> AnyPublisher<PublicModel, ServiceProviderError> in
            let mapped = Mapper.map(dto)
            return Just(mapped).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
```

### **4. Client Integration Pattern**
**Reference**: `Client.swift` lines 70-176
```swift
public class Client {
    private var someProvider: (any SomeProvider)?
    
    public func connect() {
        switch self.providerType {
        case .everymatrix:
            let connector = SomeConnector()
            self.someProvider = SomeProviderImplementation(connector: connector)
        }
    }
    
    public func somePublicMethod() -> AnyPublisher<SomeType, ServiceProviderError> {
        guard let provider = self.someProvider else {
            return Fail(error: ServiceProviderError.providerNotFound).eraseToAnyPublisher()
        }
        return provider.someMethod()
    }
}
```

---

## 🌐 API Response Analysis

### **Critical API Endpoints** (From Investigation)
**Reference**: `Documentation/Casino/01-API_INVESTIGATION.md`

#### **1. Categories Endpoint**
```bash
curl "https://betsson-api.stage.norway.everymatrix.com/v1/casino/categories?language=en&platform=PC&pagination=offset=0,games(offset=0,limit=0)&fields=id,name,href,games"
```
**Key Response Structure**:
- Root: `count`, `total`, `items[]`, `pages{}`
- Items: `id`, `name`, `href`, `games.total`
- **Filter Rule**: Only show categories where `games.total > 0`

#### **2. Games Endpoint**
```bash
curl "https://betsson-api.stage.norway.everymatrix.com/v1/casino/games?language=en&platform=PC&pagination=offset=0,limit=5&expand=vendor&filter=categories(id=VIDEOSLOTS)&sortedField=popularity"
```
**Key Response Structure**:
- Complex nested objects: `vendor{}`, `tags{}`, `categories{}`, `jackpots{}`
- Multiple image URLs: `thumbnail`, `backgroundImageUrl`, `icons{}`
- Platform array: `["PC", "iPad", "iPhone", "Android"]`
- **Template Variables**: `categories(id={{categoryId}})`

#### **3. Recently Played Structure**
**Expected Response**:
- Wrapper object: `gameModel: { /* game object */ }`
- **Authentication Required**: sessionId + user ID
- **Fallback**: Return empty array if not authenticated

---

## 🔧 Configuration References

### **Environment Configuration Pattern**
**Reference**: `Providers/Everymatrix/PlayerAPI/EveryMatrixPlayerAPIEnvironment.swift`
```swift
enum EveryMatrixPlayerAPIEnvironment {
    case staging
    case production
    
    var baseURL: String {
        switch self {
        case .staging: return "https://api-stage.example.com"
        case .production: return "https://api.example.com"
        }
    }
}
```

### **Casino-Specific Configuration Needs**
- **Base URL**: `https://betsson-api.stage.norway.everymatrix.com`
- **Platform Parameter**: Change from `PC` to `iOS` for mobile
- **Required Parameters**: `language`, `platform`, `pagination`, `fields`
- **Template Variables**: `{{categoryId}}`, `{{gameId}}`, `{{playerId}}`

---

## 🧪 Testing References

### **Existing Test Patterns**
**Study These Test Files**:
- 📁 `Tests/ServicesProviderTests/` - General test structure
- Look for existing provider test patterns
- Study mock connector implementations
- Review test data setup patterns

### **Test Data from API Investigation**
**Reference**: `Documentation/Casino/01-API_INVESTIGATION.md`
- Real API responses for mocking
- Edge cases (empty categories, missing fields)
- Authentication scenarios

---

## ⚠️ Critical Implementation Notes

### **1. Authentication Handling**
- **Session Cookie**: `sessionId` required for authenticated endpoints
- **User ID**: Required for recently played games
- **Fallback Strategy**: Guest mode for unauthenticated users
- **Error Handling**: Invalid/expired session scenarios

### **2. Template Variable Replacement**
- **Categories Filter**: `categories(id={{categoryId}})`
- **Game Filter**: `id={{gameId}}`
- **Player Endpoint**: `/v1/player/{{playerId}}/games/last-played`
- **Implementation**: URL string replacement before request

### **3. Platform Parameter Adaptation**
- **Web**: `platform=PC`
- **Mobile**: `platform=iOS` (needs testing)
- **Impact**: May affect available games or response format

### **4. Image URL Handling**
- **Relative URLs**: Many start with `//static.everymatrix.com`
- **Multiple Sizes**: `icons` object has different size keys
- **Fallback Strategy**: `thumbnail` → `defaultThumbnail` → empty string

### **5. Pagination Logic**
- **HasMore Calculation**: Check for `next` URL in `pages` object
- **Offset Calculation**: `currentOffset + limit`
- **Total Items**: Use for progress indicators

---

## 📋 Pre-Implementation Checklist

Before starting the next implementation phase, ensure you have:

### **Understanding Verification**
- [ ] Read all casino public models and understand their structure
- [ ] Studied CasinoProvider protocol and all required methods
- [ ] Analyzed EveryMatrix DTOs and their optional field patterns
- [ ] Reviewed mapper implementations and transformation logic
- [ ] Understood API response structures from investigation

### **Pattern Comprehension**
- [ ] Studied existing EveryMatrix provider implementations
- [ ] Reviewed REST connector patterns (PlayerAPI)
- [ ] Understood Client integration patterns
- [ ] Analyzed endpoint definition patterns
- [ ] Reviewed error handling and mapping patterns

### **API Knowledge**
- [ ] Tested casino API endpoints with cURL
- [ ] Understood authentication requirements
- [ ] Identified template variable replacement needs
- [ ] Analyzed platform parameter requirements
- [ ] Understood pagination mechanics

### **Configuration Planning**
- [ ] Identified environment configuration needs
- [ ] Understood base URL requirements
- [ ] Planned parameter mapping strategies
- [ ] Considered mobile-specific adaptations

This comprehensive reference ensures you have all the context needed to implement the casino feature correctly and consistently with existing patterns.