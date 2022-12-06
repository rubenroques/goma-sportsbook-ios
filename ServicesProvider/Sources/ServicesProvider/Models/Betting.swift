//
//  Betting.swift
//  
//
//  Created by Ruben Roques on 16/11/2022.
//

import Foundation

public struct BettingHistory: Codable {
    public var bets: [Bet]
}

public struct Bet: Codable {
    public var identifier: String
    public var selections: [BetSelection]
    public var potentialReturn: Double
}

public struct BetSelection: Codable {
    public var identifier: String
    public var eventName: String
    public var homeTeamName: String
    public var awayTeamName: String
    public var marketName: String
    public var outcomeName: String
}


public struct BetSlip: Codable {
    public var tickets: [BetTicket]
}

public struct BetTicket: Codable {
    public var selection: [BetTicketSelection]
    public var betType: String
}

public struct BetTicketSelection: Codable {
    public var identifier: String
    public var eventName: String
    public var homeTeamName: String
    public var awayTeamName: String
    public var marketName: String
    public var outcomeName: String
}

public struct BetslipState: Codable {
    
}
