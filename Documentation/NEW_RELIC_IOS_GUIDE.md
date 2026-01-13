# New Relic iOS - Maximizing Your Integration

> A practical guide focused on extracting maximum value from New Relic mobile monitoring for iOS applications.

## Table of Contents

1. [Network Observability](#1-network-observability)
2. [Performance Tracking](#2-performance-tracking)
3. [User & Action Tracking](#3-user--action-tracking)
4. [Error Intelligence](#4-error-intelligence)
5. [Distributed Tracing](#5-distributed-tracing)
6. [Dashboards & NRQL](#6-dashboards--nrql)
7. [Alerting Strategy](#7-alerting-strategy)
8. [API Quick Reference](#8-api-quick-reference)

---

## 1. Network Observability

Network monitoring is critical for API-heavy applications. New Relic provides both automatic and manual instrumentation for comprehensive HTTP visibility.

### 1.1 Automatic HTTP Monitoring

Out-of-the-box, New Relic captures:

- **Request/Response timing** - Full round-trip duration
- **Status codes** - Success (2xx/3xx) and errors (4xx/5xx)
- **Bytes transferred** - Request and response payload sizes
- **Geographic analysis** - Response times by region/country
- **Failure rates** - Connection failures, timeouts, SSL errors

All `URLSession` requests are automatically instrumented. Data appears in:
- `MobileRequest` events (status < 400)
- `MobileRequestError` events (status >= 400 or network failures)

### 1.2 Network Failure Detection

Transport-layer failures are automatically tracked:

| Failure Type | NSURLError Code | Description |
|--------------|-----------------|-------------|
| `TimedOut` | `NSURLErrorTimedOut` | Request exceeded timeout |
| `CannotConnectToHost` | `NSURLErrorCannotConnectToHost` | Server unreachable |
| `DNSLookupFailed` | `NSURLErrorCannotFindHost` | DNS resolution failed |
| `SecureConnectionFailed` | `NSURLErrorSecureConnectionFailed` | SSL/TLS handshake failed |
| `BadServerResponse` | `NSURLErrorBadServerResponse` | Invalid server response |

### 1.3 Manual Network Instrumentation

For custom networking (WebSocket, WAMP, custom URLSession configurations), use manual instrumentation:

#### Recording Successful Requests

```swift
import NewRelic

func trackNetworkRequest(
    url: URL,
    method: String,
    startTime: Date,
    endTime: Date,
    statusCode: Int,
    requestSize: Int,
    responseSize: Int,
    responseData: Data?
) {
    let timer = NRTimer()
    timer.startTime = startTime.timeIntervalSince1970
    timer.endTime = endTime.timeIntervalSince1970

    NewRelic.noticeNetworkRequest(
        for: url,
        httpMethod: method,
        with: timer,
        responseHeaders: [:],
        statusCode: statusCode,
        bytesSent: UInt(requestSize),
        bytesReceived: UInt(responseSize),
        responseData: responseData ?? Data(),
        traceHeaders: nil,
        andParams: nil
    )
}
```

#### Recording Network Failures

Use `noticeNetworkFailure` inside catch blocks for transport-layer errors:

```swift
import NewRelic

func performRequest(url: URL) async {
    let timer = NRTimer()
    timer.start()

    do {
        let (_, _) = try await URLSession.shared.data(from: url)
        timer.stop()
        // Success handled automatically or via noticeNetworkRequest
    } catch let error as NSError {
        timer.stop()
        NewRelic.noticeNetworkFailure(
            for: url,
            httpMethod: "GET",
            with: timer,
            andFailureCode: error.code
        )
    }
}
```

### 1.4 Tracking Decoding & Parsing Errors

JSON decoding failures are business-critical. Track them as handled exceptions:

```swift
import NewRelic

func decode<T: Decodable>(_ type: T.Type, from data: Data, endpoint: String) throws -> T {
    do {
        return try JSONDecoder().decode(type, from: data)
    } catch {
        // Record the decoding error with context
        NewRelic.recordError(error, attributes: [
            "endpoint": endpoint,
            "error_type": "json_decode",
            "data_size": data.count,
            "expected_type": String(describing: type),
            "raw_preview": String(data: data.prefix(500), encoding: .utf8) ?? "non-utf8"
        ])
        throw error
    }
}
```

For unexpected response shapes or changed API contracts:

```swift
func validateResponse(_ response: APIResponse, endpoint: String) {
    // Track unexpected null values or missing fields
    if response.unexpectedlyNil {
        NewRelic.recordBreadcrumb("unexpected_response_shape", attributes: [
            "endpoint": endpoint,
            "missing_field": "odds",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ])
    }
}
```

### 1.5 WebSocket / WAMP Connection Tracking

For real-time connections (EveryMatrix WAMP), track connection lifecycle:

```swift
// Track connection establishment
func onWebSocketConnected(url: URL, connectionTime: TimeInterval) {
    NewRelic.recordCustomEvent("WebSocketConnection", attributes: [
        "url": url.absoluteString,
        "connection_time_ms": connectionTime * 1000,
        "status": "connected"
    ])
}

// Track disconnections
func onWebSocketDisconnected(url: URL, reason: String, wasClean: Bool) {
    NewRelic.recordCustomEvent("WebSocketConnection", attributes: [
        "url": url.absoluteString,
        "status": "disconnected",
        "reason": reason,
        "clean_disconnect": wasClean
    ])
}

// Track message latency
func onMessageReceived(topic: String, latency: TimeInterval) {
    NewRelic.recordCustomEvent("WebSocketMessage", attributes: [
        "topic": topic,
        "latency_ms": latency * 1000
    ])
}
```

---

## 2. Performance Tracking

### 2.1 App Launch Metrics

New Relic automatically captures cold and warm start times. For more granular control:

```swift
// In AppDelegate or SceneDelegate
private var launchStartTime: Date?

func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    launchStartTime = Date()
    NewRelic.start(withApplicationToken: "YOUR_TOKEN")
    return true
}

// In your first meaningful screen
func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if let startTime = AppDelegate.shared.launchStartTime {
        let launchDuration = Date().timeIntervalSince(startTime)
        NewRelic.recordCustomEvent("AppLaunch", attributes: [
            "time_to_interactive_ms": launchDuration * 1000,
            "launch_type": "cold"
        ])
        AppDelegate.shared.launchStartTime = nil
    }
}
```

### 2.2 Custom Interactions

The `startInteraction` / `stopCurrentInteraction` APIs measure async workflows with precision:

```swift
import NewRelic

class BetPlacementService {

    func placeBet(slip: BetSlip) async throws -> BetConfirmation {
        // Start tracking the entire bet placement flow
        let interactionId = NewRelic.startInteraction(withName: "PlaceBet")

        defer {
            // Always stop the interaction, even on failure
            NewRelic.stopCurrentInteraction(interactionId)
        }

        // The interaction captures all nested network calls, DB operations, etc.
        let validation = try await validateSlip(slip)
        let odds = try await refreshOdds(slip)
        let confirmation = try await submitBet(slip, odds: odds)

        return confirmation
    }
}
```

#### Nested Interaction Tracking

Track sub-operations within a larger flow:

```swift
func performCheckout() async throws {
    let checkoutId = NewRelic.startInteraction(withName: "Checkout_Full")
    defer { NewRelic.stopCurrentInteraction(checkoutId) }

    // Sub-interaction: Cart validation
    let validateId = NewRelic.startInteraction(withName: "Checkout_Validate")
    try await validateCart()
    NewRelic.stopCurrentInteraction(validateId)

    // Sub-interaction: Payment processing
    let paymentId = NewRelic.startInteraction(withName: "Checkout_Payment")
    try await processPayment()
    NewRelic.stopCurrentInteraction(paymentId)

    // Sub-interaction: Confirmation
    let confirmId = NewRelic.startInteraction(withName: "Checkout_Confirm")
    try await sendConfirmation()
    NewRelic.stopCurrentInteraction(confirmId)
}
```

> **Note**: Custom interactions created via `startInteraction` don't appear on the Interactions page but are queryable via NRQL.

### 2.3 Measuring Critical User Paths

Create reusable timing utilities:

```swift
import NewRelic

final class PerformanceTimer {
    private let name: String
    private let startTime: Date
    private var attributes: [String: Any]

    init(name: String, attributes: [String: Any] = [:]) {
        self.name = name
        self.startTime = Date()
        self.attributes = attributes
    }

    func addAttribute(_ key: String, value: Any) {
        attributes[key] = value
    }

    func stop(success: Bool = true) {
        let duration = Date().timeIntervalSince(startTime) * 1000
        var finalAttributes = attributes
        finalAttributes["duration_ms"] = duration
        finalAttributes["success"] = success

        NewRelic.recordCustomEvent("PerformanceMetric",
                                    name: name,
                                    attributes: finalAttributes)
    }
}

// Usage
func loadMatchDetails(matchId: String) async throws -> MatchDetails {
    let timer = PerformanceTimer(name: "LoadMatchDetails", attributes: [
        "match_id": matchId
    ])

    do {
        let details = try await api.fetchMatchDetails(matchId)
        timer.addAttribute("market_count", value: details.markets.count)
        timer.stop(success: true)
        return details
    } catch {
        timer.stop(success: false)
        throw error
    }
}
```

---

## 3. User & Action Tracking

### 3.1 User Identification

Associate all session data with a user identifier:

```swift
import NewRelic

final class SessionManager {

    func onUserLoggedIn(user: User) {
        // Use a hashed/anonymized ID for privacy
        let hashedId = user.id.sha256Hash

        let success = NewRelic.setUserId(hashedId)
        if success {
            // Session now tagged with this user
            GomaLogger.info("New Relic user ID set", subsystem: .analytics)
        }
    }

    func onUserLoggedOut() {
        // Setting nil terminates current session and starts fresh
        NewRelic.setUserId(nil)
    }
}
```

**Session Behavior**:
- Setting userId when previously nil: Session continues with new ID
- Changing userId (including to nil): Current session ends, new session begins

### 3.2 User Attributes (Segmentation)

Add session-level attributes for filtering and segmentation:

```swift
import NewRelic

func configureUserAttributes(user: User) {
    // User tier for business segmentation
    NewRelic.setAttribute("user_tier", value: user.tier.rawValue)  // "standard", "vip", "premium"

    // Preferences for feature analysis
    NewRelic.setAttribute("preferred_sport", value: user.favoriteSport ?? "none")
    NewRelic.setAttribute("notification_enabled", value: user.pushEnabled)

    // Account age for cohort analysis
    let accountAgeDays = Calendar.current.dateComponents([.day],
                                                          from: user.createdAt,
                                                          to: Date()).day ?? 0
    NewRelic.setAttribute("account_age_days", value: Double(accountAgeDays))

    // Build configuration
    NewRelic.setAttribute("build_config", value: BuildConfiguration.current.rawValue)
}
```

**Attribute Constraints**:
- Types allowed: `String`, `Double`, `Boolean`
- Cannot override reserved attributes: `sessionId`, `timestamp`, `platform`, `osVersion`, etc.
- Attributes prefixed with `NewRelic` are reserved

### 3.3 Custom Events (Business Actions)

Track meaningful business events:

```swift
import NewRelic

// MARK: - Betting Events

func trackBetPlaced(bet: PlacedBet) {
    NewRelic.recordCustomEvent("BetPlaced", attributes: [
        "bet_type": bet.type.rawValue,           // "single", "accumulator", "system"
        "sport": bet.sport,                       // "football", "basketball"
        "stake_amount": bet.stake,                // Numeric value
        "potential_return": bet.potentialReturn,
        "odds": bet.totalOdds,
        "selection_count": bet.selections.count,
        "is_live": bet.isLiveBet,
        "market_type": bet.primaryMarket         // "1x2", "over_under", "btts"
    ])
}

func trackBetSettled(bet: SettledBet) {
    NewRelic.recordCustomEvent("BetSettled", attributes: [
        "bet_id": bet.id,
        "outcome": bet.outcome.rawValue,          // "won", "lost", "void", "cashout"
        "profit_loss": bet.profitLoss,
        "settlement_time_hours": bet.settlementDuration
    ])
}

// MARK: - Deposit/Withdrawal Events

func trackDeposit(deposit: Deposit) {
    NewRelic.recordCustomEvent("Deposit", attributes: [
        "method": deposit.method.rawValue,        // "card", "mobile_money", "bank"
        "amount": deposit.amount,
        "currency": deposit.currency,
        "success": deposit.isSuccessful,
        "processing_time_ms": deposit.processingTime * 1000
    ])
}

// MARK: - Feature Usage Events

func trackFeatureUsed(feature: String, context: [String: Any] = [:]) {
    var attributes: [String: Any] = ["feature_name": feature]
    attributes.merge(context) { _, new in new }

    NewRelic.recordCustomEvent("FeatureUsage", attributes: attributes)
}
```

**Event Design Best Practices**:
- Limit to ~5 event types total (use attributes for variation)
- Use consistent naming across iOS/Android/Web
- Don't use `$eventType` for naming - use the `name` parameter instead
- Attribute values must be `String` or `NSNumber` (no nested objects)

### 3.4 Breadcrumbs (Journey Trails)

Breadcrumbs create a trail of user actions visible in crash analysis:

```swift
import NewRelic

// MARK: - Navigation Breadcrumbs

func trackScreenView(screen: String, params: [String: Any] = [:]) {
    var attributes: [String: Any] = ["screen": screen]
    attributes.merge(params) { _, new in new }

    NewRelic.recordBreadcrumb("screen_view", attributes: attributes)
}

// MARK: - User Action Breadcrumbs

func trackUserAction(action: String, element: String, screen: String) {
    NewRelic.recordBreadcrumb("user_action", attributes: [
        "action": action,           // "tap", "swipe", "long_press"
        "element": element,         // "place_bet_button", "odds_cell"
        "screen": screen
    ])
}

// MARK: - State Change Breadcrumbs

func trackStateChange(from: String, to: String, trigger: String) {
    NewRelic.recordBreadcrumb("state_change", attributes: [
        "from_state": from,
        "to_state": to,
        "trigger": trigger
    ])
}

// MARK: - Workflow Step Breadcrumbs

func trackWorkflowStep(workflow: String, step: Int, stepName: String) {
    NewRelic.recordBreadcrumb("workflow_step", attributes: [
        "workflow": workflow,       // "registration", "deposit", "bet_placement"
        "step_number": step,
        "step_name": stepName
    ])
}
```

**Breadcrumb vs Custom Event**:
| Aspect | Breadcrumb | Custom Event |
|--------|------------|--------------|
| Primary Use | Crash analysis trail | Business metrics |
| UI Location | Crash event trail | Dashboards, queries |
| Event Type | `MobileBreadcrumb` | Custom type you define |
| Scope | Debug/troubleshooting | Analytics/reporting |

---

## 4. Error Intelligence

### 4.1 Crash Analysis

Crashes are automatically captured. Enhance crash context with:

1. **Breadcrumbs before critical operations**
2. **User attributes for segmentation**
3. **dSYM uploads for symbolication**

```swift
// Add breadcrumb before risky operation
NewRelic.recordBreadcrumb("starting_video_playback", attributes: [
    "match_id": matchId,
    "stream_url": streamUrl.absoluteString
])

// Perform operation that might crash
videoPlayer.play(url: streamUrl)
```

### 4.2 Handled Exceptions

Catch and report non-fatal errors:

```swift
import NewRelic

func fetchUserProfile() async {
    do {
        let profile = try await api.getProfile()
        updateUI(with: profile)
    } catch let error as APIError {
        // Record with rich context
        NewRelic.recordError(error, attributes: [
            "endpoint": "/user/profile",
            "error_code": error.code,
            "error_message": error.localizedDescription,
            "retry_count": retryCount,
            "network_type": NetworkMonitor.shared.connectionType
        ])
        showErrorState()
    } catch {
        // Generic error
        NewRelic.recordError(error, attributes: [
            "context": "profile_fetch",
            "error_type": String(describing: type(of: error))
        ])
        showErrorState()
    }
}
```

### 4.3 Error Categories

Create consistent error categorization:

```swift
enum ErrorCategory: String {
    case network = "network"
    case parsing = "parsing"
    case authentication = "authentication"
    case validation = "validation"
    case payment = "payment"
    case unknown = "unknown"
}

func recordCategorizedError(_ error: Error, category: ErrorCategory, context: [String: Any] = [:]) {
    var attributes = context
    attributes["error_category"] = category.rawValue
    attributes["error_domain"] = (error as NSError).domain
    attributes["error_code"] = (error as NSError).code

    NewRelic.recordError(error, attributes: attributes)
}
```

---

## 5. Distributed Tracing

Distributed tracing correlates mobile requests with backend services.

### 5.1 Requirements

- iOS agent version **7.3.0+**
- Backend services instrumented with New Relic APM
- Distributed tracing enabled (default: on)

### 5.2 How It Works

1. Mobile agent automatically adds trace headers to HTTP requests
2. Backend APM agents read headers and continue the trace
3. Full request path visible: Mobile App → API Gateway → Services → Database

### 5.3 Manual Header Injection

For custom networking that bypasses automatic instrumentation:

```swift
import NewRelic

func createTracedRequest(url: URL) -> URLRequest {
    var request = URLRequest(url: url)

    // Get trace headers from New Relic
    if let traceHeaders = NewRelic.generateDistributedTracingHeaders() {
        for (key, value) in traceHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }

    return request
}
```

### 5.4 Limitations

- Mobile spans may appear disconnected from backend spans due to sampling differences
- APM agents sample more aggressively than mobile agents
- Infinite Tracing feature can improve correlation

---

## 6. Dashboards & NRQL

### 6.1 Mobile Event Types

| Event Type | Description | Key Attributes |
|------------|-------------|----------------|
| `Mobile` | Legacy catch-all event | `name`, `interactionDuration` |
| `MobileSession` | Session lifecycle | `sessionDuration`, `deviceType`, `osVersion` |
| `MobileCrash` | App crashes | `crashMessage`, `crashLocation` |
| `MobileRequest` | Successful HTTP (< 400) | `requestUrl`, `responseTime`, `statusCode` |
| `MobileRequestError` | Failed HTTP (>= 400) | `requestUrl`, `statusCode`, `networkError` |
| `MobileBreadcrumb` | User breadcrumbs | `name`, custom attributes |
| `MobileHandledException` | Recorded errors | `exceptionMessage`, custom attributes |

### 6.2 Essential NRQL Queries

#### Performance Queries

```sql
-- App launch time trend
SELECT average(appLaunchDuration)
FROM Mobile
FACET appVersion
SINCE 7 days ago
TIMESERIES

-- Slowest screens
SELECT average(interactionDuration)
FROM Mobile
WHERE category = 'ViewLoading'
FACET name
SINCE 1 day ago
LIMIT 10

-- Custom interaction performance
SELECT average(duration_ms), percentile(duration_ms, 95)
FROM PerformanceMetric
FACET name
SINCE 1 day ago
```

#### Network Queries

```sql
-- API response times by endpoint
SELECT average(responseTime), percentile(responseTime, 95)
FROM MobileRequest
FACET requestUrl
SINCE 1 hour ago

-- Error rate by endpoint
SELECT percentage(count(*), WHERE statusCode >= 400) as 'Error Rate'
FROM MobileRequest
FACET requestUrl
SINCE 1 day ago

-- Network failures by type
SELECT count(*)
FROM MobileRequestError
FACET networkErrorCode
SINCE 1 day ago
```

#### User & Business Queries

```sql
-- Bet placement success rate
SELECT percentage(count(*), WHERE success = true)
FROM BetPlaced
SINCE 1 day ago
TIMESERIES 1 hour

-- Revenue by user tier
SELECT sum(stake_amount)
FROM BetPlaced
FACET user_tier
SINCE 7 days ago

-- Feature adoption
SELECT uniqueCount(sessionId)
FROM FeatureUsage
FACET feature_name
SINCE 7 days ago
```

#### Crash Analysis Queries

```sql
-- Crash-free session rate
SELECT percentage(count(*), WHERE category != 'Crash') as 'Crash-Free Rate'
FROM MobileSession
SINCE 7 days ago
TIMESERIES 1 day

-- Crashes by version
SELECT count(*)
FROM MobileCrash
FACET appVersion
SINCE 7 days ago

-- Last actions before crash
SELECT count(*)
FROM MobileBreadcrumb
WHERE sessionId IN (
    SELECT uniques(sessionId) FROM MobileCrash SINCE 1 day ago
)
FACET name
SINCE 1 day ago
```

### 6.3 Dashboard Templates

Create dashboards for different audiences:

**Engineering Dashboard**:
- Crash rate by version
- API latency percentiles
- Network error breakdown
- Custom interaction durations

**Product Dashboard**:
- Feature usage trends
- User flow completion rates
- A/B test performance comparison

**Business Dashboard**:
- Bet placement success rate
- Deposit conversion funnel
- User tier distribution
- Revenue correlation with performance

---

## 7. Alerting Strategy

### 7.1 Critical Alerts

| Alert | Condition | Threshold | Severity |
|-------|-----------|-----------|----------|
| Crash Rate Spike | `MobileCrash` count | > 10 in 5 min | Critical |
| API Degradation | `MobileRequest` avg response | > 3s for 5 min | Warning |
| Error Rate Spike | `MobileRequestError` percentage | > 5% for 5 min | Critical |
| App Launch Regression | `appLaunchDuration` avg | > 5s for 10 min | Warning |

### 7.2 NRQL Alert Examples

```sql
-- Crash rate alert
SELECT count(*) FROM MobileCrash
WHERE appVersion = 'LATEST_VERSION'
SINCE 5 minutes ago

-- Bet placement failure alert
SELECT percentage(count(*), WHERE success = false)
FROM BetPlaced
SINCE 5 minutes ago

-- WebSocket disconnect spike
SELECT count(*) FROM WebSocketConnection
WHERE status = 'disconnected' AND clean_disconnect = false
SINCE 5 minutes ago
```

### 7.3 Alert Routing

- **Critical**: PagerDuty / On-call rotation
- **Warning**: Slack channel + Email
- **Info**: Dashboard only

---

## 8. API Quick Reference

### Initialization

```swift
NewRelic.start(withApplicationToken: "YOUR_APP_TOKEN")
```

### User & Session

```swift
// Set user identifier
NewRelic.setUserId("hashed_user_id")

// Set session attribute
NewRelic.setAttribute("user_tier", value: "premium")
NewRelic.setAttribute("account_age", value: 365.0)
NewRelic.setAttribute("push_enabled", value: true)

// Remove attribute
NewRelic.removeAttribute("temporary_flag")

// Remove all custom attributes
NewRelic.removeAllAttributes()
```

### Events & Breadcrumbs

```swift
// Record custom event
NewRelic.recordCustomEvent(
    "EventType",                           // Required: event type
    name: "EventName",                     // Optional: event name
    attributes: ["key": "value"]           // Optional: attributes
)

// Record breadcrumb
NewRelic.recordBreadcrumb(
    "breadcrumb_name",
    attributes: ["key": "value"]
)
```

### Errors

```swift
// Record handled exception
NewRelic.recordError(error, attributes: ["context": "operation_name"])

// Force a test crash (DEBUG only)
NewRelic.crashNow("Test crash message")
```

### Interactions

```swift
// Start custom interaction
let interactionId = NewRelic.startInteraction(withName: "CustomOperation")

// ... perform work ...

// Stop interaction
NewRelic.stopCurrentInteraction(interactionId)
```

### Network

```swift
// Record successful request
NewRelic.noticeNetworkRequest(
    for: url,
    httpMethod: "POST",
    with: timer,
    responseHeaders: headers,
    statusCode: 200,
    bytesSent: requestSize,
    bytesReceived: responseSize,
    responseData: data,
    traceHeaders: nil,
    andParams: nil
)

// Record network failure
NewRelic.noticeNetworkFailure(
    for: url,
    httpMethod: "GET",
    with: timer,
    andFailureCode: NSURLErrorTimedOut
)
```

---

## Sources

- [iOS Agent Documentation](https://docs.newrelic.com/docs/mobile-monitoring/new-relic-mobile-ios/get-started/introduction-new-relic-mobile-ios/)
- [Mobile Monitoring Best Practices](https://docs.newrelic.com/docs/new-relic-solutions/best-practices-guides/full-stack-observability/mobile-monitoring-best-practices-guide/)
- [Custom Events & Attributes](https://docs.newrelic.com/docs/data-apis/custom-data/custom-events/report-mobile-monitoring-custom-events-attributes/)
- [Record Breadcrumbs API](https://docs.newrelic.com/docs/mobile-monitoring/new-relic-mobile/mobile-sdk/record-breadcrumb/)
- [Record Custom Events API](https://docs.newrelic.com/docs/mobile-monitoring/new-relic-mobile/mobile-sdk/record-custom-events/)
- [Start Interaction API](https://docs.newrelic.com/docs/mobile-monitoring/new-relic-mobile/mobile-sdk/start-interaction/)
- [Record Error API](https://docs.newrelic.com/docs/mobile-monitoring/new-relic-mobile-ios/ios-sdk-api/recorderror-ios-sdk-api/)
- [Set User ID API](https://docs.newrelic.com/docs/mobile-monitoring/new-relic-mobile/mobile-sdk/set-custom-user-id/)
- [Set Attribute API](https://docs.newrelic.com/docs/mobile-monitoring/new-relic-mobile/mobile-sdk/create-attribute/)
- [Network Request Success API](https://docs.newrelic.com/docs/mobile-monitoring/new-relic-mobile/mobile-sdk/network-request-success/)
- [Network Request Failure API](https://docs.newrelic.com/docs/mobile-monitoring/new-relic-mobile/mobile-sdk/network-request-failures/)
- [iOS Distributed Tracing](https://docs.newrelic.com/docs/mobile-monitoring/new-relic-mobile-ios/get-started/new-relic-ios-and-dt/)
- [Mobile Event Types](https://docs.newrelic.com/docs/data-apis/understand-data/event-data/events-reported-mobile-monitoring/)
- [GitHub - New Relic iOS Agent](https://github.com/newrelic/newrelic-ios-agent)
