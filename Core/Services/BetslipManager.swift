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

    private var bettingTicketPublisher: [String: CurrentValueSubject<BettingTicket, Never>]

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

        self.bettingTicketsPublisher = .init([])
        self.bettingTicketsDictionaryPublisher = .init([:])
        self.bettingTicketPublisher = [:]

        self.simpleBetslipSelectionState = .init(nil)
        self.multipleBetslipSelectionState = .init(nil)
        self.systemBetslipSelectionState = .init(nil)
        self.betPlacedDetailsErrorsPublisher = .init([])
        self.betslipPlaceBetResponseErrorsPublisher = .init([])
        
        super.init()
        
        NotificationCenter.default.publisher(for: .socketConnected)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] _ in
                self?.reconnectBettingTicketsUpdates()
            })
            .store(in: &cancellables)

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

    private func reconnectBettingTicketsUpdates() {
        
        if UserDefaults.standard.cachedBetslipTickets.isNotEmpty {
            self.bettingTicketsPublisher.send(UserDefaults.standard.cachedBetslipTickets)
        }
        else {
            for bettingTicket in self.bettingTicketsPublisher.value {
                self.subscribeBettingTicketPublisher(bettingTicket: bettingTicket)
            }
        }
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

        self.bettingTicketPublisher.removeValue(forKey: id)
        
    }

    private func subscribeBettingTicketPublisher(bettingTicket: BettingTicket) {

        if let publisher = self.bettingTicketPublisher[bettingTicket.id] {
            publisher.send(bettingTicket)
        }
        else {
            self.bettingTicketPublisher[bettingTicket.id] = .init(bettingTicket)
        }

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
                            if case let .bettingOfferUpdate(id, statusId, odd, _, isAvailable) = contentType {
                                self?.updateBettingTicketOdd(withId: id, statusId: statusId, newOdd: odd, isAvailable: isAvailable)
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
                                                 isAvailable: bettingOffer.isAvailable ?? bettingTicket.isAvailable,
                                                 statusId: bettingOffer.statusId ?? bettingTicket.statusId,
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
                                                 value: newOdd ?? bettingTicket.value,
                                                 isAvailable: isAvailable ?? bettingTicket.isAvailable,
                                                 statusId: statusId ?? bettingTicket.statusId,
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

    func requestSimpleBetslipSelectionState(oddsBoostPercentage: Double? = nil) {

        let ticketSelections = self.bettingTicketsPublisher.value
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })

        for ticket in ticketSelections {

            let route = TSRouter.getBetslipSelectionInfo(language: "en",
                                                         stakeAmount: 1,
                                                         betType: .single,
                                                         tickets: [ticket], oddsBoostPercentage: oddsBoostPercentage)

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

    func requestMultipleBetslipSelectionState(oddsBoostPercentage: Double? = nil) {

        let ticketSelections = self.bettingTicketsPublisher.value
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })

        let route = TSRouter.getBetslipSelectionInfo(language: "en",
                                                     stakeAmount: 1,
                                                     betType: .multiple,
                                                     tickets: ticketSelections, oddsBoostPercentage: oddsBoostPercentage)

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

        let ticketSelections = self.bettingTicketsPublisher.value
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
    func placeAllSingleBets(withSkateAmount amounts: [String: Double], singleFreeBet: SingleBetslipFreebet? = nil, singleOddsBoost: SingleBetslipOddsBoost? = nil) ->
    AnyPublisher<[BetPlacedDetails], EveryMatrix.APIError> {

        let future = Future<[BetPlacedDetails], EveryMatrix.APIError>.init({ promise in

            var betPlacedDetailsList: [BetPlacedDetails] = []
            let ticketSelections = self.bettingTicketsPublisher.value

            let requests = ticketSelections.map { ticketSelection -> AnyPublisher<BetPlacedDetails, EveryMatrix.APIError>? in
                guard let amount = amounts[ticketSelection.id] else {
                    return nil
                }
                return self.placeSingleBet(betTicketId: ticketSelection.id, amount: amount, singleFreeBet: singleFreeBet, singleOddsBoost: singleOddsBoost)
            }
            .compactMap({ $0 })

            Publishers.MergeMany(requests)
                .sink(receiveCompletion: { completion in

                    switch completion {
                    case .finished:
                        promise(.success(betPlacedDetailsList))
                    case .failure(let everyMatrixAPIError):
                        promise(.failure(everyMatrixAPIError))
                    }

                }, receiveValue: { betPlacedDetails in
                    betPlacedDetailsList.append(betPlacedDetails)
                })
                .store(in: &self.cancellables)

        })
        .eraseToAnyPublisher()

        return future
    }

    private func placeSingleBet(betTicketId: String, amount: Double, singleFreeBet: SingleBetslipFreebet?, singleOddsBoost: SingleBetslipOddsBoost?) ->
    AnyPublisher<BetPlacedDetails, EveryMatrix.APIError> {

        let updatedTicketSelections = self.bettingTicketsPublisher.value
        let ticketSelections = updatedTicketSelections.filter({ bettingTicket in
            bettingTicket.id == betTicketId
        }).map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })

        let userBetslipSetting = UserDefaults.standard.string(forKey: "user_betslip_settings")

        var betAmount = amount
        var isFreeBet = false
        var ubsWalletId = ""

        if let singleFreeBet = singleFreeBet, singleFreeBet.bettingId == betTicketId {
            betAmount = singleFreeBet.freeBet.freeBetAmount
            isFreeBet = true
            ubsWalletId = singleFreeBet.freeBet.walletId
        }

        if let singleOddsBoost = singleOddsBoost, singleOddsBoost.bettingId == betTicketId {
            ubsWalletId = singleOddsBoost.oddsBoost.walletId
        }

        let route = TSRouter.placeBet(language: "en",
                                      amount: betAmount,
                                      betType: .single,
                                      tickets: ticketSelections, oddsValidationType: userBetslipSetting ?? "ACCEPT_ANY",
                                      freeBet: isFreeBet,
                                      ubsWalletId: ubsWalletId)

        Logger.log("BetslipManager - Submitting single bet: \(route)")

        return Env.everyMatrixClient.manager
            .getModel(router: route, decodingType: BetslipPlaceBetResponse.self)
            .map({ response in
                
                return BetPlacedDetails.init(response: response, tickets: updatedTicketSelections)
            })
            .eraseToAnyPublisher()
        
    }

    func placeMultipleBet(withSkateAmount amount: Double, freeBet: BetslipFreebet? = nil, oddsBoost: BetslipOddsBoost? = nil) -> AnyPublisher<BetPlacedDetails, EveryMatrix.APIError> {

        let updatedTicketSelections = self.bettingTicketsPublisher.value
        let ticketSelections = updatedTicketSelections
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })
        let userBetslipSetting = UserDefaults.standard.string(forKey: "user_betslip_settings")

        var betAmount = amount
        var isFreeBet = false
        var ubsWalletId = ""

        if let freeBet = freeBet {
            betAmount = freeBet.freeBetAmount
            isFreeBet = true
            ubsWalletId = freeBet.walletId
        }

        if let oddsBoost = oddsBoost {
            ubsWalletId = oddsBoost.walletId
        }

        let route = TSRouter.placeBet(language: "en",
                                      amount: betAmount,
                                      betType: .multiple,
                                      tickets: ticketSelections, oddsValidationType: userBetslipSetting ?? "ACCEPT_ANY",
                                      freeBet: isFreeBet,
                                      ubsWalletId: ubsWalletId)

        Logger.log("BetslipManager - Submitting multiple bet: \(route)")

        return Env.everyMatrixClient.manager
            .getModel(router: route, decodingType: BetslipPlaceBetResponse.self)
            .map({ return BetPlacedDetails.init(response: $0, tickets: updatedTicketSelections) })
            .handleEvents(receiveOutput: { betslipPlaceBetResponse in
                if betslipPlaceBetResponse.response.betSucceed ?? false {
                    //self.clearAllBettingTickets()
                    self.newBetsPlacedPublisher.send()
                    UserDefaults.standard.cachedBetslipTickets = []
                    
                }
            })
            .eraseToAnyPublisher()
    }

    func placeSystemBet(withSkateAmount amount: Double, systemBetType: SystemBetType, freeBet: BetslipFreebet? = nil) -> AnyPublisher<BetPlacedDetails, EveryMatrix.APIError> {

        let updatedTicketSelections = self.bettingTicketsPublisher.value
        let ticketSelections = updatedTicketSelections
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })
        let userBetslipSetting = UserDefaults.standard.string(forKey: "user_betslip_settings")

        var betAmount = amount
        var isFreeBet = false
        var ubsWalletId = ""
        if let freeBet = freeBet {
            betAmount = freeBet.freeBetAmount
            isFreeBet = true
            ubsWalletId = freeBet.walletId
        }

        let route = TSRouter.placeSystemBet(language: "en",
                                            amount: betAmount,
                                            systemBetType: systemBetType,
                                            tickets: ticketSelections, oddsValidationType: userBetslipSetting ?? "ACCEPT_ANY",
                                            freeBet: isFreeBet,
                                            ubsWalletId: ubsWalletId)

        Logger.log("BetslipManager - Submitting system bet: \(route)")
        
        return Env.everyMatrixClient.manager
            .getModel(router: route, decodingType: BetslipPlaceBetResponse.self)
            .map({ return BetPlacedDetails.init(response: $0, tickets: updatedTicketSelections) })
            .handleEvents(receiveOutput: { betslipPlaceBetResponse in
                if betslipPlaceBetResponse.response.betSucceed ?? false {
                    //self.clearAllBettingTickets()
                    self.newBetsPlacedPublisher.send()
                    UserDefaults.standard.cachedBetslipTickets = []
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
