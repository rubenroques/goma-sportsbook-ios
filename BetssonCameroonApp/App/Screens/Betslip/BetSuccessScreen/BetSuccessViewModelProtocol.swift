//
//  BetSuccessViewModelProtocol.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import Combine
import GomaUI

/// Protocol defining the interface for BetSuccessViewController ViewModels
public protocol BetSuccessViewModelProtocol {
    /// Status notification view model for displaying success information
    var statusNotificationViewModel: StatusNotificationViewModelProtocol { get }

    /// Bet ID (booking code) for sharing and viewing details
    var betId: String? { get }

    /// Betslip ID (alternative identifier from response)
    var betslipId: String? { get }

    /// List of betting tickets that were placed
    var bettingTickets: [BettingTicket] { get }
} 