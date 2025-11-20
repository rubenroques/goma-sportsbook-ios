import Foundation

/// File destination for persistent logging with automatic rotation
///
/// Writes logs to files in the application's Documents directory with automatic rotation
/// based on file size. Useful for capturing logs for bug reports and support.
///
/// Example:
/// ```swift
/// let fileDestination = FileDestination(
///     filename: "app.log",
///     maxFileSize: 5 * 1024 * 1024  // 5MB
/// )
/// GomaLogger.addDestination(fileDestination)
/// ```
public final class FileDestination: LogDestination {
    private let filename: String
    private let maxFileSize: Int
    private let maxBackupCount: Int
    private let dateFormatter: DateFormatter
    private let fileManager = FileManager.default
    private var fileHandle: FileHandle?
    private let lock = NSLock()

    private lazy var logsDirectory: URL? = {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let logsDir = documentsDirectory.appendingPathComponent("Logs", isDirectory: true)

        // Create logs directory if needed
        if !fileManager.fileExists(atPath: logsDir.path) {
            try? fileManager.createDirectory(at: logsDir, withIntermediateDirectories: true)
        }

        return logsDir
    }()

    private var currentLogFilePath: URL? {
        return logsDirectory?.appendingPathComponent(filename)
    }

    /// Initialize file destination
    ///
    /// - Parameters:
    ///   - filename: Name of the log file (default: "gomalogger.log")
    ///   - maxFileSize: Maximum file size before rotation in bytes (default: 10MB)
    ///   - maxBackupCount: Number of rotated backup files to keep (default: 3)
    public init(
        filename: String = "gomalogger.log",
        maxFileSize: Int = 10 * 1024 * 1024,  // 10MB
        maxBackupCount: Int = 3
    ) {
        self.filename = filename
        self.maxFileSize = maxFileSize
        self.maxBackupCount = maxBackupCount

        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

        setupLogFile()
    }

    deinit {
        if #available(iOS 13.0, macOS 10.15, *) {
            try? fileHandle?.close()
        } else {
            fileHandle?.closeFile()
        }
    }

    // MARK: - LogDestination

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
        lock.lock()
        defer { lock.unlock() }

        guard currentLogFilePath != nil else {
            return
        }

        // Check if rotation is needed
        rotateIfNeeded()

        // Format log message
        var components: [String] = []

        // Timestamp
        components.append(dateFormatter.string(from: timestamp))

        // Level
        components.append("[\(level.description)]")

        // Subsystem and category
        if let subsystem = subsystem {
            if let category = category {
                components.append("[\(subsystem.rawValue)/\(category)]")
            } else {
                components.append("[\(subsystem.rawValue)]")
            }
        } else if let category = category {
            components.append("[\(category)]")
        }

        // Message
        components.append(message)

        // Metadata
        if let metadata = metadata, !metadata.isEmpty {
            let metadataString = metadata.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            components.append("{\(metadataString)}")
        }

        // File info
        let filename = (file as NSString).lastPathComponent
        components.append("[\(filename):\(line)]")

        let logLine = components.joined(separator: " ") + "\n"

        // Write to file
        if let data = logLine.data(using: .utf8) {
            if fileHandle == nil {
                setupLogFile()
            }

            if #available(iOS 13.4, macOS 10.15.4, *) {
                try? fileHandle?.write(contentsOf: data)
            } else {
                fileHandle?.write(data)
            }
        }
    }

    // MARK: - File Management

    private func setupLogFile() {
        guard let logFilePath = currentLogFilePath else {
            return
        }

        // Create file if it doesn't exist
        if !fileManager.fileExists(atPath: logFilePath.path) {
            fileManager.createFile(atPath: logFilePath.path, contents: nil)
        }

        // Open file handle
        fileHandle = try? FileHandle(forWritingTo: logFilePath)
        if #available(iOS 13.4, macOS 10.15.4, *) {
            _ = try? fileHandle?.seekToEnd()
        } else {
            fileHandle?.seekToEndOfFile()
        }
    }

    private func rotateIfNeeded() {
        guard let logFilePath = currentLogFilePath else {
            return
        }

        // Check file size
        guard let attributes = try? fileManager.attributesOfItem(atPath: logFilePath.path),
              let fileSize = attributes[.size] as? Int,
              fileSize >= maxFileSize else {
            return
        }

        // Close current file
        if #available(iOS 13.0, macOS 10.15, *) {
            try? fileHandle?.close()
        } else {
            fileHandle?.closeFile()
        }
        fileHandle = nil

        // Rotate existing backups
        for i in stride(from: maxBackupCount - 1, through: 1, by: -1) {
            let oldPath = logFilePath.deletingPathExtension().appendingPathExtension("\(i).log")
            let newPath = logFilePath.deletingPathExtension().appendingPathExtension("\(i + 1).log")

            if fileManager.fileExists(atPath: oldPath.path) {
                try? fileManager.removeItem(at: newPath)
                try? fileManager.moveItem(at: oldPath, to: newPath)
            }
        }

        // Move current log to .1
        let backupPath = logFilePath.deletingPathExtension().appendingPathExtension("1.log")
        try? fileManager.removeItem(at: backupPath)
        try? fileManager.moveItem(at: logFilePath, to: backupPath)

        // Delete old backups beyond maxBackupCount
        let oldBackupPath = logFilePath.deletingPathExtension().appendingPathExtension("\(maxBackupCount + 1).log")
        try? fileManager.removeItem(at: oldBackupPath)

        // Create new log file
        setupLogFile()
    }

    // MARK: - Public Utilities

    /// Get the path to the current log file
    public var logFilePath: String? {
        return currentLogFilePath?.path
    }

    /// Get all log file paths (current + backups)
    public var allLogFilePaths: [String] {
        guard let logFilePath = currentLogFilePath else {
            return []
        }

        var paths: [String] = []

        // Current log
        if fileManager.fileExists(atPath: logFilePath.path) {
            paths.append(logFilePath.path)
        }

        // Backups
        for i in 1...maxBackupCount {
            let backupPath = logFilePath.deletingPathExtension().appendingPathExtension("\(i).log")
            if fileManager.fileExists(atPath: backupPath.path) {
                paths.append(backupPath.path)
            }
        }

        return paths
    }

    /// Delete all log files
    public func clearLogs() {
        lock.lock()
        defer { lock.unlock() }

        if #available(iOS 13.0, macOS 10.15, *) {
            try? fileHandle?.close()
        } else {
            fileHandle?.closeFile()
        }
        fileHandle = nil

        for path in allLogFilePaths {
            try? fileManager.removeItem(atPath: path)
        }

        setupLogFile()
    }
}
