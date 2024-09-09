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

    var cashoutReoffer: Double?

    var hasSetupPartialCashoutSlider: Bool = false

    private var cashoutSubscription: AnyCancellable?

    var hasRedraw: Bool = false

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

        if ticket.type?.lowercased() == "single" {
            self.title = localized("single")+" - \(ticket.localizedBetStatus.capitalized)"
        }
        else if ticket.type?.lowercased() == "multiple" {
            self.title = localized("multiple")+" - \(ticket.localizedBetStatus.capitalized)"
        }
        else if ticket.type?.lowercased() == "system" {
            self.title = localized("system")+" - \(ticket.systemBetType?.capitalized ?? "") - \(ticket.localizedBetStatus.capitalized)"
        }
        else if ticket.type?.lowercased() == "mix_match" {
            self.title = localized("mix-match")+" - \(ticket.localizedBetStatus.capitalized)"
        }
        else {
            self.title = String([ticket.type, ticket.localizedBetStatus]
                .compactMap({ $0 })
                .map({ $0.capitalized })
                .joined(separator: " - "))
        }

        if let isFreeBet = ticket.freeBet {
            if !isFreeBet {
                self.requestCashoutAvailability()
            }
        }
        else {
            self.requestCashoutAvailability()
        }

    }

    deinit {
        // print("MyTicketCellViewModel.deinit")
    }

    func requestCashoutAvailability() {
        let ticket = self.ticket
        
        let stake = String(format: "%.2f", ticket.totalBetAmount ?? 0.0)

        Env.servicesProvider.calculateCashout(betId: ticket.betId, stakeValue: stake)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
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

        // Reset cashout reoffer value
        self.cashoutReoffer = nil

        Env.servicesProvider.calculateCashout(betId: ticket.betId, stakeValue: stakeValue)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.partialCashout.send(nil)
                }
            }, receiveValue: { [weak self] cashoutInfo in
                let partialCashout = CashoutInfo(id: ticket.betId, betId: ticket.betId, value: cashoutInfo.cashoutValue, stake: ticket.totalBetAmount)
                self?.partialCashout.send(partialCashout)
            })
            .store(in: &cancellables)

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

            Env.servicesProvider.cashoutBet(betId: betId, cashoutValue: cashoutValue)
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
                            //self?.requestCashoutAvailability()
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
                .store(in: &self.cancellables)
        }

    }

    func requestPartialCashout() {

        guard let partialCashout = self.partialCashout.value else { return }

        if let betId = partialCashout.betId,
           let cashoutValue = self.cashoutReoffer == nil ? partialCashout.value : self.cashoutReoffer,
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
                            //self?.requestPartialCashoutAvailability(ticket: ticket, stakeValue: "\(stakeValue)")
                            self?.cashoutReoffer = cashoutReoffer
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
                .store(in: &self.cancellables)
        }

    }

}
