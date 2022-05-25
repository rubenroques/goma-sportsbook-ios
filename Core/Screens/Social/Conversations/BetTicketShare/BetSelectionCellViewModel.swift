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

    private var ticket: BetHistoryEntry

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

    var oddValueString: String {
        return OddConverter.stringForValue(self.ticket.totalPriceValue ?? 0.0, format: UserDefaults.standard.userOddsFormat)
    }

}
