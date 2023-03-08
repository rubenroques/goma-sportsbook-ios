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

    private var goalsRegister: EndpointPublisherIdentifiable?
    private var goalsSubscription: AnyCancellable?

    private var selection: BetHistoryEntrySelection

    init(selection: BetHistoryEntrySelection) {
        self.selection = selection

        if let matchId = self.selection.eventId {
            self.requestGoals(forMatchWithId: matchId)
        }
    }

    deinit {
        print("MyTicketBetLineViewModel deinit")

        if let goalsRegister = goalsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: goalsRegister)
        }

        self.goalsSubscription?.cancel()
        self.goalsSubscription = nil
    }

    private func requestGoals(forMatchWithId id: String) {

        self.goalsSubscription?.cancel()
        self.goalsSubscription = nil

    }

}
