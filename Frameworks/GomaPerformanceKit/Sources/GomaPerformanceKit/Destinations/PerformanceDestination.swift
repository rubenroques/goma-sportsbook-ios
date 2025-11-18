//
//  PerformanceDestination.swift
//  GomaPerformanceKit
//
//  Protocol for performance output destinations
//

import Foundation

/// Protocol for performance log destinations (console, file, analytics, etc.)
/// Inspired by SwiftyBeaver's destination pattern
public protocol PerformanceDestination: AnyObject {
    /// Process a completed performance entry
    /// - Parameter entry: The performance entry to log
    func log(entry: PerformanceEntry)

    /// Flush any buffered entries immediately
    /// Called when app backgrounds or on manual flush
    func flush()

    /// Optional filter predicate for selective logging
    /// Return true to log the entry, false to skip
    var filter: ((PerformanceEntry) -> Bool)? { get set }
}

// MARK: - Default Implementation

public extension PerformanceDestination {
    /// Default implementation: no filtering
    var filter: ((PerformanceEntry) -> Bool)? {
        get { nil }
        set { /* Default: no filter */ }
    }
}
