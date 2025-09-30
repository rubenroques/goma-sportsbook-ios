//
//  Sport.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 21/07/2025.
//
import Foundation

struct Sport: Codable, Hashable {

    var id: String
    var name: String
    var alphaId: String?
    var numericId: String?
    var showEventCategory: Bool
    var liveEventsCount: Int
    var outrightEventsCount: Int
    var eventsCount: Int
    var hasMatches: Bool
    var hasOutrights: Bool

    init(id: String,
         name: String,
         alphaId: String?,
         numericId: String?,
         showEventCategory: Bool,
         liveEventsCount: Int,
         outrightEventsCount: Int = 0,
         eventsCount: Int = 0,
         hasMatches: Bool = false,
         hasOutrights: Bool = false) {
        
        self.id = id
        self.name = name
        self.alphaId = alphaId
        self.numericId = numericId
        self.showEventCategory = showEventCategory
        self.liveEventsCount = liveEventsCount
        self.outrightEventsCount = outrightEventsCount
        self.eventsCount = eventsCount
        self.hasMatches = hasMatches
        self.hasOutrights = hasOutrights
    }
    
}
