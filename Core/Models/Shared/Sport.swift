//
//  Sport.swift
//  Sportsbook
//
//  Created by Ruben Roques on 14/01/2022.
//

import Foundation

struct Sport {

    let id: String
    var type: SportType
    let name: String
    let showEventCategory: Bool

    init(id: String, type: SportType = .unknown, name: String = "", showEventCategory: Bool = false) {
        self.id = id
        self.type = type
        self.name = name
        self.showEventCategory = showEventCategory
    }

    static var football: Sport {
        return Sport(id: "1", type: .football, name: "Football", showEventCategory: false)
    }
    
}
