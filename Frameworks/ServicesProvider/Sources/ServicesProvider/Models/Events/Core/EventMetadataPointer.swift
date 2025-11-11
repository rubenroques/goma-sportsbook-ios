//
//  EventMetadataPointer.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public class EventMetadataPointer: Codable {

    public var id: String?
    public var eventId: String
    public var eventMarketId: String
    public var callToActionURL: String?
    public var imageURL: String?

    init(id: String?, eventId: String, eventMarketId: String, callToActionURL: String?, imageURL: String?) {
        self.id = id
        self.eventId = eventId
        self.eventMarketId = eventMarketId
        self.callToActionURL = callToActionURL
        self.imageURL = imageURL
    }

}
