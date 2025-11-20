import Foundation

/// Protocol for pluggable log destinations
///
/// Implement this protocol to create custom log destinations (e.g., remote logging,
/// crash reporting integration, custom file formats).
///
/// Example:
/// ```swift
/// struct MyCustomDestination: LogDestination {
///     func log(level: LogLevel, subsystem: LogSubsystem?, category: String?,
///              message: String, metadata: [String: Any]?, timestamp: Date,
///              file: String, function: String, line: Int) {
///         // Custom logging implementation
///     }
/// }
///
/// GomaLogger.addDestination(MyCustomDestination())
/// ```
public protocol LogDestination {
    /// Log a message to this destination
    ///
    /// - Parameters:
    ///   - level: Severity level of the log message
    ///   - subsystem: Optional subsystem categorization
    ///   - category: Optional freeform category string
    ///   - message: The log message
    ///   - metadata: Optional structured data associated with the log
    ///   - timestamp: When the log was created
    ///   - file: Source file where log was called
    ///   - function: Function where log was called
    ///   - line: Line number where log was called
    func log(
        level: LogLevel,
        subsystem: LogSubsystem?,
        category: String?,
        message: String,
        metadata: [String: Any]?,
        timestamp: Date,
        file: String,
        function: String,
        line: Int
    )
}
