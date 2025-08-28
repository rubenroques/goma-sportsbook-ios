
import Foundation

struct MyBetSelection: Codable, Equatable, Hashable {
    
    // MARK: - Core Properties
    
    let identifier: String
    let state: MyBetState
    let result: MyBetResult
    let globalState: MyBetState
    
    // MARK: - Event Information
    
    let eventName: String
    let homeTeamName: String?
    let awayTeamName: String?
    let eventDate: Date?
    let tournamentName: String
    let sport: Sport?
    
    // MARK: - Market Information
    
    let marketName: String
    let outcomeName: String
    let odd: OddFormat
    let marketId: String?
    let outcomeId: String?
    
    // MARK: - Score Information
    
    let homeResult: String?
    let awayResult: String?
    
    // MARK: - Additional Properties
    
    let eventId: String
    let country: Country?
    
    // MARK: - Initialization
    
    init(
        identifier: String,
        state: MyBetState,
        result: MyBetResult,
        globalState: MyBetState,
        eventName: String,
        homeTeamName: String?,
        awayTeamName: String?,
        eventDate: Date?,
        tournamentName: String,
        sport: Sport?,
        marketName: String,
        outcomeName: String,
        odd: OddFormat,
        marketId: String?,
        outcomeId: String?,
        homeResult: String?,
        awayResult: String?,
        eventId: String,
        country: Country?
    ) {
        self.identifier = identifier
        self.state = state
        self.result = result
        self.globalState = globalState
        self.eventName = eventName
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.eventDate = eventDate
        self.tournamentName = tournamentName
        self.sport = sport
        self.marketName = marketName
        self.outcomeName = outcomeName
        self.odd = odd
        self.marketId = marketId
        self.outcomeId = outcomeId
        self.homeResult = homeResult
        self.awayResult = awayResult
        self.eventId = eventId
        self.country = country
    }
    
    // MARK: - Convenience Properties
    
    /// Returns a formatted string representing the match participants
    var matchDescription: String {
        if let homeTeam = homeTeamName, let awayTeam = awayTeamName {
            return "\(homeTeam) vs \(awayTeam)"
        }
        return eventName
    }
    
    /// Returns a formatted string representing the full selection description
    var fullSelectionDescription: String {
        return "\(matchDescription): \(marketName) - \(outcomeName)"
    }
    
    
    /// Returns a formatted score string if available
    var scoreDescription: String? {
        guard let homeScore = homeResult, let awayScore = awayResult else {
            return nil
        }
        return "\(homeScore) - \(awayScore)"
    }
    
    /// Returns true if the selection has a defined result
    var hasResult: Bool {
        return result != .notSpecified && result != .pending
    }
}
