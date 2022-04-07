//
//  UrlSchemaManager.swift
//  Sportsbook
//
//  Created by André Lascas on 03/02/2022.
//

import Foundation
import Combine

class URLSchemaManager {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var sharedBetsRegisters: [EndpointPublisherIdentifiable] = []
    private var isSharedBet: Bool = false

    // MARK: Public Properties
    var redirectPublisher: CurrentValueSubject<[String: String], Never>

    var ticketPublisher: AnyCancellable?
    var shouldShowBetslipPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    // MARK: Lifetime and Cycle
    init() {
        self.redirectPublisher = .init([:])
    }

    // MARK: General functions
    func setRedirect(subject: [String: String]) {
        self.redirectPublisher.value = subject
    }

    // Bet shares related functions
    func getBetslipTicketData(betToken: String) {
        self.isSharedBet = true

        let betDataRoute = TSRouter.getSharedBetData(betToken: betToken)

        Env.everyMatrixClient.manager.getModel(router: betDataRoute, decodingType: SharedBetDataResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let apiError):
                    switch apiError {
                    case .requestError(let value):
                        print("Bet token request error: \(value)")
                    case .notConnected:
                        ()
                    default:
                        ()
                    }
                case .finished:
                    ()
                }
            },
                  receiveValue: { [weak self] betDataResponse in
                self?.addBetDataTickets(betData: betDataResponse.sharedBetData)

            })
            .store(in: &cancellables)
    }

    private func addBetDataTickets(betData: SharedBetData) {
        self.ticketPublisher = nil

        self.ticketPublisher = Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] tickets in
                if tickets.count == betData.selections.count && self?.isSharedBet == true {
                    self?.isSharedBet = false
                    self?.unregisterSharedBets()
                    self?.shouldShowBetslipPublisher.send(true)
                }
            })

        for betSelection in betData.selections {
            self.getBetMarketOdds(betSelection: betSelection)
        }

    }

    private func getBetMarketOdds(betSelection: SharedBet) {
        let endpoint = TSRouter.matchMarketOdds(operatorId: Env.appSession.operatorId,
                                                language: "en",
                                                matchId: "\(betSelection.eventId)",
                                                bettingType: "\(betSelection.bettingTypeId)",
                                                eventPartId: "\(betSelection.bettingTypeEventPartId)")

        Env.everyMatrixClient.manager
            .registerOnEndpoint(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] state in
                switch state {
                case .connect(let publisherIdentifiable):
                    print(publisherIdentifiable)
                    self?.sharedBetsRegisters.append(publisherIdentifiable)
                case .initialContent(let aggregator):
                    print(aggregator)
                    self?.processBetAggregator(aggregator: aggregator, betSelection: betSelection)
                case .updatedContent:
                    ()
                case .disconnect:
                    ()
                }
            })
            .store(in: &cancellables)
    }

    private func processBetAggregator(aggregator: EveryMatrix.Aggregator, betSelection: SharedBet) {

        var markets: [EveryMatrix.Market] = []
        var betOutcomes: [EveryMatrix.BetOutcome] = []
        var marketOutcomeRelations: [EveryMatrix.MarketOutcomeRelation] = []
        var bettingOffers: [EveryMatrix.BettingOffer] = []

        var betSelectionBettingOfferId: String?

        for content in aggregator.content ?? [] {
            switch content {
            case .tournament:
                ()
            case .match:
                ()
            case .matchInfo:
                ()
            case .market(let marketContent):

                markets.append(marketContent)

            case .betOutcome(let betOutcomeContent):
                betOutcomes.append(betOutcomeContent)

            case .bettingOffer(let bettingOfferContent):
                bettingOffers.append(bettingOfferContent)
                if bettingOfferContent.outcomeId == betSelection.outcomeId {
                    betSelectionBettingOfferId = bettingOfferContent.id
                }

            case .mainMarket:
                ()

            case .marketOutcomeRelation(let marketOutcomeRelationContent):
                marketOutcomeRelations.append(marketOutcomeRelationContent)
            case .marketGroup:
                ()
            case .location:
               ()
            case .cashout:
               ()
            case .event:
                ()
            case .eventPartScore:
                ()
            case .unknown:
                ()
            }
        }

        // Add to tickets
        if let bettingOfferId = betSelectionBettingOfferId {

            if Env.betslipManager.hasBettingTicket(withId: bettingOfferId){
                Env.betslipManager.removeBettingTicket(withId: bettingOfferId)
            }
            else {
                let marketDescription = "\(betSelection.marketName), \(betSelection.bettingTypeEventPartName)"
                let bettingTicket = BettingTicket(id: bettingOfferId,
                                                  outcomeId: betSelection.outcomeId,
                                                  marketId: markets.first?.id ?? "1",
                                                  matchId: betSelection.eventId,
                                                  value: betSelection.priceValue,
                                                  isAvailable: markets.first?.isAvailable ?? true,
                                                  statusId: "1",
                                                  matchDescription: betSelection.eventName,
                                                  marketDescription: marketDescription,
                                                  outcomeDescription: betSelection.betName)
                
                Env.betslipManager.addBettingTicket(bettingTicket)
            }
        }

    }

    private func unregisterSharedBets() {
        for sharedBetRegister in self.sharedBetsRegisters {
            Env.everyMatrixClient.manager.unregisterFromEndpoint(endpointPublisherIdentifiable: sharedBetRegister)
        }
    }

}
