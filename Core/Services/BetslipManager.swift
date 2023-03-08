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

    var allowedBetTypesPublisher = CurrentValueSubject<[BetType], Never>.init([])
    var systemTypesAvailablePublisher = CurrentValueSubject<[SystemBetType], Never>.init([])

    var newBetsPlacedPublisher = PassthroughSubject<Void, Never>.init()
    var bettingTicketsPublisher: CurrentValueSubject<[BettingTicket], Never>
    private var bettingTicketsDictionaryPublisher: CurrentValueSubject<OrderedDictionary<String, BettingTicket>, Never>
    private var bettingTicketPublisher: [String: CurrentValueSubject<BettingTicket, Never>]

    var simpleBetslipSelectionState: CurrentValueSubject<BetslipSelectionState?, Never>
    var multipleBetslipSelectionState: CurrentValueSubject<BetslipSelectionState?, Never>
    var systemBetslipSelectionState: CurrentValueSubject<BetslipSelectionState?, Never>
    var simpleBetslipSelectionStateList: CurrentValueSubject<[String: BetslipSelectionState], Never> = .init([:])
    var betPlacedDetailsErrorsPublisher: CurrentValueSubject<[BetPlacedDetails], Never>
    var betslipPlaceBetResponseErrorsPublisher: CurrentValueSubject<[BetslipPlaceBetResponse], Never>

    private var bettingTicketServiceProviderSubscriptions: [String: ServicesProvider.Subscription] = [:]
    private var bettingTicketsCancellables: [String: AnyCancellable] = [:]

    var betBuilderOddPublisher: CurrentValueSubject<Double?, Never> = .init(nil)

    private var cancellables: Set<AnyCancellable> = []

    override init() {
        
        self.bettingTicketsPublisher = .init([])
        self.bettingTicketsDictionaryPublisher = .init([:])
        self.bettingTicketPublisher = [:]

        self.simpleBetslipSelectionState = .init(nil)
        self.multipleBetslipSelectionState = .init(nil)
        self.systemBetslipSelectionState = .init(nil)

        self.betPlacedDetailsErrorsPublisher = .init([])
        self.betslipPlaceBetResponseErrorsPublisher = .init([])
        
        super.init()

    }

    func start() {

        var cachedBetslipTicketsDictionary: OrderedDictionary<String, BettingTicket> = [:]
        for ticket in UserDefaults.standard.cachedBetslipTickets {
            cachedBetslipTicketsDictionary[ticket.id] = ticket
        }
        self.bettingTicketsDictionaryPublisher.send(cachedBetslipTicketsDictionary)

        NotificationCenter.default.publisher(for: .socketConnected)
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

                print("Tickets updates")
                for ticket in tickets {
                    print("\(ticket.id) \(ticket.outcomeDescription) \(ticket.odd)")
                }
            }
            .store(in: &cancellables)

        self.bettingTicketsPublisher
            .sink { tickets in
                UserDefaults.standard.cachedBetslipTickets = tickets
            }
            .store(in: &cancellables)

        self.bettingTicketsDictionaryPublisher
            .filter(\.isEmpty)
            .sink { [weak self] _ in
                self?.simpleBetslipSelectionState.send(nil)
                self?.multipleBetslipSelectionState.send(nil)
                UserDefaults.standard.cachedBetslipTickets = []
            }
            .store(in: &cancellables)

        self.bettingTicketsPublisher
            .filter({ return !$0.isEmpty })
            .sink(receiveValue: { [weak self] bettingTickets in
                self?.requestAllowedBetTypes(withBettingTickets: bettingTickets)
            })
            .store(in: &cancellables)

        self.bettingTicketsDictionaryPublisher
            .filter({ return !$0.isEmpty })
            .removeDuplicates()
            .debounce(for: 1.0, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
            .map({ _ -> Void in
                return ()
            })
            .sink { [weak self] in
                self?.requestSimpleBetslipSelectionState()
                self?.requestMultipleBetslipSelectionState()
            }
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
        self.bettingTicketServiceProviderSubscriptions[id] = nil

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
                    self?.bettingTicketServiceProviderSubscriptions[bettingTicket.id] = subscription
                case .contentUpdate(let market):
                    print("Betslip subscribeToMarketDetails content retrieved!")
                    let internalMarket = ServiceProviderModelMapper.market(fromServiceProviderMarket: market)
                    self?.updateBettingTickets(ofMarket: internalMarket)
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
            }
        }
    }

    private func updateBettingTicket(withId id: String, bettingOffer: EveryMatrix.BettingOffer) {
        if let bettingTicket = self.bettingTicketsDictionaryPublisher.value[id], let value = bettingOffer.oddsValue {
            let newBettingTicket = BettingTicket(id: bettingTicket.id,
                                                 outcomeId: bettingTicket.outcomeId,
                                                 marketId: bettingTicket.marketId,
                                                 matchId: bettingTicket.matchId,
                                                 decimalOdd: value,
                                                 isAvailable: bettingOffer.isAvailable ?? bettingTicket.isAvailable,
                                                 matchDescription: bettingTicket.matchDescription,
                                                 marketDescription: bettingTicket.marketDescription,
                                                 outcomeDescription: bettingTicket.outcomeDescription)
            self.bettingTicketsDictionaryPublisher.value[id] = newBettingTicket

            self.bettingTicketPublisher[id]?.send(newBettingTicket)
        }
    }

    private func updateBettingTicketOdd(withId id: String, statusId: String?, newOdd: Double?, isAvailable: Bool?) {
        if let bettingTicket = self.bettingTicketsDictionaryPublisher.value[id] {
            let newBettingTicket = BettingTicket(id: bettingTicket.id,
                                                 outcomeId: bettingTicket.outcomeId,
                                                 marketId: bettingTicket.marketId,
                                                 matchId: bettingTicket.matchId,
                                                 decimalOdd: newOdd ?? bettingTicket.decimalOdd,
                                                 isAvailable: isAvailable ?? bettingTicket.isAvailable,
                                                 matchDescription: bettingTicket.matchDescription,
                                                 marketDescription: bettingTicket.marketDescription,
                                                 outcomeDescription: bettingTicket.outcomeDescription)
            self.bettingTicketsDictionaryPublisher.value[id] = newBettingTicket

            self.bettingTicketPublisher[id]?.send(newBettingTicket)
        }
    }

    func bettingTicketPublisher(withId id: String) -> AnyPublisher<BettingTicket, Never>? {
        if let bettingTicketPublisher = self.bettingTicketPublisher[id] {
            return bettingTicketPublisher.eraseToAnyPublisher()
        }
        return nil
    }

    // TODO: Code Review - Vamos ver se é possivel simplificar isto, são dois publishers para o mesmo efeito
    func addBetPlacedDetailsError(betPlacedDetails: [BetPlacedDetails]) {
        self.betPlacedDetailsErrorsPublisher.send(betPlacedDetails)
    }

    func removeAllPlacedDetailsError() {
        self.betPlacedDetailsErrorsPublisher.send([])
    }

    func addBetslipPlacedBetErrorResponse(betPlacedError: [BetslipPlaceBetResponse]) {
        self.betslipPlaceBetResponseErrorsPublisher.send(betPlacedError)
    }

    func removeAllBetslipPlacedBetErrorResponse() {
        self.betslipPlaceBetResponseErrorsPublisher.send([])
    }

}

//
extension BetslipManager {

    func refreshAllowedBetTypes() {
        self.requestAllowedBetTypes(withBettingTickets: self.bettingTicketsPublisher.value)
    }

    func requestAllowedBetTypes(withBettingTickets bettingTickets: [BettingTicket]) {
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
            .sink { completion in

                print("getAllowedBetTypes completion \(completion)")
            } receiveValue: { [weak self] allowedBetTypes in

                let betTypes = allowedBetTypes.map { betType in

                    switch betType.grouping {
                    case .single: return BetType.single(identifier: betType.code)
                    case .multiple: return BetType.multiple(identifier: betType.code)
                    case .system: return BetType.system(identifier: betType.code, name: betType.name)
                    }
                }

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

                self?.allowedBetTypesPublisher.send(betTypes)
                self?.systemTypesAvailablePublisher.send(systemBetTypes)
            }
            .store(in: &cancellables)
    }

    func placeMultipleBet(withBettingTickets bettingTickets: [BettingTicket]) {

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
        self.allowedBetTypesPublisher.value.forEach { betType in
            switch betType {
            case .multiple(let identifier):
                multipleBetIdentifier = identifier
            default:
                ()
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

    func requestSimpleBetPotentialReturn(withSkateAmount amounts: [String: Double]) {

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

        let betslipState = ServicesProvider.BetTicket(tickets: ticketSelections,
                                                      stake: nil,
                                                      betGroupingType: BetGroupingType.single(identifier: "S"))

        Env.servicesProvider.calculatePotentialReturn(forBetTicket: betslipState)
            .sink(receiveCompletion: { completion in

            }, receiveValue: { (betslipPotentialReturn: BetslipPotentialReturn) in

            })
            .store(in: &cancellables)

    }

    func requestSystemBetPotentialReturn(withSkateAmount stake: Double, systemBetType: SystemBetType) -> AnyPublisher<BetPotencialReturn, Never> {

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
            .replaceError(with: nil)
            .replaceNil(with: BetPotencialReturn(potentialReturn: 0, totalStake: 0, numberOfBets: 0))
            .eraseToAnyPublisher()
    }

    func requestSimpleBetslipSelectionState(oddsBoostPercentage: Double? = nil) {

        let ticketSelections = self.bettingTicketsPublisher.value
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.decimalOdd) })

        for ticket in ticketSelections {

            let route = TSRouter.getBetslipSelectionInfo(language: "en",
                                                         stakeAmount: 1,
                                                         betType: .single,
                                                         tickets: [ticket],
                                                         oddsBoostPercentage: oddsBoostPercentage)

            Env.everyMatrixClient.manager
                .getModel(router: route, decodingType: BetslipSelectionState.self)
                .handleEvents(receiveOutput: { betslipSelectionState in
                    self.simpleBetslipSelectionState.send(betslipSelectionState)
                })
                .receive(on: DispatchQueue.main)
                .sink { _ in

                } receiveValue: { betslipSelectionState in
                    self.simpleBetslipSelectionState.send(betslipSelectionState)

                    // Add to simple selection array
                    self.simpleBetslipSelectionStateList.value[ticket.id] = betslipSelectionState
                    self.simpleBetslipSelectionStateList.send(self.simpleBetslipSelectionStateList.value)
                }
                .store(in: &cancellables)

        }
    }

    func requestMultipleBetslipSelectionState(oddsBoostPercentage: Double? = nil) {

        let ticketSelections = self.bettingTicketsPublisher.value
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.decimalOdd) })

        let route = TSRouter.getBetslipSelectionInfo(language: "en",
                                                     stakeAmount: 1,
                                                     betType: .multiple,
                                                     tickets: ticketSelections, oddsBoostPercentage: oddsBoostPercentage)

        Env.everyMatrixClient.manager
            .getModel(router: route, decodingType: BetslipSelectionState.self)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] betslipSelectionState in
                self?.multipleBetslipSelectionState.send(betslipSelectionState)

                if let betBuilder = betslipSelectionState.betBuilder,
                   let betBuilderOdds = betBuilder[safe: 0]?.betBuilderOdds {
                    self?.betBuilderOddPublisher.send(betBuilderOdds)
                }
                else {
                    self?.betBuilderOddPublisher.send(nil)
                }
            }
            .store(in: &cancellables)

    }

    func requestSystemBetslipSelectionState(withSkateAmount amount: Double = 1.0, systemBetType: SystemBetType)
    -> AnyPublisher<BetslipSelectionState, EveryMatrix.APIError> {

        let ticketSelections = self.bettingTicketsPublisher.value
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.decimalOdd) })

        let route = TSRouter.getSystemBetSelectionInfo(language: "en",
                                                       stakeAmount: amount,
                                                       systemBetType: systemBetType,
                                                       tickets: ticketSelections)

        return Env.everyMatrixClient.manager
            .getModel(router: route, decodingType: BetslipSelectionState.self)
            .handleEvents(receiveOutput: { betslipSelectionState in
                // self.simpleBetslipSelectionState.send(betslipSelectionState)
                self.systemBetslipSelectionState.send(betslipSelectionState)
            })
            .eraseToAnyPublisher()

    }

    func getErrorsForBettingTicket(bettingTicket: BettingTicket) -> BetslipError {

        if !betslipPlaceBetResponseErrorsPublisher.value.isEmpty {
            let bettingTicketErrors = betslipPlaceBetResponseErrorsPublisher.value

            var hasFoundCorrespondingId = false
            var errorMessage = ""

            for bettingError in bettingTicketErrors {
                if let bettingErrorCode = bettingError.errorCode {
                    // Error code with corresponding id
                    if bettingErrorCode == "107" {
                        if let bettingErrorMessage = bettingError.errorMessage {
                            if bettingErrorMessage.contains(bettingTicket.bettingId) {
                                hasFoundCorrespondingId = true
                                errorMessage = bettingError.errorMessage ?? localized("error")
                                break
                            }

                        }
                    }
                    else {
                        if let bettingSelections = bettingError.selections {
                            for selection in bettingSelections where selection.id == bettingTicket.bettingId {
                                hasFoundCorrespondingId = true
                                errorMessage = bettingError.errorMessage ?? localized("error")
                                break
                            }

                        }
                    }
                }
            }

            if hasFoundCorrespondingId {
                let betslipError = BetslipError(errorMessage: errorMessage, errorType: .betPlacementError)
                return betslipError
            }
            else {
                return BetslipError()
            }

        }
        else if let forbiddenBetCombinations = Env.betslipManager.multipleBetslipSelectionState.value?.forbiddenCombinations,
                !forbiddenBetCombinations.isEmpty {

            var hasFoundCorrespondingId = false

            for forbiddenBetCombination in forbiddenBetCombinations {
                for selection in forbiddenBetCombination.selections where selection.bettingOfferId == bettingTicket.bettingId {
                    hasFoundCorrespondingId = true
                    break

                }
            }

            if hasFoundCorrespondingId {
                let betslipError = BetslipError(errorMessage: localized("selections_not_combinable"), errorType: .forbiddenBetError)
                return betslipError
            }
            else {
                return BetslipError()
            }
        }
        else {
            return BetslipError()
        }
    }

    func getErrorsForSingleBetBettingTicket(bettingTicket: BettingTicket) -> BetslipError {

        if betslipPlaceBetResponseErrorsPublisher.value.isEmpty {
            let bettingTicketErrors = betslipPlaceBetResponseErrorsPublisher.value
            var hasFoundCorrespondingId = false
            var errorMessage = localized("error")
            for bettingError in bettingTicketErrors {
                if let bettingSelections = bettingError.selections {
                    for selection in bettingSelections where selection.id == bettingTicket.bettingId {
                        hasFoundCorrespondingId = true
                        errorMessage = bettingError.errorMessage ?? localized("error")
                    }

                }
            }

            if hasFoundCorrespondingId {
                let betslipError = BetslipError(errorMessage: errorMessage, errorType: .betPlacementError)
                return betslipError
            }
            else {
                return BetslipError()

            }
        }
        else {
            return BetslipError()
        }
    }

}

enum BetslipErrorType: Error {
    case emptyBetslip
    case betPlacementError
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
