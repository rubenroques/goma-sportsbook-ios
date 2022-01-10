//
//  SubmitedBetTableViewCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 10/01/2022.
//

import Foundation
import Combine

class SubmitedBetTableViewCellViewModel {

    var ticket: BetHistoryEntry

    private var cashoutRegister: EndpointPublisherIdentifiable?
    private var cashoutAvailabilitySubscription: AnyCancellable?
    var hasCashoutEnabled = CurrentValueSubject<Bool, Never>.init(false)

    var cashout: EveryMatrix.Cashout?
    private var cashoutSubscription: AnyCancellable?

    init(ticket: BetHistoryEntry) {
        self.ticket = ticket

        self.requestCashoutAvailability(ticket: self.ticket)
    }

    private func requestCashoutAvailability(ticket: BetHistoryEntry) {

        self.cashout = nil

        self.cashoutAvailabilitySubscription?.cancel()
        self.cashoutAvailabilitySubscription = nil

        if let cashoutRegister = cashoutRegister {
            TSManager.shared.unregisterFromEndpoint(endpointPublisherIdentifiable: cashoutRegister)
        }

        let endpoint = TSRouter.cashoutPublisher(operatorId: Env.appSession.operatorId,
                                                 language: "en",
                                                 betId: ticket.betId)

        self.cashoutAvailabilitySubscription = TSManager.shared
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
                    self?.cashoutRegister = publisherIdentifiable

                case .initialContent(let aggregator):
                    print("MyBets cashoutPublisher initialContent")

                    if let content = aggregator.content?.first {
                        switch content {
                        case .cashout(let cashout):
                            if let value = cashout.value {
                                self?.cashout = cashout
                                self?.hasCashoutEnabled.send(true)
                            }
                        default: ()
                        }
                    }

                case .updatedContent(let aggregatorUpdates):
                    print("MyBets cashoutPublisher updatedContent")
                    guard
                        let contentUpdates = aggregatorUpdates.contentUpdates
                    else {
                        return
                    }

                    for update in contentUpdates {
                        switch update {
                        case .cashoutUpdate(let id, let value, let stake):
                            if let cashout = self?.cashout {
                                let updatedCashout = cashout.cashoutUpdated(value: value, stake: stake)
                                self?.cashout = updatedCashout
                            }
                        default:
                            ()
                        }
                    }
                case .disconnect:
                    print("My Games cashoutPublisher disconnect")
                }
            })

    }

}
