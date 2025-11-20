import Foundation

/// Log severity levels with emoji representation for visual scanning
public enum LogLevel: String, CaseIterable, Comparable {
    case debug
    case info
    case error

    /// Emoji representation for visual identification in logs
    public var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .error: return "❌"
        }
    }

    /// Human-readable description
    public var description: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .error: return "ERROR"
        }
    }

    /// Numeric priority for comparison (higher = more important)
    public var priority: Int {
        switch self {
        case .debug: return 0
        case .info: return 1
        case .error: return 2
        }
    }

    /// Compare log levels by priority
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.priority < rhs.priority
    }
}
