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
    private var socketConnector: EveryMatrixSocketConnector
    private var restConnector: EveryMatrixRESTConnector
    private let sseConnector: EveryMatrixSSEConnector
    private var cancellables: Set<AnyCancellable> = []

    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        return self.connectionStateSubject.eraseToAnyPublisher()
    }
    private var connectionStateSubject: CurrentValueSubject<ConnectorState, Never> = .init(.connected)

    init(socketConnector: EveryMatrixSocketConnector,
         sessionCoordinator: EveryMatrixSessionCoordinator,
         restConnector: EveryMatrixRESTConnector,
         sseConnector: EveryMatrixSSEConnector) {
        self.socketConnector = socketConnector
        self.sessionCoordinator = sessionCoordinator
        self.restConnector = restConnector
        self.sseConnector = sseConnector

        // Update connection state
        self.connectionStateSubject.send(.connected)
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
        
        let endpoint = EveryMatrixOddsMatrixWebAPI.getOpenBets(limit: limit, placedBefore: placedBefore)
        
        return restConnector.request(endpoint)
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
        
        let endpoint = EveryMatrixOddsMatrixWebAPI.getSettledBets(limit: limit, placedBefore: placedBefore, betStatus: nil)
        
        return restConnector.request(endpoint)
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
        
        let endpoint = EveryMatrixOddsMatrixWebAPI.getSettledBets(limit: limit, placedBefore: placedBefore, betStatus: "WON")
        
        return restConnector.request(endpoint)
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
    
    func placeBets(betTickets: [BetTicket], useFreebetBalance: Bool, currency: String? = nil, username: String?, userId: String?, oddsValidationType: String?, ubsWalletId: String?, betBuilderOdds: Double?) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError> {
        // Convert BetTickets to PlaceBetRequest
        let placeBetRequest = convertBetTicketsToPlaceBetRequest(betTickets, currency: currency, username: username, userId: userId, oddsValidationType: oddsValidationType, ubsWalletId: ubsWalletId, betBuilderOdds: betBuilderOdds)

        // Create the API endpoint
        let endpoint = EveryMatrixOddsMatrixWebAPI.placeBet(betData: placeBetRequest)

        // Make the API call
        return restConnector.request(endpoint)
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
    
    // MARK: - Cashout Methods (Legacy)

    func calculateCashout(betId: String, stakeValue: String?) -> AnyPublisher<Cashout, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func cashoutBet(betId: String, cashoutValue: Double, stakeValue: Double?) -> AnyPublisher<CashoutResult, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func allowedCashoutBetIds() -> AnyPublisher<[String], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    // MARK: - NEW Cashout Methods (SSE-based)

    func subscribeToCashoutValue(betId: String) -> AnyPublisher<SubscribableContent<CashoutValue>, ServiceProviderError> {
        print("💰 EveryMatrixBettingProvider: Subscribing to cashout value for bet \(betId)")

        let endpoint = EveryMatrixOddsMatrixWebAPI.getCashoutValueSSE(betId: betId)

        return self.sseConnector.request(endpoint, decodingType: EveryMatrix.CashoutValueSSEResponse.self)
            .compactMap { sseEvent -> SubscribableContent<CashoutValue>? in
                switch sseEvent {
                case .connected:
                    print("✅ SSE Connected - waiting for cashout value...")
                    // Create simple subscription for SSE connection
                    let subscription = Subscription(id: "sse-cashout-\(betId)")
                    return .connected(subscription: subscription)

                case .message(let response):
                    // Log message type
                    print("📨 SSE Message: type=\(response.messageType), code=\(response.details.code)")

                    // Filter 1: Only process CASHOUT_VALUE messages (ignore AUTOCASHOUT_RULE)
                    guard response.messageType == "CASHOUT_VALUE" else {
                        print("⏭️ Skipping \(response.messageType) message")
                        return nil
                    }

                    // Filter 2: Only emit messages with code 100 (ignore code 103)
                    guard response.details.code == 100 else {
                        print("⏳ Code 103 - still loading odds...")
                        return nil
                    }

                    // Filter 3: Ensure cashout value is present
                    guard response.cashoutValue != nil else {
                        print("⚠️ Code 100 but no cashout value - skipping")
                        return nil
                    }

                    print("✅ Cashout value ready: \(response.cashoutValue!)")

                    // Map to public model
                    let mappedValue = EveryMatrixModelMapper.cashoutValue(fromSSEResponse: response)
                    return .contentUpdate(content: mappedValue)

                case .disconnected:
                    print("🔌 SSE Disconnected")
                    return .disconnected
                }
            }
            .eraseToAnyPublisher()
    }

    func executeCashout(request: CashoutRequest) -> AnyPublisher<CashoutResponse, ServiceProviderError> {
        print("💰 EveryMatrixBettingProvider: Executing cashout for bet \(request.betId)")
        print("💰 Type: \(request.cashoutType), Value: \(request.cashoutValue)")

        // Map public request to internal DTO
        let internalRequest = EveryMatrixModelMapper.cashoutRequest(from: request)

        // Create endpoint
        let endpoint = EveryMatrixOddsMatrixWebAPI.executeCashoutV2(request: internalRequest)

        // Execute request
        return restConnector.request(endpoint)
            .map { (response: EveryMatrix.CashoutResponse) -> CashoutResponse in
                print("✅ Cashout executed: success=\(response.success), payout=\(response.cashoutPayout)")

                // Map internal response to public model
                return EveryMatrixModelMapper.cashoutResponse(fromInternalResponse: response)
            }
            .mapError { error in
                print("❌ Cashout execution failed: \(error)")
                return ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
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
    
    private func convertBetTicketsToPlaceBetRequest(_ betTickets: [BetTicket], currency: String?, username: String?, userId: String?, oddsValidationType: String?, ubsWalletId: String?, betBuilderOdds: Double?) -> EveryMatrix.PlaceBetRequest {
        let selections = betTickets.flatMap { betTicket in
            betTicket.tickets.map { selection in
                EveryMatrix.BetSelectionInfo(
                    bettingOfferId: selection.identifier,
                    priceValue: selection.odd.decimalOdd,
                    eventId: selection.eventId ?? "",
                    marketId: selection.marketId ?? "",
                    bettingTypeId: selection.marketTypeId ?? "",
                    outcomeId: selection.outcomeId ?? "",
                    betBuilderPriceValue: betBuilderOdds
                )
            }
        }

        let totalAmount = betTickets.reduce(0.0) { $0 + ($1.globalStake ?? 0.0) }

        let type = selections.count > 1 ? "MULTIPLE" : "SINGLE"

        let domainId = EveryMatrixUnifiedConfiguration.shared.operatorId
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
            terminalType: "DESKTOP",
            ubsWalletId: ubsWalletId,
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
    
    func calculateUnifiedBettingOptions(
        betType: BetGroupingType,
        selections: [BettingOptionsCalculateSelection],
        stakeAmount: Double?
    ) -> AnyPublisher<UnifiedBettingOptions, ServiceProviderError> {

        let language = EveryMatrixUnifiedConfiguration.shared.defaultLanguage

        // Convert BetSelection (domain) → BetSelectionInfo (EveryMatrix)
        let emSelections = selections.compactMap { selection -> EveryMatrix.BettingOptionsCalculateSelection in
            return EveryMatrix.BettingOptionsCalculateSelection(
                bettingOfferId: selection.bettingOfferId,
                priceValue: selection.oddFormat.decimalOdd
            )
        }

        // Validate selections
        guard !emSelections.isEmpty else {
            print("❌ BettingProvider: No valid selections for betting options calculation")
            return Fail(error: ServiceProviderError.errorDetailedMessage(
                key: "invalid_selections",
                message: "No valid selections provided"
            )).eraseToAnyPublisher()
        }

        // Create router with parameters
        let router = WAMPRouter.getBettingOptionsV2(
            type: betType,
            selections: emSelections,
            stakeAmount: stakeAmount,
            language: language
        )

        print("🎯 BettingProvider: Calculating betting options for \(emSelections.count) selections, betType: \(betType)")

        // Make RPC call via socketConnector
        let rpcResponsePublisher: AnyPublisher<EveryMatrix.BettingOptionsV2Response, ServiceProviderError> =
            socketConnector.request(router)

        // Map response to domain model
        return rpcResponsePublisher
            .map { response in
                print("✅ BettingProvider: Received betting options - success: \(response.success ?? false), minStake: \(response.minStake ?? 0), maxStake: \(response.maxStake?.description ?? "nil"), odds: \(response.priceValueFactor ?? 0)")
                return EveryMatrixModelMapper.unifiedBettingOptions(from: response)
            }
            .eraseToAnyPublisher()
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

