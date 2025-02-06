//
//  CompetitionSectionViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/10/2021.
//

import Foundation

struct CompetitionFilterSectionViewModel: Identifiable {

    var id: String
    var name: String
    var cells: [CompetitionFilterRowViewModel]
    var country: Country?

    init(id: String, name: String, cells: [CompetitionFilterRowViewModel], country: Country? = nil) {
        self.id = id
        self.name = name
        self.cells = cells
        self.country = country
    }

}

extension CompetitionFilterSectionViewModel {
    init(index: Int, competitionGroup: CompetitionGroup) {
        self.init(id: competitionGroup.id,
                  name: competitionGroup.name,
                  cells: competitionGroup.competitions.map(CompetitionFilterRowViewModel.init(competition:)),
                  country: competitionGroup.country)
    }
}
