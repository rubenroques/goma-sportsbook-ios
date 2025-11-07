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
    
    /// Publisher for combined tickets state (invalid state + bet builder data)
    var ticketsStatePublisher: AnyPublisher<BetslipTicketsState, Never> { get }
    
    /// Current tickets state (for immediate access)
    var ticketsState: BetslipTicketsState { get }
    
    /// Convenience accessor for tickets invalid state
    var ticketsInvalidState: TicketsInvalidState { get }
    
    /// Convenience accessor for betBuilder data
    var betBuilderData: BetBuilderData? { get }
    
    // MARK: - Child View Models
    var bookingCodeButtonViewModel: ButtonIconViewModelProtocol { get set}
    var clearBetslipButtonViewModel: ButtonIconViewModelProtocol { get set}
    var emptyStateViewModel: EmptyStateActionViewModelProtocol { get set }
    var betInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol { get set }
    var oddsAcceptanceViewModel: OddsAcceptanceViewModelProtocol { get set }
    var codeInputViewModel: CodeInputViewModelProtocol { get set }
    var loginButtonViewModel: ButtonViewModelProtocol { get set }
    var betslipOddsBoostHeaderViewModel: BetslipOddsBoostHeaderViewModelProtocol { get }
    
    var betslipLoggedState: ((BetslipLoggedState) -> Void)? { get set }
    var showPlacedBetState: ((BetPlacedState) -> Void)? { get set }
    var showLoginScreen: (() -> Void)? { get set }
    var showToastMessage: ((String) -> Void)? { get set }

    var isLoadingSubject: CurrentValueSubject<Bool, Never> { get set }
    
    // MARK: - Recommended Matches
    var suggestedBetsViewModel: SuggestedBetsExpandedViewModelProtocol { get }
    var toasterViewModel: ToasterViewModelProtocol { get }

    // MARK: - Odds Boost Header Visibility
    var oddsBoostHeaderVisibilityPublisher: AnyPublisher<Bool, Never> { get }

    /// Remove a specific ticket
    func removeTicket(_ ticket: BettingTicket)
    
    /// Clear all tickets from the betslip
    func clearAllTickets()
    
    /// Gets or creates a ticket view model, tracking odds changes
    func getTicketViewModel(
        for ticket: BettingTicket,
        isEnabled: Bool,
        disabledMessage: String?,
        formattedDate: String?
    ) -> MockBetslipTicketViewModel
} 
