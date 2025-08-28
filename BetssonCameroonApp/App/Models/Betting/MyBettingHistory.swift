
import Foundation

struct MyBettingHistory: Codable, Equatable {
    
    // MARK: - Properties
    
    let bets: [MyBet]
    
    // MARK: - Initialization
    
    init(bets: [MyBet]) {
        self.bets = bets
    }
    
    // MARK: - Convenience Properties
    
    /// Returns the total number of bets
    var count: Int {
        return bets.count
    }
    
    /// Returns true if there are no bets
    var isEmpty: Bool {
        return bets.isEmpty
    }
    
    /// Returns bets filtered by state
    func bets(withState state: MyBetState) -> [MyBet] {
        return bets.filter { $0.state == state }
    }
    
    /// Returns bets filtered by result
    func bets(withResult result: MyBetResult) -> [MyBet] {
        return bets.filter { $0.result == result }
    }
    
    /// Returns active (open) bets
    var activeBets: [MyBet] {
        return bets.filter { $0.isActive }
    }
    
    /// Returns settled bets
    var settledBets: [MyBet] {
        return bets.filter { $0.isSettled }
    }
    
    /// Returns won bets
    var wonBets: [MyBet] {
        return bets(withResult: .won)
    }
    
    /// Returns lost bets
    var lostBets: [MyBet] {
        return bets(withResult: .lost)
    }
    
    /// Returns bets that can be cashed out
    var cashoutEligibleBets: [MyBet] {
        return bets.filter { $0.canCashOut }
    }
    
    /// Returns total stake amount for all bets (in mixed currencies)
    var totalStakeAmount: Double {
        return bets.reduce(0) { $0 + $1.stake }
    }
    
    /// Returns total potential return for active bets (in mixed currencies)
    var totalPotentialReturn: Double {
        return activeBets.compactMap { $0.potentialReturn }.reduce(0, +)
    }
    
    /// Returns total return for settled bets (in mixed currencies)
    var totalActualReturn: Double {
        return settledBets.compactMap { $0.totalReturn }.reduce(0, +)
    }
    
    /// Returns bets sorted by date (newest first)
    var betsSortedByDate: [MyBet] {
        return bets.sorted { $0.date > $1.date }
    }
    
    /// Returns bets grouped by currency
    var betsGroupedByCurrency: [String: [MyBet]] {
        return Dictionary(grouping: bets) { $0.currency }
    }
}
