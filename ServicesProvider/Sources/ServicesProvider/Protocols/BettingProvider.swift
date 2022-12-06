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
    
    func calculateBetslipState(_ betslip: BetSlip)  -> AnyPublisher<BetslipState, ServiceProviderError>
}
