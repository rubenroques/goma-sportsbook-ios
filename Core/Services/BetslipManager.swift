//
//  BetslipManager.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine
import OrderedCollections

struct BetPlacedDetails {
    var response: BetslipPlaceBetResponse
    var tickets: [BettingTicket]
}

class BetslipManager: NSObject {

    private var bettingTicketsDictionaryPublisher: CurrentValueSubject<OrderedDictionary<String, BettingTicket>, Never>
    var bettingTicketsPublisher: CurrentValueSubject<[BettingTicket], Never>

    private var simpleBetslipSelectionState: CurrentValueSubject<BetslipSelectionState?, Never>
    private var multipleBetslipSelectionState: CurrentValueSubject<BetslipSelectionState?, Never>
    private var systemBetslipSelectionState: CurrentValueSubject<BetslipSelectionState?, Never>

    var betPlacedDetailsErrorsPublisher: CurrentValueSubject<[BetPlacedDetails], Never>

    var betslipPlaceBetResponseErrorsPublisher: CurrentValueSubject<[BetslipPlaceBetResponse], Never>

    private var cancellable: Set<AnyCancellable> = []

    private var oddsCancellableDictionary: [String: AnyCancellable] = [:]
    private var  amounts: [String: Double] = [:]
    var requests: [AnyPublisher<BetPlacedDetails, EveryMatrix.APIError>] = []
    var cancellables = Set<AnyCancellable>()
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
            .store(in: &cancellable)

        bettingTicketsDictionaryPublisher.filter(\.isEmpty).sink { _ in
            self.simpleBetslipSelectionState.send(nil)
            self.multipleBetslipSelectionState.send(nil)
        }
        .store(in: &cancellable)

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
            .store(in: &cancellable)

    }

    func addBettingTicket(_ bettingTicket: BettingTicket) {
        bettingTicketsDictionaryPublisher.value[bettingTicket.id] = bettingTicket
    }

    func removeBettingTicket(_ bettingTicket: BettingTicket) {

        bettingTicketsDictionaryPublisher.value[bettingTicket.id] = nil

        oddsCancellableDictionary[bettingTicket.id]?.cancel()
        oddsCancellableDictionary[bettingTicket.id] = nil
    }

    func removeBettingTicket(withId id: String) {

        bettingTicketsDictionaryPublisher.value[id] = nil

        oddsCancellableDictionary[id]?.cancel()
        oddsCancellableDictionary[id] = nil
    }

    func hasBettingTicket(_ bettingTicket: BettingTicket) -> Bool {
        return bettingTicketsDictionaryPublisher.value[bettingTicket.id] != nil
    }

    func hasBettingTicket(withId id: String) -> Bool {
        return bettingTicketsDictionaryPublisher.value[id] != nil
    }

    func clearAllBettingTickets() {
        self.bettingTicketsDictionaryPublisher.send([:])
    }

    func updatedBettingTicketsOdds() -> [BettingTicket] {
        var updatedTickets: [BettingTicket] = []

        for ticket in self.bettingTicketsPublisher.value {
            if let ticketOdd = Env.everyMatrixStorage.bettingOfferPublishers[ticket.id], let oddsValue = ticketOdd.value.oddsValue {
                let newTicket = BettingTicket(id: ticket.id,
                                              outcomeId: ticket.outcomeId,
                                              matchId: ticket.matchId,
                                              value: oddsValue,
                                              matchDescription: ticket.matchDescription,
                                              marketDescription: ticket.marketDescription,
                                              outcomeDescription: ticket.outcomeDescription)
                updatedTickets.append(newTicket)
            }
            else {
//#warning TODO: The ticket value is not updated
                let newTicket = BettingTicket(id: ticket.id,
                                              outcomeId: ticket.outcomeId,
                                              matchId: ticket.matchId,
                                              value: ticket.value,
                                              matchDescription: ticket.matchDescription,
                                              marketDescription: ticket.marketDescription,
                                              outcomeDescription: ticket.outcomeDescription)
                updatedTickets.append(newTicket)
            }
        }
        return updatedTickets
    }

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

        let route = TSRouter.getBetslipSelectionInfo(language: "en",
                                                     stakeAmount: 1,
                                                     betType: .single,
                                                     tickets: ticketSelections)

        TSManager.shared
            .getModel(router: route, decodingType: BetslipSelectionState.self)
            .handleEvents(receiveOutput: { betslipSelectionState in
                self.simpleBetslipSelectionState.send(betslipSelectionState)
            })
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("completed simple: \(completion)")
            } receiveValue: { betslipSelectionState in
                self.simpleBetslipSelectionState.send(betslipSelectionState)
            }
            .store(in: &cancellable)
    }

    func requestMultipleBetslipSelectionState() {

        let ticketSelections = self.updatedBettingTicketsOdds()
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })

        let route = TSRouter.getBetslipSelectionInfo(language: "en",
                                                     stakeAmount: 1,
                                                     betType: .multiple,
                                                     tickets: ticketSelections)

        TSManager.shared
            .getModel(router: route, decodingType: BetslipSelectionState.self)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("completed multi: \(completion)")
            } receiveValue: { betslipSelectionState in
                self.multipleBetslipSelectionState.send(betslipSelectionState)
            }
            .store(in: &cancellable)

    }

    func requestSystemBetslipSelectionState(withSkateAmount amount: Double, systemBetType: SystemBetType)
    -> AnyPublisher<BetslipSelectionState, EveryMatrix.APIError> {

        let ticketSelections = self.updatedBettingTicketsOdds()
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })

        let route = TSRouter.getSystemBetSelectionInfo(language: "en",
                                                       stakeAmount: amount,
                                                       systemBetType: systemBetType,
                                                       tickets: ticketSelections)

        return TSManager.shared
            .getModel(router: route, decodingType: BetslipSelectionState.self)
            .handleEvents(receiveOutput: { betslipSelectionState in
                self.simpleBetslipSelectionState.send(betslipSelectionState)
            })
            .eraseToAnyPublisher()

    }
    /////////
    func placeAllSingleBets(withSkateAmount amounts: [String: Double], completion: @escaping (Bool) -> Void){

        self.amounts = amounts
        self.requestNextBet(completionDoCiclo: completion)
    }
    
    func requestNextBet(completionDoCiclo: @escaping (Bool) -> Void){
        let ticketSelections = self.updatedBettingTicketsOdds()
            
        
        if ticketSelections.isEmpty {
            completionDoCiclo(true)
            return
        }
        
        if let lastTicket = ticketSelections.last, let lastTicketAmount = self.amounts[lastTicket.id] {
            
            placeSingleBet(betTicketId: lastTicket.id , amount: lastTicketAmount)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    print(completion)
                } receiveValue: { betPlacedDetails in
                    if let response = betPlacedDetails.response.betSucceed {
                        self.removeBettingTicket(withId: lastTicket.id)
                        self.requestNextBet(completionDoCiclo: completionDoCiclo)
                    }else{
                        completionDoCiclo(false)
                    }
                }
                .store(in: &cancellables)

        }
    }
    
    
    func placeSingleBet(betTicketId: String, amount: Double) -> AnyPublisher<BetPlacedDetails, EveryMatrix.APIError> {
        let updatedTicketSelections = self.updatedBettingTicketsOdds()
        let ticketSelections = updatedTicketSelections.filter({ bettingTicket in
            bettingTicket.id == betTicketId
        }).map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })

        let route = TSRouter.placeBet(language: "en",
                                      amount: amount,
                                      betType: .single,
                                      tickets: ticketSelections)

        return TSManager.shared
            .getModel(router: route, decodingType: BetslipPlaceBetResponse.self)
            .map({ return BetPlacedDetails.init(response: $0, tickets: updatedTicketSelections) })
            .handleEvents(receiveOutput: { betslipPlaceBetResponse in
                if betslipPlaceBetResponse.response.betSucceed ?? false {
                    self.clearAllBettingTickets()
                }
            })
            .eraseToAnyPublisher()
        
    }

    /*func placeSingleBets(withSkateAmount amounts: [String: Double]) -> [AnyPublisher<BetPlacedDetails, EveryMatrix.APIError>] {
        
        if betAmounts.count == 0 {
            for (key, value) in amounts {
                betAmounts.append(value)
            }
        }
        
        let updatedTicketSelections = self.updatedBettingTicketsOdds()
        let ticketSelections = updatedTicketSelections
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })

        var requests: [AnyPublisher<BetPlacedDetails, EveryMatrix.APIError>] = []
        
        for selection in ticketSelections {
            
            if amount = amounts[selection.id] {
                let route = TSRouter.placeBet(language: "en",
                                              amount: amount,
                                              betType: .single,
                                              tickets: [selection])

                let request = TSManager.shared
                    .getModel(router: route, decodingType: BetslipPlaceBetResponse.self)
                    .map({ return BetPlacedDetails.init(response: $0, tickets: updatedTicketSelections) })
                    .handleEvents(receiveOutput: { betslipPlaceBetResponse in
                        if betslipPlaceBetResponse.response.betSucceed ?? false,
                           let firstSelection = betslipPlaceBetResponse.response.selections?.first {
                            self.removeBettingTicket(withId: firstSelection.id)
                        }
                    })
                    .eraseToAnyPublisher()
            }
        
            guard let amount = amounts[selection.id] else { continue }

            let route = TSRouter.placeBet(language: "en",
                                          amount: amount,
                                          betType: .single,
                                          tickets: [selection])

            let request = TSManager.shared
                .getModel(router: route, decodingType: BetslipPlaceBetResponse.self)
                .map({ return BetPlacedDetails.init(response: $0, tickets: updatedTicketSelections) })
                .handleEvents(receiveOutput: { betslipPlaceBetResponse in
                    if betslipPlaceBetResponse.response.betSucceed ?? false,
                       let firstSelection = betslipPlaceBetResponse.response.selections?.first {
                        self.removeBettingTicket(withId: firstSelection.id)
                    }
                })
                .eraseToAnyPublisher()

            requests.append(request)
        }
        return requests
    }

    */
    func placeMultipleBet(withSkateAmount amount: Double) -> AnyPublisher<BetPlacedDetails, EveryMatrix.APIError> {

        let updatedTicketSelections = self.updatedBettingTicketsOdds()
        let ticketSelections = updatedTicketSelections
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })

        let route = TSRouter.placeBet(language: "en",
                                      amount: amount,
                                      betType: .multiple,
                                      tickets: ticketSelections)

        return TSManager.shared
            .getModel(router: route, decodingType: BetslipPlaceBetResponse.self)
            .map({ return BetPlacedDetails.init(response: $0, tickets: updatedTicketSelections) })
            .handleEvents(receiveOutput: { betslipPlaceBetResponse in
                if betslipPlaceBetResponse.response.betSucceed ?? false {
                    self.clearAllBettingTickets()
                }
            })
            .eraseToAnyPublisher()
    }

    func placeSystemBet(withSkateAmount amount: Double, systemBetType: SystemBetType) -> AnyPublisher<BetPlacedDetails, EveryMatrix.APIError> {

        let updatedTicketSelections = self.updatedBettingTicketsOdds()
        let ticketSelections = updatedTicketSelections
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })

        let route = TSRouter.placeSystemBet(language: "en",
                                            amount: amount,
                                            systemBetType: systemBetType,
                                            tickets: ticketSelections)

        return TSManager.shared
            .getModel(router: route, decodingType: BetslipPlaceBetResponse.self)
            .map({ return BetPlacedDetails.init(response: $0, tickets: updatedTicketSelections) })
            .handleEvents(receiveOutput: { betslipPlaceBetResponse in
                if betslipPlaceBetResponse.response.betSucceed ?? false {
                    self.clearAllBettingTickets()
                }
            })
            .eraseToAnyPublisher()
    }

}
