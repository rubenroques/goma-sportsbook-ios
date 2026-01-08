//
//  SingleBettingTicketDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/06/2024.
//

import UIKit

class SingleBettingTicketDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    var shouldHighlightTextfield: () -> Bool = { return false }

    var bettingTickets: [BettingTicket] = []

    var didUpdateBettingValueAction: ((String, Double) -> Void)?
    var bettingValueForId: ((String) -> (Double?))?

    var isFreeBetSelected: Bool = false
    var currentTicketFreeBetSelected: SingleBetslipFreebet?
    var changedFreebetSelectionState: ((SingleBetslipFreebet?) -> Void)?

    var isOddsBoostSelected: Bool = false
    var currentTicketOddsBoostSelected: SingleBetslipOddsBoost?
    var changedOddsBoostSelectionState: ((SingleBetslipOddsBoost?) -> Void)?
    var tableNeedsDebouncedReload: (() -> Void)?

    init(bettingTickets: [BettingTicket]) {
        self.bettingTickets = bettingTickets
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bettingTickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(SingleBettingTicketTableViewCell.self),
            let bettingTicket = self.bettingTickets[safe: indexPath.row]
        else {
            fatalError()
        }
        let bettingAmount = self.bettingValueForId?(bettingTicket.id)

        let shouldHighlightTextfield = self.shouldHighlightTextfield()
        cell.configureWithBettingTicket(bettingTicket,
                                        previousBettingAmount: bettingAmount,
                                        shouldHighlightTextfield: shouldHighlightTextfield)

        cell.didUpdateBettingValueAction = self.didUpdateBettingValueAction
        cell.shouldHighlightTextfield = { [weak self] in
            return self?.shouldHighlightTextfield() ?? false
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }

}
