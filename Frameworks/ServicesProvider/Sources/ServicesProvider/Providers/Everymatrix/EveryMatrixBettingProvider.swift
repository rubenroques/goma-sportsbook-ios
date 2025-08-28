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
            .handleEvents(
                receiveSubscription: { _ in
                    print("[AUTH_DEBUG]  Starting open bets request")
                },
                receiveOutput: { (bets: [EveryMatrix.Bet]) in
                    print("[AUTH_DEBUG] EveryMatrixBettingProvider: Received \(bets.count) bets from API")
                    print("[AUTH_DEBUG] EveryMatrixBettingProvider: Raw bets: \(bets)")
                },
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("[AUTH_DEBUG] ✅ EveryMatrixBettingProvider: Request completed successfully")
                    case .failure(let error):
                        print("[AUTH_DEBUG] ❌ EveryMatrixBettingProvider: Error details: \(error.localizedDescription)")
                    }
                }
            )
            .map { (bets: [EveryMatrix.Bet]) -> BettingHistory in
                print("🔄 EveryMatrixBettingProvider: Mapping \(bets.count) EveryMatrix bets to internal format")
                let mappedBets = bets.compactMap { self.mapEveryMatrixBetToBet($0) }
                print("✅ EveryMatrixBettingProvider: Successfully mapped to \(mappedBets.count) internal bets")
                return BettingHistory(bets: mappedBets)
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
                let mappedBets = bets.compactMap { self.mapEveryMatrixBetToBet($0) }
                return BettingHistory(bets: mappedBets)
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
                let mappedBets = bets.compactMap { self.mapEveryMatrixBetToBet($0) }
                return BettingHistory(bets: mappedBets)
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
    
    private func convertBetTicketsToPlaceBetRequest(_ betTickets: [BetTicket], currency: String?, username: String?, userId: String?, oddsValidationType: String?) -> PlaceBetRequest {
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
            oddsValidationType: oddsValidationType ?? "ACCEPT_ANY",
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
    
    // MARK: - Helper Methods
    
    private func defaultPlacedBeforeDate() -> String {
        let calendar = Calendar.current
        let sixMonthsFromNow = calendar.date(byAdding: .month, value: 6, to: Date()) ?? Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Use UTC
        
        return formatter.string(from: sixMonthsFromNow)
    }
    
    private func mapEveryMatrixBetToBet(_ everyMatrixBet: EveryMatrix.Bet) -> Bet? {
        // Convert EveryMatrix bet model to internal Bet model
        // This is a basic mapping - you may need to adjust based on actual API response structure
        guard let betId = everyMatrixBet.id,
              let status = everyMatrixBet.status,
              let amount = everyMatrixBet.amount,
              let dateString = everyMatrixBet.placedDate else {
            return nil
        }
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: dateString) ?? Date()
        
        // Map EveryMatrix status to BetState and BetResult
        let betState = mapEveryMatrixStatusToBetState(status)
        let betResult = mapEveryMatrixStatusToBetResult(status)
        
        // Map selections if available
        let selections = everyMatrixBet.selections?.compactMap { selection in
            mapEveryMatrixSelectionToBetSelection(selection)
        } ?? []
        
        return Bet(
            identifier: betId,
            type: everyMatrixBet.type ?? "SINGLE",
            state: betState,
            result: betResult,
            globalState: betState,
            stake: amount,
            totalOdd: everyMatrixBet.odds ?? 1.0,
            selections: selections,
            potentialReturn: everyMatrixBet.potentialWinnings,
            totalReturn: everyMatrixBet.payout,
            date: date,
            freebet: false,
            partialCashoutReturn: everyMatrixBet.partialCashoutValue,
            partialCashoutStake: everyMatrixBet.partialCashoutStake
        )
    }
    
    private func mapEveryMatrixStatusToBetState(_ status: String) -> BetState {
        switch status.uppercased() {
        case "PENDING", "IN_PROGRESS":
            return .opened
        case "WON":
            return .won
        case "LOST":
            return .lost
        case "CASHED_OUT":
            return .cashedOut
        case "VOID":
            return .void
        case "CANCELLED":
            return .cancelled
        case "SETTLED":
            return .settled
        default:
            return .undefined
        }
    }
    
    private func mapEveryMatrixStatusToBetResult(_ status: String) -> BetResult {
        switch status.uppercased() {
        case "PENDING", "IN_PROGRESS":
            return .open
        case "WON":
            return .won
        case "LOST":
            return .lost
        case "VOID":
            return .void
        default:
            return .notSpecified
        }
    }
    
    private func mapEveryMatrixSelectionToBetSelection(_ selection: EveryMatrix.BetSelection) -> BetSelection? {
        // Map EveryMatrix selection to BetSelection
        // This is a basic mapping - adjust based on actual API response structure
        guard let selectionId = selection.id,
              let eventName = selection.matchName,
              let marketName = selection.marketType,
              let outcomeName = selection.selection else {
            return nil
        }
        
        return BetSelection(
            identifier: selectionId,
            state: mapEveryMatrixStatusToBetState(selection.status ?? "PENDING"),
            result: mapEveryMatrixStatusToBetResult(selection.status ?? "PENDING"),
            globalState: mapEveryMatrixStatusToBetState(selection.status ?? "PENDING"),
            eventName: eventName,
            homeTeamName: selection.homeTeam,
            awayTeamName: selection.awayTeam,
            marketName: marketName,
            outcomeName: outcomeName,
            odd: .decimal(odd: selection.odds ?? 1.0),
            homeResult: selection.homeScore,
            awayResult: selection.awayScore,
            eventId: selection.eventId ?? selectionId,
            eventDate: nil, // Parse from selection if available
            country: nil, // Parse from selection if available
            sportType: SportType.defaultFootball, // Default - parse from selection if available
            tournamentName: selection.competition ?? "",
            marketId: selection.marketId,
            outcomeId: selection.outcomeId
        )
    }
}

// MARK: - EveryMatrix Response Models

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

 
