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

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}


extension CompetitionFilterRowViewModel {
    init(competition: Competition) {
        self.init(id: competition.id, name: competition.name)
    }
}
