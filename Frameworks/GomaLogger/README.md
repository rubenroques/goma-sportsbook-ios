# GomaLogger

Production-ready logging framework for iOS applications with hierarchical categorization, runtime configuration, and pluggable destinations.

## Features

- ✅ **Simple Static API** - No instances to manage, works everywhere immediately
- 📊 **Hierarchical Categories** - Subsystems + freeform categories for flexible organization
- 🎚️ **Runtime Configuration** - Enable/disable logging without removing code
- 🔌 **Pluggable Destinations** - Console, File, or custom implementations
- ⚡ **Zero-Cost When Disabled** - Minimal performance impact when logs are filtered
- 🔍 **Visual Emojis** - Quick visual scanning with emoji severity levels
- 🧪 **Fully Tested** - Comprehensive unit test coverage

## Quick Start

### Basic Logging

```swift
import GomaLogger

// Simple logging
GomaLogger.debug("User tapped button")
GomaLogger.info("Session started")
GomaLogger.error("Network request failed")
```

### Hierarchical Logging

```swift
// With subsystem
GomaLogger.debug(.authentication, "Login started")
GomaLogger.info(.betting, "Bet placed successfully")
GomaLogger.error(.networking, "Connection timeout")

// With subsystem + category
GomaLogger.debug(.betting, category: "ODDS_BOOST", "Fetching stairs for \(count) selections")
GomaLogger.info(.realtime, category: "LIVE_SCORE", "Score updated: \(newScore)")
```

### Structured Logging

```swift
// With metadata
GomaLogger.error(.networking, category: "API", "Request failed", metadata: [
    "endpoint": "/auth/login",
    "statusCode": 401,
    "errorCode": "INVALID_CREDENTIALS"
])
```

## Configuration

### Global Minimum Level

```swift
// Set global minimum level (default: .debug in DEBUG, .info in RELEASE)
GomaLogger.configure(minimumLevel: .info)
```

### Subsystem Control

```swift
// Enable only specific subsystems
GomaLogger.configure(enabledSubsystems: [.authentication, .betting, .networking])

// Or disable specific subsystems
GomaLogger.disable(.social)
GomaLogger.disable(.analytics)

// Per-subsystem log level
GomaLogger.setLevel(.debug, for: .authentication)  // Verbose auth logging
GomaLogger.setLevel(.error, for: .ui)              // Only errors from UI
```

### Category Control

```swift
// Disable specific categories without removing code
GomaLogger.disableCategory("SSE")
GomaLogger.disableCategory("LIVE_SCORE")

// Re-enable later
GomaLogger.enableCategory("SSE")
```

### Complete Example

```swift
// Configure at app startup
GomaLogger.configure(
    minimumLevel: .info,
    enabledSubsystems: [.authentication, .betting, .networking, .realtime],
    disabledCategories: ["WAMP", "SocketDebug"]
)

// Fine-tune specific subsystems
GomaLogger.setLevel(.debug, for: .authentication)
```

## Severity Levels

| Level | Emoji | Usage | Production |
|-------|-------|-------|------------|
| `.debug` | 🔍 | Development debugging, verbose logging | Disabled |
| `.info` | ℹ️ | Important operational information | Enabled |
| `.error` | ❌ | Errors and failures | Always enabled |

## Subsystems

GomaLogger includes 10 predefined subsystems based on codebase analysis:

| Subsystem | Purpose | Example Tags |
|-----------|---------|--------------|
| `.authentication` | Auth, sessions, SSE | `AUTH_DEBUG`, `SSEDebug`, `XTREMEPUSH` |
| `.betting` | Betting operations | `ODDS_BOOST`, `BETTING_OPTIONS`, `BET_PLACEMENT` |
| `.networking` | Network requests, APIs | `GOMAAPI`, `SocketDebug` |
| `.realtime` | WebSocket subscriptions | `LIVE_SCORE`, `LIVE_DATA`, `WAMP` |
| `.ui` | UI components, VCs/VMs | Component lifecycle, BLINK_DEBUG |
| `.performance` | Performance tracking | Performance monitoring |
| `.payments` | Payments, transactions | PaymentsDropIn |
| `.social` | Social features | Chat, friends |
| `.analytics` | Analytics tracking | Event tracking |
| `.general` | Uncategorized | General purpose |

## Destinations

### Console Destination (Default)

Outputs to Xcode console:

```
2025-11-20 00:15:32.123 🔍 [Betting/ODDS_BOOST] Fetching stairs for 5 selections
2025-11-20 00:15:33.456 ❌ [Networking/API] Request failed {endpoint=/auth/login, statusCode=401}
```

### File Destination

Persistent logging with automatic rotation:

```swift
import GomaLogger

// Add file logging
let fileDestination = FileDestination(
    filename: "app.log",
    maxFileSize: 5 * 1024 * 1024,  // 5MB before rotation
    maxBackupCount: 3               // Keep 3 backup files
)
GomaLogger.addDestination(fileDestination)

// Access log files
if let logPath = fileDestination.logFilePath {
    print("Current log: \(logPath)")
}

// Get all logs (current + backups)
let allLogs = fileDestination.allLogFilePaths

// Clear logs
fileDestination.clearLogs()
```

### Custom Destination

Create custom destinations by conforming to `LogDestination`:

```swift
struct RemoteLogDestination: LogDestination {
    func log(level: LogLevel, subsystem: LogSubsystem?, category: String?,
             message: String, metadata: [String: Any]?, timestamp: Date,
             file: String, function: String, line: Int) {
        // Send to remote logging service
        analytics.logEvent(
            name: "app_log",
            parameters: [
                "level": level.description,
                "subsystem": subsystem?.rawValue ?? "none",
                "message": message
            ]
        )
    }
}

GomaLogger.addDestination(RemoteLogDestination())
```

## Migration from `print()`

### Simple Replacements

```swift
// Before
print("User logged in")
// After
GomaLogger.debug("User logged in")

// Before
print("ERROR: Login failed")
// After
GomaLogger.error("Login failed")
```

### Tagged Patterns

```swift
// Before: [ODDS_BOOST] Fetching stairs
print("[ODDS_BOOST] Fetching stairs")
// After
GomaLogger.debug(.betting, category: "ODDS_BOOST", "Fetching stairs")

// Before: BLINK_DEBUG [MatchDetailsVC] 🔔 Market update
print("BLINK_DEBUG [MatchDetailsVC] 🔔 Market update #\(counter)")
// After
GomaLogger.debug(.ui, category: "MatchDetailsVC", "Market update #\(counter)")

// Before: [SSEDebug] 📡 Starting stream
print("[SSEDebug] 📡 Starting stream")
// After
GomaLogger.debug(.realtime, category: "SSE", "Starting stream")
```

### Error Patterns

```swift
// Before
print("FAVORITE EVENTS ERROR: \(error)")
// After
GomaLogger.error(.general, "Favorite events failed", metadata: ["error": error])

// Before
print("PAYMENTS RESPONSE ERROR: \(error)")
// After
GomaLogger.error(.payments, "Payment processing failed", metadata: [
    "error": error.localizedDescription
])
```

## Architecture

GomaLogger uses a clean, modular architecture:

```
┌─────────────────┐
│   GomaLogger    │  Static API
│  (Entry Point)  │
└────────┬────────┘
         │
         ├──────────────────────────┐
         │                          │
┌────────▼─────────┐      ┌─────────▼─────────┐
│ LogConfiguration │      │  LogDestination   │
│  (Filtering)     │      │   (Protocol)      │
└──────────────────┘      └─────────┬─────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
           ┌────────▼──────┐ ┌──────▼──────┐ ┌─────▼────────┐
           │  Console      │ │    File     │ │   Custom     │
           │ Destination   │ │ Destination │ │ Destination  │
           └───────────────┘ └─────────────┘ └──────────────┘
```

## Performance

- **Zero-cost filtering**: When a log is filtered out by configuration, the message closure is never evaluated
- **Lazy evaluation**: Message interpolation only happens if the log will be output
- **Minimal overhead**: Typical logging call adds <1ms in debug builds, negligible in release
- **Thread-safe**: All operations are thread-safe for concurrent logging

## Testing

Run tests:

```bash
swift test --package-path Frameworks/GomaLogger
```

Or in Xcode:
- Open `Sportsbook.xcworkspace`
- Select `GomaLogger` scheme
- Press Cmd+U

## Best Practices

1. **Use appropriate levels**
   - `.debug` - Detailed information for debugging (will be stripped in production)
   - `.info` - Important operational events (user actions, state changes)
   - `.error` - Failures and exceptions

2. **Choose subsystems wisely**
   - Use subsystems to group related functionality
   - Enables easy filtering during debugging

3. **Use categories for specificity**
   - Categories are freeform strings for fine-grained control
   - Use existing category names for consistency (see analysis data)

4. **Include context in metadata**
   - Use metadata for structured data that might need parsing
   - Better than string interpolation for IDs, codes, etc.

5. **Configure early**
   - Set up logging configuration in `AppDelegate` or app startup
   - Adjust per environment (DEBUG/UAT/PROD)

## License

Internal use only - Betsson Group

## Support

For questions or issues, contact the iOS development team.
