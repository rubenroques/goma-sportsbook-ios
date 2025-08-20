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

    init(sessionCoordinator: EveryMatrixSessionCoordinator, connector: EveryMatrixOddsMatrixAPIConnector = EveryMatrixOddsMatrixAPIConnector()) {
        self.sessionCoordinator = sessionCoordinator
        self.connector = connector
        
        // Update connection state
        self.connectionStateSubject.send(.connected)
        
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
    }

    // MARK: - BettingProvider Protocol Methods
    
    func getBetHistory(pageIndex: Int) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getBetDetails(identifier: String) -> AnyPublisher<Bet, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getOpenBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getResolvedBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getWonBetsHistory(pageIndex: Int, startDate: String?, endDate: String?) -> AnyPublisher<BettingHistory, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getAllowedBetTypes(withBetTicketSelections betTicketSelections: [BetTicketSelection]) -> AnyPublisher<[BetType], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func calculatePotentialReturn(forBetTicket betTicket: BetTicket) -> AnyPublisher<BetslipPotentialReturn, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    // MARK: - Place Bets Implementation
    
    func placeBets(betTickets: [BetTicket], useFreebetBalance: Bool, currency: String? = nil, username: String?, userId: String?) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        // Convert BetTickets to PlaceBetRequest
        let placeBetRequest = convertBetTicketsToPlaceBetRequest(betTickets, currency: currency, username: username, userId: userId)
        
        // Create the API endpoint
        let endpoint = EveryMatrixOddsMatrixAPI.placeBet(betData: placeBetRequest)
        
        // Make the API call
        return connector.request(endpoint)
            .flatMap { (response: EveryMatrixPlaceBetResponse) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> in
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
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func cashoutBet(betId: String, cashoutValue: Double, stakeValue: Double?) -> AnyPublisher<CashoutResult, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
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
    
    private func convertBetTicketsToPlaceBetRequest(_ betTickets: [BetTicket], currency: String?, username: String?, userId: String?) -> PlaceBetRequest {
        let selections = betTickets.flatMap { betTicket in
            betTicket.tickets.map { selection in
                BetSelectionInfo(
                    bettingOfferId: selection.outcomeId ?? "",
                    priceValue: selection.odd.decimalOdd
                )
            }
        }
        
        let totalAmount = betTickets.reduce(0.0) { $0 + ($1.globalStake ?? 0.0) }
        
        let type = selections.count > 1 ? "MULTIPLE" : "SINGLE"
        
        return PlaceBetRequest(
            ucsOperatorId: 4093, // Default operator ID, should be configurable
            userId: userId ?? "",
            username: username ?? "",
            currency: currency ?? "EUR",
            type: type,
            selections: selections,
            amount: totalAmount,
            oddsValidationType: "ACCEPT_ANY", // Default validation type
            terminalType: "MOBILE",
            ubsWalletId: nil,
            freeBet: nil
        )
    }
    
    private func convertResponseToPlacedBetsResponse(_ response: EveryMatrixPlaceBetResponse, originalTickets: [BetTicket]) -> PlacedBetsResponse {
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
}

// MARK: - EveryMatrix Place Bet Response Model

struct EveryMatrixPlaceBetResponse: Codable {
    let betId: String?
    let potentialReturn: Double?
    let status: String?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case betId = "betId"
        case potentialReturn = "potentialReturn"
        case status = "status"
        case message = "message"
    }
} 
