//
//  MyTicketCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 22/12/2021.
//

import Foundation
import Combine

class MyTicketCellViewModel {

    var title: String = ""

    var hasCashoutEnabled = CurrentValueSubject<CashoutButtonState, Never>.init(.hidden)
    var isLoadingCellData = CurrentValueSubject<Bool, Never>.init(false)

    var selections: [MyTicketBetLineViewModel] = []

    var requestDataRefreshAction: (() -> Void)?

    private var ticket: BetHistoryEntry

    private var cashoutRegister: EndpointPublisherIdentifiable?
    private var cashoutAvailabilitySubscription: AnyCancellable?

    private var cashout: EveryMatrix.Cashout?
    private var cashoutSubscription: AnyCancellable?

    enum CashoutButtonState: Equatable {
        case hidden
        case visible(Double)

        static func == (lhs: CashoutButtonState, rhs: CashoutButtonState) -> Bool {
            switch (lhs, rhs) {
            case (.hidden, .hidden): return true
            case (.hidden, .visible): return false
            case (.visible, .hidden): return false
            case (.visible(let leftValue), .visible(let rightValue)):
                return leftValue == rightValue
            }
        }
    }
    

    init(ticket: BetHistoryEntry) {
        self.ticket = ticket

        self.requestCashoutAvailability(ticket: self.ticket)

        for selection in self.ticket.selections ?? [] {
            self.selections.append( MyTicketBetLineViewModel(selection: selection) )
        }

        if ticket.type == "SINGLE" {
            self.title = "Single - \(self.betStatusText(forCode: ticket.status?.uppercased() ?? "-"))"
        }
        else if ticket.type == "MULTIPLE" {
            self.title = "Multiple - \(self.betStatusText(forCode: ticket.status?.uppercased() ?? "-"))"
        }
        else if ticket.type == "SYSTEM" {
            self.title = "System - \(ticket.systemBetType?.capitalized ?? "") - \(self.betStatusText(forCode: ticket.status?.uppercased() ?? "-"))"
        }

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
                                self?.hasCashoutEnabled.send( .visible(value) )
                            }
                        default: ()
                        }
                    }

                case .updatedContent(let aggregatorUpdates):
                    print("MyBets cashoutPublisher updatedContent")
                case .disconnect:
                    print("My Games cashoutPublisher disconnect")
                }
            })

    }

    private func betStatusText(forCode code: String) -> String {
        switch code {
        case "OPEN": return "Open"
        case "DRAW": return "Draw"
        case "WON": return "Won"
        case "HALF_WON": return "Half Won"
        case "LOST": return "Lost"
        case "HALF_LOST": return "Half Lost"
        case "CANCELLED": return "Cancelled"
        case "CASHED_OUT": return "Cashed Out"
        default: return ""
        }
    }

    static var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()

    func requestCashout() {

        guard let cashout = self.cashout else { return }

        self.isLoadingCellData.send(true)

        let route = TSRouter.cashoutBet(language: "en", betId: cashout.id)
        self.cashoutSubscription = TSManager.shared
            .getModel(router: route, decodingType: CashoutSubmission.self)
            .delay(for: .seconds(5), scheduler: RunLoop.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.requestDataRefreshAction?()
                self?.isLoadingCellData.send(false)
            }, receiveValue: { _ in

            })
    }

}
