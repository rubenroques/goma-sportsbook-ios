//
//  AlertBanner.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

public struct AlertBanner: Identifiable, Equatable, Hashable, Codable {
    
    public let id: Int
    public let title: String
    public let subtitle: String?
    public let ctaText: String?
    public let ctaUrl: String?
    public let platform: String?
    public let status: String?
    public let startDate: String?
    public let endDate: String?
    public let userType: String?

    /// Coding keys for JSON serialization/deserialization
    /// Ensures compatibility with API responses
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case ctaText = "cta_text"
        case ctaUrl = "cta_url"
        case platform
        case status
        case startDate = "start_date"
        case endDate = "end_date"
        case userType = "user_type"
    }

}
