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
            .map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory:))
            .eraseToAnyPublisher()
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

    func calculatePotentialReturn(forBetTicket betTicket: BetTicket)  -> AnyPublisher<BetslipPotentialReturn, ServiceProviderError> {
        let endpoint = BettingAPIClient.calculateReturns(betTicket: betTicket)
        let publisher: AnyPublisher<SportRadarModels.BetslipPotentialReturnResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map { (betslipPotentialReturn: SportRadarModels.BetslipPotentialReturnResponse) -> BetslipPotentialReturn in
                return BetslipPotentialReturn(potentialReturn: betslipPotentialReturn.potentialReturn,
                                              totalStake: betslipPotentialReturn.totalStake,
                                              numberOfBets: betslipPotentialReturn.numberOfBets)
            }
            .eraseToAnyPublisher()
    }

    func placeBets(betTickets: [BetTicket]) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        let endpoint = BettingAPIClient.placeBets(betTickets: betTickets)
        let publisher: AnyPublisher<SportRadarModels.PlacedBetsResponse, ServiceProviderError> = self.connector.request(endpoint)
        return publisher
            .map({ SportRadarModelMapper.placedBetsResponse(fromInternalPlacedBetsResponse: $0) })
            .eraseToAnyPublisher()
    }

    func getBetDetails(identifier: String) -> AnyPublisher<Bet, ServiceProviderError> {
//        let endpoint = BettingAPIClient.betDetails(identifier: identifier)
//        let publisher: AnyPublisher<SportRadarModels.Bet, ServiceProviderError> = self.connector.request(endpoint)
//        return publisher.map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory: <#T##SportRadarModels.BettingHistory#>)

        return Fail(error: ServiceProviderError.bettingProviderNotFound).eraseToAnyPublisher()
    }

}

