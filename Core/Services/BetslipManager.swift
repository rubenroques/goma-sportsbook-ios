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
    
    var allowedBetTypesPublisher = CurrentValueSubject< LoadableContent<[BetType]>, Never>.init( .idle )
    var systemTypesAvailablePublisher = CurrentValueSubject<LoadableContent<[SystemBetType]>, Never> .init(.idle)
    
    var allBetTypes = [ServicesProvider.BetType]()
    var newBetsPlacedPublisher = PassthroughSubject<Void, Never>.init()
    var bettingTicketsPublisher: CurrentValueSubject<[BettingTicket], Never>
    
    private var bettingTicketsDictionaryPublisher: CurrentValueSubject<OrderedDictionary<String, BettingTicket>, Never>
    private var bettingTicketPublisher: [String: CurrentValueSubject<BettingTicket, Never>]
    
    private var serviceProviderSubscriptions: [String: ServicesProvider.Subscription] = [:]
    private var bettingTicketsCancellables: [String: AnyCancellable] = [:]
    
    // BetBuilder
    var betBuilderProcessor: BetBuilderProcessor = BetBuilderProcessor()
    
    var betBuilderTransformer: BetBuilderTransformer = BetBuilderTransformer()
    
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
            .sink { [weak self] tickets in
                self?.refreshBetBuilderPotentialReturn()
            }
            .store(in: &cancellables)
        
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
    
}

//
extension BetslipManager {
    
    func refreshAllowedBetTypes() {
        self.requestAllowedBetTypes(withBettingTickets: self.bettingTicketsPublisher.value)
    }
    
    func requestAllowedBetTypes(withBettingTickets bettingTickets: [BettingTicket]) {
        
        self.allowedBetTypesPublisher.send(LoadableContent.loading)
        self.systemTypesAvailablePublisher.send(LoadableContent.loading)
        self.allBetTypes = []
        
        let betTicketSelections: [ServicesProvider.BetTicketSelection] = bettingTickets.map { bettingTicket -> ServicesProvider.BetTicketSelection in
            let convertedOdd = ServiceProviderModelMapper.serviceProviderOddFormat(fromOddFormat: bettingTicket.odd)
            let betTicketSelection = ServicesProvider.BetTicketSelection(identifier: bettingTicket.id,
                                                                         eventName: "",
                                                                         homeTeamName: "",
                                                                         awayTeamName: "",
                                                                         marketName: "",
                                                                         outcomeName: "",
                                                                         odd: convertedOdd,
                                                                         stake: 1,
                                                                         sportIdCode: bettingTicket.sportIdCode)
            return betTicketSelection
        }
        
        Env.servicesProvider.getAllowedBetTypes(withBetTicketSelections: betTicketSelections)
            .sink { [weak self] completion in
                
                switch completion {
                case .failure:
                    self?.allowedBetTypesPublisher.send(LoadableContent.failed)
                case .finished:
                    ()
                }
                
                print("getAllowedBetTypes completion \(completion)")
                
            } receiveValue: { [weak self] allowedBetTypes in
                let betTypes = allowedBetTypes.map { betType in
                    
                    if let allBetTypes = self?.allBetTypes {
                        if !allBetTypes.contains(where: {
                            $0.code == betType.code
                        }) {
                            self?.allBetTypes.append(betType)
                        }
                    }
                    
                    switch betType.grouping {
                    case .single: return BetType.single(identifier: betType.code)
                    case .multiple: return BetType.multiple(identifier: betType.code)
                    case .system: return BetType.system(identifier: betType.code, name: betType.name)
                    }
                    
                }
                self?.allowedBetTypesPublisher.send( LoadableContent.loaded(betTypes) )
                
                var systemBetTypes: [SystemBetType] = []
                allowedBetTypes.forEach { betType in
                    switch betType.grouping {
                    case .system:
                        systemBetTypes.append(SystemBetType(id: betType.code,
                                                            name: betType.name,
                                                            numberOfBets: betType.numberOfBets))
                    default: ()
                    }
                }
                
                self?.systemTypesAvailablePublisher.send(.loaded(systemBetTypes))
                
            }
            .store(in: &self.cancellables)
    }
    
    func placeMultipleBet(withBettingTickets bettingTickets: [BettingTicket]) {
        
    }
    
    func placeQuickBet(bettingTicket: BettingTicket, amount: Double, useFreebetBalance: Bool) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> {
        
        let convertedOdd = ServiceProviderModelMapper.serviceProviderOddFormat(fromOddFormat: bettingTicket.odd)
        let betTicketSelection = ServicesProvider.BetTicketSelection(identifier: bettingTicket.id,
                                                                     eventName: "",
                                                                     homeTeamName: "",
                                                                     awayTeamName: "",
                                                                     marketName: "",
                                                                     outcomeName: "",
                                                                     odd: convertedOdd,
                                                                     stake: amount,
                                                                     sportIdCode: bettingTicket.sportIdCode)
        
        let betTicket = ServicesProvider.BetTicket(tickets: [betTicketSelection],
                                                   stake: amount,
                                                   betGroupingType: .single(identifier: "S"))
        
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
                default:
                    return BetslipErrorType.betPlacementError
                }
            })
            .flatMap({ (placedBetsResponse: PlacedBetsResponse) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> in
                let betPlacedDetailsArray = placedBetsResponse.bets.map { (placedBetEntry: PlacedBetEntry) -> BetPlacedDetails in
                    let totalPriceValue = placedBetEntry.betLegs.map(\.odd).reduce(1.0, *)
                    
                    let betslipPlaceEntries = placedBetEntry.betLegs.map( {
                        ServiceProviderModelMapper.betlipPlacedEntry(fromPlacedBetLeg: $0)
                    })
                    
                    var betType = localized("single")
                    
                    if let type = placedBetEntry.type {
                        let allowedBetTypes = self.allBetTypes
                        
                        if let betTypeFound = allowedBetTypes.filter({
                            $0.code == type
                        }).first {
                            betType = betTypeFound.name
                        }
                    }
                    
                    let response = BetslipPlaceBetResponse(betId: placedBetEntry.identifier,
                                                           betSucceed: true,
                                                           totalPriceValue: totalPriceValue,
                                                           amount: placedBetEntry.totalStake,
                                                           type: betType,
                                                           maxWinning: placedBetEntry.potentialReturn, selections: betslipPlaceEntries,
                                                           betslipId: placedBetsResponse.identifier)
                    
                    return BetPlacedDetails(response: response)
                }
                return Just(betPlacedDetailsArray).setFailureType(to: BetslipErrorType.self).eraseToAnyPublisher()
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
    
    func placeSingleBets(amounts: [String: Double], useFreebetBalance: Bool) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> {
        var betTickets: [ServicesProvider.BetTicket] = []
        for singleTicket in self.bettingTicketsPublisher.value {
            let stake = amounts[singleTicket.id] ?? 0.0
            let convertedOdd = ServiceProviderModelMapper.serviceProviderOddFormat(fromOddFormat: singleTicket.odd)
            let betTicketSelection = ServicesProvider.BetTicketSelection(identifier: singleTicket.id,
                                                                         eventName: "",
                                                                         homeTeamName: "",
                                                                         awayTeamName: "",
                                                                         marketName: "",
                                                                         outcomeName: "",
                                                                         odd: convertedOdd,
                                                                         stake: stake,
                                                                         sportIdCode: singleTicket.sportIdCode)
            
            let betTicket = ServicesProvider.BetTicket(tickets: [betTicketSelection],
                                                       stake: stake,
                                                       betGroupingType: .single(identifier: "S"))
            betTickets.append(betTicket)
        }
        
        let publisher =  Env.servicesProvider.placeBets(betTickets: betTickets, useFreebetBalance: useFreebetBalance)
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
                let betPlacedDetailsArray = placedBetsResponse.bets.map { (placedBetEntry: PlacedBetEntry) -> BetPlacedDetails in
                    let totalPriceValue = placedBetEntry.betLegs.map(\.odd).reduce(1.0, *)
                    
                    let betslipPlaceEntries = placedBetEntry.betLegs.map( {
                        ServiceProviderModelMapper.betlipPlacedEntry(fromPlacedBetLeg: $0)
                    })
                    
                    var betType = "Single"
                    
                    if let type = placedBetEntry.type {
                        let allowedBetTypes = self.allBetTypes
                        
                        if let betTypeFound = allowedBetTypes.filter({
                            $0.code == type
                        }).first {
                            betType = betTypeFound.name
                        }
                    }
                    
                    let response = BetslipPlaceBetResponse(betId: placedBetEntry.identifier,
                                                           betSucceed: true,
                                                           totalPriceValue: totalPriceValue,
                                                           amount: placedBetEntry.totalStake,
                                                           type: betType,
                                                           maxWinning: placedBetEntry.potentialReturn, selections: betslipPlaceEntries,
                                                           betslipId: placedBetsResponse.identifier)
                    
                    return BetPlacedDetails(response: response)
                }
                return Just(betPlacedDetailsArray).setFailureType(to: BetslipErrorType.self).eraseToAnyPublisher()
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
    
    func placeMultipleBet(withStake stake: Double, useFreebetBalance: Bool) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> {
        
        guard
            self.bettingTicketsPublisher.value.isNotEmpty
        else {
            return Fail(error: BetslipErrorType.emptyBetslip).eraseToAnyPublisher()
        }
        
        let betTicketSelections = self.bettingTicketsPublisher.value.map { bettingTicket in
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
        
        var multipleBetIdentifier = "A"
        if case let .loaded(allowedBetTypes) =  self.allowedBetTypesPublisher.value {
            allowedBetTypes.forEach { betType in
                switch betType {
                case .multiple(let identifier):
                    multipleBetIdentifier = identifier
                default:
                    ()
                }
            }
        }
        
        let betTicket = BetTicket.init(tickets: betTicketSelections, stake: stake, betGroupingType: BetGroupingType.multiple(identifier: multipleBetIdentifier))
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
                let betPlacedDetailsArray = placedBetsResponse.bets.map { (placedBetEntry: PlacedBetEntry) -> BetPlacedDetails in
                    let totalPriceValue = placedBetEntry.betLegs.map(\.odd).reduce(1.0, *)
                    
                    let betslipPlaceEntries = placedBetEntry.betLegs.map( {
                        ServiceProviderModelMapper.betlipPlacedEntry(fromPlacedBetLeg: $0)
                    })
                    
                    var betType = "Multiple"
                    
                    if let type = placedBetEntry.type {
                        let allowedBetTypes = self.allBetTypes
                        
                        if let betTypeFound = allowedBetTypes.filter({
                            $0.code == type
                        }).first {
                            betType = betTypeFound.name
                        }
                    }
                    
                    let response = BetslipPlaceBetResponse(betId: placedBetEntry.identifier,
                                                           betSucceed: true,
                                                           totalPriceValue: totalPriceValue,
                                                           amount: placedBetEntry.totalStake,
                                                           type: betType,
                                                           maxWinning: placedBetEntry.potentialReturn,
                                                           selections: betslipPlaceEntries, 
                                                           betslipId: placedBetsResponse.identifier)
                    
                    return BetPlacedDetails(response: response)
                }
                return Just(betPlacedDetailsArray).setFailureType(to: BetslipErrorType.self).eraseToAnyPublisher()
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
    
    func placeSystemBet(withStake stake: Double, systemBetType: SystemBetType, useFreebetBalance: Bool) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> {
        
        guard
            self.bettingTicketsPublisher.value.isNotEmpty
        else {
            return Fail(error: BetslipErrorType.emptyBetslip).eraseToAnyPublisher()
        }
        
        let betTicketSelections = self.bettingTicketsPublisher.value.map { bettingTicket in
            let odd = ServiceProviderModelMapper.serviceProviderOddFormat(fromOddFormat: bettingTicket.odd)
            let betTicketSelection = ServicesProvider.BetTicketSelection(identifier: bettingTicket.id,
                                                                         eventName: "",
                                                                         homeTeamName: "",
                                                                         awayTeamName: "",
                                                                         marketName: "",
                                                                         outcomeName: "",
                                                                         odd: odd,
                                                                         stake: stake, sportIdCode: bettingTicket.sportIdCode)
            return betTicketSelection
        }
        
        let betTicket = BetTicket.init(tickets: betTicketSelections,
                                       stake: stake,
                                       betGroupingType: BetGroupingType.system(identifier: systemBetType.id,
                                                                               name: systemBetType.name ?? "", numberOfBets: systemBetType.numberOfBets ?? 1))
        
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
                case .badRequest:
                    return BetslipErrorType.betPlacementError
                default:
                    return BetslipErrorType.betPlacementError
                }
            })
            .flatMap({ (placedBetsResponse: PlacedBetsResponse) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> in
                let betPlacedDetailsArray = placedBetsResponse.bets.map { (placedBetEntry: PlacedBetEntry) -> BetPlacedDetails in
                    let totalPriceValue = placedBetEntry.betLegs.map(\.odd).reduce(1.0, *)
                    
                    let betslipPlaceEntries = placedBetEntry.betLegs.map( {
                        ServiceProviderModelMapper.betlipPlacedEntry(fromPlacedBetLeg: $0)
                    })
                    
                    var betType = "System"
                    
                    if let type = placedBetEntry.type {
                        let allowedBetTypes = self.allBetTypes
                        
                        if let betTypeFound = allowedBetTypes.filter({
                            $0.code == type
                        }).first {
                            betType = betTypeFound.name
                        }
                    }
                    
                    let response = BetslipPlaceBetResponse(betId: placedBetEntry.identifier,
                                                           betSucceed: true,
                                                           totalPriceValue: totalPriceValue,
                                                           amount: placedBetEntry.totalStake,
                                                           type: betType,
                                                           maxWinning: placedBetEntry.potentialReturn, selections: betslipPlaceEntries,
                                                           betslipId: placedBetsResponse.identifier)
                    
                    return BetPlacedDetails(response: response)
                }
                return Just(betPlacedDetailsArray).setFailureType(to: BetslipErrorType.self).eraseToAnyPublisher()
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
    
    func requestSimpleBetPotentialReturn(withSkateAmount amounts: [String: Double]) -> AnyPublisher<BetPotencialReturn, Never> {
        
        let ticketSelections = self.bettingTicketsPublisher.value
            .map { (ticket: BettingTicket) in
                
                let stake = amounts[ticket.id] ?? 1.0
                
                let odd = ServiceProviderModelMapper.serviceProviderOddFormat(fromOddFormat: ticket.odd)
                
                return ServicesProvider.BetTicketSelection(identifier: ticket.id,
                                                           eventName: "",
                                                           homeTeamName: "",
                                                           awayTeamName: "",
                                                           marketName: "",
                                                           outcomeName: "",
                                                           odd: odd,
                                                           stake: stake,
                                                           sportIdCode: ticket.sportIdCode)
            }
        
        let betTicket = ServicesProvider.BetTicket(tickets: ticketSelections,
                                                   stake: nil,
                                                   betGroupingType: BetGroupingType.single(identifier: "S"))
        
        return Env.servicesProvider.calculatePotentialReturn(forBetTicket: betTicket)
            .map({ betslipPotentialReturn in
                
                return BetPotencialReturn(potentialReturn: betslipPotentialReturn.potentialReturn,
                                          totalStake: betslipPotentialReturn.totalStake,
                                          numberOfBets: betslipPotentialReturn.numberOfBets,
                                          totalOdd: 1)
                
            })
            .replaceError(with: nil)
            .replaceNil(with: BetPotencialReturn(potentialReturn: 0,
                                                 totalStake: 0,
                                                 numberOfBets: 0,
                                                 totalOdd: 1))
            .eraseToAnyPublisher()
        
    }
    
    func requestMultipleBetPotentialReturn(withSkateAmount stake: Double) -> AnyPublisher<BetPotencialReturn, BetslipErrorType> {
        
        let betTicketSelections = self.bettingTicketsPublisher.value.map { bettingTicket in
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
        
        var multipleBetIdentifier = "A"
        if case let .loaded(allowedBetTypes) =  self.allowedBetTypesPublisher.value {
            allowedBetTypes.forEach { betType in
                switch betType {
                case .multiple(let identifier):
                    multipleBetIdentifier = identifier
                default:
                    ()
                }
            }
        }
        
        var processedStake = stake
        if stake == 0.0 {
            processedStake = 1.0
        }
        let betTicket = BetTicket.init(tickets: betTicketSelections,
                                       stake: processedStake,
                                       betGroupingType: BetGroupingType.multiple(identifier: multipleBetIdentifier))
        
        return Env.servicesProvider.calculatePotentialReturn(forBetTicket: betTicket)
            .map({ betslipPotentialReturn in
                return BetPotencialReturn(potentialReturn: betslipPotentialReturn.potentialReturn,
                                          totalStake: betslipPotentialReturn.totalStake,
                                          numberOfBets: betslipPotentialReturn.numberOfBets,
                                          totalOdd: 1)
            })
            .mapError({ error in
                return BetslipErrorType.potentialReturn
            })
            .eraseToAnyPublisher()
    }
    
    func requestSystemBetPotentialReturn(withSkateAmount stake: Double, systemBetType: SystemBetType) -> AnyPublisher<BetPotencialReturn, BetslipErrorType> {
        
        let betTicketSelections = self.bettingTicketsPublisher.value.map { bettingTicket in
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
        
        var processedStake = stake
        if stake == 0.0 {
            processedStake = 1.0
        }
        
        let betTicket = BetTicket.init(tickets: betTicketSelections,
                                       stake: processedStake,
                                       betGroupingType: BetGroupingType.system(identifier: systemBetType.id,
                                                                               name: systemBetType.name ?? "",
                                                                               numberOfBets: systemBetType.numberOfBets ?? 1))
        
        return Env.servicesProvider.calculatePotentialReturn(forBetTicket: betTicket)
            .map({ betslipPotentialReturn in
                return BetPotencialReturn(potentialReturn: betslipPotentialReturn.potentialReturn,
                                          totalStake: betslipPotentialReturn.totalStake,
                                          numberOfBets: betslipPotentialReturn.numberOfBets,
                                          totalOdd: 1)
            })
            .mapError({ _ in
                return BetslipErrorType.potentialReturn
            })
            .eraseToAnyPublisher()
    }
    
    func requestCalculateCashback(stakeValue stake: Double) -> AnyPublisher<CashbackResult, BetslipErrorType> {
        
        let betTicketSelections = self.bettingTicketsPublisher.value.map { bettingTicket in
            let odd = ServiceProviderModelMapper.serviceProviderOddFormat(fromOddFormat: bettingTicket.odd)
            
            // let bet = bettingTicket
            
            let betTicketSelection = ServicesProvider.BetTicketSelection(identifier: bettingTicket.id,
                                                                         eventName: bettingTicket.matchId,
                                                                         homeTeamName: "",
                                                                         awayTeamName: "",
                                                                         marketName: bettingTicket.marketId,
                                                                         outcomeName: bettingTicket.outcomeId,
                                                                         odd: odd,
                                                                         stake: 0,
                                                                         sportIdCode: bettingTicket.sportIdCode)
            return betTicketSelection
        }
        
        var multipleBetIdentifier = "A"
        if case let .loaded(allowedBetTypes) =  self.allowedBetTypesPublisher.value {
            allowedBetTypes.forEach { betType in
                switch betType {
                case .multiple(let identifier):
                    multipleBetIdentifier = identifier
                default:
                    ()
                }
            }
        }
        
        let betTicket = BetTicket.init(tickets: betTicketSelections,
                                       stake: stake,
                                       betGroupingType: BetGroupingType.multiple(identifier: multipleBetIdentifier))
        
        return Env.servicesProvider.calculateCashback(forBetTicket: betTicket)
            .mapError({ _ in
                return BetslipErrorType.invalidStake
            })
            .eraseToAnyPublisher()
    }
    
    // BetBuilder
    //
    func refreshBetBuilderPotentialReturn() {
        let tickets = self.getBettingTickets()
        if tickets.isEmpty {
            self.betBuilderProcessor.resetProcessor()
            UserDefaults.standard.cachedBetBuilderProcessor = self.betBuilderProcessor
        }
        else if tickets.count == 1 {
            self.betBuilderProcessor.processValidTickets(tickets)
            UserDefaults.standard.cachedBetBuilderProcessor = self.betBuilderProcessor
        }
        else {
            self.requestBetBuilderPotentialReturn(withSkateAmount: 0.0)
                .sink { completion in
                    print("refreshBetBuilderPotentialReturn completed")
                } receiveValue: { [weak self] betBuilderCalculateResponse in
                    print("refreshBetBuilderPotentialReturn value")
                    if let self = self {
                        // Cache bet builder
                        UserDefaults.standard.cachedBetBuilderProcessor = self.betBuilderProcessor
                    }
                }
                .store(in: &self.cancellables)
        }
    }
    
    func requestBetBuilderPotentialReturn(withSkateAmount stake: Double) -> AnyPublisher<BetBuilderCalculateResponse, BetslipErrorType> {
        
        let ticketsToIgnore = self.betBuilderProcessor.ticketsToIgnore
        let tickets = self.bettingTicketsPublisher.value.filter { !ticketsToIgnore.contains($0) }
        
        guard
            tickets.isNotEmpty
        else  {
            return Fail(error: BetslipErrorType.emptyBetslip)
                .eraseToAnyPublisher()
        }
        
        guard
            tickets.count >  1
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
                
                return BetBuilderCalculateResponse.valid(potentialReturn: potencialReturn, tickets: tickets)
            })
            .catch { error -> AnyPublisher<BetBuilderCalculateResponse, BetslipErrorType> in
                switch error {
                case .pageNotFound, .badRequest:
                    return Just(BetBuilderCalculateResponse.invalid(tickets: tickets))
                        .setFailureType(to: BetslipErrorType.self)
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
                    if message.contains("bet_error") {
                        return Fail(error: BetslipErrorType.betPlacementDetailedError(message: localized(message)))
                            .eraseToAnyPublisher()
                    }
                    else {
                        return Fail(error: BetslipErrorType.betPlacementDetailedError(message: message))
                            .eraseToAnyPublisher()
                    }
                case .betNeedsUserConfirmation(let betDetails):
                    return Fail(error: BetslipErrorType.betNeedsUserConfirmation(betDetails: betDetails))
                        .eraseToAnyPublisher()
                default:
                    return Fail(error: BetslipErrorType.betPlacementError).eraseToAnyPublisher()
                }
            }
            .handleEvents(receiveOutput: { [weak self] betBuilderCalculateResponse in
                
                switch betBuilderCalculateResponse {
                case .valid(let potentialReturn, let tickets):
                    self?.betBuilderProcessor.processValidTickets(tickets)
                    self?.betBuilderProcessor.calculatedOddForValidTickets = potentialReturn.totalOdd
                    
                case .invalid(let invalidTickets):
                    self?.betBuilderProcessor.processInvalidTickets(invalidTickets)
                }
            })
            .eraseToAnyPublisher()
    }
    
    func placeBetBuilderBetValidTickets(stake: Double) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> {
        guard
            self.betBuilderProcessor.hasValidTickets
        else {
            return Fail(error: BetslipErrorType.noValidSelectionsFound).eraseToAnyPublisher()
        }
        
        let validTickets = self.betBuilderProcessor.validTickets
        let validOdd = self.betBuilderProcessor.calculatedOddForValidTickets
        return self.placeBetBuilderBet(withTickets: validTickets, stake: stake, calculatedOdd: validOdd)
    }
    
    func placeBetBuilderBet(withTickets tickets: [BettingTicket], stake: Double, calculatedOdd: Double) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> {
        
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
        
        let betTicket = BetTicket.init(tickets: betTicketSelections, stake: stake, betGroupingType: BetGroupingType.multiple(identifier: ""))
        
        let publisher =  Env.servicesProvider.placeBetBuilderBet(betTicket: betTicket, calculatedOdd: calculatedOdd)
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
                case .badRequest, .internalServerError:
                    return BetslipErrorType.betPlacementError
                default:
                    return BetslipErrorType.betPlacementError
                }
            })
            .flatMap({ (placedBetsResponse: PlacedBetsResponse) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> in
                let betPlacedDetailsArray = placedBetsResponse.bets.map { (placedBetEntry: PlacedBetEntry) -> BetPlacedDetails in
                    let totalPriceValue = placedBetEntry.betLegs.map(\.odd).reduce(1.0, *)
                    
                    let betslipPlaceEntries = placedBetEntry.betLegs.map( {
                        ServiceProviderModelMapper.betlipPlacedEntry(fromPlacedBetLeg: $0)
                    })
                    
                    let response = BetslipPlaceBetResponse(betId: placedBetEntry.identifier,
                                                           betSucceed: true,
                                                           totalPriceValue: totalPriceValue,
                                                           amount: placedBetEntry.totalStake,
                                                           type: placedBetEntry.type ?? "",
                                                           maxWinning: placedBetEntry.potentialReturn,
                                                           selections: betslipPlaceEntries, betslipId: placedBetsResponse.identifier)
                    
                    return BetPlacedDetails(response: response)
                }
                return Just(betPlacedDetailsArray).setFailureType(to: BetslipErrorType.self).eraseToAnyPublisher()
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
