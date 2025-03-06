//
//  MultipleBettingTicketDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/06/2024.
//

import UIKit

class MultipleBettingTicketDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    var bettingTickets: [BettingTicket] = []
    var bonusMultiple: [BonusMultipleBetslip] = []

    var freebetSelected: Bool = false
    var changedFreebetSelectionState: ((BetslipFreebet?) -> Void)?

    var oddsBoostSelected: Bool = false
    var changedOddsBoostSelectionState: ((BetslipOddsBoost?) -> Void)?
    var isBetBuilderActive: Bool = false

    init(bettingTickets: [BettingTicket]) {
        self.bettingTickets = bettingTickets
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (bettingTickets.count + bonusMultiple.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueCellType(MultipleBettingTicketTableViewCell.self),
           let bettingTicket = self.bettingTickets[safe: indexPath.row] {
            // Always set mixMatchMode to false for MultipleBettingTicketDataSource
            // This is for regular multiple bets, not MixMatch bets
            cell.configureWithBettingTicket(bettingTicket, mixMatchMode: false)
            return cell
        }
        else if let cell = tableView.dequeueCellType(BonusSwitchTableViewCell.self),
                    let bonusMultiple = self.bonusMultiple[safe: (indexPath.row - self.bettingTickets.count)] {

            if let freeBet = bonusMultiple.freeBet {
                cell.setupBonusInfo(freeBet: freeBet, oddsBoost: nil, bonusType: .freeBet)

                cell.didTappedSwitch = { [weak self] in
                    if cell.isSwitchOn {
                        self?.changedFreebetSelectionState?(freeBet)
                    }
                    else {
                        self?.changedFreebetSelectionState?(nil)
                    }
                }
            }
            else if let oddsBoost = bonusMultiple.oddsBoost {
                cell.setupBonusInfo(freeBet: nil, oddsBoost: oddsBoost, bonusType: .oddsBoost)

                cell.didTappedSwitch = { [weak self] in
                    if cell.isSwitchOn {
                        self?.changedOddsBoostSelectionState?(oddsBoost)
                    }
                    else {
                        self?.changedOddsBoostSelectionState?(nil)
                    }
                }
            }
            return cell
        }
        else {
            fatalError()
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row <= self.bettingTickets.count - 1 {
            return 99
        }
        return 50
    }
}
