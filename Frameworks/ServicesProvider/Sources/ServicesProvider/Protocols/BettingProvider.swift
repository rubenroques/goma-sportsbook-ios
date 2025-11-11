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
    func getCashedOutBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError>

    func getAllowedBetTypes(withBetTicketSelections betTicketSelections: [BetTicketSelection]) -> AnyPublisher<[BetType], ServiceProviderError>

    func calculatePotentialReturn(forBetTicket betTicket: BetTicket) -> AnyPublisher<BetslipPotentialReturn, ServiceProviderError>

    /// Validates bet selections and returns unified betting options including:
    /// - Min/max stake constraints
    /// - Total odds calculation
    /// - Available bonuses (free bets, odds boosts, stake backs)
    /// - Tax information
    ///
    /// - Parameters:
    ///   - betType: Type of bet (single, multiple, or system)
    ///   - selections: Array of bet selections to validate
    ///   - stakeAmount: Optional stake amount for calculating potential winnings
    /// - Returns: Publisher emitting unified betting options or error, including betbuilder validity state
    func calculateUnifiedBettingOptions(
        betType: BetGroupingType,
        selections: [BettingOptionsCalculateSelection],
        stakeAmount: Double?
    ) -> AnyPublisher<UnifiedBettingOptions, ServiceProviderError>

    func placeBets(betTickets: [BetTicket], useFreebetBalance: Bool, currency: String?, username: String?, userId: String?, oddsValidationType: String?, ubsWalletId: String?, betBuilderOdds: Double?) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError>

    // BetBuilder
    func calculateBetBuilderPotentialReturn(forBetTicket betTicket: BetTicket) -> AnyPublisher<BetBuilderPotentialReturn, ServiceProviderError>
    func placeBetBuilderBet(betTicket: BetTicket, calculatedOdd: Double) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError>

    func confirmBoostedBet(identifier: String) -> AnyPublisher<Bool, ServiceProviderError>
    func rejectBoostedBet(identifier: String) -> AnyPublisher<Bool, ServiceProviderError>

    // OLD Cashout API (legacy)
    func calculateCashout(betId: String, stakeValue: String?) -> AnyPublisher<Cashout, ServiceProviderError>
    func cashoutBet(betId: String, cashoutValue: Double, stakeValue: Double?) -> AnyPublisher<CashoutResult, ServiceProviderError>
    func allowedCashoutBetIds() -> AnyPublisher<[String], ServiceProviderError>
    func calculateCashback(forBetTicket betTicket: BetTicket)  -> AnyPublisher<CashbackResult, ServiceProviderError>
    
    // NEW Cashout API (SSE-based real-time streaming)

    /// Subscribe to real-time cashout value updates via Server-Sent Events
    ///
    /// This method streams cashout value updates in real-time. The stream emits multiple messages:
    /// 1. `.connect` - Connection established
    /// 2. `.contentUpdate` - Cashout value with code 103 (loading) - should be ignored
    /// 3. `.contentUpdate` - Cashout value with code 100 (success) - use this value
    /// 4. `.disconnect` - Connection closed
    ///
    /// - Parameter betId: Bet identifier to get cashout value for
    /// - Returns: Publisher emitting real-time cashout value updates
    func subscribeToCashoutValue(betId: String) -> AnyPublisher<SubscribableContent<CashoutValue>, ServiceProviderError>

    /// Execute cashout (full or partial)
    ///
    /// - Parameter request: Cashout execution request
    /// - Returns: Publisher emitting cashout result
    func executeCashout(request: CashoutRequest) -> AnyPublisher<CashoutResponse, ServiceProviderError>


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
