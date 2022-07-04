//
//  BetSelectionCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 23/05/2022.
//

import Foundation
import Combine

class BetSelectionCellViewModel {

    var isCheckboxSelectedPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var ticket: BetHistoryEntry

    init(ticket: BetHistoryEntry) {
        self.ticket = ticket
    }

    func selectTicket() {
        self.isCheckboxSelectedPublisher.send(true)
    }

    func unselectTicket() {
        self.isCheckboxSelectedPublisher.send(false)
    }

    func betSelections() -> [BetHistoryEntrySelection] {
        return ticket.selections ?? []
    }

    var id: String {
        self.ticket.betId
    }
    
    var oddValueString: String {
        return OddConverter.stringForValue(self.ticket.totalPriceValue ?? 0.0, format: UserDefaults.standard.userOddsFormat)
    }

    var betAmountString: String {
        let currencyFormatter = CurrencyFormater()
        let betAmount = currencyFormatter.currencyTypeFormatting(string: "\(self.ticket.totalBetAmount)")
        return betAmount

    }

    var possibleWinningString: String {
        let currencyFormatter = CurrencyFormater()
        let possibleWinning = currencyFormatter.currencyTypeFormatting(string: "\(self.ticket.maxWinning)")
        return possibleWinning

    }
}
