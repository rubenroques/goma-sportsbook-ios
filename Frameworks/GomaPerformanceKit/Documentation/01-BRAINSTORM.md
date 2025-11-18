# GomaPerformanceKit - Brainstorm & Design Decisions

## Initial Problem Statement

The Betsson Cameroon app needed to track deposit/withdraw webpage loading performance to demonstrate to clients where bottlenecks occur (APP vs API vs WEBPAGE). This evolved into a need for comprehensive performance monitoring across the entire application.

## Core Requirements

### 1. Centralized Performance Tracking
- **Singleton class** for app-wide access
- **Swift Package** separate from main app
- Importable by both `ServicesProvider` and `BetssonCameroonApp`

### 2. Categorization
- **Layers**: Different parts of the tech stack
  - `web` - Webpage rendering time
  - `app` - iOS app processing time
  - `api` - Backend API response time

- **Features**: Business capabilities
  - `deposit` - Deposit flow
  - `withdraw` - Withdraw flow
  - `login` - Authentication
  - `register` - User registration
  - `sportsData` - Sports data loading

### 3. Tracking Capabilities
- Manual start/end tracking
- Millisecond precision timing
- Rich metadata (URLs, errors, parameters)
- Static device context (computed once)
- Optional user ID (hashed, can be nil for logged-out users)

### 4. Storage & Output
- **In-memory**: Fast access to recent data
- **File system**: Persistent logs in JSON format
- **Export**: Share/send logs for analysis
- **Analytics**: Send to backend for aggregation

### 5. Production Readiness
- Active in all builds (production + debug)
- Easy enable/disable toggle
- No UI in the package itself
- Hidden debug UI in app (6 taps on Betsson logo)

## Key Design Decisions

### Decision 1: Destination Pattern (Inspired by SwiftyBeaver)

**Rationale**: Flexible output configuration without changing core logic

**Implementation**:
```swift
PerformanceTracker.shared.addDestination(ConsoleDestination())
PerformanceTracker.shared.addDestination(FileDestination())
PerformanceTracker.shared.addDestination(AnalyticsDestination())
```

**Benefits**:
- Enable/disable specific outputs independently
- Add custom destinations without modifying package
- Each destination has own configuration
- Clean separation of concerns

### Decision 2: Auto-Generated Session Keys

**Rationale**: Simplify API while handling concurrent operations

**Format**: `"\(feature)_\(layer)_\(timestamp)"`

**Example**: `"deposit_api_1731927483.234"`

**Trade-offs**:
- ✅ Simple API (no need to manage UUIDs)
- ✅ Handles concurrent operations of different types
- ⚠️ Same feature+layer must complete in order (FIFO queue)

### Decision 3: Batched Persistence

**Rationale**: Balance performance and data safety

**Strategy**:
- Buffer in memory
- Flush every 10 entries OR 30 seconds (whichever comes first)
- Explicit flush on app background

**Trade-offs**:
- ✅ Reduced disk I/O overhead
- ✅ Better performance
- ⚠️ Risk losing last few entries on crash (acceptable for performance monitoring)

### Decision 4: Raw Individual Measurements for Analytics

**Rationale**: Keep analytics simple, do aggregation server-side

**Approach**:
- Send every measurement to analytics
- Include full context (device, user, metadata)
- Let backend calculate percentiles/averages

**Trade-offs**:
- ✅ Full data granularity
- ✅ Flexible backend analysis
- ⚠️ Higher network usage (batched to mitigate)

### Decision 5: Static Device Context

**Rationale**: Avoid recomputing unchanging data

**Captured Once at Startup**:
- Device model (e.g., "iPhone 14 Pro")
- iOS version (e.g., "17.2.1")
- App version (e.g., "1.5.0")
- Build number (e.g., "142")
- Network type (e.g., "WiFi", "5G")

**Dynamic Per-Measurement**:
- User ID (can change on login/logout)
- Metadata (URLs, errors, etc.)

## Threading Model

**Approach**: Serial queue for all operations

**Rationale**:
- Thread-safe without complex locking
- Predictable order of operations
- FIFO matching works correctly

**Implementation**:
```swift
private let queue = DispatchQueue(label: "com.goma.performance", qos: .utility)
```

**Background I/O**:
- File writes on background queue
- Analytics sends on background queue
- Never block main thread

## Storage Strategy

### In-Memory
- **Data Structure**: Circular buffer (bounded)
- **Capacity**: Last 1000 entries
- **Purpose**: Fast queries for debug UI

### File System
- **Location**: `Documents/Performance/`
- **Format**: JSON files
- **Naming**: `performance_YYYY-MM-DD.json`
- **Rotation**: Delete files older than 7 days

### Analytics
- **Protocol**: HTTPS POST to configurable endpoint
- **Format**: JSON array of entries
- **Batching**: Send every 50 entries or 60 seconds
- **Retry**: Basic exponential backoff

## API Design Philosophy

### Simplicity Over Flexibility

**Bad (Too Complex)**:
```swift
let tracker = PerformanceTracker()
let session = tracker.createSession(feature: .deposit)
session.start(layer: .api)
// ...
session.end(layer: .api)
tracker.commit(session)
```

**Good (Simple)**:
```swift
PerformanceTracker.shared.start(feature: .deposit, layer: .api)
// ...
PerformanceTracker.shared.end(feature: .deposit, layer: .api)
```

### Fail-Safe Operation

- Missing start() → end() logs warning but doesn't crash
- Missing end() → auto-cleanup after timeout
- Invalid metadata → sanitized/stripped, not rejected
- Storage failure → log to console, continue operation

## Integration Points

### ServicesProvider
**Where**: Wrap all API calls

**Example**:
```swift
func getBankingWebView(...) -> AnyPublisher<CashierWebViewResponse, Error> {
    PerformanceTracker.shared.start(
        feature: .deposit,
        layer: .api,
        metadata: ["endpoint": "/payment/GetPaymentSession"]
    )

    return apiClient.request(...)
        .handleEvents(
            receiveOutput: { response in
                PerformanceTracker.shared.end(
                    feature: .deposit,
                    layer: .api,
                    metadata: ["status": "success", "responseSize": "\(response.size)"]
                )
            },
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    PerformanceTracker.shared.end(
                        feature: .deposit,
                        layer: .api,
                        metadata: ["error": error.localizedDescription]
                    )
                }
            }
        )
}
```

### BetssonCameroonApp
**Where**: ViewControllers for APP layer, WKWebView delegates for WEB layer

**Example**:
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    PerformanceTracker.shared.start(feature: .deposit, layer: .app)
    setupUI()
    PerformanceTracker.shared.end(feature: .deposit, layer: .app)
}

func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    PerformanceTracker.shared.start(feature: .deposit, layer: .web)
}

func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    PerformanceTracker.shared.end(feature: .deposit, layer: .web)
}
```

## Future Enhancements (Out of Scope for V1)

1. **Nested Tracking**: Parent-child relationships for hierarchical operations
2. **Memory Profiling**: Track memory usage alongside timing
3. **Custom Metrics**: Allow arbitrary numeric values beyond duration
4. **Sampling**: Sample % of operations instead of tracking all
5. **Remote Configuration**: Enable/disable tracking remotely
6. **Crash Correlation**: Integrate with crash reporting
7. **UI Performance**: Track frame drops, scroll performance
8. **Network Monitoring**: Automatic URLSession interception

## Success Criteria

1. ✅ Track deposit/withdraw flows with clear APP/API/WEB breakdown
2. ✅ Zero UI dependencies in package
3. ✅ Thread-safe operation
4. ✅ Production-ready with minimal overhead
5. ✅ Easy integration into existing code
6. ✅ Flexible output destinations
7. ✅ Export capability for support team
8. ✅ Analytics integration for trend monitoring

## References

- [SwiftyBeaver](https://github.com/SwiftyBeaver/SwiftyBeaver) - Inspiration for destination pattern
- Current implementation: `BankingTimingMetrics.swift` - Specialized banking flow tracking (to be replaced)
