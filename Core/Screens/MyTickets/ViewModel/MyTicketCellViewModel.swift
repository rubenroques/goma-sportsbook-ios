//
//  MyTicketCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 22/12/2021.
//

import Foundation
import Combine
import ServicesProvider

class MyTicketCellViewModel {

    var title: String = ""

    var hasCashoutEnabled = CurrentValueSubject<CashoutButtonState, Never>.init(.hidden)
    var isLoadingCellData = CurrentValueSubject<Bool, Never>.init(false)

    var selections: [MyTicketBetLineViewModel] = []

    var requestDataRefreshAction: (() -> Void)?

    private var ticket: BetHistoryEntry

    private var cashoutRegister: EndpointPublisherIdentifiable?
    private var cashoutAvailabilitySubscription: AnyCancellable?

//    private var cashout: EveryMatrix.Cashout?
    private var cashout: CashoutInfo?

    private var cashoutSubscription: AnyCancellable?

    private var cancellables = Set<AnyCancellable>()

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
            self.title = localized("single") + " - \(self.betStatusText(forCode: ticket.status?.uppercased() ?? "-"))"
        }
        else if ticket.type == "MULTIPLE" {
            self.title = localized("multiple") + " - \(self.betStatusText(forCode: ticket.status?.uppercased() ?? "-"))"
        }
        else if ticket.type == "SYSTEM" {
            self.title = localized("system") + " - \(ticket.systemBetType?.capitalized ?? "") - \(self.betStatusText(forCode: ticket.status?.uppercased() ?? "-"))"
        }

    }

    deinit {
        print("MyTicketCellViewModel deinit")
        self.unregisterCashoutSubscription()
    }

    private func requestCashoutAvailability(ticket: BetHistoryEntry) {
        // CASHOUT HERE

        Env.servicesProvider.calculateCashout(betId: ticket.betId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("CASHOUT INFO ERROR: \(error)")
                }
            }, receiveValue: { [weak self] cashoutInfo in

                let cashout = CashoutInfo(id: ticket.betId, betId: ticket.betId, value: cashoutInfo.cashoutValue, stake: ticket.totalBetAmount)

                self?.cashout = cashout
                self?.hasCashoutEnabled.send( .visible(cashoutInfo.cashoutValue))

            })
            .store(in: &cancellables)

//        self.cashout = nil
//
//        self.cashoutAvailabilitySubscription?.cancel()
//        self.cashoutAvailabilitySubscription = nil
//
//        if let cashoutRegister = cashoutRegister {
//            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: cashoutRegister)
//        }
//
//        let endpoint = TSRouter.cashoutPublisher(operatorId: Env.appSession.operatorId,
//                                                 language: "en",
//                                                 betId: ticket.betId)
//
//        self.cashoutAvailabilitySubscription = Env.everyMatrixClient.manager
//            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure:
//                    print("Error retrieving data!")
//                case .finished:
//                    print("Data retrieved!")
//                }
//            }, receiveValue: { [weak self] state in
//                switch state {
//                case .connect(let publisherIdentifiable):
//                    self?.cashoutRegister = publisherIdentifiable
//                case .initialContent(let aggregator):
//                    print("MyBets cashoutPublisher initialContent")
//                    if let content = aggregator.content?.first {
//                        switch content {
//                        case .cashout(let cashout):
//                            if let value = cashout.value {
//                                self?.cashout = cashout
//                                self?.hasCashoutEnabled.send( .visible(value) )
//                            }
//                        default: ()
//                        }
//                    }
//                case .updatedContent:
//                    print("MyBets cashoutPublisher updatedContent")
//                case .disconnect:
//                    print("MyBets cashoutPublisher disconnect")
//                }
//            })

    }

    private func betStatusText(forCode code: String) -> String {
        switch code {
        case "OPEN": return localized("open")
        case "DRAW": return localized("draw")
        case "WON": return localized("won")
        case "HALF_WON": return localized("half_won")
        case "LOST": return localized("lost")
        case "HALF_LOST": return localized("half_lost")
        case "CANCELLED": return localized("cancelled")
        case "CASHED_OUT": return localized("cashed_out")
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

        if let betId = cashout.betId,
           let cashoutValue = cashout.value,
           let stakeValue = cashout.stake {

            self.isLoadingCellData.send(true)

            Env.servicesProvider.cashoutBet(betId: betId, cashoutValue: cashoutValue, stakeValue: stakeValue)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("CASHOUT RESULT ERROR: \(error)")
                        self?.isLoadingCellData.send(false)
                    }
                }, receiveValue: { [weak self] cashoutResult in
                    print("CASHOUT RESULT: \(cashoutResult)")

                    if cashoutResult.cashoutResultSuccess {
                        self?.requestDataRefreshAction?()
                        self?.isLoadingCellData.send(false)
                    }

                })
                .store(in: &cancellables)
        }
//        let route = TSRouter.cashoutBet(language: "en", betId: cashout.id)
//        self.cashoutSubscription = Env.everyMatrixClient.manager
//            .getModel(router: route, decodingType: CashoutSubmission.self)
//            .delay(for: .seconds(5), scheduler: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] _ in
//                self?.requestDataRefreshAction?()
//                self?.isLoadingCellData.send(false)
//            }, receiveValue: { _ in
//
//            })
    }

    func unregisterCashoutSubscription() {
        
        if let cashoutRegister = self.cashoutRegister {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: cashoutRegister)
        }

        self.cashoutAvailabilitySubscription?.cancel()
        self.cashoutAvailabilitySubscription = nil

        self.cashoutSubscription?.cancel()
        self.cashoutSubscription = nil
    }

}
