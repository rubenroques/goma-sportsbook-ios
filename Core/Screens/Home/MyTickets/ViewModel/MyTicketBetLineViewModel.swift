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
        self.goalsSubscription?.cancel()
        self.goalsSubscription = nil

        if let goalsRegister = goalsRegister {
            TSManager.shared.unregisterFromEndpoint(endpointPublisherIdentifiable: goalsRegister)
        }
    }

    private func requestGoals(forMatchWithId id: String) {

        self.goalsSubscription?.cancel()
        self.goalsSubscription = nil

        if let goalsRegister = goalsRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: goalsRegister)
        }

        let endpoint = TSRouter.eventPartScoresPublisher(operatorId: Env.appSession.operatorId, language: "en", matchId: id)

        self.goalsSubscription = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    self?.goalsRegister = publisherIdentifiable
                case .initialContent(let aggregator):
                    print("MyBets cashoutPublisher initialContent")

                    for content in (aggregator.content ?? []) {
                        switch content {
                        case .eventPartScore(let eventPartScore):
                            if let eventInfoTypeId = eventPartScore.eventInfoTypeID, eventInfoTypeId == "1" {
                                self?.homeScore.send(eventPartScore.homeScore ?? nil)
                                self?.awayScore.send(eventPartScore.awayScore ?? nil)
                            }
                        default: ()
                        }
                    }
                case .updatedContent(let aggregatorUpdates):
                    print("MyBets cashoutPublisher updatedContent")
                case .disconnect:
                    print("MyBets cashoutPublisher disconnect")
                }
            })
    }

}
