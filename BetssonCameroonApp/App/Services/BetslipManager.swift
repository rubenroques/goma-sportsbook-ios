//
//  BetslipManager.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine
import OrderedCollections
import ServicesProvider

class BetslipManager: NSObject {
    
    var allowedBetTypesPublisher = CurrentValueSubject< LoadableContent<[ServicesProvider.BetType]>, Never>.init( .idle )
    
    var allBetTypes = [ServicesProvider.BetType]()
    var newBetsPlacedPublisher = PassthroughSubject<Void, Never>.init()
    var bettingTicketsPublisher: CurrentValueSubject<[BettingTicket], Never>
    
    private var bettingTicketsDictionaryPublisher: CurrentValueSubject<OrderedDictionary<String, BettingTicket>, Never>
    private var bettingTicketPublisher: [String: CurrentValueSubject<BettingTicket, Never>]
    
    private var serviceProviderSubscriptions: [String: ServicesProvider.Subscription] = [:]
    private var bettingTicketsCancellables: [String: AnyCancellable] = [:]
    
    private var cancellables: Set<AnyCancellable> = []
    
    override init() {
        self.bettingTicketsPublisher = .init([])
        self.bettingTicketsDictionaryPublisher = .init([:])
        self.bettingTicketPublisher = [:]
        
        super.init()
    }
    
    func start() {
        var cachedBetslipTicketsDictionary: OrderedDictionary<String, BettingTicket> = [:]
        for ticket in UserDefaults.standard.cachedBetslipTickets {
            cachedBetslipTicketsDictionary[ticket.id] = ticket
        }
        self.bettingTicketsDictionaryPublisher.send(cachedBetslipTicketsDictionary)
        
        Env.servicesProvider.eventsConnectionStatePublisher
            .filter({ $0 == .connected })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] _ in
                self?.reconnectBettingTicketsUpdates()
            })
            .store(in: &self.cancellables)
        
        self.bettingTicketsDictionaryPublisher
            .map({ dictionary -> [BettingTicket] in
                return Array.init(dictionary.values)
            })
            .sink { [weak self] tickets in
                self?.bettingTicketsPublisher.send(tickets)
            }
            .store(in: &self.cancellables)
        
        self.bettingTicketsPublisher
            .removeDuplicates()
            .sink { tickets in
                UserDefaults.standard.cachedBetslipTickets = tickets
            }
            .store(in: &self.cancellables)
        
        self.bettingTicketsPublisher
            .removeDuplicates(by: { left, right in
                left.map(\.id) == right.map(\.id)
            })
            .filter({ return !$0.isEmpty })
            .sink(receiveValue: { [weak self] bettingTickets in
                self?.requestAllowedBetTypes(withBettingTickets: bettingTickets)
            })
            .store(in: &self.cancellables)

    }
    
    func addBettingTicket(_ bettingTicket: BettingTicket) {
        self.bettingTicketsDictionaryPublisher.value[bettingTicket.id] = bettingTicket
        self.subscribeBettingTicketPublisher(bettingTicket: bettingTicket)
    }
    
    func removeBettingTicket(_ bettingTicket: BettingTicket) {
        self.bettingTicketsDictionaryPublisher.value[bettingTicket.id] = nil
        self.unsubscribeBettingTicketPublisher(withId: bettingTicket.id)
    }
    
    func removeBettingTicket(withId id: String) {
        self.bettingTicketsDictionaryPublisher.value[id] = nil
        self.unsubscribeBettingTicketPublisher(withId: id)
    }
    
    func hasBettingTicket(_ bettingTicket: BettingTicket) -> Bool {
        return self.bettingTicketsDictionaryPublisher.value[bettingTicket.id] != nil
    }
    
    func hasBettingTicket(withId id: String) -> Bool {
        return self.bettingTicketsDictionaryPublisher.value[id] != nil
    }
    
    func clearAllBettingTickets() {
        for bettingTicket in self.bettingTicketsDictionaryPublisher.value.values {
            self.unsubscribeBettingTicketPublisher(withId: bettingTicket.id)
        }
        self.bettingTicketsDictionaryPublisher.send([:])
    }
    
    private func reconnectBettingTicketsUpdates() {
        for bettingTicket in self.bettingTicketsPublisher.value {
            self.subscribeBettingTicketPublisher(bettingTicket: bettingTicket)
        }
    }
    
    private func unsubscribeBettingTicketPublisher(withId id: String) {
        // Cancel the subscription
        self.serviceProviderSubscriptions[id] = nil
        
        // Cancel combine
        if let subscriber = self.bettingTicketsCancellables[id] {
            subscriber.cancel()
            self.bettingTicketsCancellables.removeValue(forKey: id)
        }
        
        self.bettingTicketPublisher.removeValue(forKey: id)
    }
    
    private func subscribeBettingTicketPublisher(bettingTicket: BettingTicket) {
        
        if let publisher = self.bettingTicketPublisher[bettingTicket.id] {
            publisher.send(bettingTicket)
        }
        else {
            self.bettingTicketPublisher[bettingTicket.id] = .init(bettingTicket)
        }
        
        let bettingTicketSubscriber = Env.servicesProvider.subscribeToMarketDetails(withId: bettingTicket.marketId, onEventId: bettingTicket.matchId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .resourceUnavailableOrDeleted:
                        self?.disableBettingTicket(bettingTicket)
                    default:
                        print("Error retrieving data! subscribeToMarketDetails \(error)")
                    }
                case .finished:
                    print("Data retrieved!")
                }
            } receiveValue: { [weak self] subscribableContent in
                switch subscribableContent {
                case .connected(let subscription):
                    self?.serviceProviderSubscriptions[bettingTicket.id] = subscription
                case .contentUpdate(let market):
                    let internalMarket = ServiceProviderModelMapper.market(fromServiceProviderMarket: market)
                    self?.updateBettingTickets(ofMarket: internalMarket)
                case .disconnected:
                    print("Betslip subscribeToMarketDetails disconnected")
                }
            }
        self.bettingTicketsCancellables[bettingTicket.id] = bettingTicketSubscriber
        
    }
    
    private func disableBettingTicket(_ bettingTicket: BettingTicket) {
        if let bettingTicket = self.bettingTicketsDictionaryPublisher.value[bettingTicket.id] {
            let newAvailablity = false
            let newBettingTicket = BettingTicket.init(id: bettingTicket.id,
                                                      outcomeId: bettingTicket.outcomeId,
                                                      marketId: bettingTicket.marketId,
                                                      matchId: bettingTicket.matchId,
                                                      isAvailable: newAvailablity,
                                                      matchDescription: bettingTicket.matchDescription,
                                                      marketDescription: bettingTicket.marketDescription,
                                                      outcomeDescription: bettingTicket.outcomeDescription,
                                                      homeParticipantName: bettingTicket.homeParticipantName,
                                                      awayParticipantName: bettingTicket.awayParticipantName,
                                                      sport: bettingTicket.sport,
                                                      sportIdCode: bettingTicket.sportIdCode,
                                                      venue: bettingTicket.venue,
                                                      competition: bettingTicket.competition,
                                                      date: bettingTicket.date,
                                                      odd: bettingTicket.odd,
                                                      isFromBetBuilderMarket: bettingTicket.isFromBetBuilderMarket)
            
            self.bettingTicketsDictionaryPublisher.value[bettingTicket.id] = newBettingTicket
            self.bettingTicketPublisher[bettingTicket.id]?.send(newBettingTicket)
        }
    }
    
    private func updateBettingTickets(ofMarket market: Market) {
        
        for outcome in market.outcomes {
            if let bettingTicket = self.bettingTicketsDictionaryPublisher.value[outcome.id] {
                let newAvailablity = market.isAvailable
                let newOdd = outcome.bettingOffer.odd
                let newBettingTicket = BettingTicket.init(id: bettingTicket.id,
                                                          outcomeId: bettingTicket.outcomeId,
                                                          marketId: bettingTicket.marketId,
                                                          matchId: bettingTicket.matchId,
                                                          isAvailable: newAvailablity,
                                                          matchDescription: market.eventName ?? bettingTicket.matchDescription,
                                                          marketDescription: outcome.marketName ?? bettingTicket.marketDescription,
                                                          outcomeDescription: outcome.translatedName,
                                                          homeParticipantName: market.homeParticipant ?? bettingTicket.homeParticipantName,
                                                          awayParticipantName: market.awayParticipant ?? bettingTicket.awayParticipantName,
                                                          sport: market.sport ?? bettingTicket.sport,
                                                          sportIdCode: market.sportIdCode ?? bettingTicket.sportIdCode,
                                                          venue: bettingTicket.venue,
                                                          competition: bettingTicket.competition,
                                                          date: market.startDate ?? bettingTicket.date,
                                                          odd: newOdd,
                                                          isFromBetBuilderMarket: bettingTicket.isFromBetBuilderMarket)

                self.bettingTicketsDictionaryPublisher.value[bettingTicket.id] = newBettingTicket
                self.bettingTicketPublisher[bettingTicket.id]?.send(newBettingTicket)
            }
        }
    }
    
    func bettingTicketPublisher(withId id: String) -> AnyPublisher<BettingTicket, Never>? {
        if let bettingTicketPublisher = self.bettingTicketPublisher[id] {
            return bettingTicketPublisher.eraseToAnyPublisher()
        }
        return nil
    }
    
    func getBettingTickets() -> [BettingTicket] {
        return self.bettingTicketsPublisher.value
    }
    
    // Place bets
    func placeMultipleBet(withStake stake: Double, useFreebetBalance: Bool) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> {
        
        guard
            self.bettingTicketsPublisher.value.isNotEmpty
        else {
            return Fail(error: BetslipErrorType.emptyBetslip).eraseToAnyPublisher()
        }
        
        let betTicketSelections = self.bettingTicketsPublisher.value.map { bettingTicket in
            let odd = ServiceProviderModelMapper.serviceProviderOddFormat(fromOddFormat: bettingTicket.odd)
            let betTicketSelection = ServicesProvider.BetTicketSelection(identifier: bettingTicket.id,
                                                                         eventName: bettingTicket.matchDescription,
                                                                         homeTeamName: bettingTicket.homeParticipantName ?? "",
                                                                         awayTeamName: bettingTicket.awayParticipantName ?? "",
                                                                         marketName: bettingTicket.marketId,
                                                                         outcomeName: bettingTicket.outcomeDescription,
                                                                         odd: odd,
                                                                         stake: stake,
                                                                         sportIdCode: bettingTicket.sportIdCode,
                                                                         outcomeId: bettingTicket.id)
            return betTicketSelection
        }
        
        var betGroupingType: BetGroupingType = .single(identifier: "S")
        
        if betTicketSelections.count > 1 {
            betGroupingType = .multiple(identifier: "M")
        }
        
        let betTicket = BetTicket.init(tickets: betTicketSelections, stake: stake, betGroupingType: betGroupingType)
        
        let publisher =  Env.servicesProvider.placeBets(betTickets: [betTicket], useFreebetBalance: useFreebetBalance)
            .mapError({ error in
                switch error {
                case .forbidden:
                    return BetslipErrorType.forbiddenRequest
                case .errorMessage(let message):
                    
                    if message.contains("bet_error") {
                        return BetslipErrorType.betPlacementDetailedError(message: localized(message))
                    }
                    
                    return BetslipErrorType.betPlacementDetailedError(message: message)
                case .notPlacedBet(let message):
                    if message.contains("bet_error") {
                        return BetslipErrorType.betPlacementDetailedError(message: localized(message))
                    }
                    return BetslipErrorType.betPlacementDetailedError(message: message)
                case .betNeedsUserConfirmation(let betDetails):
                    return BetslipErrorType.betNeedsUserConfirmation(betDetails: betDetails)
                default:
                    return BetslipErrorType.betPlacementError
                }
            })
            .flatMap({ (placedBetsResponse: PlacedBetsResponse) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> in
                
                print("Placed bet response: \(placedBetsResponse)")
                
                return Just([]).setFailureType(to: BetslipErrorType.self).eraseToAnyPublisher()
                
            })
            .handleEvents(receiveOutput: { betPlacedDetailsArray in
                let shouldUpdate: Bool = betPlacedDetailsArray.map(\.response.betSucceed).compactMap({ $0 }).allSatisfy { $0 }
                if shouldUpdate {
                    self.newBetsPlacedPublisher.send()
                }
            })
            .eraseToAnyPublisher()
        
        return publisher
    }
}

//
extension BetslipManager {
    
    func refreshAllowedBetTypes() {
        self.requestAllowedBetTypes(withBettingTickets: self.bettingTicketsPublisher.value)
    }
    
    func requestAllowedBetTypes(withBettingTickets bettingTickets: [BettingTicket]) {
       
    }
    
    func placeMultipleBet(withBettingTickets bettingTickets: [BettingTicket]) {
        
    }
    
    
}
