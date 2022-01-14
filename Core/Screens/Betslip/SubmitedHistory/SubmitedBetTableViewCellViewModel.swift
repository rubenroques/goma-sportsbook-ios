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
    var cashoutValueSubscription: CurrentValueSubject<Double, Never> = .init(0)
    var cashoutSubscription: CurrentValueSubject<EveryMatrix.Cashout, Never>?

    var updateCashoutValue: PassthroughSubject<Void, Never> = .init()
    var createdCashout: PassthroughSubject<Void, Never> = .init()
    var deletedCashout: PassthroughSubject<Void, Never> = .init()

    init(ticket: BetHistoryEntry) {
        self.ticket = ticket

        self.requestCashoutAvailability(ticket: self.ticket)
    }

    private func requestCashoutAvailability(ticket: BetHistoryEntry) {

        self.cashout = nil

        self.cashoutAvailabilitySubscription?.cancel()
        self.cashoutAvailabilitySubscription = nil

        if let cashoutRegister = cashoutRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: cashoutRegister)
        }

        let endpoint = TSRouter.cashoutPublisher(operatorId: Env.appSession.operatorId,
                                                 language: "en",
                                                 betId: ticket.betId)

        self.cashoutAvailabilitySubscription = Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.CashoutAggregator.self)
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
                                self?.cashoutSubscription = .init(cashout)
                                self?.cashoutValueSubscription.send(value)
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
                                self?.cashoutSubscription?.send(updatedCashout)
                                self?.updateCashoutValue.send()
                                if let cashoutValue = self?.cashout?.value {
                                    self?.cashoutValueSubscription.send(cashoutValue)
                                }
                            }
                        case .cashoutCreate(let cashout):
                            self?.cashout = cashout
                            self?.createdCashout.send()
                            self?.hasCashoutEnabled.send(true)
                        case .cashoutDelete(let cashoutId):
                            if let cashout = self?.cashout {
                                self?.cashout = nil
                                self?.hasCashoutEnabled.send(false)
                                self?.deletedCashout.send()
                            }
                        default:
                            ()
                        }
                    }
                case .disconnect:
                    print("MyBets cashoutPublisher disconnect")
                }
            })

    }

}
