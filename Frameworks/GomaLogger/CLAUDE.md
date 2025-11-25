# CLAUDE.md - GomaLogger

Project-specific instructions for Claude Code when working on the GomaLogger framework.

## Overview

GomaLogger is a production-ready logging framework for iOS applications. It provides a static API with hierarchical categorization (subsystems + categories), runtime configuration, and pluggable destinations.

## Project Structure

```
GomaLogger/
├── Package.swift                 # Swift Package definition (iOS 15+)
├── Sources/GomaLogger/
│   ├── GomaLogger.swift          # Main static API entry point
│   ├── LogLevel.swift            # Severity levels (debug, info, error)
│   ├── LogSubsystem.swift        # Domain categorization enum
│   ├── LogConfiguration.swift    # Runtime filtering configuration
│   └── Destinations/
│       ├── LogDestination.swift  # Protocol for custom destinations
│       ├── ConsoleDestination.swift  # Xcode console output
│       └── FileDestination.swift     # File logging with rotation
└── Tests/GomaLoggerTests/
    └── GomaLoggerTests.swift     # Unit tests
```

## Build & Test Commands

```bash
# Build the package
swift build --package-path /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/GomaLogger

# Run tests
swift test --package-path /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Frameworks/GomaLogger

# Build via workspace (preferred)
xcodebuild -workspace /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Sportsbook.xcworkspace -scheme GomaLogger -destination 'platform=iOS Simulator,id=YOUR_DEVICE_ID' build 2>&1 | xcbeautify --quieter
```

## Architecture Principles

### Static API Pattern
- `GomaLogger` is a static-only class (private init)
- All logging methods are class-level static functions
- Configuration is accessed via `GomaLogger.configuration` singleton

### Thread Safety
- All mutable state protected by `NSLock`
- Configuration changes are thread-safe
- Multiple destinations can be written to concurrently

### Zero-Cost Disabled Logging
- Message parameters use `@autoclosure` for lazy evaluation
- `shouldLog()` check happens before message evaluation
- Disabled logs have minimal performance impact

### Destination Protocol
- `LogDestination` protocol defines the contract
- Destinations receive fully-formed log data
- Multiple destinations can be active simultaneously

## Key Design Decisions

1. **No External Dependencies** - Pure Swift implementation for maximum compatibility
2. **Subsystems are Fixed** - Enum-based for compile-time safety and autocomplete
3. **Categories are Freeform** - String-based for flexibility without code changes
4. **Default Behavior Differs by Build** - DEBUG defaults to `.debug`, RELEASE to `.info`
5. **File Destination Rotation** - Automatic rotation prevents unbounded log growth

## Adding New Subsystems

When adding a new subsystem to `LogSubsystem.swift`:

1. Add the new case to the enum
2. Update the `description` computed property if needed
3. Document the subsystem's purpose with a comment
4. Consider which existing log patterns map to this subsystem

```swift
public enum LogSubsystem: String, CaseIterable {
    // ... existing cases ...

    /// New feature description
    /// Maps to: [RELEVANT_TAGS]
    case newFeature
}
```

## Adding New Destinations

To create a custom destination:

1. Create a new file in `Sources/GomaLogger/Destinations/`
2. Implement the `LogDestination` protocol
3. Handle all parameters appropriately for your destination
4. Consider thread safety if destination has mutable state

```swift
public struct MyDestination: LogDestination {
    public func log(
        level: LogLevel,
        subsystem: LogSubsystem?,
        category: String?,
        message: String,
        metadata: [String: Any]?,
        timestamp: Date,
        file: String,
        function: String,
        line: Int
    ) {
        // Implementation
    }
}
```

## Common Tasks

### Adding a New Log Level
Not recommended - the three-level system (debug/info/error) is intentional. If you need more granularity, use categories instead.

### Modifying Console Output Format
Edit `ConsoleDestination.swift` - the `log()` method builds the output string.

### Changing Default Configuration
Edit `LogConfiguration.swift` - the `init()` method sets defaults based on `#if DEBUG`.

### Adding Metadata Support to a Destination
The `metadata` parameter is already passed to all destinations. Format it appropriately in your destination's `log()` method.

## Testing Guidelines

- Test configuration changes affect filtering
- Test thread safety with concurrent logging
- Test file destination rotation behavior
- Mock destinations for unit testing log output

## Integration Points

GomaLogger is used throughout the workspace:
- **BetssonCameroonApp** - Primary consumer
- **BetssonFranceApp** - Legacy integration
- **ServicesProvider** - Network/API logging
- **GomaUI** - Component lifecycle logging

## Do NOT

- Add external dependencies
- Change the static API pattern to instance-based
- Remove thread safety locks
- Add warning/verbose/trace levels (use categories instead)
- Put emojis in production log messages (only in LogLevel.emoji for console)
