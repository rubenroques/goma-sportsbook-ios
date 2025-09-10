# EveryMatrix WAMP Maintenance Mode Handling

## Issue Description

When the EveryMatrix staging server (`sportsapi-betsson-stage.everymatrix.com`) is in maintenance mode, the iOS app gets stuck on the splash screen. This happens because:

1. The WAMP WebSocket connection establishes successfully
2. The app attempts to subscribe to sports data via `swampSession.register()`
3. **The server doesn't respond to subscription registration attempts during maintenance**
4. The app waits indefinitely for a callback that never comes

## How Maintenance Mode Works

### RPC Calls (Working)
RPC calls properly return maintenance errors:
```json
{
  "error": "wamp.no.backend",
  "args": [],
  "kwargs": {
    "desc": "We're sorry, our system is in maintenance now.",
    "detail": null
  }
}
```

### Subscriptions (Broken)
- Registration attempts (`swampSession.register()`) are silently ignored
- No `onSuccess` or `onError` callbacks are triggered
- The app hangs waiting for a response

## Testing Maintenance Status

### Using cWAMP Tool
```bash
# From project root
cd Tools/wamp-client

# Test connection and check for maintenance
node bin/cwamp.js rpc --procedure "/sports#operatorInfo" --verbose --debug

# Expected maintenance response:
# {
#   "error": "wamp.no.backend",
#   "kwargs": {
#     "desc": "We're sorry, our system is in maintenance now."
#   }
# }
```

### Using Web Tools
The EveryMatrix web testing tools show maintenance messages clearly for all RPC calls.

## Proposed Solution

### 1. Health Check with OperatorInfo

**IMPORTANT**: Use `/sports#operatorInfo` as the health check because it returns the operator ID that should be used dynamically instead of hardcoding "4093".

```swift
// In SportsManager.swift
func subscribe() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
    // First, make health check and get operator ID
    return connector.request(WAMPRouter.operatorInfo())
        .flatMap { [weak self] (operatorInfo: OperatorInfoResponse) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> in
            guard let self = self else {
                return Fail(error: ServiceProviderError.unknown).eraseToAnyPublisher()
            }
            
            // Use the operator ID from the response instead of hardcoded "4093"
            let operatorId = operatorInfo.operatorId ?? "4093" // Fallback to 4093 if not provided
            
            // Now proceed with subscription using dynamic operator ID
            let router = WAMPRouter.sportsPublisher(operatorId: operatorId)
            return self.connector.subscribe(router)
                // ... rest of subscription logic
        }
        .catch { error -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> in
            // Check if it's a maintenance error
            if case .errorDetailedMessage(_, let message) = error,
               message.contains("maintenance") {
                return Fail(error: ServiceProviderError.maintenanceMode(message: message))
                    .eraseToAnyPublisher()
            }
            return Fail(error: error).eraseToAnyPublisher()
        }
}
```

### 2. Add Maintenance Error Type

In `Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Common/Errors.swift`:
```swift
public enum ServiceProviderError: Error, Equatable, Hashable {
    // ... existing cases
    case maintenanceMode(message: String)  // Add this
}
```

### 3. Improve WAMPManager Error Handling

In `WAMPManager.swift`, the subscription error handler should extract the `desc` field:
```swift
onError: { (details: [String: Any], errorStr: String) in
    // Extract maintenance message if available
    var errorMessage = errorStr
    if let desc = details["desc"] as? String {
        errorMessage = desc
    }
    
    print("❌ WAMPManager: Registration failed - \(errorMessage)")
    subject.send(WAMPSubscriptionContent.disconnect)
    subject.send(completion: .failure(.requestError(value: errorMessage)))
}
```

### 4. Add Registration Timeout

Add a timeout mechanism to prevent indefinite waiting:
```swift
// In WAMPManager.registerOnEndpoint
let timeoutDuration: TimeInterval = 10.0
let timeoutWorkItem = DispatchWorkItem { [weak subject] in
    subject?.send(WAMPSubscriptionContent.disconnect)
    subject?.send(completion: .failure(.requestError(value: "Registration timeout - server may be in maintenance")))
}

tsQueue.asyncAfter(deadline: .now() + timeoutDuration, execute: timeoutWorkItem)

swampSession.register(
    endpoint.procedure,
    options: args,
    onSuccess: { (registration: WAMPRegistration) in
        timeoutWorkItem.cancel()  // Cancel timeout on success
        // ... rest of success handling
    },
    onError: { (details: [String: Any], errorStr: String) in
        timeoutWorkItem.cancel()  // Cancel timeout on error
        // ... rest of error handling
    }
)
```

### 5. Handle Maintenance in AppStateManager

In `AppStateManager.swift`:
```swift
case .failure(let error):
    print("❌ SportTypeStore: Subscription failed with error: \(error)")
    
    // Check if it's maintenance mode
    if case .maintenanceMode(let message) = error {
        self?.currentStateSubject.send(.maintenanceMode(message: message))
    } else {
        self?.currentStateSubject.send(.error(.sportsLoadingFailed))
    }
    
    self?.sportsSubscription = nil
```

## Benefits of This Approach

1. **Dynamic Operator ID**: Uses the actual operator ID from the server instead of hardcoding "4093"
2. **Fast Failure**: Health check fails quickly with proper error message
3. **User-Friendly**: Shows maintenance screen with server's message
4. **Timeout Protection**: Won't hang indefinitely even if server behavior changes
5. **Proper Error Propagation**: Maintenance errors flow through the entire stack to the UI

## Current Workaround

While EveryMatrix is in maintenance, you can bypass the sports loading by uncommenting lines 63-64 in `SportTypeStore.swift`:
```swift
self.activeSportsCurrentValueSubject.send(.loaded([self.defaultSport]))
return
```

This loads a default football sport and allows testing other parts of the app.

## Files Affected

1. `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/SubscriptionManagers/SportsManager.swift`
2. `Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Libs/WAMPClient/WAMPManager.swift`
3. `Frameworks/ServicesProvider/Sources/ServicesProvider/Models/Common/Errors.swift`
4. `BetssonCameroonApp/App/Boot/AppStateManager.swift`
5. `BetssonCameroonApp/App/Services/SportTypeStore.swift`

## Testing After Implementation

1. **During Maintenance**: App should show maintenance screen with message
2. **After Maintenance**: App should load normally with sports data
3. **Network Issues**: Should show network error, not maintenance
4. **Timeout**: If server doesn't respond within 10 seconds, should show timeout error

## Notes

- The web tools can show maintenance errors because they use RPC calls which properly return errors
- The iOS app uses subscriptions which don't get error callbacks during maintenance
- The operator ID should always be fetched dynamically from `/sports#operatorInfo` to ensure compatibility across different environments