import Foundation
import Combine
import UIKit

/// State for the odds change indicator
public enum OddsChangeState: Equatable {
    case none
    case increased
    case decreased
}

/// Data model for the betslip ticket view
public struct BetslipTicketData: Equatable {
    public let leagueName: String
    public let startDate: String
    public let homeTeam: String
    public let awayTeam: String
    public let selectedTeam: String
    public let oddsValue: String
    public let oddsChangeState: OddsChangeState
    public let isEnabled: Bool
    public let bettingOfferId: String?
    public let disabledMessage: String?
    
    public init(leagueName: String, startDate: String, homeTeam: String, awayTeam: String, selectedTeam: String, oddsValue: String, oddsChangeState: OddsChangeState = .none, isEnabled: Bool = true, bettingOfferId: String? = nil, disabledMessage: String? = nil) {
        self.leagueName = leagueName
        self.startDate = startDate
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.selectedTeam = selectedTeam
        self.oddsValue = oddsValue
        self.oddsChangeState = oddsChangeState
        self.isEnabled = isEnabled
        self.bettingOfferId = bettingOfferId
        self.disabledMessage = disabledMessage
    }
}

/// Protocol defining the interface for BetslipTicketView ViewModels
public protocol BetslipTicketViewModelProtocol: AnyObject {
    /// Publisher for the betslip ticket data
    var dataPublisher: AnyPublisher<BetslipTicketData, Never> { get }
    
    /// Publisher specifically for odds change state (for animations)
    var oddsChangeStatePublisher: AnyPublisher<OddsChangeState, Never> { get }
    
    /// Current data (for immediate access)
    var currentData: BetslipTicketData { get }
    
    /// Update the league name
    func updateLeagueName(_ leagueName: String)
    
    /// Update the start date
    func updateStartDate(_ startDate: String)
    
    /// Update the home team
    func updateHomeTeam(_ homeTeam: String)
    
    /// Update the away team
    func updateAwayTeam(_ awayTeam: String)
    
    /// Update the selected team
    func updateSelectedTeam(_ selectedTeam: String)
    
    /// Update the odds value
    func updateOddsValue(_ oddsValue: String)
    
    /// Update the odds change state
    func updateOddsChangeState(_ state: OddsChangeState)
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
    
    /// Callback closure for close button tap
    var onCloseTapped: (() -> Void)? { get set }
} 