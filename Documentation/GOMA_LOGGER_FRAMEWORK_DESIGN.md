# GomaLogger - Professional iOS Logging Framework

## Overview

GomaLogger is a comprehensive logging framework designed as a Swift Package to provide structured logging with multiple outputs, log levels, and filtering capabilities for BetssonCameroonApp and other iOS projects in the GOMA ecosystem.

## Current State Analysis

- **397 print() statements** across 71 files in BetssonCameroonApp alone
- No structured logging system currently in place
- Debugging issues like splash screen problems require manual log insertion
- No centralized way to control log output levels or destinations

## Goals

1. **Unified Logging**: Replace scattered `print()` statements with structured logging
2. **Multi-Destination**: Console, file, and remote logging capabilities
3. **Configurable**: Easy filtering by level, category, and environment
4. **Performance**: Minimal impact on app performance
5. **Production Ready**: Safe for production use with appropriate filtering

## Package Structure

```
Frameworks/GomaLogger/
├── Package.swift
├── README.md
├── Sources/
│   └── GomaLogger/
│       ├── Core/
│       │   ├── LogLevel.swift              # Log severity levels
│       │   ├── LogCategory.swift           # App subsystem categories
│       │   ├── LogMessage.swift            # Log message model
│       │   ├── Logger.swift                # Main logger interface
│       │   └── LoggerConfiguration.swift   # Configuration container
│       ├── Destinations/
│       │   ├── LogDestination.swift        # Protocol for destinations
│       │   ├── ConsoleDestination.swift    # Xcode console output
│       │   ├── FileDestination.swift       # Local file logging
│       │   └── RemoteDestination.swift     # Web service logging
│       ├── Formatters/
│       │   ├── LogFormatter.swift          # Protocol for formatters
│       │   ├── DefaultFormatter.swift      # Human-readable format
│       │   └── JSONFormatter.swift         # Machine-readable format
│       ├── Utilities/
│       │   ├── LogBuffer.swift             # For batching remote logs
│       │   ├── LogFileManager.swift        # File rotation/cleanup
│       │   ├── LogFilter.swift             # Category/level filtering
│       │   └── PerformanceLogger.swift     # Timing utilities
│       └── GomaLogger.swift                # Public API
└── Tests/
    └── GomaLoggerTests/
        ├── CoreTests/
        ├── DestinationTests/
        └── FormatterTests/
```

## Core Components

### 1. Log Levels

```swift
public enum LogLevel: Int, CaseIterable, Comparable {
    case verbose = 0    // Detailed debugging info
    case debug = 1      // Debug information
    case info = 2       // General information
    case warning = 3    // Warnings that might need attention
    case error = 4      // Error conditions
    case critical = 5   // Critical issues requiring immediate attention
    
    public var emoji: String {
        switch self {
        case .verbose: return "💬"
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .critical: return "🚨"
        }
    }
}
```

### 2. Log Categories

```swift
public enum LogCategory: String, CaseIterable {
    // Core App
    case app = "APP"                    // App lifecycle, startup
    case ui = "UI"                      // View controllers, UI events
    case navigation = "NAV"             // Coordinators, routing
    
    // Services & Data
    case network = "NET"                // API calls, HTTP requests
    case webSocket = "WS"               // WebSocket, WAMP connections
    case database = "DB"                // Core Data, UserDefaults
    case services = "SVC"               // ServicesProvider operations
    
    // Business Logic
    case auth = "AUTH"                  // Authentication, user sessions
    case betting = "BET"                // Betting operations
    case wallet = "WALLET"              // Wallet, payments
    case casino = "CASINO"              // Casino games, operations
    
    // Technical
    case performance = "PERF"           // Performance measurements
    case security = "SEC"               // Security-related logs
    case analytics = "ANALYTICS"        // User analytics, tracking
    case crash = "CRASH"                // Crash reporting, errors
    
    // Development
    case test = "TEST"                  // Testing, mocking
    case debug = "DEBUG"                // Development debugging
}
```

### 3. Log Message Model

```swift
public struct LogMessage {
    public let level: LogLevel
    public let category: LogCategory
    public let message: String
    public let metadata: [String: Any]?
    public let error: Error?
    public let timestamp: Date
    public let file: String
    public let function: String
    public let line: Int
    public let thread: String
    
    // Computed properties
    public var fileName: String
    public var formattedTimestamp: String
}
```

## Usage Examples

### Basic Logging

```swift
import GomaLogger

// Simple logging
GomaLogger.debug("User tapped login button", category: .ui)
GomaLogger.info("API request started", category: .network)
GomaLogger.error("Failed to save bet", category: .betting)

// With metadata
GomaLogger.info("Bet placed successfully", 
               category: .betting,
               metadata: ["betId": "12345", "amount": 100.0])

// With error
GomaLogger.error("Network request failed", 
                category: .network,
                error: networkError)
```

### Advanced Usage

```swift
// Performance measurement
GomaLogger.measure("Sports data loading", category: .performance) {
    // Code to measure
    loadSportsData()
}

// Conditional logging
GomaLogger.verbose("Detailed sports data: \(sportsData)", 
                  category: .services,
                  condition: TargetVariables.isDebugBuild)

// Batch logging for related operations
GomaLogger.context(category: .auth) { logger in
    logger.info("Starting login process")
    logger.debug("Validating credentials")
    logger.info("Login successful")
}
```

## Configuration System

### Environment-Based Configuration

```swift
// Configure for development
GomaLogger.configure { config in
    config.minimumLevel = .debug
    config.enabledCategories = .all
    
    // Console with colors and emojis
    config.addDestination(ConsoleDestination(
        formatter: DefaultFormatter(includeMetadata: true),
        useColors: true,
        filterLevel: .verbose
    ))
    
    // File for persistent debugging
    config.addDestination(FileDestination(
        directory: .documents,
        fileName: "goma-debug.log",
        formatter: JSONFormatter(),
        maxFileSize: 10_000_000, // 10MB
        maxFiles: 3
    ))
}

// Configure for production
GomaLogger.configure { config in
    config.minimumLevel = .warning
    config.enabledCategories = [.crash, .security, .network]
    
    // Remote logging for monitoring
    config.addDestination(RemoteDestination(
        endpoint: "https://logs.goma.com/ios",
        apiKey: "production-key",
        batchSize: 50,
        flushInterval: 60,
        formatter: JSONFormatter()
    ))
    
    // Local file for crash debugging
    config.addDestination(FileDestination(
        directory: .documents,
        fileName: "goma-production.log",
        maxFileSize: 5_000_000,
        maxFiles: 1
    ))
}
```

### Dynamic Configuration

```swift
// Runtime configuration changes
GomaLogger.setMinimumLevel(.error)
GomaLogger.enableCategory(.network)
GomaLogger.disableCategory(.ui)

// Environment detection
#if DEBUG
GomaLogger.setMinimumLevel(.debug)
#else
GomaLogger.setMinimumLevel(.warning)
#endif
```

## Destination Types

### 1. Console Destination

- **Features**: Colored output, emoji indicators, real-time filtering
- **Best For**: Development debugging
- **Format**: `[09:30:15.123] 🔧 SVC [DEBUG] Sports data loading...`

```swift
ConsoleDestination(
    formatter: DefaultFormatter(
        includeTimestamp: true,
        includeThread: false,
        includeFileInfo: true
    ),
    useColors: true,
    filterLevel: .debug
)
```

### 2. File Destination

- **Features**: JSON format, automatic rotation, compression
- **Best For**: Persistent debugging, crash analysis
- **Management**: Automatic cleanup of old files

```swift
FileDestination(
    directory: .documents,
    fileName: "app-\(Date().ISO8601Format()).log",
    formatter: JSONFormatter(),
    maxFileSize: 10_000_000,
    maxFiles: 5,
    compressionEnabled: true
)
```

### 3. Remote Destination

- **Features**: Batch uploading, retry mechanism, offline queue
- **Best For**: Production monitoring, analytics
- **Security**: PII scrubbing, data encryption

```swift
RemoteDestination(
    endpoint: "https://logs.example.com/submit",
    apiKey: "your-api-key",
    batchSize: 100,
    flushInterval: 30,
    retryAttempts: 3,
    piiScrubbing: true
)
```

## Integration Strategy

### Phase 1: Core Framework (Week 1-2)

1. **Create Package Structure**
   - Set up Swift Package with proper dependencies
   - Implement core logging interfaces
   - Add basic console destination

2. **Unit Testing**
   - Test log level filtering
   - Test message formatting
   - Test destination routing

### Phase 2: Advanced Features (Week 3-4)

1. **File & Remote Destinations**
   - Implement file rotation and management
   - Add remote batching and retry logic
   - Performance optimization

2. **Utilities & Helpers**
   - Performance measurement tools
   - Log search and filtering utilities
   - Integration helpers for common patterns

### Phase 3: Migration (Week 5-6)

1. **Replace Print Statements**
   - Create migration script to identify all print() usage
   - Replace with appropriate GomaLogger calls
   - Add proper categories based on file location

2. **Configuration Setup**
   - Add environment-specific configurations
   - Set up remote logging endpoints
   - Configure appropriate log levels

### Phase 4: Enhancement (Week 7-8)

1. **Developer Tools**
   - In-app log viewer for debug builds
   - Log export functionality
   - Search and filtering UI

2. **Production Features**
   - Crash reporting integration
   - Analytics correlation
   - Performance monitoring

## Migration Plan

### Automated Migration

```bash
# Find and replace common patterns
find . -name "*.swift" -exec sed -i '' 's/print("DEBUG: \(.*\)")/GomaLogger.debug(\1, category: .debug)/g' {} \;
find . -name "*.swift" -exec sed -i '' 's/print("ERROR: \(.*\)")/GomaLogger.error(\1, category: .debug)/g' {} \;
```

### Manual Migration Guidelines

1. **By Location**:
   - `AppDelegate.swift`, `Bootstrap.swift` → `.app`
   - `*Coordinator.swift` → `.navigation`
   - `*ViewController.swift` → `.ui`
   - `*Service.swift`, `*Provider.swift` → `.services`
   - `*Manager.swift` → appropriate business category

2. **By Content**:
   - Network requests → `.network`
   - WebSocket/WAMP → `.webSocket`
   - User authentication → `.auth`
   - Betting operations → `.betting`
   - Performance timing → `.performance`

### Migration Priority

1. **High Priority**: Core app flow, network operations, authentication
2. **Medium Priority**: UI logging, business logic
3. **Low Priority**: Debug prints, temporary logging

## Best Practices

### Do's

- Use appropriate log levels (`debug` for development, `info` for important events)
- Include relevant metadata with structured data
- Use specific categories to enable targeted filtering
- Log errors with full error objects for better debugging
- Use performance logging for critical paths

### Don'ts

- Don't log sensitive information (passwords, tokens, PII)
- Don't use verbose logging in performance-critical code
- Don't log within tight loops without level checks
- Don't include full object dumps in production logs

### Performance Guidelines

```swift
// Good: Lazy evaluation
GomaLogger.debug { "Heavy computation result: \(expensiveOperation())" }

// Bad: Always evaluated
GomaLogger.debug("Heavy computation result: \(expensiveOperation())")

// Good: Level checking for expensive operations
if GomaLogger.isLevelEnabled(.debug) {
    let debugInfo = buildExpensiveDebugInfo()
    GomaLogger.debug("Debug info: \(debugInfo)", category: .debug)
}
```

## Benefits

### For Development

1. **Faster Debugging**: Structured logs with filtering and search
2. **Better Understanding**: Clear categorization shows app flow
3. **Performance Monitoring**: Built-in timing and measurement tools
4. **Consistency**: Unified logging format across all modules

### for Production

1. **Issue Tracking**: Remote logging helps track user issues
2. **Performance Monitoring**: Identify bottlenecks and slow operations  
3. **Crash Analysis**: Detailed logs leading up to crashes
4. **User Behavior**: Analytics integration for user flow understanding

### For Team

1. **Maintainability**: Centralized logging configuration
2. **Consistency**: Standard logging practices across projects
3. **Debugging**: Shared vocabulary and structure for troubleshooting
4. **Monitoring**: Production health monitoring and alerting

## Implementation Timeline

- **Week 1-2**: Core framework and basic destinations
- **Week 3-4**: Advanced features and utilities
- **Week 5-6**: Migration of existing codebase
- **Week 7-8**: Polish, optimization, and developer tools

## Success Metrics

- Replace all 397+ print() statements with structured logging
- Achieve <1ms average logging performance impact
- Enable 5+ different log filtering scenarios for debugging
- Implement production monitoring with <30 second log delivery
- Reduce debugging time by 50% through better log structure

## Future Enhancements

- Integration with crash reporting services (Crashlytics, Sentry)
- Log analytics and visualization dashboard
- Automated log-based alerting for production issues
- Machine learning for anomaly detection in logs
- Integration with CI/CD for automated log analysis

---

*This document serves as the technical specification for implementing GomaLogger framework. It should be updated as implementation progresses and requirements evolve.*