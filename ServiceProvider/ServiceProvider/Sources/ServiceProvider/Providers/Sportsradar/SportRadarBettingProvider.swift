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
        let endpoint = BettingAPIClient.betHistory(page: pageIndex, startDate: nil, endDate: nil, betState: nil, betOutcome: nil)
        let publisher: AnyPublisher<SportRadarModels.BettingHistory, ServiceProviderError> = self.connector.request(endpoint)
        return publisher.map(SportRadarModelMapper.bettingHistory(fromInternalBettingHistory:)).eraseToAnyPublisher()
    }

    func calculateBetslipState(_ betslip: BetSlip)  -> AnyPublisher<BetslipState, ServiceProviderError> {
       
        guard
            let firstBetTicket = betslip.tickets.first
        else {
            return Fail(outputType: BetslipState.self, failure: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
        }
        
        let betTicket = SportRadarModelMapper.internalBetTicket(fromBetTicket: firstBetTicket)
        let endpoint = BettingAPIClient.calculateReturns(betTicket: betTicket)
        let publisher: AnyPublisher<SportRadarModels.BetSlipStateResponse, ServiceProviderError> = self.connector.request(endpoint)

        return Fail(outputType: BetslipState.self, failure: ServiceProviderError.privilegedAccessManagerNotFound).eraseToAnyPublisher()
    }

}
