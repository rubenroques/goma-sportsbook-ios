//
//  FooterCMSSponsor.swift
//
//
//  Created on: Nov 19, 2025
//

import Foundation

/// Collection alias for sponsor items exposed by the CMS
public typealias FooterSponsors = [FooterCMSSponsor]

/// Represents a single sponsor/collaboration logo configured in the CMS
public struct FooterCMSSponsor: Identifiable, Equatable, Hashable, Codable {

    public let id: String
    public let url: String
    public let target: String?
    public let order: Int
    public let iconURL: URL?
    public let platform: String?
    public let userType: String?
    public let status: String?
    public let language: String?
    public let startDate: Date?
    public let endDate: Date?

    public init(
        id: String,
        url: String,
        target: String?,
        order: Int,
        iconURL: URL?,
        platform: String?,
        userType: String?,
        status: String?,
        language: String?,
        startDate: Date?,
        endDate: Date?
    ) {
        self.id = id
        self.url = url
        self.target = target
        self.order = order
        self.iconURL = iconURL
        self.platform = platform
        self.userType = userType
        self.status = status
        self.language = language
        self.startDate = startDate
        self.endDate = endDate
    }
}


