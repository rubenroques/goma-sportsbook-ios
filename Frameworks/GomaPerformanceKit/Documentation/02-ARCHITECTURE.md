# GomaPerformanceKit - Architecture Documentation

## Overview

GomaPerformanceKit is a standalone Swift Package that provides comprehensive performance monitoring for the Goma iOS applications. It tracks timing and metadata for operations across different application layers and business features.

## Package Structure

```
GomaPerformanceKit/
├── Package.swift
├── Sources/
│   └── GomaPerformanceKit/
│       ├── PerformanceTracker.swift          # Main singleton
│       ├── Models/
│       │   ├── PerformanceLayer.swift        # Layer enum
│       │   ├── PerformanceFeature.swift      # Feature enum
│       │   ├── PerformanceEntry.swift        # Measurement record
│       │   ├── DeviceContext.swift           # Static device info
│       │   └── PendingSession.swift          # In-flight tracking
│       ├── Destinations/
│       │   ├── PerformanceDestination.swift  # Protocol
│       │   ├── ConsoleDestination.swift      # Debug console output
│       │   ├── FileDestination.swift         # JSON file storage
│       │   └── AnalyticsDestination.swift    # Backend integration
│       ├── Storage/
│       │   ├── PerformanceStorage.swift      # File I/O manager
│       │   └── CircularBuffer.swift          # In-memory cache
│       └── Export/
│           └── PerformanceExporter.swift     # JSON/CSV export
├── Tests/
│   └── GomaPerformanceKitTests/
└── Documentation/
    ├── 01-BRAINSTORM.md
    ├── 02-ARCHITECTURE.md (this file)
    └── 03-USAGE-GUIDE.md
```

## Core Components

### 1. PerformanceTracker (Singleton)

**Responsibilities**:
- Central entry point for all tracking operations
- Manages destinations (console, file, analytics)
- Maintains in-memory cache of recent entries
- Coordinates start/end matching
- Thread-safe operation via serial queue

**Public API**:
```swift
class PerformanceTracker {
    static let shared: PerformanceTracker

    // Configuration
    func configure(deviceContext: DeviceContext, userID: String?)
    func enable()
    func disable()
    var isEnabled: Bool { get }

    // Destination Management
    func addDestination(_ destination: PerformanceDestination)
    func removeDestination(_ destination: PerformanceDestination)
    func removeAllDestinations()

    // Tracking
    func start(feature: PerformanceFeature, layer: PerformanceLayer, metadata: [String: String])
    func end(feature: PerformanceFeature, layer: PerformanceLayer, metadata: [String: String])

    // Querying
    func getAllLogs() -> [PerformanceEntry]
    func getLogs(feature: PerformanceFeature) -> [PerformanceEntry]
    func getLogs(layer: PerformanceLayer) -> [PerformanceEntry]
    func getLogs(feature: PerformanceFeature, layer: PerformanceLayer) -> [PerformanceEntry]

    // Export
    func exportJSON() -> Data?
    func exportCSV() -> Data?

    // Manual Flush
    func flush()
}
```

**Internal State**:
```swift
private let queue: DispatchQueue
private var destinations: [PerformanceDestination]
private var pendingSessions: [String: PendingSession]
private var inMemoryCache: CircularBuffer<PerformanceEntry>
private var deviceContext: DeviceContext
private var userID: String?
private var enabled: Bool
```

### 2. Models

#### PerformanceLayer
```swift
public enum PerformanceLayer: String, Codable, CaseIterable {
    case web    // Webpage rendering (WKWebView)
    case app    // iOS app processing
    case api    // Backend API calls
}
```

#### PerformanceFeature
```swift
public enum PerformanceFeature: String, Codable, CaseIterable {
    case deposit        // Deposit flow
    case withdraw       // Withdraw flow
    case login          // User authentication
    case register       // User registration
    case sportsData     // Sports data loading
}
```

#### PerformanceEntry
```swift
public struct PerformanceEntry: Codable {
    let id: String                          // Auto-generated key
    let feature: PerformanceFeature
    let layer: PerformanceLayer
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval              // In milliseconds
    let metadata: [String: String]          // Custom key-value pairs
    let context: DeviceContext              // Static device info

    // Computed Properties
    var durationFormatted: String {
        String(format: "%.3fms", duration * 1000)
    }
}
```

#### DeviceContext
```swift
public struct DeviceContext: Codable {
    let deviceModel: String                 // e.g., "iPhone 14 Pro"
    let iosVersion: String                  // e.g., "17.2.1"
    let appVersion: String                  // e.g., "1.5.0"
    let buildNumber: String                 // e.g., "142"
    let networkType: String                 // e.g., "WiFi", "5G"

    // Computed once at app startup
    static func current(networkType: String) -> DeviceContext
}
```

#### PendingSession
```swift
internal struct PendingSession {
    let feature: PerformanceFeature
    let layer: PerformanceLayer
    let startTime: Date
    let metadata: [String: String]
    let createdAt: Date

    // For timeout detection
    var isExpired: Bool {
        Date().timeIntervalSince(createdAt) > 300 // 5 minutes
    }
}
```

### 3. Destinations (Protocol Pattern)

#### PerformanceDestination Protocol
```swift
public protocol PerformanceDestination: AnyObject {
    /// Process a completed performance entry
    func log(entry: PerformanceEntry)

    /// Flush any buffered entries immediately
    func flush()

    /// Optional: Filter predicate for selective logging
    var filter: ((PerformanceEntry) -> Bool)? { get set }
}
```

#### ConsoleDestination
```swift
public class ConsoleDestination: PerformanceDestination {
    public enum LogLevel {
        case minimal    // Just duration
        case standard   // Duration + feature + layer
        case verbose    // Full entry with metadata
    }

    public var logLevel: LogLevel = .standard

    public func log(entry: PerformanceEntry) {
        // Print to console with formatting
    }
}
```

**Output Example**:
```
[Performance] deposit.api completed in 1.234s
[Performance] deposit.web completed in 3.456s
```

#### FileDestination
```swift
public class FileDestination: PerformanceDestination {
    public var batchSize: Int = 10
    public var flushInterval: TimeInterval = 30.0
    public var maxFileAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days

    private var buffer: [PerformanceEntry] = []
    private var lastFlushTime: Date = Date()

    public func log(entry: PerformanceEntry) {
        // Add to buffer, flush if needed
    }

    public func flush() {
        // Write buffer to JSON file
        // Rotate old files
    }
}
```

**File Format**:
```json
{
  "entries": [
    {
      "id": "deposit_api_1731927483.234",
      "feature": "deposit",
      "layer": "api",
      "startTime": "2025-11-18T12:24:43.234Z",
      "endTime": "2025-11-18T12:24:44.468Z",
      "duration": 1.234,
      "metadata": {
        "url": "https://betsson.nwacdn.com/v1/player/...",
        "status": "success"
      },
      "context": {
        "deviceModel": "iPhone 14 Pro",
        "iosVersion": "17.2.1",
        "appVersion": "1.5.0",
        "buildNumber": "142",
        "networkType": "WiFi"
      }
    }
  ]
}
```

#### AnalyticsDestination
```swift
public class AnalyticsDestination: PerformanceDestination {
    public var endpoint: URL
    public var batchSize: Int = 50
    public var flushInterval: TimeInterval = 60.0

    private var buffer: [PerformanceEntry] = []
    private var lastFlushTime: Date = Date()

    public func log(entry: PerformanceEntry) {
        // Add to buffer, send if needed
    }

    public func flush() {
        // POST JSON to analytics endpoint
    }
}
```

**Request Format**:
```json
POST /api/performance/batch
Content-Type: application/json

{
  "entries": [...],
  "appVersion": "1.5.0",
  "timestamp": "2025-11-18T12:24:43.234Z"
}
```

### 4. Storage

#### CircularBuffer
```swift
internal class CircularBuffer<T> {
    private var buffer: [T]
    private let capacity: Int
    private var head: Int = 0

    init(capacity: Int)
    func append(_ element: T)
    func all() -> [T]
    func filter(_ predicate: (T) -> Bool) -> [T]
    func clear()
}
```

**Purpose**: Keep last N entries in memory for fast queries

#### PerformanceStorage
```swift
internal class PerformanceStorage {
    static let shared = PerformanceStorage()

    func write(entries: [PerformanceEntry], to file: String) throws
    func read(from file: String) throws -> [PerformanceEntry]
    func listFiles() -> [String]
    func deleteOldFiles(olderThan interval: TimeInterval)
    func storageDirectory() -> URL
}
```

**Directory Structure**:
```
Documents/Performance/
├── performance_2025-11-18.json
├── performance_2025-11-17.json
└── performance_2025-11-16.json
```

### 5. Export

#### PerformanceExporter
```swift
public class PerformanceExporter {
    static func exportJSON(entries: [PerformanceEntry]) -> Data?
    static func exportCSV(entries: [PerformanceEntry]) -> Data?
}
```

**CSV Format**:
```csv
id,feature,layer,startTime,endTime,duration,metadata,deviceModel,iosVersion
deposit_api_1731927483.234,deposit,api,2025-11-18T12:24:43.234Z,2025-11-18T12:24:44.468Z,1.234,"url=https://...|status=success",iPhone 14 Pro,17.2.1
```

## Threading Model

### Serial Queue
```swift
private let queue = DispatchQueue(label: "com.goma.performance", qos: .utility)
```

**All public methods execute on this queue:**
- `start()`
- `end()`
- `getAllLogs()`
- Destination management

**Background I/O:**
```swift
private let ioQueue = DispatchQueue(label: "com.goma.performance.io", qos: .background)
```

**Used for:**
- File writes
- File reads
- Analytics network requests
- Old file deletion

### Thread Safety Guarantees

1. **All public API calls are thread-safe**
2. **Internal state only accessed on serial queue**
3. **Destinations called on serial queue** (they can dispatch internally if needed)
4. **No race conditions on pending sessions dictionary**

## Start/End Matching Algorithm

### Key Generation
```swift
private func generateKey(feature: PerformanceFeature, layer: PerformanceLayer) -> String {
    "\(feature.rawValue)_\(layer.rawValue)_\(Date().timeIntervalSince1970)"
}
```

### FIFO Matching
```swift
// Start creates entry
let key = generateKey(feature, layer)
pendingSessions[key] = PendingSession(...)

// End finds oldest matching entry
let matchingKey = pendingSessions.keys
    .filter { $0.hasPrefix("\(feature.rawValue)_\(layer.rawValue)_") }
    .sorted()
    .first

if let key = matchingKey, let session = pendingSessions[key] {
    // Create PerformanceEntry
    // Remove from pending
    // Send to destinations
}
```

### Timeout Cleanup
```swift
// Periodically remove expired sessions (> 5 minutes old)
func cleanupExpiredSessions() {
    let expiredKeys = pendingSessions
        .filter { $0.value.isExpired }
        .map { $0.key }

    expiredKeys.forEach { key in
        pendingSessions.removeValue(forKey: key)
        print("[Performance] Warning: Session \(key) expired without end()")
    }
}
```

## Configuration Example

```swift
// In AppDelegate or SceneDelegate
import GomaPerformanceKit
import Reachability

func application(_ application: UIApplication, didFinishLaunchingWithOptions ...) -> Bool {
    // 1. Get network type
    let reachability = try? Reachability()
    let networkType: String
    switch reachability?.connection {
    case .wifi: networkType = "WiFi"
    case .cellular: networkType = "Cellular"
    default: networkType = "Unknown"
    }

    // 2. Configure device context
    let context = DeviceContext.current(networkType: networkType)

    // 3. Get user ID (if logged in)
    let userID = UserSession.current?.userID?.sha256Hash

    // 4. Configure tracker
    PerformanceTracker.shared.configure(
        deviceContext: context,
        userID: userID
    )

    // 5. Add destinations
    #if DEBUG
    PerformanceTracker.shared.addDestination(ConsoleDestination())
    #endif

    let fileDestination = FileDestination(
        batchSize: 10,
        flushInterval: 30
    )
    PerformanceTracker.shared.addDestination(fileDestination)

    if let analyticsURL = URL(string: "https://analytics.betsson.com/performance") {
        let analyticsDestination = AnalyticsDestination(
            endpoint: analyticsURL,
            batchSize: 50,
            flushInterval: 60
        )
        PerformanceTracker.shared.addDestination(analyticsDestination)
    }

    // 6. Enable tracking
    PerformanceTracker.shared.enable()

    return true
}

// Update user ID on login/logout
func onUserLoggedIn(userID: String) {
    PerformanceTracker.shared.configure(
        deviceContext: PerformanceTracker.shared.currentContext,
        userID: userID.sha256Hash
    )
}

func onUserLoggedOut() {
    PerformanceTracker.shared.configure(
        deviceContext: PerformanceTracker.shared.currentContext,
        userID: nil
    )
}
```

## Error Handling

### Fail-Safe Philosophy
- **Never crash** - log warnings instead
- **Graceful degradation** - disable on errors
- **Continue operation** - don't block app functionality

### Error Scenarios

**1. Missing start() call:**
```swift
// end() called without matching start()
print("[Performance] Warning: end() called for \(feature).\(layer) without start()")
// Don't create entry, continue
```

**2. Missing end() call:**
```swift
// Session expires after 5 minutes
print("[Performance] Warning: Session expired: \(key)")
// Remove from pending, log to console
```

**3. File write failure:**
```swift
do {
    try storage.write(entries, to: file)
} catch {
    print("[Performance] Error writing to file: \(error)")
    // Continue with in-memory cache only
}
```

**4. Analytics send failure:**
```swift
// Network error
print("[Performance] Analytics send failed: \(error)")
// Buffer entries, retry on next flush
```

## Performance Considerations

### Memory Usage
- In-memory cache: ~1000 entries × ~500 bytes = ~500 KB
- Pending sessions: Typically < 10 × ~200 bytes = ~2 KB
- **Total**: < 1 MB overhead

### CPU Usage
- Timer updates: Negligible (only when active operations)
- Queue operations: Microseconds per call
- JSON encoding: Milliseconds per batch
- **Total**: < 0.1% CPU

### Disk Usage
- ~1 MB per day (typical usage)
- 7-day retention = ~7 MB
- Auto-cleanup keeps bounded

### Network Usage
- ~100 bytes per entry
- Batched: ~5 KB per request
- ~10 requests per hour = ~50 KB/hour
- **Total**: < 5 MB/day

## Dependencies

- **Foundation** (built-in)
- **Dispatch** (built-in)
- **No external dependencies**

## Minimum Requirements

- iOS 15.0+
- Swift 5.7+
- Xcode 14.0+
