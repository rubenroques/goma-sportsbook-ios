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

struct BetPlacedDetails {
    var response: BetslipPlaceBetResponse
    var tickets: [BettingTicket]
}

class BetslipManager: NSObject {

    var newBetsPlacedPublisher = PassthroughSubject<Void, Never>.init()
    var bettingTicketsPublisher: CurrentValueSubject<[BettingTicket], Never>

    private var bettingTicketsDictionaryPublisher: CurrentValueSubject<OrderedDictionary<String, BettingTicket>, Never>

    var simpleBetslipSelectionState: CurrentValueSubject<BetslipSelectionState?, Never>
    var multipleBetslipSelectionState: CurrentValueSubject<BetslipSelectionState?, Never>
    var systemBetslipSelectionState: CurrentValueSubject<BetslipSelectionState?, Never>
    var simpleBetslipSelectionStateList: CurrentValueSubject<[String: BetslipSelectionState], Never> = .init([:])

    var betPlacedDetailsErrorsPublisher: CurrentValueSubject<[BetPlacedDetails], Never>
    var betslipPlaceBetResponseErrorsPublisher: CurrentValueSubject<[BetslipPlaceBetResponse], Never>


    private var bettingTicketRegisters: [String: EndpointPublisherIdentifiable] = [:]
    private var bettingTicketSubscribers: [String: AnyCancellable] = [:]

    private var cancellables: Set<AnyCancellable> = []

    override init() {

        self.bettingTicketsDictionaryPublisher = .init([:])
        self.bettingTicketsPublisher = .init([])
        self.simpleBetslipSelectionState = .init(nil)
        self.multipleBetslipSelectionState = .init(nil)
        self.systemBetslipSelectionState = .init(nil)
        self.betPlacedDetailsErrorsPublisher = .init([])
        self.betslipPlaceBetResponseErrorsPublisher = .init([])
        
        super.init()

        bettingTicketsDictionaryPublisher
            .map({ dictionary -> [BettingTicket] in
                return Array.init(dictionary.values)
            })
            .sink { [weak self] tickets in
                self?.bettingTicketsPublisher.send(tickets)
            }
            .store(in: &cancellables)

        bettingTicketsDictionaryPublisher
            .filter(\.isEmpty)
            .sink { [weak self] _ in
            self?.simpleBetslipSelectionState.send(nil)
            self?.multipleBetslipSelectionState.send(nil)
        }
        .store(in: &cancellables)

        bettingTicketsDictionaryPublisher
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
        bettingTicketsDictionaryPublisher.value[bettingTicket.id] = bettingTicket
        self.subscribeBettingTicketPublisher(bettingTicket: bettingTicket)
    }

    func removeBettingTicket(_ bettingTicket: BettingTicket) {
        bettingTicketsDictionaryPublisher.value[bettingTicket.id] = nil
        self.unsubscribeBettingTicketPublisher(withId: bettingTicket.id)
    }

    func removeBettingTicket(withId id: String) {
        bettingTicketsDictionaryPublisher.value[id] = nil
        self.unsubscribeBettingTicketPublisher(withId: id)
    }

    func hasBettingTicket(_ bettingTicket: BettingTicket) -> Bool {
        return bettingTicketsDictionaryPublisher.value[bettingTicket.id] != nil
    }

    func hasBettingTicket(withId id: String) -> Bool {
        return bettingTicketsDictionaryPublisher.value[id] != nil
    }

    func clearAllBettingTickets() {
        for bettingTicket in self.bettingTicketsDictionaryPublisher.value.values {
            self.unsubscribeBettingTicketPublisher(withId: bettingTicket.id)
        }
        bettingTicketsDictionaryPublisher.send([:])
    }

    private func unsubscribeBettingTicketPublisher(withId id: String) {
        if let register = self.bettingTicketRegisters[id] {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: register)
            self.bettingTicketRegisters.removeValue(forKey: id)
        }
        if let subscriber = self.bettingTicketSubscribers[id] {
            subscriber.cancel()
            self.bettingTicketSubscribers.removeValue(forKey: id)
        }
    }

    private func subscribeBettingTicketPublisher(bettingTicket: BettingTicket) {
        let endpoint = TSRouter.bettingOfferPublisher(operatorId: Env.appSession.operatorId,
                                                      language: "en",
                                                      bettingOfferId: bettingTicket.id)

        let bettingTicketSubscriber = Env.everyMatrixClient.manager.registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving data!")
                case .finished:
                    print("Data retrieved!")
                }
            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let oddUpdatesRegister):
                    self?.bettingTicketRegisters[bettingTicket.id] = oddUpdatesRegister

                case .initialContent(let aggregator):

                    if let content = aggregator.content {
                        for contentType in content {
                            if case let .bettingOffer(bettingOffer) = contentType {
                                self?.updateBettingTicket(withId: bettingOffer.id, bettingOffer: bettingOffer)
                            }
                        }
                    }

                case .updatedContent(let aggregatorUpdates):
                    if let content = aggregatorUpdates.contentUpdates {
                        for contentType in content {
                            if case let .bettingOfferUpdate(id, odd, _, isAvailable) = contentType {
                                self?.updateBettingTicketOdd(withId: id, newOdd: odd, isAvailable: isAvailable)
                            }
                        }
                    }

                case .disconnect:
                    print("MarketDetailCell odd update - disconnect")
                }
            })

        self.bettingTicketSubscribers[bettingTicket.id] = bettingTicketSubscriber
    }
    
    private func updateBettingTicket(withId id: String, bettingOffer: EveryMatrix.BettingOffer) {
        if let bettingTicket = self.bettingTicketsDictionaryPublisher.value[id], let value = bettingOffer.oddsValue {
            let newBettingTicket = BettingTicket(id: bettingTicket.id,
                                                 outcomeId: bettingTicket.outcomeId,
                                                 marketId: bettingTicket.marketId,
                                                 matchId: bettingTicket.matchId,
                                                 value: value,
                                                 isAvailable: bettingTicket.isAvailable,
                                                 matchDescription: bettingTicket.matchDescription,
                                                 marketDescription: bettingTicket.marketDescription,
                                                 outcomeDescription: bettingTicket.outcomeDescription)
            self.bettingTicketsDictionaryPublisher.value[id] = newBettingTicket
        }
    }

    private func updateBettingTicketOdd(withId id: String, newOdd: Double?, isAvailable: Bool?) {
        if let bettingTicket = self.bettingTicketsDictionaryPublisher.value[id] {
            let newBettingTicket = BettingTicket(id: bettingTicket.id,
                                                 outcomeId: bettingTicket.outcomeId,
                                                 marketId: bettingTicket.marketId,
                                                 matchId: bettingTicket.matchId,
                                                 value: newOdd ?? bettingTicket.value,
                                                 isAvailable: isAvailable ?? bettingTicket.isAvailable,
                                                 matchDescription: bettingTicket.matchDescription,
                                                 marketDescription: bettingTicket.marketDescription,
                                                 outcomeDescription: bettingTicket.outcomeDescription)
            self.bettingTicketsDictionaryPublisher.value[id] = newBettingTicket
        }
    }

    func updatedBettingTicketsOdds() -> [BettingTicket] {
        var updatedTickets: [BettingTicket] = []

        for ticket in self.bettingTicketsPublisher.value {
            if let ticketOdd = Env.everyMatrixStorage.bettingOfferPublishers[ticket.id], let oddsValue = ticketOdd.value.oddsValue {
                let newTicket = BettingTicket(id: ticket.id,
                                              outcomeId: ticket.outcomeId,
                                              marketId: ticket.marketId,
                                              matchId: ticket.matchId,
                                              value: oddsValue,
                                              isAvailable: ticket.isAvailable,
                                              matchDescription: ticket.matchDescription,
                                              marketDescription: ticket.marketDescription,
                                              outcomeDescription: ticket.outcomeDescription)
                updatedTickets.append(newTicket)
            }
            else {
                // TODO: The ticket value is not updated
                let newTicket = BettingTicket(id: ticket.id,
                                              outcomeId: ticket.outcomeId,
                                              marketId: ticket.marketId,
                                              matchId: ticket.matchId,
                                              value: ticket.value,
                                              isAvailable: ticket.isAvailable,
                                              matchDescription: ticket.matchDescription,
                                              marketDescription: ticket.marketDescription,
                                              outcomeDescription: ticket.outcomeDescription)
                updatedTickets.append(newTicket)
            }
        }
        return updatedTickets
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

    func requestSimpleBetslipSelectionState() {

        let ticketSelections = self.updatedBettingTicketsOdds()
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })

        for ticket in ticketSelections {

            let route = TSRouter.getBetslipSelectionInfo(language: "en",
                                                         stakeAmount: 1,
                                                         betType: .single,
                                                         tickets: [ticket])

            Env.everyMatrixClient.manager
                .getModel(router: route, decodingType: BetslipSelectionState.self)
                .handleEvents(receiveOutput: { betslipSelectionState in
                    self.simpleBetslipSelectionState.send(betslipSelectionState)
                })
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    print("completed simple: \(completion)")
                } receiveValue: { betslipSelectionState in
                    self.simpleBetslipSelectionState.send(betslipSelectionState)

                    // Add to simple selection array
                    self.simpleBetslipSelectionStateList.value[ticket.id] = betslipSelectionState
                    self.simpleBetslipSelectionStateList.send(self.simpleBetslipSelectionStateList.value)
                }
                .store(in: &cancellables)

        }

    }

    func requestMultipleBetslipSelectionState() {

        let ticketSelections = self.updatedBettingTicketsOdds()
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })

        let route = TSRouter.getBetslipSelectionInfo(language: "en",
                                                     stakeAmount: 1,
                                                     betType: .multiple,
                                                     tickets: ticketSelections)

        Env.everyMatrixClient.manager
            .getModel(router: route, decodingType: BetslipSelectionState.self)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("completed multi: \(completion)")
            } receiveValue: { betslipSelectionState in
                self.multipleBetslipSelectionState.send(betslipSelectionState)
            }
            .store(in: &cancellables)

    }

    func requestSystemBetslipSelectionState(withSkateAmount amount: Double = 1.0, systemBetType: SystemBetType)
    -> AnyPublisher<BetslipSelectionState, EveryMatrix.APIError> {

        let ticketSelections = self.updatedBettingTicketsOdds()
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })

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

    ///
    ///
    func placeAllSingleBets(withSkateAmount amounts: [String: Double]) -> AnyPublisher<[BetPlacedDetails], EveryMatrix.APIError> {

        let future = Future<[BetPlacedDetails], EveryMatrix.APIError>.init({ promise in
            self.placeNextSingleBet(betPlacedDetailsList: [], amounts: amounts, completion: { result in
                switch result {
                case .success(let betPlacedDetailsList):
                    promise(.success(betPlacedDetailsList))
                case .failure(let error):
                    promise(.failure(error))
                }
            })
        })
        .eraseToAnyPublisher()

        return future
    }

    private func placeNextSingleBet( betPlacedDetailsList: [BetPlacedDetails],
                                     amounts: [String: Double],
                                     completion: @escaping ( Result<[BetPlacedDetails], EveryMatrix.APIError> ) -> Void) {

        let ticketSelections = self.updatedBettingTicketsOdds()
        
        if ticketSelections.isEmpty {
            completion(.success(betPlacedDetailsList))
            self.newBetsPlacedPublisher.send()
            return
        }

        if let lastTicket = ticketSelections.first, let lastTicketAmount = amounts[lastTicket.id] {
            placeSingleBet(betTicketId: lastTicket.id, amount: lastTicketAmount)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (publisherCompletion: Subscribers.Completion<EveryMatrix.APIError>) -> Void in
                    switch publisherCompletion {
                    case .failure(let error):
                        completion( .failure(error) )
                    default: ()
                    }
                }, receiveValue: { (betPlacedDetails: BetPlacedDetails) -> Void in
                    if let response = betPlacedDetails.response.betSucceed, response == true {
                            self.removeBettingTicket(withId: lastTicket.id)
                            var newList = betPlacedDetailsList
                            newList.append(betPlacedDetails)
                        self.placeNextSingleBet(betPlacedDetailsList: newList, amounts: amounts, completion: completion)
                    }
                    else {
                        var newList = betPlacedDetailsList
                        newList.append(betPlacedDetails)
                        completion( .success(newList) )
                        self.newBetsPlacedPublisher.send()
                    }
                })
                .store(in: &cancellables)
        }
    }
    
    private func placeSingleBet(betTicketId: String, amount: Double) -> AnyPublisher<BetPlacedDetails, EveryMatrix.APIError> {
        let updatedTicketSelections = self.updatedBettingTicketsOdds()
        let ticketSelections = updatedTicketSelections.filter({ bettingTicket in
            bettingTicket.id == betTicketId
        }).map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })
        let userBetslipSetting = UserDefaults.standard.string(forKey: "user_betslip_settings")
        let route = TSRouter.placeBet(language: "en",
                                      amount: amount,
                                      betType: .single,
                                      tickets: ticketSelections, oddsValidationType: userBetslipSetting ?? "ACCEPT_ANY")

        Logger.log("BetslipManager - Submitting single bet: \(route)")

        return Env.everyMatrixClient.manager
            .getModel(router: route, decodingType: BetslipPlaceBetResponse.self)
            .map({ response in
                return BetPlacedDetails.init(response: response, tickets: updatedTicketSelections)
            })
            .eraseToAnyPublisher()
        
    }

    func placeMultipleBet(withSkateAmount amount: Double) -> AnyPublisher<BetPlacedDetails, EveryMatrix.APIError> {

        let updatedTicketSelections = self.updatedBettingTicketsOdds()
        let ticketSelections = updatedTicketSelections
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })
        let userBetslipSetting = UserDefaults.standard.string(forKey: "user_betslip_settings")
        let route = TSRouter.placeBet(language: "en",
                                      amount: amount,
                                      betType: .multiple,
                                      tickets: ticketSelections, oddsValidationType: userBetslipSetting ?? "ACCEPT_ANY")

        Logger.log("BetslipManager - Submitting multiple bet: \(route)")

        return Env.everyMatrixClient.manager
            .getModel(router: route, decodingType: BetslipPlaceBetResponse.self)
            .map({ return BetPlacedDetails.init(response: $0, tickets: updatedTicketSelections) })
            .handleEvents(receiveOutput: { betslipPlaceBetResponse in
                if betslipPlaceBetResponse.response.betSucceed ?? false {
                    self.clearAllBettingTickets()
                    self.newBetsPlacedPublisher.send()
                }
            })
            .eraseToAnyPublisher()
    }

    func placeSystemBet(withSkateAmount amount: Double, systemBetType: SystemBetType) -> AnyPublisher<BetPlacedDetails, EveryMatrix.APIError> {

        let updatedTicketSelections = self.updatedBettingTicketsOdds()
        let ticketSelections = updatedTicketSelections
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })
        let userBetslipSetting = UserDefaults.standard.string(forKey: "user_betslip_settings")

        let route = TSRouter.placeSystemBet(language: "en",
                                            amount: amount,
                                            systemBetType: systemBetType,
                                            tickets: ticketSelections, oddsValidationType: userBetslipSetting ?? "ACCEPT_ANY")

        Logger.log("BetslipManager - Submitting system bet: \(route)")
        
        return Env.everyMatrixClient.manager
            .getModel(router: route, decodingType: BetslipPlaceBetResponse.self)
            .map({ return BetPlacedDetails.init(response: $0, tickets: updatedTicketSelections) })
            .handleEvents(receiveOutput: { betslipPlaceBetResponse in
                if betslipPlaceBetResponse.response.betSucceed ?? false {
                    self.clearAllBettingTickets()
                    self.newBetsPlacedPublisher.send()
                }
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
                let betslipError = BetslipError(errorMessage: errorMessage, errorType: .placedBetError)
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
                let betslipError = BetslipError(errorMessage: errorMessage, errorType: .placedBetError)
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

struct BetslipError {
    var errorMessage: String
    var errorType: BetslipErrorType

    init(errorMessage: String = "", errorType: BetslipErrorType = .none) {
        self.errorMessage = errorMessage
        self.errorType = errorType
    }

    enum BetslipErrorType {
        case placedBetError
        case forbiddenBetError
        case none
    }
}
