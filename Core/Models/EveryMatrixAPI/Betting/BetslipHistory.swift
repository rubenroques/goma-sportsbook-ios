//
//  BetslipHistory.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/11/2021.
//

import Foundation

// MARK: - BetHistoryRow
struct BetHistoryResponse {
    var betList: [BetHistoryEntry]?

    enum CodingKeys: String, CodingKey {
        case betList = "betList"
    }
}

struct BetHistoryEntry {
    let betId: String
    let selections: [BetHistoryEntrySelection]?
    let type: String?
    let systemBetType: String?
    let amount: Double?
    let totalBetAmount: Double?
    let freeBetAmount: Int?
    let bonusBetAmount: Int?
    let currency: String?
    let maxWinning: Double?
    let totalPriceValue: Double?
    let overallBetReturns: Double?
    let numberOfSelections: Int?
    let status: String?
    let placedDate: Date?
    let settledDate: Date?
    let freeBet: Bool?

    let betShareToken: String?

    enum CodingKeys: String, CodingKey {
        case betId = "betId"
        case selections = "selections"
        case type = "type"
        case systemBetType = "systemBetType"
        case amount = "amount"
        case totalBetAmount = "totalBetAmount"
        case freeBetAmount = "freeBetAmount"
        case bonusBetAmount = "bonusBetAmount"
        case currency = "currency"
        case maxWinning = "maxWinning"
        case totalPriceValue = "totalPriceValue"
        case numberOfSelections = "numberOfSelections"
        case overallBetReturns = "overallBetReturns"
        case status = "status"
        case placedDate = "placedDate"
        case settledDate = "settledDate"
        case freeBet = "freeBet"

        case betShareToken = "betShareToken"
    }
}

// MARK: - Selection
enum BetSelectionStatus: String, Codable, CaseIterable {
    case opened
    case closed
    case settled
    case cancelled
    case won
    case lost
    case cashedOut
    case undefined
}

enum BetSelectionResult: String, Codable, CaseIterable {
    case won
    case halfWon
    case lost
    case halfLost
    case drawn
    case open
    case undefined
}

struct BetHistoryEntrySelection: Codable {
    let outcomeId: String
    let status: BetSelectionStatus
    let result: BetSelectionResult
    let priceValue: Double?
    let sportId: String?
    let sportName: String?
    let venueId: String?
    let venueName: String?
    let tournamentId: String?
    let tournamentName: String?
    let eventId: String?
    let eventStatusId: String?
    let eventName: String?
    let eventResult: String?
    let eventDate: Date?
    let bettingTypeId: String?
    let bettingTypeName: String?
    let bettingTypeEventPartId: String?
    let bettingTypeEventPartName: String?

    let homeParticipantName: String?
    let awayParticipantName: String?

    let homeParticipantScore: String?
    let awayParticipantScore: String?

    let marketName: String?
    let betName: String?

    enum CodingKeys: String, CodingKey {
        case outcomeId = "outcomeId"
        case status = "status"
        case result = "result"
        case priceValue = "priceValue"
        case sportId = "sportId"
        case sportName = "sportName"
        case venueId = "venueId"
        case venueName = "venueName"
        case tournamentId = "tournamentId"
        case tournamentName = "tournamentName"
        case eventId = "eventId"
        case eventName = "eventName"
        case eventResult = "eventResult"
        case eventStatusId = "eventStatusId"
        case eventDate = "eventDate"
        case bettingTypeId = "bettingTypeId"
        case bettingTypeName = "bettingTypeName"
        case bettingTypeEventPartId = "bettingTypeEventPartId"
        case bettingTypeEventPartName = "bettingTypeEventPartName"

        case homeParticipantName = "homeParticipantName"
        case awayParticipantName = "awayParticipantName"

        case homeParticipantScore = "homeParticipantScore"
        case awayParticipantScore = "awayParticipantScore"

        case marketName = "marketName"
        case betName = "betName"
    }
}
