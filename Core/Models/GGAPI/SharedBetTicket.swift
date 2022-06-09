//
//  SharedBetTicket.swift
//  Sportsbook
//
//  Created by Ruben Roques on 26/05/2022.
//

import Foundation

struct SharedBetTicketAttachment: Codable, Hashable {

    var id: String
    var type: String
    var fromUser: String
    var content: SharedBetTicket

    enum CodingKeys: String, CodingKey {
        case id = "value"
        case type = "type"
        case fromUser = "fromUser"
        case content = "content"
    }

    init(id: String, type: String, fromUser: String, content: SharedBetTicket) {
        self.id = id
        self.type = type
        self.fromUser = fromUser
        self.content = content
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(String.self, forKey: .type)
        self.fromUser = try container.decode(String.self, forKey: .fromUser)

        if let contentAsString = try? container.decode(String.self, forKey: .content),
           let contentData = contentAsString.data(using: .utf8),
           let contentFromString = try? JSONDecoder().decode(SharedBetTicket.self, from: contentData) {
            self.content = contentFromString
        }
        else if let typedContent = try? container.decode(SharedBetTicket.self, forKey: .content) {
            self.content = typedContent
        }
        else {
            throw GomaGamingSocialServiceClient.SocketError.invalidContent
        }

    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(fromUser, forKey: .fromUser)

//        let jsonData = try JSONEncoder().encode(content)
//        let dictionary: [String: AnyObject] = (try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
//            as? [String: AnyObject]) ?? [:]
//
//        try container.encode(dictionary.json(), forKey: .content)
        try container.encode(content, forKey: .content)
    }

}

struct SharedBetTicket: Codable, Hashable {

    let betId: String
    let selections: [SharedBetTicketSelection]?
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
        case betId = "id"
        case selections = "bet_selections"
        case type = "bet_type"
        case systemBetType = "systemBetType"
        case amount = "stake"
        case totalBetAmount = "totalBetAmount"
        case freeBetAmount = "freeBetAmount"
        case bonusBetAmount = "bonusBetAmount"
        case currency = "currency"
        case maxWinning = "max_winning"
        case totalPriceValue = "total_odds"
        case numberOfSelections = "numberOfSelections"
        case overallBetReturns = "overallBetReturns"
        case status = "status"
        case placedDate = "placedDate"
        case settledDate = "settledDate"
        case freeBet = "freeBet"
        case betShareToken = "betShareToken"
    }

}

extension SharedBetTicket {

    init(betHistoryEntry: BetHistoryEntry, betShareToken: String? = nil) {
        let mappedSelections = betHistoryEntry.selections?.compactMap({ $0 }).map(SharedBetTicketSelection.init(selection:))
        self.init(betId: betHistoryEntry.betId,
                  selections: mappedSelections,
                  type: betHistoryEntry.type,
                  systemBetType: betHistoryEntry.systemBetType,
                  amount: betHistoryEntry.amount,
                  totalBetAmount: betHistoryEntry.totalBetAmount,
                  freeBetAmount: betHistoryEntry.freeBetAmount,
                  bonusBetAmount: betHistoryEntry.bonusBetAmount,
                  currency: betHistoryEntry.currency,
                  maxWinning: betHistoryEntry.maxWinning,
                  totalPriceValue: betHistoryEntry.totalPriceValue,
                  overallBetReturns: betHistoryEntry.overallBetReturns,
                  numberOfSelections: betHistoryEntry.numberOfSelections,
                  status: betHistoryEntry.status,
                  placedDate: betHistoryEntry.placedDate,
                  settledDate: betHistoryEntry.settledDate,
                  freeBet: betHistoryEntry.freeBet,
                  betShareToken: betShareToken)
    }

}

extension BetHistoryEntry {

    init(sharedBetTicket: SharedBetTicket) {

        let mappedSelections = sharedBetTicket.selections?.compactMap({ $0 }).map(BetHistoryEntrySelection.init(sharedBetTicketSelection:))

        self.init(betId: sharedBetTicket.betId,
                  selections: mappedSelections,
                  type: sharedBetTicket.type,
                  systemBetType: sharedBetTicket.systemBetType,
                  amount: sharedBetTicket.amount,
                  totalBetAmount: sharedBetTicket.totalBetAmount,
                  freeBetAmount: sharedBetTicket.freeBetAmount,
                  bonusBetAmount: sharedBetTicket.bonusBetAmount,
                  currency: sharedBetTicket.currency,
                  maxWinning: sharedBetTicket.maxWinning,
                  totalPriceValue: sharedBetTicket.totalPriceValue,
                  overallBetReturns: sharedBetTicket.overallBetReturns,
                  numberOfSelections: sharedBetTicket.numberOfSelections,
                  status: sharedBetTicket.status,
                  placedDate: sharedBetTicket.placedDate,
                  settledDate: sharedBetTicket.settledDate,
                  freeBet: sharedBetTicket.freeBet,
                  betShareToken: sharedBetTicket.betShareToken)
    }

}

// MARK: - Selection
struct SharedBetTicketSelection: Codable, Hashable {
    
    let outcomeId: String
    let status: String?
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

    let marketName: String?
    let betName: String?

    enum CodingKeys: String, CodingKey {
        case outcomeId = "outcomeId"
        case status = "status"
        case priceValue = "odds"
        case sportId = "sport_id"
        case sportName = "sport"
        case venueId = "location_id"
        case venueName = "location"
        case tournamentId = "tournamentId"
        case tournamentName = "competition"
        case eventId = "event_id"
        case eventName = "event_name"
        case eventResult = "eventResult"
        case eventStatusId = "eventStatusId"
        case eventDate = "eventDate"
        case bettingTypeId = "betting_type_id"
        case bettingTypeName = "bettingTypeName"
        case bettingTypeEventPartId = "event_part_id"
        case bettingTypeEventPartName = "bettingTypeEventPartName"

        case homeParticipantName = "home_team"
        case awayParticipantName = "away_team"

        case marketName = "bet_type"
        case betName = "outcome_name"

    }
}

extension SharedBetTicketSelection {

    init(selection: BetHistoryEntrySelection) {
        self.init(outcomeId: selection.outcomeId,
                  status: selection.status,
                  priceValue: selection.priceValue,
                  sportId: selection.sportId,
                  sportName: selection.sportName,
                  venueId: selection.venueId,
                  venueName: selection.venueName,
                  tournamentId: selection.tournamentId,
                  tournamentName: selection.tournamentName,
                  eventId: selection.eventId,
                  eventStatusId: selection.eventStatusId,
                  eventName: selection.eventName,
                  eventResult: selection.eventResult,
                  eventDate: selection.eventDate,
                  bettingTypeId: selection.bettingTypeId,
                  bettingTypeName: selection.bettingTypeName,
                  bettingTypeEventPartId: selection.bettingTypeEventPartId,
                  bettingTypeEventPartName: selection.bettingTypeEventPartName,
                  homeParticipantName: selection.homeParticipantName,
                  awayParticipantName: selection.awayParticipantName,
                  marketName: selection.marketName,
                  betName: selection.betName)
    }

}

extension BetHistoryEntrySelection {
    init(sharedBetTicketSelection: SharedBetTicketSelection) {
        self.init(outcomeId: sharedBetTicketSelection.outcomeId,
                  status: sharedBetTicketSelection.status,
                  priceValue: sharedBetTicketSelection.priceValue,
                  sportId: sharedBetTicketSelection.sportId,
                  sportName: sharedBetTicketSelection.sportName,
                  venueId: sharedBetTicketSelection.venueId,
                  venueName: sharedBetTicketSelection.venueName,
                  tournamentId: sharedBetTicketSelection.tournamentId,
                  tournamentName: sharedBetTicketSelection.tournamentName,
                  eventId: sharedBetTicketSelection.eventId,
                  eventStatusId: sharedBetTicketSelection.eventStatusId,
                  eventName: sharedBetTicketSelection.eventName,
                  eventResult: sharedBetTicketSelection.eventResult,
                  eventDate: sharedBetTicketSelection.eventDate,
                  bettingTypeId: sharedBetTicketSelection.bettingTypeId,
                  bettingTypeName: sharedBetTicketSelection.bettingTypeName,
                  bettingTypeEventPartId: sharedBetTicketSelection.bettingTypeEventPartId,
                  bettingTypeEventPartName: sharedBetTicketSelection.bettingTypeEventPartName,
                  homeParticipantName: sharedBetTicketSelection.homeParticipantName,
                  awayParticipantName: sharedBetTicketSelection.awayParticipantName,
                  marketName: sharedBetTicketSelection.marketName,
                  betName: sharedBetTicketSelection.betName)
    }
}
