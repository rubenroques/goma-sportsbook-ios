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
    
    /// Publisher for tickets invalid state (tracks forbidden combinations and invalid selections)
    var ticketsInvalidStatePublisher: AnyPublisher<TicketsInvalidState, Never> { get }
    
    /// Current tickets invalid state (for immediate access)
    var ticketsInvalidState: TicketsInvalidState { get }
    
    /// Publisher for betBuilder selections (betting offer IDs)
    var betBuilderSelectionsPublisher: AnyPublisher<Set<String>, Never> { get }
    
    /// Current betBuilder selections (for immediate access)
    var betBuilderSelections: Set<String> { get }
    
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
} 
