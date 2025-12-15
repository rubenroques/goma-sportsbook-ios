//
//  BetBuilderBettingTicketDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/06/2024.
//

import UIKit

class BetBuilderBettingTicketDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    var bettingTickets: [BettingTicket] = []
    var invalidBettingTicketIds: [String] = []
    
    init(bettingTickets: [BettingTicket]) {
        self.bettingTickets = bettingTickets
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bettingTickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(MultipleBettingTicketTableViewCell.self),
            let bettingTicket = self.bettingTickets[safe: indexPath.row]
        else {
            fatalError()
        }
        
        let isInvalid = self.invalidBettingTicketIds.contains(bettingTicket.id)
        cell.configureWithBettingTicket(bettingTicket,
                                        showInvalidView: isInvalid,
                                        mixMatchMode: true)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
    
}
