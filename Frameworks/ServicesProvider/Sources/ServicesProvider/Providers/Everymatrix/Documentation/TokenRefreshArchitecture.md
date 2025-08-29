# EveryMatrix Token Refresh Architecture

## Overview

This document describes the transparent token refresh mechanism implemented for the EveryMatrix provider, which automatically handles session expiration across all API clients (PlayerAPI, OddsMatrixAPI, and CasinoAPI).

## Problem Statement

EveryMatrix APIs return **403 Forbidden** errors (not 401) when sessions expire, requiring:
- Re-authentication via `/v1/player/legislation/login`
- Token distribution across multiple API clients
- Transparent retry without UI awareness
- Prevention of concurrent refresh attempts

## Architecture Components

### 1. EveryMatrixAuthenticator

**Purpose**: Centralized token management and refresh orchestration

**Key Features**:
- Thread-safe token storage using serial dispatch queue
- Shared refresh publisher prevents concurrent refresh attempts
- Credential storage for automatic re-authentication
- Automatic session distribution via SessionCoordinator

**Location**: `EveryMatrixAuthenticator.swift`

### 2. EveryMatrixBaseConnector

**Purpose**: Base class providing transparent retry logic for all API connectors

**Key Features**:
- Automatic retry on 401/403 errors using Combine's `tryCatch`
- Token injection into request headers
- API-specific header handling (e.g., Cookie for Casino API)
- Seamless request retry with refreshed tokens

**Location**: `EveryMatrixBaseConnector.swift`

### 3. API Connectors (Refactored)

All API connectors now inherit from `EveryMatrixBaseConnector`:
- `EveryMatrixPlayerAPIConnector`
- `EveryMatrixOddsMatrixAPIConnector`
- `EveryMatrixCasinoConnector`

Each maintains backward compatibility while leveraging base retry logic.

## Token Refresh Flow

```
1. Initial Request
   ├─> Check if authentication required
   ├─> Get valid token from authenticator
   ├─> Add auth headers
   └─> Make HTTP request

2. Error Detection
   ├─> Receive 403 Forbidden (or 401)
   └─> Trigger automatic retry

3. Token Refresh
   ├─> Force refresh via authenticator
   ├─> Re-authenticate with stored credentials
   ├─> Update session in all components
   └─> Return new token

4. Request Retry
   ├─> Add new token to headers
   ├─> Retry original request
   └─> Return response to caller

5. Transparent Delivery
   └─> UI/ViewModel receives data without awareness of refresh
```

## Implementation Details

### Thread Safety

```swift
private let queue = DispatchQueue(label: "EveryMatrixAuthenticator.\(UUID().uuidString)")

return queue.sync { [weak self] in
    // Thread-safe token operations
}
```

### Shared Refresh Publisher

Prevents multiple simultaneous refresh attempts:

```swift
if let publisher = self.refreshPublisher {
    // Return existing refresh operation
    return publisher
}

// Create new refresh operation
let publisher = performLogin(credentials: credentials)
    .share() // Share among multiple subscribers
    .handleEvents(receiveCompletion: { _ in
        self.refreshPublisher = nil // Clear on completion
    })
```

### Automatic Retry Logic

Using Combine's `tryCatch` for selective retry:

```swift
.tryCatch { error -> AnyPublisher<Data, Error> in
    guard let serviceError = error as? ServiceProviderError,
          (serviceError == .unauthorized || serviceError == .forbidden) else {
        throw error // Not auth error, propagate
    }
    
    // Force token refresh and retry
    return authenticator.publisherWithValidToken(forceRefresh: true)
        .flatMap { /* retry request with new token */ }
}
```

## Usage Example

### BettingProvider Making API Call

```swift
func getOpenBetsHistory() -> AnyPublisher<BettingHistory, ServiceProviderError> {
    let endpoint = EveryMatrixOddsMatrixAPI.getOpenBets(limit: 20)
    
    // Automatic token refresh happens transparently
    return connector.request(endpoint)
        .map { /* transform response */ }
        .eraseToAnyPublisher()
}
```

### Login Flow with Credential Storage

```swift
func login(username: String, password: String) -> AnyPublisher<UserProfile, ServiceProviderError> {
    // Store credentials for future refresh
    let credentials = EveryMatrixCredentials(username: username, password: password)
    sessionCoordinator.authenticator?.updateCredentials(credentials)
    
    // Perform login
    // ...
}
```

## Benefits

### For UI/ViewModels
- **Zero Configuration**: No authentication logic in UI layer
- **Seamless Experience**: No interruptions for token refresh
- **Error Simplification**: Only business errors surface to UI

### For System Reliability
- **Automatic Recovery**: Self-healing on session expiration
- **Concurrency Safe**: Thread-safe token management
- **Resource Efficient**: Shared refresh prevents redundant API calls

### For Development
- **Consistent Pattern**: All APIs use same retry mechanism
- **Backward Compatible**: Existing code continues to work
- **Testable**: Mock authenticator for testing scenarios

## Migration Notes

### For Existing Code

No changes required in ViewModels or UI code. The token refresh happens transparently.

### For New Features

Use the API connectors normally - token refresh is automatic:

```swift
connector.request(endpoint) // Automatic retry on 403
```

## Testing

### Mock Authenticator

```swift
class MockEveryMatrixAuthenticator: EveryMatrixAuthenticator {
    var shouldFailRefresh = false
    
    override func publisherWithValidToken(forceRefresh: Bool) -> AnyPublisher<EveryMatrixSessionResponse, Error> {
        if shouldFailRefresh {
            return Fail(error: ServiceProviderError.forbidden).eraseToAnyPublisher()
        }
        // Return mock session
    }
}
```

### Testing Scenarios

1. **Expired Session**: Force 403 response, verify automatic retry
2. **Concurrent Requests**: Multiple simultaneous 403s should share refresh
3. **Credential Invalid**: Verify proper error propagation
4. **Network Issues**: Ensure network errors aren't retried as auth errors

## Troubleshooting

### Common Issues

1. **Infinite Retry Loop**
   - Cause: Invalid credentials stored
   - Solution: Clear credentials on permanent auth failure

2. **Token Not Refreshing**
   - Cause: Credentials not stored on login
   - Solution: Ensure `updateCredentials()` called on successful login

3. **403 Not Triggering Refresh**
   - Cause: Using old connector without BaseConnector
   - Solution: Ensure all connectors inherit from EveryMatrixBaseConnector

## Future Enhancements

1. **Preemptive Refresh**: Refresh before token expiry using timestamp
2. **Refresh Token Support**: Use refresh tokens instead of credentials
3. **Exponential Backoff**: Add retry delays for network issues
4. **Token Persistence**: Keychain storage for app restart scenarios
5. **Analytics**: Track refresh frequency and success rates