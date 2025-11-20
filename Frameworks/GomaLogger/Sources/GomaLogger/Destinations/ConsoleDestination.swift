import Foundation

/// Console destination for Xcode debug output
///
/// Prints formatted log messages to the console using Swift's `print()` function.
/// Output includes timestamp, level emoji, subsystem, category, and message.
///
/// Example output:
/// ```
/// 2025-11-20 00:15:32.123 🔍 [Betting/ODDS_BOOST] Fetching stairs
/// 2025-11-20 00:15:33.456 ❌ [Networking] API call failed
/// ```
public struct ConsoleDestination: LogDestination {
    private let dateFormatter: DateFormatter
    private let includeFileInfo: Bool

    /// Initialize console destination
    ///
    /// - Parameter includeFileInfo: Whether to include file/function/line in output (default: false in release, true in debug)
    public init(includeFileInfo: Bool? = nil) {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

        #if DEBUG
        self.includeFileInfo = includeFileInfo ?? true
        #else
        self.includeFileInfo = includeFileInfo ?? false
        #endif
    }

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
        var components: [String] = []

        // Timestamp
        components.append(dateFormatter.string(from: timestamp))

        // Level emoji
        components.append(level.emoji)

        // Subsystem and category
        if let subsystem = subsystem {
            if let category = category {
                components.append("[\(subsystem.rawValue.capitalized)/\(category)]")
            } else {
                components.append("[\(subsystem.rawValue.capitalized)]")
            }
        } else if let category = category {
            components.append("[\(category)]")
        }

        // Message
        components.append(message)

        // Metadata (if present)
        if let metadata = metadata, !metadata.isEmpty {
            let metadataString = metadata.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            components.append("{\(metadataString)}")
        }

        // Build final log line
        var logLine = components.joined(separator: " ")

        // File info (debug only or if explicitly enabled)
        if includeFileInfo {
            let filename = (file as NSString).lastPathComponent
            logLine += " [\(filename):\(line) \(function)]"
        }

        print(logLine)
    }
}
