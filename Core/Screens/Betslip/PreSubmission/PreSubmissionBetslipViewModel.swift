//
//  PreSubmissionBetslipViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 10/03/2022.
//

import Foundation
import Combine

class PreSubmissionBetslipViewModel {

    // MARK: Public Properties
    var bonusBetslipArrayPublisher: CurrentValueSubject<[BonusBetslip], Never> = .init([])
    var sharedBetsPublisher: CurrentValueSubject<LoadableContent<[BettingTicket]>, Never> = .init(LoadableContent.idle)
    var isPartialBetSelection: CurrentValueSubject<Bool, Never> = .init(false)
    var isUnavailableBetSelection: CurrentValueSubject<Bool, Never> = .init(false)

    // MARK: Private Properties
    private var sharedBetToken: String?
    private var sharedBetsRegisters: [EndpointPublisherIdentifiable] = []

    private var cancellables = Set<AnyCancellable>()

    init(sharedBetToken: String? = nil) {

        self.sharedBetToken = sharedBetToken

        Env.userSessionStore.userSessionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .logged {
                    if let sharedBetTokenValue = self?.sharedBetToken {
                        self?.sharedBetsPublisher.send(.loading)
                        self?.getBetslipTicketData(betToken: sharedBetTokenValue)
                    }
                    self?.getGrantedBonus()
                }
            }
            .store(in: &cancellables)

    }

    deinit {
        print("PreSubmissionBetslipViewModel Called")
    }

    private func getGrantedBonus() {

        Env.everyMatrixClient.getGrantedBonus()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] bonusResponse in
                if let bonuses = bonusResponse.bonuses {
                    self?.processGrantedBonus(bonuses: bonuses)
                }
            })
            .store(in: &cancellables)
    }

    private func processGrantedBonus(bonuses: [EveryMatrix.GrantedBonus]) {

        var bonusArray: [BonusBetslip] = []

        for bonus in bonuses {
            if bonus.status == "active" {
                var bonusType: GrantedBonusType?

                if let bonusTypeString = bonus.type {
                    if bonusTypeString == GrantedBonusType.freeBet.identifier {
                        bonusType = GrantedBonusType.freeBet
                    }
                    else if bonusTypeString == GrantedBonusType.oddsBoost.identifier {
                        bonusType = GrantedBonusType.oddsBoost
                    }
                    else {
                        bonusType = GrantedBonusType.standard
                    }
                }
                let bonusBetslip = BonusBetslip(bonus: bonus, bonusType: bonusType ?? .standard)
                bonusArray.append(bonusBetslip)
            }
        }

        self.bonusBetslipArrayPublisher.value = bonusArray
    }

    // Bet shares related functions
    func getBetslipTicketData(betToken: String) {

        let betDataRoute = TSRouter.getSharedBetData(betToken: betToken)
        Env.everyMatrixClient.manager.getModel(router: betDataRoute, decodingType: SharedBetDataResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("SHARED BET DATA ERROR: \(error)")
                    switch error {

                    case .decodingError(value: let value):
                        self?.isUnavailableBetSelection.send(true)
                    case .httpError(_):
                        ()
                    case .unknown:
                        self?.isUnavailableBetSelection.send(true)
                    case .missingTransportSessionID:
                        ()
                    case .notConnected:
                        ()
                    case .noResultsReceived:
                        self?.isUnavailableBetSelection.send(true)
                    case .requestError(value: let value):
                        self?.isUnavailableBetSelection.send(true)
                    }

                    self?.sharedBetsPublisher.send(.failed)
                case .finished:
                    print("SHARED BET DATA FINISHED")
                }
            },
            receiveValue: { [weak self] betDataResponse in
                self?.addBetDataTickets(betData: betDataResponse.sharedBetData)
            })
            .store(in: &cancellables)
    }

    private func addBetDataTickets(betData: SharedBetData) {

        let requests = betData.selections.map(getBetMarketOddsRPC)

        var bettingTickets: [BettingTicket?] = []

        Publishers.MergeMany(requests)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                let validTickets = bettingTickets.compactMap({ $0 })

                for ticket in validTickets {
                    Env.betslipManager.addBettingTicket(ticket)
                }

                if validTickets.count != betData.selections.count && validTickets.isNotEmpty {
                    self?.isPartialBetSelection.send(true)
                }

                if validTickets.isEmpty {
                    self?.isUnavailableBetSelection.send(true)
                }
                else {
                    self?.isUnavailableBetSelection.send(false)
                }

                self?.sharedBetsPublisher.send(.loaded(validTickets))
                self?.sharedBetsPublisher.send(.idle)
            } receiveValue: { ticket in
                bettingTickets.append(ticket)
            }
            .store(in: &cancellables)

    }

    private func getBetMarketOddsRPC(betSelection: SharedBet) -> AnyPublisher<BettingTicket?, EveryMatrix.APIError> {

        let endpoint = TSRouter.matchMarketOdds(operatorId: Env.appSession.operatorId,
                                                language: "en",
                                                matchId: "\(betSelection.eventId)",
                                                bettingType: "\(betSelection.bettingTypeId)",
                                                eventPartId: "\(betSelection.bettingTypeEventPartId)")

        return Env.everyMatrixClient.manager
            .registerOnEndpointAsRPC(endpoint, decodingType: EveryMatrix.Aggregator.self)
            .map { [weak self] aggregator in
                return self?.processAggregator(aggregator: aggregator, betSelection: betSelection)
            }
            .eraseToAnyPublisher()

    }

    private func processAggregator(aggregator: EveryMatrix.Aggregator, betSelection: SharedBet) -> BettingTicket? {

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

        if let bettingOfferId = betSelectionBettingOfferId {
                let marketDescription = "\(betSelection.marketName), \(betSelection.bettingTypeEventPartName)"
                let bettingTicket = BettingTicket(id: bettingOfferId,
                                                  outcomeId: betSelection.outcomeId,
                                                  marketId: markets.first?.id ?? "1",
                                                  matchId: betSelection.eventId,
                                                  decimalOdd: betSelection.priceValue,
                                                  isAvailable: markets.first?.isAvailable ?? true,
                                                  matchDescription: betSelection.eventName,
                                                  marketDescription: marketDescription,
                                                  outcomeDescription: betSelection.betName)
            return bettingTicket
        }

        return nil
    }

}

struct BonusBetslip {
    let bonus: EveryMatrix.GrantedBonus
    let bonusType: GrantedBonusType
}
