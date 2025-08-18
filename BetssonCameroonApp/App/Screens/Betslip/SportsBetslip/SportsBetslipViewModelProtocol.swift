//
//  SportsBetslipViewModelProtocol.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import Combine
import GomaUI

/// Protocol defining the interface for SportsBetslipViewController ViewModels
public protocol SportsBetslipViewModelProtocol {
    /// Publisher for tickets updates
    var ticketsPublisher: AnyPublisher<[BettingTicket], Never> { get }
    
    /// Current tickets data (for immediate access)
    var currentTickets: [BettingTicket] { get }
    
    // MARK: - Child View Models
    var bookingCodeButtonViewModel: ButtonIconViewModelProtocol { get set}
    var clearBetslipButtonViewModel: ButtonIconViewModelProtocol { get set}
    var emptyStateViewModel: EmptyStateActionViewModelProtocol { get set }
    var betInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol { get set }
    
    var betslipLoggedState: ((BetslipLoggedState) -> Void)? { get set }
    var showPlacedBetState: ((BetPlacedState) -> Void)? { get set }

    var isLoadingSubject: CurrentValueSubject<Bool, Never> { get set }

    /// Remove a specific ticket
    func removeTicket(_ ticket: BettingTicket)
    
    /// Clear all tickets from the betslip
    func clearAllTickets()
} 
