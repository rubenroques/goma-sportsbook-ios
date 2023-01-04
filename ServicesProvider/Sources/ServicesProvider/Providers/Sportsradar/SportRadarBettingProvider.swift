//
//  SportRadarBettingProvider.swift
//
//
//  Created by Ruben Roques on 16/11/2022.
//

import Foundation
import Combine

class SportRadarBettingProvider: BettingProvider {

    var sessionCoordinator: SportRadarSessionCoordinator

    private var connector: BettingConnector
    private var cancellables: Set<AnyCancellable> = []

    init(sessionCoordinator: SportRadarSessionCoordinator, connector: BettingConnector = BettingConnector()) {
        self.sessionCoordinator = sessionCoordinator
        self.connector = connector

        self.sessionCoordinator.token(forKey: .launchToken)
            .sink { [weak self] launchToken in
                if let launchTokenValue = launchToken  {
                    self?.connector.saveSessionKey(launchTokenValue)
                }
                else {
                    self?.connector.clearSessionKey()
                }
            }
            .store(in: &cancellables)
    }

    func getBetHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let endpoint = BettingAPIClient.betHistory(page: pageIndex, startDate: nil, endDate: nil, betState: nil, betResult: nil)
        let publisher: AnyPublisher<[SportRadarModels.Bet], ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { bets in
                return SportRadarModels.BettingHistory(bets: bets)
            }
            .map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory:)).eraseToAnyPublisher()
    }

    func getOpenBetsHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let endpoint = BettingAPIClient.betHistory(page: pageIndex, startDate: nil, endDate: nil, betState: [SportRadarModels.BetState.opened], betResult: nil)
        let publisher: AnyPublisher<[SportRadarModels.Bet], ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { bets in
                return SportRadarModels.BettingHistory(bets: bets)
            }
            .map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory:)).eraseToAnyPublisher()
    }

    func getResolvedBetsHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let endpoint = BettingAPIClient.betHistory(page: pageIndex, startDate: nil, endDate: nil, betState: [SportRadarModels.BetState.settled], betResult: nil)
        let publisher: AnyPublisher<[SportRadarModels.Bet], ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { bets in
                return SportRadarModels.BettingHistory(bets: bets)
            }
            .map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory:)).eraseToAnyPublisher()
    }

    func getWonBetsHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let endpoint = BettingAPIClient.betHistory(page: pageIndex, startDate: nil, endDate: nil, betState: nil, betResult: [SportRadarModels.BetResult.won])
        let publisher: AnyPublisher<[SportRadarModels.Bet], ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { bets in
                return SportRadarModels.BettingHistory(bets: bets)
            }
            .map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory:)).eraseToAnyPublisher()
    }

    func getAllowedBetTypes(withBetTicketSelections betTicketSelections: [BetTicketSelection]) -> AnyPublisher<[BetType], ServiceProviderError> {
        let endpoint = BettingAPIClient.getAllowedBetTypes(betTicketSelections: betTicketSelections)
        let publisher: AnyPublisher<[SportRadarModels.BetType], ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { (sportRadarBetTypes: [SportRadarModels.BetType]) -> [BetType] in
                return sportRadarBetTypes.map(SportRadarModelMapper.betType(fromInternalBetType:))
            }
            .eraseToAnyPublisher()
    }

    func calculatePotentialReturn(forBetslipState betslipState: BetslipState)  -> AnyPublisher<BetslipPotentialReturn, ServiceProviderError> {
        let endpoint = BettingAPIClient.calculateReturns(betslipState: betslipState)
        let publisher: AnyPublisher<SportRadarModels.BetslipPotentialReturnResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { (betslipPotentialReturn: SportRadarModels.BetslipPotentialReturnResponse) -> BetslipPotentialReturn in
                return BetslipPotentialReturn(potentialReturn: betslipPotentialReturn.potentialReturn,
                                              totalStake: betslipPotentialReturn.totalStake,
                                              numberOfBets: betslipPotentialReturn.numberOfBets,
                                              betType: betslipState.betType)
            }
            .eraseToAnyPublisher()
    }

    func placeSingleBet(betTicketSelection: BetTicketSelection) -> AnyPublisher<PlacedBetResponse, ServiceProviderError> {
        let endpoint = BettingAPIClient.placeBet(betTicketSelection: betTicketSelection)
        let publisher: AnyPublisher<SportRadarModels.PlacedBetResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map({ SportRadarModelMapper.placedBetResponse(fromInternalPlacedBetResponse: $0) })
            .eraseToAnyPublisher()
    }

}

