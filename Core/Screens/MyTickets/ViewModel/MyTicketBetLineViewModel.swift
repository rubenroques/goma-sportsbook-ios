//
//  MyTicketBetLineViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 22/12/2021.
//

import Foundation
import Combine

class MyTicketBetLineViewModel {

    var homeScore = CurrentValueSubject<String?, Never>.init(nil)
    var awayScore = CurrentValueSubject<String?, Never>.init(nil)

    private var selection: BetHistoryEntrySelection

    init(selection: BetHistoryEntrySelection) {
        self.selection = selection

        if let matchId = self.selection.eventId {
            self.requestGoals(forMatchWithId: matchId)
        }
    }

    private func requestGoals(forMatchWithId id: String) {
        // TODO: Request goals updates
    }

}
