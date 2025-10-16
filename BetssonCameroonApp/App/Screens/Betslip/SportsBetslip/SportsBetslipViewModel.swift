//
//  SportsBetslipViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import Combine
import GomaUI

public final class SportsBetslipViewModel: SportsBetslipViewModelProtocol {
    
    // MARK: - Properties
    private let ticketsSubject = CurrentValueSubject<[BettingTicket], Never>([])
    private var cancellables = Set<AnyCancellable>()
    private var environment: Environment
    
    // MARK: - Child View Models
    public var bookingCodeButtonViewModel: ButtonIconViewModelProtocol
    public var clearBetslipButtonViewModel: ButtonIconViewModelProtocol
    public var emptyStateViewModel: EmptyStateActionViewModelProtocol
    public var betInfoSubmissionViewModel: BetInfoSubmissionViewModelProtocol
    public var oddsAcceptanceViewModel: OddsAcceptanceViewModelProtocol
    public var codeInputViewModel: CodeInputViewModelProtocol
    public var loginButtonViewModel: ButtonViewModelProtocol
    
    // MARK: - Publishers
    public var ticketsPublisher: AnyPublisher<[BettingTicket], Never> {
        return ticketsSubject.eraseToAnyPublisher()
    }
    
    public var currentTickets: [BettingTicket] {
        return ticketsSubject.value
    }
    
    public var isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    
    public var betslipLoggedState: ((BetslipLoggedState) -> Void)?
    public var showPlacedBetState: ((BetPlacedState) -> Void)?
    public var showLoginScreen: (() -> Void)?
    public var showToastMessage: ((String) -> Void)?
    
    // MARK: - Recommended Matches
    public var suggestedBetsViewModel: SuggestedBetsExpandedViewModelProtocol
    public let toasterViewModel: ToasterViewModelProtocol
    
    // MARK: - Initialization
    init(environment: Environment) {
        self.environment = environment
        // Initialize child view models
        self.bookingCodeButtonViewModel = MockButtonIconViewModel(
            title: "Booking Code",
            icon: "doc.text",
            layoutType: .iconLeft
        )
        
        self.clearBetslipButtonViewModel = MockButtonIconViewModel(
            title: "Clear Betslip",
            icon: "trash_icon",
            layoutType: .iconLeft
        )
        
        self.emptyStateViewModel = MockEmptyStateActionViewModel(state: .loggedOut, title: "You need at least 1 selection\nin your betslip to place a bet", actionButtonTitle: "Log in to bet", image: "empty_betslip_icon")
        
        // Initialize with default currency, will be updated when user profile is available
        let currency = environment.userSessionStore.userWalletPublisher.value?.currency ?? "XAF"
        self.betInfoSubmissionViewModel = MockBetInfoSubmissionViewModel(currency: currency)
        self.oddsAcceptanceViewModel = MockOddsAcceptanceViewModel.acceptedMock()
        self.codeInputViewModel = MockCodeInputViewModel()
        
        
        self.loginButtonViewModel = MockButtonViewModel(buttonData:
                                                            ButtonData(id: "login", title: "Login", style: .solidBackground)
        )
        
        // Initialize suggested bets view model
        self.suggestedBetsViewModel = MockSuggestedBetsExpandedViewModel(
            title: "Explore more bets",
            isExpanded: false,
            matchCardViewModels: []
        )
        
        // Toaster VM
        self.toasterViewModel = AppToasterViewModel()
        
        // Setup real data subscription
        setupPublishers()
        getRecommendedMatches()

        // Wire CodeInputView submission to screen-level logic
        self.codeInputViewModel.onSubmitRequested = { [weak self] code in
            self?.getBettingTicketsFromCode(code: code)
        }
    }
    
    private func getRecommendedMatches() {
                
        let userId = environment.userSessionStore.userProfilePublisher.value?.userIdentifier ?? ""
        
        environment.servicesProvider.getRecommendedMatch(userId: userId, isLive: false, limit: 5)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("RECOMMENDED ERROR: \(error)")
//                    self?.isLoadingSubject.send(false)
                }
            }, receiveValue: { [weak self] events in
                guard let self = self else { return }
                let matches = ServiceProviderModelMapper.matches(fromEvents: events)
                
                let items: [TallOddsMatchCardViewModelProtocol] = matches.map { match in
                    let tallOddsMatchCardViewModel = TallOddsMatchCardViewModel.create(from: match, relevantMarkets: match.markets, marketTypeId: match.markets.first?.typeId ?? "", matchCardContext: .search)
                    return tallOddsMatchCardViewModel
                }
                
                // Update suggested bets view model with matches
                if let mockViewModel = self.suggestedBetsViewModel as? MockSuggestedBetsExpandedViewModel {
                    mockViewModel.updateMatches(items)
                }
                                
                self.isLoadingSubject.send(false)
            })
            .store(in: &cancellables)
    }

    // MARK: - Booking code loading
    private func getBettingTicketsFromCode(code: String) {
        // Trigger loading state in the component
        codeInputViewModel.setLoading(true)

        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            codeInputViewModel.setLoading(false)
            codeInputViewModel.setError("Booking Code can't be found. It either doesn't exist or expired.")
            return
        }

        // Call actual endpoint to resolve betting offer ids from booking code
        environment.servicesProvider.getBettingOfferIds(bookingCode: trimmed)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.codeInputViewModel.setLoading(false)
                    if case .failure(let error) = completion {
                        self.codeInputViewModel.setError(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] bettingOfferIds in
                    guard let self = self else { return }
                    self.codeInputViewModel.clearError()
                    print("[BOOKING_CODE] Retrieved betting offer ids (\(bettingOfferIds.count)) for code: \(trimmed)")
                    
                    // TODO: Implement actual endpoint to create betting tickets
                    if let first = bettingOfferIds.first {
                        let ticket = BettingTicket(
                            id: first,
                            outcomeId: "outcome_\(first)",
                            marketId: "market_\(first)",
                            matchId: "match_\(first)",
                            decimalOdd: 2.10,
                            isAvailable: true,
                            matchDescription: "Team A x Team B",
                            marketDescription: "Match Winner",
                            outcomeDescription: "Team A",
                            homeParticipantName: "Team A",
                            awayParticipantName: "Team B",
                            sport: nil,
                            sportIdCode: nil,
                            venue: nil,
                            competition: "Premier League",
                            date: Date()
                        )
                        self.environment.betslipManager.addBettingTicket(ticket)
                        
                        self.codeInputViewModel.updateCode("")
                        self.showToastMessage?("Booking Code Loaded")
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    public func removeTicket(_ ticket: BettingTicket) {
        environment.betslipManager.removeBettingTicket(ticket)
    }
    
    public func clearAllTickets() {
        environment.betslipManager.clearAllBettingTickets()
    }
    
    // MARK: - Private Methods
    private func setupPublishers() {
        // Subscribe to real betslip data from the manager
        environment.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tickets in
                self?.ticketsSubject.send(tickets)
                // Recalculate odds
                self?.calculateOdds()
                // Recalculate potential winnings when tickets change
                self?.calculatePotentialWinnings()

                // Forward selected outcomes to suggested bets VM (for cell selection state)
                if let mockSuggested = self?.suggestedBetsViewModel as? MockSuggestedBetsExpandedViewModel {
                    let selectedOutcomeIds = Set(tickets.map { String($0.outcomeId) })
                    mockSuggested.updateSelectedOutcomeIds(selectedOutcomeIds)
                }
            }
            .store(in: &cancellables)
        
        environment.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                if userProfile != nil {
                    self?.emptyStateViewModel.updateState(.loggedIn)
                } else {
                    self?.emptyStateViewModel.updateState(.loggedOut)
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(environment.betslipManager.bettingTicketsPublisher, environment.userSessionStore.userProfilePublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] tickets, userProfile in
                
                if userProfile == nil {
                    if tickets.isEmpty {
                        self?.betslipLoggedState?(.noTicketsLoggedOut)
                    }
                    else {
                        self?.betslipLoggedState?(.ticketsLoggedOut)
                    }
                }
                else {
                    if tickets.isEmpty {
                        self?.betslipLoggedState?(.noTicketsLoggedIn)
                    }
                    else {
                        self?.betslipLoggedState?(.ticketsLoggedIn)
                    }
                }
                
            })
            .store(in: &cancellables)
        
        betInfoSubmissionViewModel.onPlaceBetTapped = { [weak self] in
            self?.placeBet()
        }
        
        betInfoSubmissionViewModel.amountChanged = { [weak self] in
            self?.calculatePotentialWinnings()
        }
        
        
        loginButtonViewModel.onButtonTapped = { [weak self] in
            self?.showLoginScreen?()
        }
    }
    
    private func placeBet() {

        let stake = convertToDouble(betInfoSubmissionViewModel.currentData.amount)

        let oddsValidationType = oddsAcceptanceViewModel.currentData.state == .accepted ? "ACCEPT_ANY" : "ACCEPT_HIGHER"

        // Capture current tickets before clearing
        let placedTickets = currentTickets
        print("[BET_PLACEMENT] 📋 Placing bet with \(placedTickets.count) tickets")
        placedTickets.enumerated().forEach { index, ticket in
            print("[BET_PLACEMENT]   [\(index+1)] \(ticket.matchDescription) - \(ticket.outcomeDescription) @ \(ticket.decimalOdd)")
        }

        // Show loading state
        self.isLoadingSubject.send(true)

        environment.betslipManager.placeBet(withStake: stake, useFreebetBalance: false, oddsValidationType: oddsValidationType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // Hide loading state
                switch completion {
                case .finished:
                    print("[BET_PLACEMENT] ✅ Placement request completed")
                case .failure(let error):
                    print("[BET_PLACEMENT] ❌ Placement failed: \(error)")
                    self?.showPlacedBetState?(.error(message: "Bet couldn't be placed. Please try again later!"))
                }

                self?.isLoadingSubject.send(false)

            }, receiveValue: { [weak self] betPlacedDetails in
                print("[BET_PLACEMENT] 🎉 Received response with \(betPlacedDetails.count) items")

                // Debug full response
                betPlacedDetails.enumerated().forEach { index, detail in
                    let response = detail.response
                    print("[BET_PLACEMENT]   Response[\(index)]:")
                    print("[BET_PLACEMENT]     betId: \(response.betId ?? "nil")")
                    print("[BET_PLACEMENT]     betslipId: \(response.betslipId ?? "nil")")
                    print("[BET_PLACEMENT]     betSucceed: \(response.betSucceed?.description ?? "nil")")
                    print("[BET_PLACEMENT]     selections count: \(response.selections?.count ?? 0)")
                }

                let firstResponse = betPlacedDetails.first?.response
                let betId = firstResponse?.betId
                let betslipId = firstResponse?.betslipId

                print("[BET_PLACEMENT] 🏷️ Extracted IDs - betId: \(betId ?? "nil"), betslipId: \(betslipId ?? "nil")")

                self?.showPlacedBetState?(.success(
                    betId: betId,
                    betslipId: betslipId,
                    bettingTickets: placedTickets
                ))

            })
            .store(in: &cancellables)
    }
    
    private func calculatePotentialWinnings() {
        // Get the current amount from the bet info submission view model
        let amountString = betInfoSubmissionViewModel.currentData.amount
        guard let amount = Double(amountString), amount > 0 else {
            // If no amount or invalid amount, set potential winnings to 0
            let currency = betInfoSubmissionViewModel.currentData.currency
            betInfoSubmissionViewModel.updatePotentialWinnings("\(currency) 0")
            return
        }
        
        // Calculate total odds by multiplying each odd value sequentially
        var totalOdds = 1.0
        for ticket in currentTickets {
            totalOdds *= ticket.decimalOdd
        }
        
        // Calculate potential winnings: amount * total odds
        let potentialWinnings = amount * totalOdds
        
        // Get the currency from the bet info submission view model
        let currency = betInfoSubmissionViewModel.currentData.currency
        
        // Format the potential winnings with the correct currency
        let formattedWinnings = String(format: "%@ %.2f", currency, potentialWinnings)
        
        // Update the potential winnings in the bet info submission view model
        betInfoSubmissionViewModel.updatePotentialWinnings(formattedWinnings)
        
        print("Calculated potential winnings: \(formattedWinnings) (Amount: \(amount) × Total Odds: \(totalOdds))")
    }
    
    private func calculateOdds() {
        
        // Calculate total odds by multiplying each odd value sequentially
        var totalOdds = 1.0
        for ticket in currentTickets {
            totalOdds *= ticket.decimalOdd
        }
        
        let formattedOdds = String(format: "%.2f", totalOdds)

        betInfoSubmissionViewModel.updateOdds(formattedOdds)
        
    }
    
    func convertToDouble(_ string: String) -> Double {
        // Remove any whitespace
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else { return 0.0 }
        
        let normalizedString = trimmed.replacingOccurrences(of: ",", with: ".")
        
        return Double(normalizedString) ?? 0.0
    }
}

public enum BetslipLoggedState {
    case noTicketsLoggedOut
    case ticketsLoggedOut
    case noTicketsLoggedIn
    case ticketsLoggedIn
}

public enum BetPlacedState {
    case success(betId: String?, betslipId: String?, bettingTickets: [BettingTicket])
    case error(message: String)
}
