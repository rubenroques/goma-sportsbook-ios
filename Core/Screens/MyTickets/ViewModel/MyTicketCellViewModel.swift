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

    var requestAlertAction: ((String, String) -> Void)?
    var requestPartialAlertAction: ((String, String) -> Void)?

    var showCashoutSuspendedAction: (() -> Void)?
    var showCashoutState: ((AlertType, String) -> Void)?

    var ticket: BetHistoryEntry

    var cashout: CashoutInfo?
    var partialCashout: CurrentValueSubject<CashoutInfo?, Never> = .init(nil)

    var partialCashoutSliderValue: Double?

    var hasSetupPartialCashoutSlider: Bool = false

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
    }

    func requestCashoutAvailability() {
        let ticket = self.ticket

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

    }

    func requestPartialCashoutAvailability(ticket: BetHistoryEntry, stakeValue: String) {
        Env.servicesProvider.calculateCashout(betId: ticket.betId, stakeValue: stakeValue)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("PARTIAL CASHOUT INFO ERROR: \(error)")
                    self?.partialCashout.send(nil)
                }
            }, receiveValue: { [weak self] cashoutInfo in
                let partialCashout = CashoutInfo(id: ticket.betId, betId: ticket.betId, value: cashoutInfo.cashoutValue, stake: ticket.totalBetAmount)
                self?.partialCashout.send(partialCashout)
            })
            .store(in: &cancellables)

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
                        print("CASHOUT ERROR: \(error)")
                        switch error {
                        case .errorMessage(let message):
                            self?.showCashoutState?(.error, message)
                        default:
                            ()
                        }
                        self?.isLoadingCellData.send(false)
                    }
                }, receiveValue: { [weak self] cashoutResult in
                    if cashoutResult.cashoutResult == -1 {
                        self?.requestDataRefreshAction?()
                        self?.isLoadingCellData.send(false)
                        self?.showCashoutState?(.success, localized("cashout_success_text"))
                    }
                    else if cashoutResult.cashoutResult == 1 {
                        if let cashoutReoffer = cashoutResult.cashoutReoffer,
                           let ticket = self?.ticket {
                            self?.requestCashoutAvailability()
                            self?.requestAlertAction?("\(cashoutReoffer)", ticket.betId)
                            self?.isLoadingCellData.send(false)
                        }
                    }
                    else {
                        self?.showCashoutSuspendedAction?()
                        self?.requestDataRefreshAction?()
                        self?.cashout = nil
                        self?.hasCashoutEnabled.send(.hidden)
                        self?.isLoadingCellData.send(false)
                    }

                })
                .store(in: &cancellables)
        }

    }

    func requestPartialCashout() {

        guard let partialCashout = self.partialCashout.value else { return }

        if let betId = partialCashout.betId,
           let cashoutValue = partialCashout.value,
           let stakeValue = self.partialCashoutSliderValue {

            self.isLoadingCellData.send(true)

            Env.servicesProvider.cashoutBet(betId: betId, cashoutValue: cashoutValue, stakeValue: stakeValue)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("CASHOUT ERROR: \(error)")
                        switch error {
                        case .errorMessage(let message):
                            self?.showCashoutState?(.error, message)
                        default:
                            ()
                        }
                        self?.isLoadingCellData.send(false)
                    }
                }, receiveValue: { [weak self] cashoutResult in
                    if cashoutResult.cashoutResult == -1 {
                        self?.requestDataRefreshAction?()
                        self?.isLoadingCellData.send(false)
                        self?.showCashoutState?(.success, localized("cashout_success_text"))
                    }
                    else if cashoutResult.cashoutResult == 1 {
                        if let cashoutReoffer = cashoutResult.cashoutReoffer,
                           let ticket = self?.ticket {
                            self?.requestPartialCashoutAvailability(ticket: ticket, stakeValue: "\(stakeValue)")
                            self?.requestPartialAlertAction?("\(cashoutReoffer)", ticket.betId)
                            self?.isLoadingCellData.send(false)
                        }
                    }
                    else {
                        self?.showCashoutSuspendedAction?()
                        self?.requestDataRefreshAction?()
                        self?.cashout = nil
                        self?.hasCashoutEnabled.send(.hidden)
                        self?.isLoadingCellData.send(false)
                    }

                })
                .store(in: &cancellables)
        }

    }

}
