//
//  CompetitionFilterRowViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/10/2021.
//

import Foundation

struct CompetitionFilterRowViewModel: Identifiable {

    var id: String = ""
    var name: String = ""

    var competition: Competition

    init(competition: Competition) {
        self.id =  competition.id
        self.name = competition.name
        self.competition = competition
    }
    
}
