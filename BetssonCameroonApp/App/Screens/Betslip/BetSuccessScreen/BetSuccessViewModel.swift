//
//  BetSuccessViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import GomaUI

final class BetSuccessViewModel: BetSuccessViewModelProtocol {

    // MARK: - Child View Models
    public let statusNotificationViewModel: StatusNotificationViewModelProtocol

    // MARK: - Properties
    public let betId: String?
    public let betslipId: String?
    public let bettingTickets: [BettingTicket]

    // MARK: - Initialization
    init(
        betId: String? = nil,
        betslipId: String? = nil,
        bettingTickets: [BettingTicket] = []
    ) {
        self.betId = betId
        self.betslipId = betslipId
        self.bettingTickets = bettingTickets

        print("[BET_PLACEMENT] 📱 Success ViewModel created - betId: \(betId ?? "nil"), betslipId: \(betslipId ?? "nil"), tickets: \(bettingTickets.count)")
        if bettingTickets.count > 0 {
            bettingTickets.enumerated().forEach { index, ticket in
                print("[BET_PLACEMENT]   [\(index+1)] \(ticket.matchDescription) - \(ticket.outcomeDescription)")
            }
        }

        // Initialize status notification view model with success state
        let statusNotificationData = StatusNotificationData(type: .success, message: "Bet Placed", icon: "success_circle_icon")

        self.statusNotificationViewModel = MockStatusNotificationViewModel(data: statusNotificationData)
    }
} 
