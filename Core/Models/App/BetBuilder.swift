//
//  BetBuilder.swift
//  Sportsbook
//
//  Created by Ruben Roques on 31/07/2024.
//

import Foundation
import Combine

enum BetBuilderCalculateResponse: Codable {
    case valid(potentialReturn: BetPotencialReturn, tickets: [BettingTicket])
    case invalid(tickets: [BettingTicket])
}
 
enum BetBuilderTicketState: Codable, Hashable {
    case valid(ticket: BettingTicket)
    case invalid(ticket: BettingTicket)
}

struct BetBuilderState: Codable, Hashable {
    var tickets: [BetBuilderTicketState] = []
    var calculatedOddForValidTickets: Double?
    var errorMessageKey: String?
}

class BetBuilderProcessor: Codable {
    
    private var invalidTicketsSubject: CurrentValueSubject<[BettingTicket], Never> = .init([])
    
    var calculatedOddForValidTickets: Double = 0.0
    
    var validTickets: [BettingTicket] = []
    var ignoredTickets: [BettingTicket] = []
    
    var invalidTicketsPublisher: AnyPublisher<[BettingTicket], Never> {
        return self.invalidTicketsSubject.eraseToAnyPublisher()
    }
    
    var ticketsToIgnore: [BettingTicket] {
        return self.invalidTicketsSubject.value
    }
    
    var exposedValidTickets: [BettingTicket] {
        return validTickets
    }
    
    var hasValidTickets: Bool {
        return self.validTickets.isNotEmpty
    }
    
    
    enum CodingKeys: String, CodingKey {
        case calculatedOddForValidTickets
        case validTickets
        case ignoredTickets
        case invalidTicketsSubjectValue
    }
    
    init() {
        
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.calculatedOddForValidTickets = try container.decode(Double.self, forKey: .calculatedOddForValidTickets)
        self.validTickets = try container.decode([BettingTicket].self, forKey: .validTickets)
        self.ignoredTickets = try container.decode([BettingTicket].self, forKey: .ignoredTickets)
        let invalidTickets = try container.decode([BettingTicket].self, forKey: .invalidTicketsSubjectValue)
        self.invalidTicketsSubject = CurrentValueSubject<[BettingTicket], Never>(invalidTickets)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.calculatedOddForValidTickets, forKey: .calculatedOddForValidTickets)
        try container.encode(self.validTickets, forKey: .validTickets)
        try container.encode(self.ignoredTickets, forKey: .ignoredTickets)
        try container.encode(self.invalidTicketsSubject.value, forKey: .invalidTicketsSubjectValue)
    }
    
    func resetProcessor() {
        self.calculatedOddForValidTickets = 0.0
        self.validTickets = []
        self.invalidTicketsSubject.send([])
        self.ignoredTickets = []
    }
    
    func processValidTickets(_ tickets: [BettingTicket]) {
        self.validTickets = tickets
        self.processDifferences()
    }
    
    func processInvalidTickets(_ tickets: [BettingTicket]) {
        // Filter out any tickets that are in validTickets
        self.invalidTicketsSubject.send(tickets.filter{!validTickets.contains($0)})
        self.processDifferences()
    }
    
    private func processDifferences() {
        let validTicketSet = Set(self.validTickets)
        let invalidTicketSet = Set(self.invalidTicketsSubject.value)
        
        // Tickets that are in invalidTickets but not in validTickets should be ignored
        self.ignoredTickets = invalidTicketSet.subtracting(validTicketSet).sorted(by: { $0.id < $1.id })
    }
}
