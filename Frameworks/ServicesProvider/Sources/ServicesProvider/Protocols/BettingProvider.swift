//
//  BettingProvider.swift
//
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

protocol BettingProvider: Connector {

    func getBetHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError>
    func getBetDetails(identifier: String) -> AnyPublisher<Bet, ServiceProviderError>

    func getOpenBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError>
    func getResolvedBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError>
    func getWonBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError>

    func getAllowedBetTypes(withBetTicketSelections betTicketSelections: [BetTicketSelection]) -> AnyPublisher<[BetType], ServiceProviderError>

    func calculatePotentialReturn(forBetTicket betTicket: BetTicket) -> AnyPublisher<BetslipPotentialReturn, ServiceProviderError>

    func placeBets(betTickets: [BetTicket], useFreebetBalance: Bool, currency: String?, username: String?, userId: String?, oddsValidationType: String?) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError>

    // BetBuilder
    func calculateBetBuilderPotentialReturn(forBetTicket betTicket: BetTicket) -> AnyPublisher<BetBuilderPotentialReturn, ServiceProviderError>
    func placeBetBuilderBet(betTicket: BetTicket, calculatedOdd: Double) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError>

    func confirmBoostedBet(identifier: String) -> AnyPublisher<Bool, ServiceProviderError>
    func rejectBoostedBet(identifier: String) -> AnyPublisher<Bool, ServiceProviderError>

    func calculateCashout(betId: String, stakeValue: String?) -> AnyPublisher<Cashout, ServiceProviderError>

    func cashoutBet(betId: String, cashoutValue: Double, stakeValue: Double?) -> AnyPublisher<CashoutResult, ServiceProviderError>
    func allowedCashoutBetIds() -> AnyPublisher<[String], ServiceProviderError>

    func calculateCashback(forBetTicket betTicket: BetTicket)  -> AnyPublisher<CashbackResult, ServiceProviderError>

    func getBetslipSettings() -> AnyPublisher<BetslipSettings?, Never>
    func updateBetslipSettings(_ betslipSettings: BetslipSettings) -> AnyPublisher<Bool, Never>

    func getFreebet() -> AnyPublisher<FreebetBalance, ServiceProviderError>

    func getSharedTicket(betslipId: String) -> AnyPublisher<SharedTicketResponse, ServiceProviderError>

    func getTicketSelection(ticketSelectionId: String) -> AnyPublisher<TicketSelection, ServiceProviderError>

    func updateTicketOdds(betId: String) -> AnyPublisher<Bet, ServiceProviderError>
    func getTicketQRCode(betId: String) -> AnyPublisher<BetQRCode, ServiceProviderError>
    func getSocialSharedTicket(shareId: String) -> AnyPublisher<Bet, ServiceProviderError>
    func deleteTicket(betId: String) -> AnyPublisher<Bool, ServiceProviderError>
    func updateTicket(betId: String, betTicket: BetTicket) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError>

}
