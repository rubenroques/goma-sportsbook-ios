//
//  News.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 19/02/2025.
//

import Foundation

public struct News: Codable {
    public var id: Int
    public var title: String
    public var slug: String?
    public var image: String?
    public var content: String
    public var sportEventId: Int?
    public var status: String?
    public var startDate: Date?
    public var endDate: Date?
    public var userType: String?
    public var order: Int
    public var event: Event?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case slug = "slug"
        case image = "image"
        case content = "content"
        case sportEventId = "sport_event_id"
        case status = "status"
        case startDate = "start_date"
        case endDate = "end_date"
        case userType = "user_type"
        case order = "order"
        case event = "event"
    }
}
