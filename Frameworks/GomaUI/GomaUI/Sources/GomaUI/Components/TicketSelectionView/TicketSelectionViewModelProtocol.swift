import Foundation
import Combine
import UIKit

// MARK: - TicketSelectionData
public struct TicketSelectionData: Equatable {
    public let id: String
    public let competitionName: String
    public let homeTeamName: String
    public let awayTeamName: String
    public let homeScore: Int
    public let awayScore: Int
    public let matchDate: String
    public let isLive: Bool
    public let sportIcon: String?
    public let countryFlag: String?
    public let marketName: String
    public let selectionName: String
    public let oddsValue: String
    
    public init(
        id: String,
        competitionName: String,
        homeTeamName: String,
        awayTeamName: String,
        homeScore: Int = 0,
        awayScore: Int = 0,
        matchDate: String,
        isLive: Bool = false,
        sportIcon: String? = nil,
        countryFlag: String? = nil,
        marketName: String = "Market",
        selectionName: String = "Selection",
        oddsValue: String = "0.00"
    ) {
        self.id = id
        self.competitionName = competitionName
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.matchDate = matchDate
        self.isLive = isLive
        self.sportIcon = sportIcon
        self.countryFlag = countryFlag
        self.marketName = marketName
        self.selectionName = selectionName
        self.oddsValue = oddsValue
    }
}

// MARK: - TicketSelectionViewModelProtocol
public protocol TicketSelectionViewModelProtocol: AnyObject {
    // Current data for immediate access (required for table view sizing)
    var currentTicketData: TicketSelectionData { get }
    
    // Publisher for dynamic updates (optional for real-time changes)
    var ticketDataPublisher: AnyPublisher<TicketSelectionData, Never> { get }
    
    // Actions
    var onTicketTapped: (() -> Void)? { get set }
    
    // Methods
    func handleTicketTap()
} 
