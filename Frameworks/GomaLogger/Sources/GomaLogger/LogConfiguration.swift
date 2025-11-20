import Foundation

/// Configuration for runtime control of logging behavior
///
/// Allows enabling/disabling specific subsystems, categories, and setting minimum log levels.
/// Thread-safe for concurrent access.
///
/// Example:
/// ```swift
/// GomaLogger.configure(
///     minimumLevel: .info,
///     enabledSubsystems: [.authentication, .betting],
///     disabledCategories: ["SSE", "WAMP"]
/// )
/// ```
public final class LogConfiguration {
    /// Shared singleton configuration
    public static let shared = LogConfiguration()

    private var lock = NSLock()
    private var _minimumLevel: LogLevel
    private var _enabledSubsystems: Set<LogSubsystem>?
    private var _disabledSubsystems: Set<LogSubsystem>
    private var _disabledCategories: Set<String>
    private var _subsystemLevels: [LogSubsystem: LogLevel]

    private init() {
        #if DEBUG
        self._minimumLevel = .debug
        #else
        self._minimumLevel = .info
        #endif
        self._enabledSubsystems = nil // nil means all enabled
        self._disabledSubsystems = []
        self._disabledCategories = []
        self._subsystemLevels = [:]
    }

    // MARK: - Public Configuration

    /// Global minimum log level
    public var minimumLevel: LogLevel {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _minimumLevel
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _minimumLevel = newValue
        }
    }

    /// Set which subsystems are enabled (nil means all enabled)
    public var enabledSubsystems: Set<LogSubsystem>? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _enabledSubsystems
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _enabledSubsystems = newValue
        }
    }

    /// Disabled subsystems (takes precedence over enabledSubsystems)
    public var disabledSubsystems: Set<LogSubsystem> {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _disabledSubsystems
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _disabledSubsystems = newValue
        }
    }

    /// Disabled categories (string-based for flexibility)
    public var disabledCategories: Set<String> {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _disabledCategories
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _disabledCategories = newValue
        }
    }

    // MARK: - Convenience Methods

    /// Set minimum log level for a specific subsystem
    public func setLevel(_ level: LogLevel, for subsystem: LogSubsystem) {
        lock.lock()
        defer { lock.unlock() }
        _subsystemLevels[subsystem] = level
    }

    /// Get minimum level for a specific subsystem (falls back to global minimum)
    public func level(for subsystem: LogSubsystem) -> LogLevel {
        lock.lock()
        defer { lock.unlock() }
        return _subsystemLevels[subsystem] ?? _minimumLevel
    }

    /// Enable a specific subsystem
    public func enable(_ subsystem: LogSubsystem) {
        lock.lock()
        defer { lock.unlock() }
        _disabledSubsystems.remove(subsystem)
    }

    /// Disable a specific subsystem
    public func disable(_ subsystem: LogSubsystem) {
        lock.lock()
        defer { lock.unlock() }
        _disabledSubsystems.insert(subsystem)
    }

    /// Disable a specific category (e.g., "LIVE_SCORE", "SSE")
    public func disableCategory(_ category: String) {
        lock.lock()
        defer { lock.unlock() }
        _disabledCategories.insert(category)
    }

    /// Enable a previously disabled category
    public func enableCategory(_ category: String) {
        lock.lock()
        defer { lock.unlock() }
        _disabledCategories.remove(category)
    }

    // MARK: - Filtering Logic

    /// Check if a log should be processed based on configuration
    internal func shouldLog(
        level: LogLevel,
        subsystem: LogSubsystem?,
        category: String?
    ) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        // Check category filter first (most specific)
        if let category = category, _disabledCategories.contains(category) {
            return false
        }

        // Check subsystem filters
        if let subsystem = subsystem {
            // Check if explicitly disabled
            if _disabledSubsystems.contains(subsystem) {
                return false
            }

            // Check if within enabled list (if specified)
            if let enabledSubsystems = _enabledSubsystems {
                if !enabledSubsystems.contains(subsystem) {
                    return false
                }
            }

            // Check subsystem-specific level
            let minimumLevelForSubsystem = _subsystemLevels[subsystem] ?? _minimumLevel
            if level < minimumLevelForSubsystem {
                return false
            }
        } else {
            // No subsystem specified, use global minimum level
            if level < _minimumLevel {
                return false
            }
        }

        return true
    }

    /// Reset configuration to defaults
    public func reset() {
        lock.lock()
        defer { lock.unlock() }

        #if DEBUG
        _minimumLevel = .debug
        #else
        _minimumLevel = .info
        #endif

        _enabledSubsystems = nil
        _disabledSubsystems = []
        _disabledCategories = []
        _subsystemLevels = [:]
    }
}
