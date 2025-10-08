//
//  EveryMatrixBettingProvider.swift
//  ServicesProvider
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import Combine

class EveryMatrixBettingProvider: BettingProvider, Connector {

    var sessionCoordinator: EveryMatrixSessionCoordinator
    private var connector: EveryMatrixOddsMatrixAPIConnector
    private var cancellables: Set<AnyCancellable> = []

    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        return self.connectionStateSubject.eraseToAnyPublisher()
    }
    private var connectionStateSubject: CurrentValueSubject<ConnectorState, Never> = .init(.connected)

    init(sessionCoordinator: EveryMatrixSessionCoordinator, connector: EveryMatrixOddsMatrixAPIConnector? = nil) {
        self.sessionCoordinator = sessionCoordinator
        
        // Create connector with session coordinator if not provided
        if let providedConnector = connector {
            self.connector = providedConnector
        } else {
            self.connector = EveryMatrixOddsMatrixAPIConnector(sessionCoordinator: sessionCoordinator)
        }
        
        // Update connection state
        self.connectionStateSubject.send(.connected)
        
        // Subscribe to session token changes
        self.sessionCoordinator.token(forKey: .playerSessionToken)
            .sink { [weak self] launchToken in
                if let launchTokenValue = launchToken  {
                    self?.connector.saveSessionToken(launchTokenValue)
                }
                else {
                    self?.connector.clearSessionToken()
                }
            }
            .store(in: &cancellables)
        
        // Subscribe to user ID changes
        self.sessionCoordinator.userId()
            .sink { [weak self] userId in
                if let userIdValue = userId {
                    self?.connector.saveUserId(userIdValue)
                } else {
                    self?.connector.clearUserId()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - BettingProvider Protocol Methods
    
    func getBetHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getBetDetails(identifier: String) -> AnyPublisher<Bet, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getOpenBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        // Convert page index to limit (assuming 20 items per page)
        let limit = 20
        let placedBefore = endDate ?? defaultPlacedBeforeDate()
        
        print("🔍 EveryMatrixBettingProvider: getOpenBetsHistory called with pageIndex=\(pageIndex), limit=\(limit), placedBefore=\(placedBefore)")
        
        let endpoint = EveryMatrixOddsMatrixAPI.getOpenBets(limit: limit, placedBefore: placedBefore)
        
        return connector.request(endpoint)
            .map { (bets: [EveryMatrix.Bet]) -> BettingHistory in
                print("🔄 EveryMatrixBettingProvider: Mapping \(bets.count) EveryMatrix bets to internal format")
                let bettingHistory = EveryMatrixModelMapper.bettingHistory(fromBets: bets)
                print("✅ EveryMatrixBettingProvider: Successfully mapped to \(bettingHistory.bets.count) internal bets")
                return bettingHistory
            }
            .mapError { error in
                print("❌ EveryMatrixBettingProvider: Converting error to ServiceProviderError: \(error)")
                return ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    func getResolvedBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let limit = 20
        let placedBefore = endDate ?? defaultPlacedBeforeDate()
        
        let endpoint = EveryMatrixOddsMatrixAPI.getSettledBets(limit: limit, placedBefore: placedBefore, betStatus: nil)
        
        return connector.request(endpoint)
            .map { (bets: [EveryMatrix.Bet]) -> BettingHistory in
                return EveryMatrixModelMapper.bettingHistory(fromBets: bets)
            }
            .mapError { error in
                ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    func getWonBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        let limit = 20
        let placedBefore = endDate ?? defaultPlacedBeforeDate()
        
        let endpoint = EveryMatrixOddsMatrixAPI.getSettledBets(limit: limit, placedBefore: placedBefore, betStatus: "WON")
        
        return connector.request(endpoint)
            .map { (bets: [EveryMatrix.Bet]) -> BettingHistory in
                return EveryMatrixModelMapper.bettingHistory(fromBets: bets)
            }
            .mapError { error in
                ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    func getAllowedBetTypes(withBetTicketSelections betTicketSelections: [BetTicketSelection]) -> AnyPublisher<[BetType], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func calculatePotentialReturn(forBetTicket betTicket: BetTicket) -> AnyPublisher<BetslipPotentialReturn, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    // MARK: - Place Bets Implementation
    
    func placeBets(betTickets: [BetTicket], useFreebetBalance: Bool, currency: String? = nil, username: String?, userId: String?, oddsValidationType: String?) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        // Convert BetTickets to PlaceBetRequest
        let placeBetRequest = convertBetTicketsToPlaceBetRequest(betTickets, currency: currency, username: username, userId: userId, oddsValidationType: oddsValidationType)

        // Create the API endpoint
        let endpoint = EveryMatrixOddsMatrixAPI.placeBet(betData: placeBetRequest)

        // Make the API call
        return connector.request(endpoint)
            .flatMap { (response: EveryMatrix.PlaceBetResponse) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> in
                // Convert the response to PlacedBetsResponse
                let placedBetsResponse = self.convertResponseToPlacedBetsResponse(response, originalTickets: betTickets)
                return Just(placedBetsResponse).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - BetBuilder Methods
    
    func calculateBetBuilderPotentialReturn(forBetTicket betTicket: BetTicket) -> AnyPublisher<BetBuilderPotentialReturn, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func placeBetBuilderBet(betTicket: BetTicket, calculatedOdd: Double) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    // MARK: - Boosted Bet Methods
    
    func confirmBoostedBet(identifier: String) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func rejectBoostedBet(identifier: String) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    // MARK: - Cashout Methods
    
    func calculateCashout(betId: String, stakeValue: String?) -> AnyPublisher<Cashout, ServiceProviderError> {
        let endpoint = EveryMatrixOddsMatrixAPI.calculateCashout(betId: betId, stakeValue: stakeValue)
        
        return connector.request(endpoint)
            .map { (response: EveryMatrix.CashoutResponse) -> Cashout in
                // Convert EveryMatrix response to Cashout model
                return Cashout(
                    cashoutValue: response.cashoutValue ?? 0.0,
                    partialCashoutAvailable: stakeValue != nil
                )
            }
            .mapError { error in
                ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    func cashoutBet(betId: String, cashoutValue: Double, stakeValue: Double?) -> AnyPublisher<CashoutResult, ServiceProviderError> {
        let endpoint = EveryMatrixOddsMatrixAPI.cashoutBet(betId: betId, cashoutValue: cashoutValue, stakeValue: stakeValue)
        
        return connector.request(endpoint)
            .map { (response: EveryMatrix.CashoutExecuteResponse) -> CashoutResult in
                return CashoutResult(
                    cashoutResult: response.success == true ? 1 : 0,
                    cashoutReoffer: response.cashoutValue,
                    message: response.errorMessage
                )
            }
            .mapError { error in
                ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    func allowedCashoutBetIds() -> AnyPublisher<[String], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    // MARK: - Cashback Methods
    
    func calculateCashback(forBetTicket betTicket: BetTicket) -> AnyPublisher<CashbackResult, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    // MARK: - Betslip Settings Methods
    
    func getBetslipSettings() -> AnyPublisher<BetslipSettings?, Never> {
        return Just(nil).eraseToAnyPublisher()
    }
    
    func updateBetslipSettings(_ betslipSettings: BetslipSettings) -> AnyPublisher<Bool, Never> {
        return Just(false).eraseToAnyPublisher()
    }
    
    // MARK: - Freebet Methods
    
    func getFreebet() -> AnyPublisher<FreebetBalance, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    // MARK: - Ticket Methods
    
    func getSharedTicket(betslipId: String) -> AnyPublisher<SharedTicketResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getTicketSelection(ticketSelectionId: String) -> AnyPublisher<TicketSelection, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func updateTicketOdds(betId: String) -> AnyPublisher<Bet, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getTicketQRCode(betId: String) -> AnyPublisher<BetQRCode, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getSocialSharedTicket(shareId: String) -> AnyPublisher<Bet, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func deleteTicket(betId: String) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func updateTicket(betId: String, betTicket: BetTicket) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    // MARK: - Private Helper Methods
    
    private func convertBetTicketsToPlaceBetRequest(_ betTickets: [BetTicket], currency: String?, username: String?, userId: String?, oddsValidationType: String?) -> EveryMatrix.PlaceBetRequest {
        let selections = betTickets.flatMap { betTicket in
            betTicket.tickets.map { selection in
                EveryMatrix.BetSelectionInfo(
                    bettingOfferId: selection.outcomeId ?? "",
                    priceValue: selection.odd.decimalOdd
                )
            }
        }

        let totalAmount = betTickets.reduce(0.0) { $0 + ($1.globalStake ?? 0.0) }

        let type = selections.count > 1 ? "MULTIPLE" : "SINGLE"

        let domainId = EveryMatrixUnifiedConfiguration.shared.domainId
        let operatorId = Int(domainId) ?? 4093

        return EveryMatrix.PlaceBetRequest(
            ucsOperatorId: operatorId,
            userId: userId ?? "",
            username: username ?? "",
            currency: currency ?? "EUR",
            type: type,
            selections: selections,
            amount: String(format: "%.2f", totalAmount),
            oddsValidationType: oddsValidationType ?? "ACCEPT_ANY",
            terminalType: "SSBT",
            ubsWalletId: nil,
            freeBet: nil
        )
    }
    
    private func convertResponseToPlacedBetsResponse(_ response: EveryMatrix.PlaceBetResponse, originalTickets: [BetTicket]) -> PlacedBetsResponse {
        // Create a PlacedBetEntry from the response
        let totalStake = originalTickets.reduce(0.0) { $0 + ($1.globalStake ?? 0.0) }

        let placedBetEntry = PlacedBetEntry(
            identifier: response.betId ?? UUID().uuidString,
            potentialReturn: response.potentialReturn ?? 0.0,
            totalStake: totalStake,
            betLegs: [], // EveryMatrix doesn't provide bet legs in this format
            type: nil
        )

        return PlacedBetsResponse(
            identifier: response.betId ?? UUID().uuidString,
            bets: [placedBetEntry],
            detailedBets: nil,
            requiredConfirmation: false,
            totalStake: totalStake
        )
    }
    
    // MARK: - Helper Methods
    
    private func defaultPlacedBeforeDate() -> String {
        let calendar = Calendar.current
        let sixMonthsFromNow = calendar.date(byAdding: .month, value: 6, to: Date()) ?? Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Use UTC
        
        return formatter.string(from: sixMonthsFromNow)
    }
}

