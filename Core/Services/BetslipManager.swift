//
//  BetslipManager.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine
import OrderedCollections
import nanopb
import ServicesProvider

class BetslipManager: NSObject {

    var allowedBetTypesPublisher = CurrentValueSubject< LoadableContent<[BetType]>, Never>.init( .idle )
    var systemTypesAvailablePublisher = CurrentValueSubject<LoadableContent<[SystemBetType]>, Never> .init(.idle)

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
            .store(in: &cancellables)

        self.bettingTicketsDictionaryPublisher
            .map({ dictionary -> [BettingTicket] in
                return Array.init(dictionary.values)
            })
            .sink { [weak self] tickets in
                self?.bettingTicketsPublisher.send(tickets)
            }
            .store(in: &cancellables)

        self.bettingTicketsPublisher
            .removeDuplicates()
            .sink { tickets in
                UserDefaults.standard.cachedBetslipTickets = tickets
            }
            .store(in: &cancellables)

        self.bettingTicketsPublisher
            .removeDuplicates()
            .filter({ return !$0.isEmpty })
            .sink(receiveValue: { [weak self] bettingTickets in
                self?.requestAllowedBetTypes(withBettingTickets: bettingTickets)
            })
            .store(in: &cancellables)

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

        let bettingTicketSubscriber = Env.servicesProvider.subscribeToMarketDetails(withId: bettingTicket.marketId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error retrieving data! \(error)")
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
                    print("betslipdebug \(bettingTicket.id) 3 betslipmanager subcribe [market:\(bettingTicket.marketId)]")
                case .disconnected:
                    print("Betslip subscribeToMarketDetails disconnected")
                }
            }
        self.bettingTicketsCancellables[bettingTicket.id] = bettingTicketSubscriber

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
                                                          matchDescription: bettingTicket.matchDescription,
                                                          marketDescription: bettingTicket.marketDescription,
                                                          outcomeDescription: bettingTicket.outcomeDescription,
                                                          odd: newOdd)

                self.bettingTicketsDictionaryPublisher.value[bettingTicket.id] = newBettingTicket

                self.bettingTicketPublisher[bettingTicket.id]?.send(newBettingTicket)

                print("betslipdebug \(outcome.id) \(newOdd) 4 betslipmanager update Publisher")
            }
        }
    }

    func bettingTicketPublisher(withId id: String) -> AnyPublisher<BettingTicket, Never>? {
        if let bettingTicketPublisher = self.bettingTicketPublisher[id] {
            return bettingTicketPublisher.eraseToAnyPublisher()
        }
        return nil
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

        let betTicketSelections: [ServicesProvider.BetTicketSelection] = bettingTickets.map { bettingTicket -> ServicesProvider.BetTicketSelection in
            let convertedOdd = ServiceProviderModelMapper.serviceProviderOddFormat(fromOddFormat: bettingTicket.odd)
            let betTicketSelection = ServicesProvider.BetTicketSelection(identifier: bettingTicket.id,
                                                                         eventName: "",
                                                                         homeTeamName: "",
                                                                         awayTeamName: "",
                                                                         marketName: "",
                                                                         outcomeName: "",
                                                                         odd: convertedOdd,
                                                                         stake: 1)
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
            .store(in: &cancellables)
    }

    func placeMultipleBet(withBettingTickets bettingTickets: [BettingTicket]) {

    }

    func placeQuickBet(bettingTicket: BettingTicket, amount: Double) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> {
        
        let convertedOdd = ServiceProviderModelMapper.serviceProviderOddFormat(fromOddFormat: bettingTicket.odd)
        let betTicketSelection = ServicesProvider.BetTicketSelection(identifier: bettingTicket.id,
                                                                     eventName: "",
                                                                     homeTeamName: "",
                                                                     awayTeamName: "",
                                                                     marketName: "",
                                                                     outcomeName: "",
                                                                     odd: convertedOdd,
                                                                     stake: amount)

        let betTicket = ServicesProvider.BetTicket(tickets: [betTicketSelection],
                                                   stake: amount,
                                                   betGroupingType: .single(identifier: "S"))


        let publisher =  Env.servicesProvider.placeBets(betTickets: [betTicket])
            .mapError({ error in
                switch error {
                case .forbidden:
                    return BetslipErrorType.forbiddenBetError
                case .errorMessage(let message):
                    return BetslipErrorType.betPlacementDetailedError(message: message)
                case .notPlacedBet(let message):
                    return BetslipErrorType.betPlacementDetailedError(message: message)
                default:
                    return BetslipErrorType.betPlacementError
                }
            })
            .flatMap({ (placedBetsResponse: PlacedBetsResponse) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> in
                let betPlacedDetailsArray = placedBetsResponse.bets.map { (placedBetEntry: PlacedBetEntry) -> BetPlacedDetails in
                    let totalPriceValue = placedBetEntry.betLegs.map(\.odd).reduce(1.0, *)
                    let response = BetslipPlaceBetResponse(betId: placedBetEntry.identifier,
                                                           betSucceed: true,
                                                           totalPriceValue: totalPriceValue,
                                                           maxWinning: placedBetEntry.potentialReturn)
                    return BetPlacedDetails(response: response, tickets: [])
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

    func placeSingleBets(amounts: [String: Double]) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> {
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
                                                                         stake: stake)

            let betTicket = ServicesProvider.BetTicket(tickets: [betTicketSelection],
                                                       stake: stake,
                                                       betGroupingType: .single(identifier: "S"))
            betTickets.append(betTicket)
        }

        let publisher =  Env.servicesProvider.placeBets(betTickets: betTickets)
            .mapError({ error in
                switch error {
                case .forbidden:
                    return BetslipErrorType.forbiddenBetError
                case .errorMessage(let message):
                    return BetslipErrorType.betPlacementDetailedError(message: message)
                case .notPlacedBet(let message):
                    return BetslipErrorType.betPlacementDetailedError(message: message)
                default:
                    return BetslipErrorType.betPlacementError
                }
            })
            .flatMap({ (placedBetsResponse: PlacedBetsResponse) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> in
                let betPlacedDetailsArray = placedBetsResponse.bets.map { (placedBetEntry: PlacedBetEntry) -> BetPlacedDetails in
                    let totalPriceValue = placedBetEntry.betLegs.map(\.odd).reduce(1.0, *)
                    let response = BetslipPlaceBetResponse(betId: placedBetEntry.identifier,
                                                           betSucceed: true,
                                                           totalPriceValue: totalPriceValue,
                                                           maxWinning: placedBetEntry.potentialReturn)
                    return BetPlacedDetails(response: response, tickets: [])
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

    func placeMultipleBet(withStake stake: Double) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> {

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
                                                                         stake: stake)
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
        let publisher =  Env.servicesProvider.placeBets(betTickets: [betTicket])
            .mapError({ error in
                switch error {
                case .forbidden:
                    return BetslipErrorType.forbiddenBetError
                case .errorMessage(let message):
                    return BetslipErrorType.betPlacementDetailedError(message: message)
                case .notPlacedBet(let message):
                    return BetslipErrorType.betPlacementDetailedError(message: message)
                default:
                    return BetslipErrorType.betPlacementError
                }
            })
            .flatMap({ (placedBetsResponse: PlacedBetsResponse) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> in
                let betPlacedDetailsArray = placedBetsResponse.bets.map { (placedBetEntry: PlacedBetEntry) -> BetPlacedDetails in
                    let totalPriceValue = placedBetEntry.betLegs.map(\.odd).reduce(1.0, *)
                    let response = BetslipPlaceBetResponse(betId: placedBetEntry.identifier,
                                                           betSucceed: true,
                                                           totalPriceValue: totalPriceValue,
                                                           maxWinning: placedBetEntry.potentialReturn)
                    return BetPlacedDetails(response: response, tickets: [])
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

    func placeSystemBet(withStake stake: Double, systemBetType: SystemBetType) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> {

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
                                                                         stake: stake)
            return betTicketSelection
        }

        let betTicket = BetTicket.init(tickets: betTicketSelections,
                                       stake: stake,
                                       betGroupingType: BetGroupingType.system(identifier: systemBetType.id, name: systemBetType.name ?? ""))
        
        let publisher =  Env.servicesProvider.placeBets(betTickets: [betTicket])
            .mapError({ error in
                switch error {
                case .forbidden:
                    return BetslipErrorType.forbiddenBetError
                case .errorMessage(let message):
                    return BetslipErrorType.betPlacementDetailedError(message: message)
                case .notPlacedBet(let message):
                    return BetslipErrorType.betPlacementDetailedError(message: message)
                default:
                    return BetslipErrorType.betPlacementError
                }
            })
            .flatMap({ (placedBetsResponse: PlacedBetsResponse) -> AnyPublisher<[BetPlacedDetails], BetslipErrorType> in
                let betPlacedDetailsArray = placedBetsResponse.bets.map { (placedBetEntry: PlacedBetEntry) -> BetPlacedDetails in
                    let totalPriceValue = placedBetEntry.betLegs.map(\.odd).reduce(1.0, *)
                    let response = BetslipPlaceBetResponse(betId: placedBetEntry.identifier,
                                                           betSucceed: true,
                                                           totalPriceValue: totalPriceValue,
                                                           maxWinning: placedBetEntry.potentialReturn)
                    return BetPlacedDetails(response: response, tickets: [])
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

    func requestSimpleBetPotentialReturn(withSkateAmount amounts: [String: Double]) -> AnyPublisher<BetPotencialReturn, Never>  {

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
                                                           stake: stake)
            }

        let betTicket = ServicesProvider.BetTicket(tickets: ticketSelections,
                                                   stake: nil,
                                                   betGroupingType: BetGroupingType.single(identifier: "S"))

        return Env.servicesProvider.calculatePotentialReturn(forBetTicket: betTicket)
            .map({ betslipPotentialReturn in
                return BetPotencialReturn(potentialReturn: betslipPotentialReturn.potentialReturn,
                                          totalStake: betslipPotentialReturn.totalStake,
                                          numberOfBets: betslipPotentialReturn.numberOfBets)
            })
            .replaceError(with: nil)
            .replaceNil(with: BetPotencialReturn(potentialReturn: 0, totalStake: 0, numberOfBets: 0))
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
                                                                         stake: stake)
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

        return Env.servicesProvider.calculatePotentialReturn(forBetTicket: betTicket)
            .map({ betslipPotentialReturn in
                return BetPotencialReturn(potentialReturn: betslipPotentialReturn.potentialReturn,
                                          totalStake: betslipPotentialReturn.totalStake,
                                          numberOfBets: betslipPotentialReturn.numberOfBets)
            })
            .mapError({ _ in
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
                                                                         stake: stake)
            return betTicketSelection
        }

        let betTicket = BetTicket.init(tickets: betTicketSelections,
                                       stake: stake,
                                       betGroupingType: BetGroupingType.system(identifier: systemBetType.id, name: systemBetType.name ?? ""))

        return Env.servicesProvider.calculatePotentialReturn(forBetTicket: betTicket)
            .map({ betslipPotentialReturn in
                return BetPotencialReturn(potentialReturn: betslipPotentialReturn.potentialReturn,
                                          totalStake: betslipPotentialReturn.totalStake,
                                          numberOfBets: betslipPotentialReturn.numberOfBets)
            })
            .mapError({ _ in
                return BetslipErrorType.potentialReturn
            })
            .eraseToAnyPublisher()
    }

}

enum BetslipErrorType: Error {
    case emptyBetslip
    case betPlacementError
    case potentialReturn
    case betPlacementDetailedError(message: String)
    case forbiddenBetError
    case none
}

struct BetslipError {
    var errorMessage: String
    var errorType: BetslipErrorType

    init(errorMessage: String = "", errorType: BetslipErrorType = .none) {
        self.errorMessage = errorMessage
        self.errorType = errorType
    }

}

struct BetPlacedDetails {
    var response: BetslipPlaceBetResponse
    var tickets: [BettingTicket]
}

struct BetPotencialReturn: Codable {
    var potentialReturn: Double
    var totalStake: Double
    var numberOfBets: Int
}
