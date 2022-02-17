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

    init(id: String,
         name: String = "",
         showEventCategory: Bool = false) {
        self.id = id
        self.name = name
        self.showEventCategory = showEventCategory
    }

    static var football: Sport {
        return Sport(id: "1", name: "Football", showEventCategory: false)
    }
    
}

extension Sport {
    init(discipline: EveryMatrix.Discipline) {
        self.init(id: discipline.id, name: discipline.name ?? "", showEventCategory: discipline.showEventCategory ?? false)
    }
}
