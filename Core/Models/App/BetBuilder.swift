//
//  BetBuilder.swift
//  Sportsbook
//
//  Created by Ruben Roques on 31/07/2024.
//

import Foundation
import Combine
import ServicesProvider

enum BetBuilderCalculateResponse: Codable {
    case valid(potentialReturn: BetPotencialReturn, tickets: [BettingTicket])
    case invalid(tickets: [BettingTicket])
}

enum BetBuilderTicketState: Codable, Hashable, CustomStringConvertible {
    case valid(ticket: BettingTicket)
    case invalid(ticket: BettingTicket)
    
    var description: String {
        switch self {
        case .valid(let ticket):
            return "Valid(\(ticket.id))"
        case .invalid(let ticket):
            return "Invalid(\(ticket.id))"
        }
    }
}

struct BetBuilderState: Codable, Hashable, CustomStringConvertible {
    var tickets: [BetBuilderTicketState] = []
    var odd: Double?
    var potentialReturn: Double?
    var messageKey: MessageKey?
    var isBetAllowed: Bool
    
    enum MessageKey: Codable, Hashable, CustomStringConvertible {
        case error(key: String)
        case warning(key: String)
        
        var description: String {
            switch self {
            case .error(let key):
                return "Error(key: \(key))"
            case .warning(let key):
                return "Warning(key: \(key))"
            }
        }
    }
    
    init(tickets: [BetBuilderTicketState] = [],
         odd: Double? = nil,
         potentialReturn: Double? = nil,
         messageKey: MessageKey? = nil,
         isBetAllowed: Bool = false) {
        self.tickets = tickets
        self.odd = odd
        self.potentialReturn = potentialReturn
        self.messageKey = messageKey
        self.isBetAllowed = isBetAllowed
    }
    
    var description: String {
        let ticketsDescription = tickets.map { $0.description }.joined(separator: ", ")
        let oddDescription = odd != nil ? "\(odd!)" : "nil"
        let potentialReturnDescription = potentialReturn != nil ? "\(potentialReturn!)" : "nil"
        let messageDescription = messageKey?.description ?? "nil"
        return "BetBuilderState(tickets: [\(ticketsDescription)], odd: \(oddDescription), pReturn: \(potentialReturnDescription) message: \(messageDescription), betAllowed: \(isBetAllowed))"
    }
}

class BetBuilderTransformer {
    
    var stake: Double = 0.0
    var state: AnyPublisher<BetBuilderState, Never> {
        return self.stateSubject.eraseToAnyPublisher()
    }
    
    private var stateSubject: CurrentValueSubject<BetBuilderState, Never>
    
    private var bettingTicketsSubject: CurrentValueSubject<[BettingTicket], Never> = .init([])
    
    private var invalidTicketsIds: Set<String> = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(initialState: BetBuilderState = BetBuilderState(), bettingTickets: [BettingTicket] = []) {
        self.stateSubject = .init(initialState)
        
        self.bettingTicketsSubject
            .removeDuplicates()
            .withPrevious([])
            .sink { (previousTickets: [BettingTicket], currentTickets: [BettingTicket]) in
                
                if currentTickets.count > previousTickets.count {
                    // Adding tickets
                    // request to check if the last is valid
                    self.requestReturn(forValidTickets: currentTickets)
                }
                else if currentTickets.count < previousTickets.count {
                    // Removing tickets
                    // Try to request with all of them
                    self.requestReturn(forAllTickets: currentTickets)
                }
                
                if currentTickets.isEmpty {
                    self.invalidTicketsIds.removeAll()
                }
            }
            .store(in: &self.cancellables)
        
        self.bettingTicketsSubject.send(bettingTickets)
        
        self.state
            .sink { newBetBuilderState in
                print("DebugTransformer: newState: \(newBetBuilderState)")
            }
            .store(in: &self.cancellables)
    }
    
    func updateBettingTickets(_ bettingTickets: [BettingTicket]) {
        self.bettingTicketsSubject.send(bettingTickets)
    }
    
    private func requestReturn(forValidTickets tickets: [BettingTicket]) {
        let validTickets = tickets.filter({ !self.invalidTicketsIds.contains($0.id) })
        self.requestBetBuilderPotentialReturnForTickets(validTickets, withStake: 0.0)
            .sink { [weak self] completion in
                
                switch completion {
                case .finished:
                    print("DebugTransformer: requestCompatibles finished")
                case .failure(let error):
                    print("DebugTransformer: requestCompatibles failure \(error)")
                    switch error {
                    case .emptyBetslip:
                        break
                    case .insufficientSelections:
                        break
                    case .invalidBetBuilderSelections:
                        // Mark last one as invalid
                        if let lastTicketId = tickets.last?.id {
                            self?.invalidTicketsIds.insert(lastTicketId)
                        }
                        print("DebugTransformer: requestCompatibles failure last is invalid, tagging it and retryng")
                    default:
                        print("DebugTransformer: requestCompatibles failure other \(error)")
                    }
                    self?.computeState(tickets, odd: nil, potentialReturn: nil)
                }
                
            } receiveValue: { [weak self] betBuilderCalculateResponse in
                guard let self else { return }
                print("DebugTransformer: requestCompatibles: \(betBuilderCalculateResponse)")
               
                self.validateTickets(validTickets)
                self.computeState(tickets, odd: betBuilderCalculateResponse.totalOdd,  potentialReturn: betBuilderCalculateResponse.potentialReturn)
            }
            .store(in: &self.cancellables)
    }
    
    private func requestReturn(forAllTickets tickets: [BettingTicket]) {
        self.requestBetBuilderPotentialReturnForTickets(tickets, withStake: 0.0)
            .sink { [weak self] completion in
                
                switch completion {
                case .finished:
                    print("DebugTransformer: requestCompatibles finished")
                case .failure(let error):
                    print("DebugTransformer: requestCompatibles failure \(error)")
                    switch error {
                    case .emptyBetslip:
                        break
                    case .insufficientSelections:
                        break
                    case .invalidBetBuilderSelections:
                        self?.requestReturn(forValidTickets: tickets)
                        print("DebugTransformer: requestCompatibles failure last is invalid, tagging it and retryng")
                    default:
                        print("DebugTransformer: requestCompatibles failure other \(error)")
                    }
                    self?.computeState(tickets, odd: nil, potentialReturn: nil)
                }
                
            } receiveValue: { [weak self] betBuilderCalculateResponse in
                guard let self else { return }
                print("DebugTransformer: requestCompatibles: \(betBuilderCalculateResponse)")
                self.validateTickets(tickets)
                self.computeState(tickets, odd: betBuilderCalculateResponse.totalOdd, potentialReturn: betBuilderCalculateResponse.potentialReturn)
            }
            .store(in: &self.cancellables)
    }
    
    private func validateTickets(_ tickets: [BettingTicket]) {
        print("DebugTransformer: Validate tickets: \(tickets.map({ $0.id + "-" + $0.outcomeDescription }))")
        tickets.forEach { bettingTicket in
            self.invalidTicketsIds.remove(bettingTicket.id)
        }
    }
    
        
    private func computeState(_ tickets: [BettingTicket], odd: Double?, potentialReturn: Double?) {
        let messageForTickets = self.messageForTickets(tickets)
        
        let betBuilderTickets = tickets.map { bettingTicket in
            if self.invalidTicketsIds.contains(bettingTicket.id) {
                return BetBuilderTicketState.invalid(ticket: bettingTicket)
            }
            else {
                return BetBuilderTicketState.valid(ticket: bettingTicket)
            }
        }
        
        self.stateSubject.send(BetBuilderState(tickets: betBuilderTickets,
                                               odd: odd,
                                               potentialReturn: potentialReturn,
                                               messageKey: messageForTickets,
                                               isBetAllowed: (odd != nil && potentialReturn != nil)) )
    }
    
    
    private func messageForTickets(_ tickets: [BettingTicket]) -> BetBuilderState.MessageKey? {
        // Check if there are any tickets that are not compatible
        // let someSelectionsNotCompatible = tickets.first { !($0.compatibleForBetBuilderGroup ?? false) } != nil
        // Count tickets that are bettable
        // let countBettableSelections = tickets.filter { $0.compatibleForBetBuilderGroup ?? false }.count
        
        // Check if there are any tickets that are not compatible
        let someSelectionsNotCompatible = tickets.contains { invalidTicketsIds.contains($0.id) }
        // Count tickets that are bettable (not in invalidTicketsIds)
        let countBettableSelections = tickets.filter { !invalidTicketsIds.contains($0.id) }.count

        
        let someSelectionsNotAvailable = tickets.filter { !$0.isAvailable }.count > 1
        
        let allTicketsFromSameEvent = Set(tickets.map { $0.matchId }).count == 1
        
        let allTicketsFromBetBuilderMarket = tickets.allSatisfy { $0.isFromBetBuilderMarket ?? false }
        
        //
        if tickets.isEmpty {
            return BetBuilderState.MessageKey.error(key: "multiple_min_selection_total_error")
        }
        else if tickets.count == 1, let firstTicket = tickets.first {
            let isValidTicket = firstTicket.isFromBetBuilderMarket ?? false
            if isValidTicket {
                return BetBuilderState.MessageKey.error(key: "multiple_min_selection_total_error")
            }
            else {
                return BetBuilderState.MessageKey.error(key: "multiple_min_selection_total_error")
            }
        }
        else if someSelectionsNotAvailable {
            return BetBuilderState.MessageKey.error(key: "some_selections_unavailable")
        }
        else if countBettableSelections < 2 {
            return BetBuilderState.MessageKey.error(key: "mix_match_min_compatible_selections")
        }
        else if someSelectionsNotCompatible {
            return BetBuilderState.MessageKey.warning(key: "mix_match_compatible_selections_warning")
        }
        else if !allTicketsFromSameEvent {
            return BetBuilderState.MessageKey.error(key: "mix_match_selections_different_events_error")
        }
        else if !allTicketsFromBetBuilderMarket {
            return BetBuilderState.MessageKey.error(key: "mix_match_some_selections_not_custom_available")
        }
        
        return nil
    }
    
    func requestBetBuilderPotentialReturnForTickets(_ tickets: [BettingTicket], withStake stake: Double) -> AnyPublisher<BetPotencialReturn, BetslipErrorType> {

        guard
            tickets.isNotEmpty
        else  {
            return Fail(error: BetslipErrorType.emptyBetslip)
                .eraseToAnyPublisher()
        }
        
        guard
            tickets.count > 1
        else  {
            return Fail(error: BetslipErrorType.insufficientSelections)
                .eraseToAnyPublisher()
        }
        
        let betTicketSelections = tickets.map { bettingTicket in
            let odd = ServiceProviderModelMapper.serviceProviderOddFormat(fromOddFormat: bettingTicket.odd)
            let betTicketSelection = ServicesProvider.BetTicketSelection(identifier: bettingTicket.id,
                                                                         eventName: "",
                                                                         homeTeamName: "",
                                                                         awayTeamName: "",
                                                                         marketName: "",
                                                                         outcomeName: "",
                                                                         odd: odd,
                                                                         stake: stake,
                                                                         sportIdCode: bettingTicket.sportIdCode)
            return betTicketSelection
        }
        
        let betTicket = BetTicket(tickets: betTicketSelections,
                                  stake: stake,
                                  betGroupingType: BetGroupingType.multiple(identifier: ""))
        
        return Env.servicesProvider.calculateBetBuilderPotentialReturn(forBetTicket: betTicket)
            .map({ betslipPotentialReturn in
                let potencialReturn = BetPotencialReturn(potentialReturn: betslipPotentialReturn.potentialReturn,
                                                         totalStake: stake,
                                                         numberOfBets: 1,
                                                         totalOdd: betslipPotentialReturn.calculatedOdds)
                return potencialReturn
            })
            .catch { error -> AnyPublisher<BetPotencialReturn, BetslipErrorType> in
                switch error {
                case .pageNotFound, .badRequest:
                    return Fail(error: BetslipErrorType.invalidBetBuilderSelections)
                        .eraseToAnyPublisher()
                    
                case .forbidden:
                    return Fail(error: BetslipErrorType.forbiddenRequest)
                        .eraseToAnyPublisher()
                    
                case .errorMessage(let message):
                    if message.contains("bet_error") {
                        return Fail(error: BetslipErrorType.betPlacementDetailedError(message: localized(message)))
                            .eraseToAnyPublisher()
                    }
                    return Fail(error: BetslipErrorType.betPlacementDetailedError(message: message))
                        .eraseToAnyPublisher()
                case .notPlacedBet(let message):
                
                    return Fail(error: BetslipErrorType.betPlacementDetailedError(message: message))
                            .eraseToAnyPublisher()
                    
                case .betNeedsUserConfirmation(let betDetails):
                    return Fail(error: BetslipErrorType.betNeedsUserConfirmation(betDetails: betDetails))
                        .eraseToAnyPublisher()
                default:
                    return Fail(error: BetslipErrorType.betPlacementError).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
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
