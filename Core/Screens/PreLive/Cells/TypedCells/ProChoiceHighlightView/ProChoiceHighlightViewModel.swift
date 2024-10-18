//
//  ProChoiceHighlightViewModel.swift
//  GomaUI
//
//  Created by Ruben Roques on 16/10/2024.
//

struct ProChoiceHighlightViewModel {
    let title: String
    let description: String
    let leagueName: String
    let matchDate: String
    let matchTime: String
    let teamsName: String
    let homeOdds: String?
    let drawOdds: String?
    let awayOdds: String?
}

extension ProChoiceHighlightViewModel {
    static let empty: ProChoiceHighlightViewModel = ProChoiceHighlightViewModel(
        title: "",
        description: "",
        leagueName: "",
        matchDate: "",
        matchTime: "",
        teamsName: "",
        homeOdds: nil,
        drawOdds: nil,
        awayOdds: nil)
}
