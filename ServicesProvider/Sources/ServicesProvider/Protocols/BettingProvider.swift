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
    func getBetDetails(identifier: String) -> AnyPublisher<Bet, ServiceProviderError>

    func getOpenBetsHistory(pageIndex: Int, pageSize: Int) -> AnyPublisher<BettingHistory, ServiceProviderError>
    func getResolvedBetsHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError>
    func getWonBetsHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError>

    func getAllowedBetTypes(withBetTicketSelections betTicketSelections: [BetTicketSelection]) -> AnyPublisher<[BetType], ServiceProviderError>
    
    func calculatePotentialReturn(forBetTicket betTicket: BetTicket) -> AnyPublisher<BetslipPotentialReturn, ServiceProviderError>

    func placeBets(betTickets: [BetTicket]) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError>

}
