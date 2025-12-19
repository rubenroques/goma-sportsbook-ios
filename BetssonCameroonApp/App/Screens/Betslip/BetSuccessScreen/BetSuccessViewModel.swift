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
    public let betPlacedDetails: [BetPlacedDetails]

    // MARK: - Initialization
    init(
        betId: String? = nil,
        betslipId: String? = nil,
        bettingTickets: [BettingTicket] = [],
        betPlacedDetails: [BetPlacedDetails] = []
    ) {
        self.betId = betId
        self.betslipId = betslipId
        self.bettingTickets = bettingTickets
        self.betPlacedDetails = betPlacedDetails

        // Initialize status notification view model with success state
        let statusNotificationData = StatusNotificationData(type: .success, message: "Bet Placed", icon: "success_circle_icon")

        self.statusNotificationViewModel = MockStatusNotificationViewModel(data: statusNotificationData)
    }
} 
