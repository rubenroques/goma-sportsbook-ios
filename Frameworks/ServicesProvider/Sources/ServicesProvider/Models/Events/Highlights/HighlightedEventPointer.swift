//
//  HighlightedEventPointer.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct HighlightedEventPointer : Codable {
    public var status: String
    public var sportId: String
    public var eventId: String
    public var eventType: String?
    public var countryId: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case sportId = "sport_id"
        case eventId = "event_id"
        case eventType = "event_type"
        case countryId = "country_id"
    }
}
