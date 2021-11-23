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

    private var cancellable: Set<AnyCancellable> = []

    private var oddsCancellableDictionary: [String: AnyCancellable] = [:]

    override init() {

        self.bettingTicketsDictionaryPublisher = .init([:])
        self.bettingTicketsPublisher = .init([])
        self.simpleBetslipSelectionState = .init(nil)
        self.multipleBetslipSelectionState = .init(nil)
        self.systemBetslipSelectionState = .init(nil)

        super.init()

        bettingTicketsDictionaryPublisher
            .map({ dictionary -> [BettingTicket] in
                return Array.init(dictionary.values)
            })
            .sink { [weak self] tickets in
                self?.bettingTicketsPublisher.send(tickets)
            }
            .store(in: &cancellable)

        bettingTicketsDictionaryPublisher.filter(\.isEmpty).sink { dictionary in
            self.simpleBetslipSelectionState.send(nil)
            self.multipleBetslipSelectionState.send(nil)
        }
        .store(in: &cancellable)

        bettingTicketsDictionaryPublisher
            .filter({ return !$0.isEmpty })
            .removeDuplicates()
            .debounce(for: 1.0, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
            .map({ tickets -> Void in
                return ()
            })
            .sink { [weak self] in
                self?.requestSimpleBetslipSelectionState()
                self?.requestMultipleBetslipSelectionState()
            }
            .store(in: &cancellable)

    }

    func addBettingTicket(_ bettingTicket: BettingTicket) {
//        var currentValue = self.bettingTicketsPublisher.value
//        currentValue.append(bettingTicket)
//        bettingTicketsPublisher.send(currentValue)

        bettingTicketsDictionaryPublisher.value[bettingTicket.id] = bettingTicket

    }

    func removeBettingTicket(_ bettingTicket: BettingTicket) {

        bettingTicketsDictionaryPublisher.value[bettingTicket.id] = nil

        oddsCancellableDictionary[bettingTicket.id]?.cancel()
        oddsCancellableDictionary[bettingTicket.id] = nil
//        var currentValue = self.bettingTicketsPublisher.value
//        currentValue.remove(bettingTicket)
//        bettingTicketsPublisher.send(currentValue)
    }

    func removeBettingTicket(withId id: String) {

        bettingTicketsDictionaryPublisher.value[id] = nil

        oddsCancellableDictionary[id]?.cancel()
        oddsCancellableDictionary[id] = nil
//        var orderedSet: OrderedSet<BettingTicket> = []
//        for ticket in self.bettingTicketsPublisher.value {
//            if ticket.id == id {
//                continue
//            }
//            orderedSet.append(ticket)
//        }
//        bettingTicketsPublisher.send(orderedSet)
    }

    func hasBettingTicket(_ bettingTicket: BettingTicket) -> Bool {
        return bettingTicketsDictionaryPublisher.value[bettingTicket.id] != nil
    }

    func hasBettingTicket(withId id: String) -> Bool {
        return bettingTicketsDictionaryPublisher.value[id] != nil
//        var hasValue = false
//        for ticket in self.bettingTicketsPublisher.value {
//            if ticket.id == id {
//                hasValue = true
//                break
//            }
//        }
//        return hasValue
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
        }
        return updatedTickets
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

    func placeSingleBets(withSkateAmount amounts: [String: Double]) -> [AnyPublisher<BetPlacedDetails, EveryMatrix.APIError>] {

        let updatedTicketSelections = self.updatedBettingTicketsOdds()
        let ticketSelections = updatedTicketSelections
            .map({ EveryMatrix.BetslipTicketSelection(id: $0.id, currentOdd: $0.value) })

        var requests: [AnyPublisher<BetPlacedDetails, EveryMatrix.APIError>] = []
        for selection in ticketSelections {

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
