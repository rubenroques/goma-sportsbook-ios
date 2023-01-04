//
//  BettingProvider.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

protocol BettingProvider {

    func getBetHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError>
    func getOpenBetsHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError>
    func getResolvedBetsHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError>
    func getWonBetsHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError>

    func getAllowedBetTypes(withBetTicketSelections betTicketSelections: [BetTicketSelection]) -> AnyPublisher<[BetType], ServiceProviderError>
    
    func calculatePotentialReturn(forBetslipState betslipState: BetslipState)  -> AnyPublisher<BetslipPotentialReturn, ServiceProviderError>
    
    func placeSingleBet(betTicketSelection: BetTicketSelection) -> AnyPublisher<PlacedBetResponse, ServiceProviderError>
}
