//
//  PreSubmissionBetslipViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 10/03/2022.
//

import Foundation
import Combine
import ServicesProvider

class PreSubmissionBetslipViewModel {

    // MARK: Public Properties
    var bonusBetslipArrayPublisher: CurrentValueSubject<[BonusBetslip], Never> = .init([])
    var sharedBetsPublisher: CurrentValueSubject<LoadableContent<[BettingTicket]>, Never> = .init(LoadableContent.idle)
    var isPartialBetSelection: CurrentValueSubject<Bool, Never> = .init(false)
    var isUnavailableBetSelection: CurrentValueSubject<Bool, Never> = .init(false)

    var expectedTicketSelections: Int = 0
    var sharedBettingTicketsIdsRetrieved: CurrentValueSubject<[String], Never> = .init([])
    var unavailableBettingTicketsRetrieved: CurrentValueSubject<[String], Never> = .init([])

    var sharedBettingTicket: [BettingTicket] = []

    var getSharedRetries: Int = 5

    // MARK: Private Properties
    private var sharedBetToken: String?

    private var cancellables = Set<AnyCancellable>()

    private let dateFormatter = DateFormatter()

    init(sharedBetToken: String? = nil) {

        self.sharedBetToken = sharedBetToken

        // TODO: Get shared bets here
        if let sharedBetToken {

            Env.servicesProvider.bettingConnectionStatePublisher
                .filter({ $0 == .connected })
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { [weak self] _ in
                    self?.expectedTicketSelections = 0
                    self?.sharedBettingTicket = []
                    self?.sharedBettingTicketsIdsRetrieved.value = []
                    self?.getSharedTicket(betId: sharedBetToken)

                })
                .store(in: &cancellables)

//            self.expectedTicketSelections = 0
//            self.sharedBettingTicket = []
//            self.sharedBettingTicketsIdsRetrieved.value = []
//            self.getSharedTicket(betId: sharedBetToken)

        }

        self.sharedBettingTicketsIdsRetrieved
            .sink(receiveValue: { [weak self] sharedBettingTicketsIds in

                guard let self = self else { return }

                if sharedBettingTicketsIds.count == self.expectedTicketSelections && self.expectedTicketSelections > 0 {

                    if self.unavailableBettingTicketsRetrieved.value.isNotEmpty && self.unavailableBettingTicketsRetrieved.value.count == sharedBettingTicketsIds.count {
                        self.isUnavailableBetSelection.send(true)
                    }
                    else if self.unavailableBettingTicketsRetrieved.value.isNotEmpty && self.unavailableBettingTicketsRetrieved.value.count != sharedBettingTicketsIds.count {
                        self.isPartialBetSelection.send(true)
                    }

                    let sharedBettingTicket = self.sharedBettingTicket

                    self.sharedBetsPublisher.send(.loaded(sharedBettingTicket))
                }
            })
            .store(in: &cancellables)
    }

    private func getSharedTicket(betId: String) {

        self.sharedBetsPublisher.send(.loading)

        Env.servicesProvider.getSharedTicket(betslipId: betId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("SHARED TICKET ERROR: \(error)")
                    if self?.getSharedRetries == 0 {
                        self?.sharedBetsPublisher.send(.failed)
                    }
                    else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self?.getSharedRetries -= 1
                            self?.getSharedTicket(betId: betId)
                        }
                    }

                }

            }, receiveValue: { [weak self] sharedTicketResponse in

                print("SHARED TICKET RESPONSE: \(sharedTicketResponse)")

                if let sharedBet = sharedTicketResponse.bets.first {
                    self?.expectedTicketSelections = sharedBet.betSelections.count

                    self?.getTicketSelections(sharedBet: sharedBet)

                }

            })
            .store(in: &cancellables)

    }

    private func getTicketSelections(sharedBet: ServicesProvider.SharedBet) {

        for betSelection in sharedBet.betSelections {

            Env.servicesProvider.getTicketSelection(ticketSelectionId: "\(betSelection.id)")
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("SHARED TICKET SELECTION ERROR: \(error)")

                        self?.unavailableBettingTicketsRetrieved.value.append("\(betSelection.id)")

                        self?.sharedBettingTicketsIdsRetrieved.value.append("\(betSelection.id)")
                    }

                }, receiveValue: { [weak self] ticketSelection in

                    print("SHARED TICKET SELECTION RESPONSE: \(ticketSelection)")

                    self?.getMarketInfo(ticketSelection: ticketSelection)

                })
                .store(in: &cancellables)
        }

    }

    func getMarketInfo(ticketSelection: TicketSelection) {

        Env.servicesProvider.getMarketInfo(marketId: ticketSelection.marketId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("MARKET ERROR: \(error)")

                    self?.unavailableBettingTicketsRetrieved.value.append(ticketSelection.id)

                    self?.sharedBettingTicketsIdsRetrieved.value.append(ticketSelection.id)

                }
            }, receiveValue: { [weak self] market in

                let internalMarket = ServiceProviderModelMapper.market(fromServiceProviderMarket: market)

                if let outcome = market.outcomes.filter({
                    $0.id == ticketSelection.id
                }).first {
                    let mappedOutcome = ServiceProviderModelMapper.outcome(fromServiceProviderOutcome: outcome)

                    self?.addBettingTicket(market: internalMarket, outcome: mappedOutcome)

                }

            })
            .store(in: &cancellables)

    }

    private func addBettingTicket(market: Market, outcome: Outcome) {

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
        let matchDate = dateFormatter.date(from: market.startDate ?? "")

        let match = Match(id: market.eventId ?? "",
                          competitionId: "",
                          competitionName: "",
                          homeParticipant: Participant(id: "", name: market.homeParticipant ?? ""),
                          awayParticipant: Participant(id: "", name: market.awayParticipant ?? ""),
                          date: matchDate,
                          sport: Sport(id: "1", name: "", alphaId: "", numericId: "", showEventCategory: false, liveEventsCount: 0, eventsCount: 0),
                          numberTotalOfMarkets: 1,
                          markets: [market],
                          rootPartId: "",
                          status: .unknown)

        let bettingTicket = BettingTicket(match: match, market: market, outcome: outcome)

        self.sharedBettingTicket.append(bettingTicket)
        self.sharedBettingTicketsIdsRetrieved.value.append(outcome.id)

        if !Env.betslipManager.hasBettingTicket(bettingTicket) {
            Env.betslipManager.addBettingTicket(bettingTicket)
        }

    }

}

struct BonusBetslip {
    let bonus: EveryMatrix.GrantedBonus
    let bonusType: GrantedBonusType
}
