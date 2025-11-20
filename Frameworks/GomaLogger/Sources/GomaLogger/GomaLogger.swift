import Foundation

/// GomaLogger - Production-ready logging framework for iOS apps
///
/// Provides a simple static API for logging with hierarchical categorization,
/// runtime configuration, and pluggable destinations.
///
/// Basic usage:
/// ```swift
/// GomaLogger.debug("User logged in")
/// GomaLogger.info(.authentication, "Session started")
/// GomaLogger.error(.networking, category: "API", "Request failed")
/// ```
///
/// Configuration:
/// ```swift
/// GomaLogger.configure(
///     minimumLevel: .info,
///     enabledSubsystems: [.authentication, .betting]
/// )
/// GomaLogger.disableCategory("SSE")
/// ```
public final class GomaLogger {
    private static var lock = NSLock()
    private static var destinations: [LogDestination] = [ConsoleDestination()]

    /// Configuration singleton
    public static let configuration = LogConfiguration.shared

    // Prevent instantiation
    private init() {}

    // MARK: - Configuration

    /// Configure global logging behavior
    ///
    /// - Parameters:
    ///   - minimumLevel: Global minimum log level (default: .debug in DEBUG, .info in RELEASE)
    ///   - enabledSubsystems: Optional whitelist of enabled subsystems (nil = all enabled)
    ///   - disabledCategories: Optional set of disabled category strings
    public static func configure(
        minimumLevel: LogLevel? = nil,
        enabledSubsystems: Set<LogSubsystem>? = nil,
        disabledCategories: Set<String>? = nil
    ) {
        if let minimumLevel = minimumLevel {
            configuration.minimumLevel = minimumLevel
        }
        if let enabledSubsystems = enabledSubsystems {
            configuration.enabledSubsystems = enabledSubsystems
        }
        if let disabledCategories = disabledCategories {
            configuration.disabledCategories = disabledCategories
        }
    }

    /// Set minimum log level for a specific subsystem
    public static func setLevel(_ level: LogLevel, for subsystem: LogSubsystem) {
        configuration.setLevel(level, for: subsystem)
    }

    /// Enable a specific subsystem
    public static func enable(_ subsystem: LogSubsystem) {
        configuration.enable(subsystem)
    }

    /// Disable a specific subsystem
    public static func disable(_ subsystem: LogSubsystem) {
        configuration.disable(subsystem)
    }

    /// Disable a specific category
    public static func disableCategory(_ category: String) {
        configuration.disableCategory(category)
    }

    /// Enable a previously disabled category
    public static func enableCategory(_ category: String) {
        configuration.enableCategory(category)
    }

    // MARK: - Destination Management

    /// Add a custom log destination
    public static func addDestination(_ destination: LogDestination) {
        lock.lock()
        defer { lock.unlock() }
        destinations.append(destination)
    }

    /// Remove all destinations
    public static func clearDestinations() {
        lock.lock()
        defer { lock.unlock() }
        destinations.removeAll()
    }

    /// Reset to default destinations (console only)
    public static func resetDestinations() {
        lock.lock()
        defer { lock.unlock() }
        destinations = [ConsoleDestination()]
    }

    // MARK: - Logging API

    /// Log a debug message
    ///
    /// Debug messages are only shown in DEBUG builds and can be filtered out in production.
    ///
    /// - Parameters:
    ///   - subsystem: Optional subsystem categorization
    ///   - category: Optional freeform category string
    ///   - message: Log message (supports string interpolation)
    ///   - metadata: Optional structured data
    ///   - file: Source file (auto-captured)
    ///   - function: Function name (auto-captured)
    ///   - line: Line number (auto-captured)
    public static func debug(
        _ subsystem: LogSubsystem? = nil,
        category: String? = nil,
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            level: .debug,
            subsystem: subsystem,
            category: category,
            message: message,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
    }

    /// Log an info message
    ///
    /// Info messages are shown in all builds for important operational information.
    ///
    /// - Parameters:
    ///   - subsystem: Optional subsystem categorization
    ///   - category: Optional freeform category string
    ///   - message: Log message (supports string interpolation)
    ///   - metadata: Optional structured data
    ///   - file: Source file (auto-captured)
    ///   - function: Function name (auto-captured)
    ///   - line: Line number (auto-captured)
    public static func info(
        _ subsystem: LogSubsystem? = nil,
        category: String? = nil,
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            level: .info,
            subsystem: subsystem,
            category: category,
            message: message,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
    }

    /// Log an error message
    ///
    /// Error messages are always shown and should be used for failures and exceptions.
    ///
    /// - Parameters:
    ///   - subsystem: Optional subsystem categorization
    ///   - category: Optional freeform category string
    ///   - message: Log message (supports string interpolation)
    ///   - metadata: Optional structured data
    ///   - file: Source file (auto-captured)
    ///   - function: Function name (auto-captured)
    ///   - line: Line number (auto-captured)
    public static func error(
        _ subsystem: LogSubsystem? = nil,
        category: String? = nil,
        _ message: @autoclosure () -> String,
        metadata: [String: Any]? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            level: .error,
            subsystem: subsystem,
            category: category,
            message: message,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
    }

    // MARK: - Internal Logging

    private static func log(
        level: LogLevel,
        subsystem: LogSubsystem?,
        category: String?,
        message: @autoclosure () -> String,
        metadata: [String: Any]?,
        file: String,
        function: String,
        line: Int
    ) {
        // Early return for zero-cost disabled logging
        guard configuration.shouldLog(level: level, subsystem: subsystem, category: category) else {
            return
        }

        // Lazy message evaluation (only if we're logging)
        let messageString = message()
        let timestamp = Date()

        // Send to all destinations
        lock.lock()
        let currentDestinations = destinations
        lock.unlock()

        for destination in currentDestinations {
            destination.log(
                level: level,
                subsystem: subsystem,
                category: category,
                message: messageString,
                metadata: metadata,
                timestamp: timestamp,
                file: file,
                function: function,
                line: line
            )
        }
    }
}

// MARK: - Convenience Extensions

extension GomaLogger {
    /// Log debug message with subsystem
    public static func debug(_ subsystem: LogSubsystem, _ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        debug(subsystem, category: nil, message(), metadata: nil, file: file, function: function, line: line)
    }

    /// Log info message with subsystem
    public static func info(_ subsystem: LogSubsystem, _ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        info(subsystem, category: nil, message(), metadata: nil, file: file, function: function, line: line)
    }

    /// Log error message with subsystem
    public static func error(_ subsystem: LogSubsystem, _ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        error(subsystem, category: nil, message(), metadata: nil, file: file, function: function, line: line)
    }

    /// Log debug message (no subsystem)
    public static func debug(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        debug(nil, category: nil, message(), metadata: nil, file: file, function: function, line: line)
    }

    /// Log info message (no subsystem)
    public static func info(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        info(nil, category: nil, message(), metadata: nil, file: file, function: function, line: line)
    }

    /// Log error message (no subsystem)
    public static func error(_ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        error(nil, category: nil, message(), metadata: nil, file: file, function: function, line: line)
    }
}
