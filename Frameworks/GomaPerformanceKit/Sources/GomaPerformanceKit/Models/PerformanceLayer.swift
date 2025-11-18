//
//  PerformanceLayer.swift
//  GomaPerformanceKit
//
//  Represents the different technical layers being measured
//

import Foundation

/// Represents the technical layer where performance is being measured
public enum PerformanceLayer: String, Codable, CaseIterable {
    /// Webpage rendering time (WKWebView)
    case web

    /// iOS app processing time
    case app

    /// Backend API response time
    case api
}
