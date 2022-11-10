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
    let showEventCategory: Bool
    let liveEventsCount: Int

    init(id: String,
         name: String = "",
         showEventCategory: Bool = false,
         liveEventsCount: Int = 0) {
        self.id = id
        self.name = name
        self.showEventCategory = showEventCategory
        self.liveEventsCount = liveEventsCount
    }

    static var football: Sport {
        return Sport(id: "1", name: "Football", showEventCategory: false, liveEventsCount: 0)
    }
    
}

extension Sport {
    
    init(discipline: EveryMatrix.Discipline) {
        self.init(id: discipline.id, name: discipline.name ?? "", showEventCategory: discipline.showEventCategory ?? false, liveEventsCount: discipline.numberOfLiveEvents ?? 0)
    }
    
}
