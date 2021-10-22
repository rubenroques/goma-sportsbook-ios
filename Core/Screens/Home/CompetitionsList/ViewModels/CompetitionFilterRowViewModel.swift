//
//  CompetitionFilterRowViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/10/2021.
//

import Foundation

struct CompetitionFilterRowViewModel {

    var id: String = ""
    var name: String = ""
    var isSelected: Bool = false

    init(id: String, name: String, isSelected: Bool) {
        self.id = id
        self.name = name
        self.isSelected = isSelected
    }
}


extension CompetitionFilterRowViewModel {
    init(competition: Competition) {
        self.init(id: competition.id, name: competition.name, isSelected: false)
    }
}
