//
//  FooterCMSLink.swift
//
//
//  Created on: Nov 18, 2025
//

import Foundation

/// Collection alias for footer links exposed by the CMS
public typealias FooterLinks = [FooterCMSLink]

/// Represents a single footer link item configured in the CMS
public struct FooterCMSLink: Identifiable, Equatable, Hashable, Codable {

    /// Supported footer link types exposed by the CMS
    public enum LinkType: String, Codable {
        case pdf
        case external
        case mailto
        case unknown

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = (try? container.decode(String.self)) ?? ""
            self = LinkType(rawValue: rawValue) ?? .unknown
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .pdf, .external, .mailto:
                try container.encode(self.rawValue)
            case .unknown:
                try container.encode(LinkType.unknown.rawValue)
            }
        }
    }

    /// Unique identifier for the footer link
    public let id: String

    /// The link type (PDF download, external URL, mailto, etc.)
    public let type: LinkType

    /// Optional subtype for additional classification (ex: privacy policy, terms, etc.)
    public let subType: String?

    /// Text shown to the user
    public let label: String

    /// Destination URL or email address (for mailto types)
    public let computedUrl: String

    /// Target describing how the link should open (`_blank`, `_self`, etc.)
    public let target: String?

    /// Sort order coming from CMS
    public let order: Int

    /// Platform visibility metadata
    public let platform: String?

    /// User type visibility metadata
    public let userType: String?

    /// Publication status string
    public let status: String?

    /// Language code for the link
    public let language: String?

    /// Publication window (start date)
    public let startDate: Date?

    /// Publication window (end date)
    public let endDate: Date?

    public init(
        id: String,
        type: LinkType,
        subType: String?,
        label: String,
        computedUrl: String,
        target: String?,
        order: Int,
        platform: String?,
        userType: String?,
        status: String?,
        language: String?,
        startDate: Date?,
        endDate: Date?
    ) {
        self.id = id
        self.type = type
        self.subType = subType
        self.label = label
        self.computedUrl = computedUrl
        self.target = target
        self.order = order
        self.platform = platform
        self.userType = userType
        self.status = status
        self.language = language
        self.startDate = startDate
        self.endDate = endDate
    }
}

