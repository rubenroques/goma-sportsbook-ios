//
//  CompetitionSectionViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/10/2021.
//

import Foundation


class CompetitionFilterSectionViewModel {

    var name: String
    var isExpanded: Bool
    var sectionIndex: Int
    var cells: [CompetitionFilterRowViewModel]

    init(name: String, isExpanded: Bool, sectionIndex: Int, cells: [CompetitionFilterRowViewModel]) {
        self.name = name
        self.isExpanded = isExpanded
        self.sectionIndex = sectionIndex
        self.cells = cells
    }

}
