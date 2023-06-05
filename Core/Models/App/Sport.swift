//
//  Sport.swift
//  Sportsbook
//
//  Created by Ruben Roques on 14/01/2022.
//

import Foundation

struct Sport {

    let id: String
    let name: String
    let alphaId: String?
    let numericId: String?
    let showEventCategory: Bool
    let liveEventsCount: Int
    let outrightEventsCount: Int
    let eventsCount: Int

    init(id: String,
         name: String,
         alphaId: String?,
         numericId: String?,
         showEventCategory: Bool,
         liveEventsCount: Int,
         outrightEventsCount: Int = 0,
         eventsCount: Int) {
        self.id = id
        self.name = name
        self.alphaId = alphaId
        self.numericId = numericId
        self.showEventCategory = showEventCategory
        self.liveEventsCount = liveEventsCount
        self.outrightEventsCount = outrightEventsCount
        self.eventsCount = eventsCount
    }
    
}
