//
//  CompetitionSectionViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/10/2021.
//

import Foundation

struct CompetitionFilterSectionViewModel {

    var id: String
    var name: String
    var cells: [CompetitionFilterRowViewModel]

    init(id: String, name: String, cells: [CompetitionFilterRowViewModel]) {
        self.id = id
        self.name = name
        self.cells = cells
    }

}

extension CompetitionFilterSectionViewModel {
    init(index: Int, competitionGroup: CompetitionGroup) {
        self.init(id: competitionGroup.id,
                  name: competitionGroup.name,
                  cells: competitionGroup.competitions.map(CompetitionFilterRowViewModel.init(competition:)))
    }
}
