//
//  ConsoleDestination.swift
//  GomaPerformanceKit
//
//  Logs performance entries to the debug console
//

import Foundation

/// Logs performance entries to the debug console (print)
public class ConsoleDestination: PerformanceDestination {

    // MARK: - Log Level

    public enum LogLevel {
        /// Just duration (e.g., "deposit.api: 1.234s")
        case minimal

        /// Duration + feature + layer (e.g., "[Performance] deposit.api completed in 1.234s")
        case standard

        /// Full entry with metadata
        case verbose
    }

    // MARK: - Properties

    /// Current log level
    public var logLevel: LogLevel

    /// Optional filter predicate
    public var filter: ((PerformanceEntry) -> Bool)?

    /// Prefix for console output
    private let prefix: String

    // MARK: - Initialization

    public init(logLevel: LogLevel = .standard, prefix: String = "[GomaPerformanceKit]") {
        self.logLevel = logLevel
        self.prefix = prefix
    }

    // MARK: - PerformanceDestination

    public func log(entry: PerformanceEntry) {
        // Apply filter if present
        if let filter = filter, !filter(entry) {
            return
        }

        let message = formatMessage(for: entry)
        print(message)
    }

    public func flush() {
        // Console has no buffer to flush
    }

    // MARK: - Formatting

    private func formatMessage(for entry: PerformanceEntry) -> String {
        switch logLevel {
        case .minimal:
            return formatMinimal(entry)
        case .standard:
            return formatStandard(entry)
        case .verbose:
            return formatVerbose(entry)
        }
    }

    private func formatMinimal(_ entry: PerformanceEntry) -> String {
        "\(entry.feature.rawValue).\(entry.layer.rawValue): \(entry.durationFormatted)"
    }

    private func formatStandard(_ entry: PerformanceEntry) -> String {
        "\(prefix) \(entry.feature.rawValue).\(entry.layer.rawValue) completed in \(entry.durationFormatted)"
    }

    private func formatVerbose(_ entry: PerformanceEntry) -> String {
        var lines: [String] = []

        lines.append("\(prefix) ========================================")
        lines.append("Feature: \(entry.feature.rawValue)")
        lines.append("Layer: \(entry.layer.rawValue)")
        lines.append("Duration: \(entry.durationFormatted)")
        lines.append("Start: \(entry.startTimeISO8601)")
        lines.append("End: \(entry.endTimeISO8601)")

        if let userID = entry.userID {
            lines.append("User ID: \(userID)")
        }

        if !entry.metadata.isEmpty {
            lines.append("Metadata:")
            for (key, value) in entry.metadata.sorted(by: { $0.key < $1.key }) {
                lines.append("  \(key): \(value)")
            }
        }

        lines.append("Device: \(entry.context.deviceModel) (\(entry.context.iosVersion))")
        lines.append("Network: \(entry.context.networkType)")
        lines.append("App: \(entry.context.appVersion) (\(entry.context.buildNumber))")
        lines.append("\(prefix) ========================================")

        return lines.joined(separator: "\n")
    }
}
