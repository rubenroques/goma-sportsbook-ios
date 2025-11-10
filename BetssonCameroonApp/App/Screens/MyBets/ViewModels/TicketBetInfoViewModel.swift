import Foundation
import Combine
import GomaUI
import ServicesProvider

final class TicketBetInfoViewModel: TicketBetInfoViewModelProtocol {
    
    // MARK: - Properties
    
    private let myBet: MyBet
    private let servicesProvider: ServicesProvider.Client
    private let betInfoSubject: CurrentValueSubject<TicketBetInfoData, Never>
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Child ViewModels
    
    var rebetButtonViewModel: ButtonIconViewModelProtocol
    var cashoutButtonViewModel: ButtonIconViewModelProtocol
    
    // MARK: - Publishers
    
    var currentBetInfo: TicketBetInfoData {
        betInfoSubject.value
    }
    
    var betInfoPublisher: AnyPublisher<TicketBetInfoData, Never> {
        betInfoSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Callbacks
    
    var onNavigationTap: ((MyBet) -> Void)?
    var onRebetTap: ((MyBet) -> Void)?
    var onCashoutTap: ((MyBet) -> Void)?
    
    // MARK: - Initialization
    
    init(myBet: MyBet, servicesProvider: ServicesProvider.Client) {
        self.myBet = myBet
        self.servicesProvider = servicesProvider
        
        // Create initial ticket bet info data using proper patterns
        let initialBetInfo = Self.createTicketBetInfoData(from: myBet)
        self.betInfoSubject = CurrentValueSubject(initialBetInfo)
        
        self.rebetButtonViewModel = ButtonIconViewModel.rebetButton(
            isEnabled: false
        )
        
        self.cashoutButtonViewModel = ButtonIconViewModel.cashoutButton(
            isEnabled: false
        )
        
        setupButtonsActions(bet: myBet)
    }
    
    // MARK: - Protocol Methods
    
    func handleNavigationTap() {
        onNavigationTap?(myBet)
    }
    
    func handleRebetTap() {
        guard canRebet(myBet) else { return }
        onRebetTap?(myBet)
    }
    
    func handleCashoutTap() {
        guard canCashout(myBet) else { return }
        onCashoutTap?(myBet)
    }
    
    // MARK: - Public Methods
    
    func updateBetInfo(_ updatedBet: MyBet) {
        let updatedBetInfo = Self.createTicketBetInfoData(from: updatedBet)
        betInfoSubject.send(updatedBetInfo)
        
        // Update button states - cast to concrete types to access setEnabled
        if let rebetVM = rebetButtonViewModel as? ButtonIconViewModel {
            rebetVM.setEnabled(canRebet(updatedBet))
        }
        if let cashoutVM = cashoutButtonViewModel as? ButtonIconViewModel {
            cashoutVM.setEnabled(canCashout(updatedBet))
        }
    }
    
    // MARK: - Private Methods
    private func setupButtonsActions(bet: MyBet) {
        
        // Create button view models
        rebetButtonViewModel.setEnabled(canRebet(bet))
        
        rebetButtonViewModel.onButtonTapped = { [weak self] in
            self?.handleRebetTap()
        }
                
        cashoutButtonViewModel.setEnabled(canCashout(bet))
        
        cashoutButtonViewModel.onButtonTapped = { [weak self] in
            self?.handleCashoutTap()
        }
        
    }
    
    private func canRebet(_ bet: MyBet) -> Bool {
        // Can rebet if bet open
        return !bet.isSettled
    }
    
    private func canCashout(_ bet: MyBet) -> Bool {
        // Can cashout if bet is active and has cashout value
        return bet.canCashOut && bet.isActive
    }
    
    // MARK: - Action Implementations
    
    private func executeCashout() {
        guard myBet.canCashOut else {
            return
        }
        
        // Disable cashout button during request
        cashoutButtonViewModel.setEnabled(false)
        
        servicesProvider.calculateCashout(betId: myBet.identifier, stakeValue: nil)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("❌ TicketBetInfoViewModel: Cashout calculation failed: \(error)")
                        // Re-enable button on error
                        self?.cashoutButtonViewModel.setEnabled(true)
                    }
                },
                receiveValue: { [weak self] cashoutResult in
                    print("✅ TicketBetInfoViewModel: Cashout calculated: \(cashoutResult.cashoutValue)")
                    // Handle successful cashout calculation
                    // This would typically trigger a cashout confirmation flow
                    self?.handleCashoutConfirmation(cashoutResult)
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleCashoutConfirmation(_ cashoutResult: Cashout) {
        // In a real implementation, this would show a confirmation dialog
        // For now, we'll execute the cashout directly
        
        servicesProvider.cashoutBet(
            betId: myBet.identifier,
            cashoutValue: cashoutResult.cashoutValue,
            stakeValue: nil
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("❌ TicketBetInfoViewModel: Cashout execution failed: \(error)")
                    // Re-enable button on error
                    self?.cashoutButtonViewModel.setEnabled(true)
                }
            },
            receiveValue: { [weak self] cashoutExecutionResult in
                print("✅ TicketBetInfoViewModel: Cashout executed successfully")
                // Update button state - cashout is no longer available
                self?.cashoutButtonViewModel.setEnabled(false)
                // Notify parent about bet state change
                self?.onCashoutTap?(self?.myBet ?? self!.myBet)
            }
        )
        .store(in: &cancellables)
    }
    
    private func executeRebet() {
        guard myBet.isSettled else {
            print("⚠️ TicketBetInfoViewModel: Bet is not settled, cannot rebet")
            return
        }
        
        // Convert bet selections to bet ticket selections for rebetting
        // This would require mapping MyBetSelection back to BetTicketSelection
        // For now, we'll just notify the parent
        onRebetTap?(myBet)
    }
    
    // MARK: - Data Creation (Following Established Patterns)
    
    private static func createTicketBetInfoData(from myBet: MyBet) -> TicketBetInfoData {
        let ticketSelections = myBet.selections.map { createTicketSelectionData(from: $0) }
        
        return TicketBetInfoData(
            id: myBet.identifier,
            title: formatBetTitle(myBet),
            betDetails: formatBetDetails(myBet),
            tickets: ticketSelections,
            totalOdds: formatOdds(myBet.totalOdd),
            betAmount: formatCurrency(myBet.stake, currency: myBet.currency),
            possibleWinnings: formatPossibleWinnings(myBet),
            partialCashoutValue: nil, // TODO: cashout
            cashoutTotalAmount: nil, // TODO: cashout
            betStatus: createBetStatus(from: myBet),
            isSettled: myBet.isSettled
        )
    }
    
    private static func createTicketSelectionData(from selection: MyBetSelection) -> TicketSelectionData {
        return TicketSelectionData(
            id: selection.identifier,
            competitionName: selection.tournamentName,
            homeTeamName: selection.homeTeamName ?? "",
            awayTeamName: selection.awayTeamName ?? "",
            homeScore: parseScore(selection.homeResult),
            awayScore: parseScore(selection.awayResult),
            matchDate: formatEventDate(selection.eventDate),
            isLive: isLiveMatch(selection),
            sportIcon: extractSportIcon(from: selection),
            countryFlag: extractCountryFlag(from: selection),
            marketName: selection.marketName,
            selectionName: selection.outcomeName,
            oddsValue: formatOdds(selection.odd)
        )
    }
    
    // MARK: - Formatting Helper Methods
    
    private static func formatBetTitle(_ myBet: MyBet) -> String {
        return myBet.typeDescription
    }
    
    private static func formatBetDetails(_ myBet: MyBet) -> String {
        return "Ticket: \(myBet.displayTicketReference)"
    }
    
    private static func formatOdds(_ oddFormat: OddFormat) -> String {
        return OddConverter.stringForValue(oddFormat.decimalValue, format: .europe)
    }
    
    private static func formatOdds(_ odds: Double) -> String {
        return OddConverter.stringForValue(odds, format: .europe)
    }
    
    private static func formatCurrency(_ amount: Double, currency: String) -> String {
        // Format amount with currency code using comma thousand separator
        return CurrencyHelper.formatAmountWithCurrency(amount, currency: currency)
    }
    
    private static func formatPossibleWinnings(_ myBet: MyBet) -> String {
        guard let potentialReturn = myBet.potentialReturn else {
            return formatCurrency(0.0, currency: myBet.currency)
        }
        return formatCurrency(potentialReturn, currency: myBet.currency)
    }
    
    private static func createBetStatus(from myBet: MyBet) -> BetTicketStatusData? {
        // Only provide status data if bet is settled
        guard myBet.isSettled else { return nil }
        
        let ticketStatus: BetTicketStatus
        switch myBet.result {
        case .won:
            ticketStatus = .won
        case .lost:
            ticketStatus = .lost
        case .drawn:
            ticketStatus = .draw
        default:
            // For other states like void, pending, etc., don't show status
            return nil
        }
        
        return BetTicketStatusData(status: ticketStatus)
    }
    
    // MARK: - Selection Helper Methods
    
    private static func parseScore(_ scoreString: String?) -> Int {
        guard let scoreString = scoreString else { return 0 }
        return Int(scoreString) ?? 0
    }
    
    private static func formatEventDate(_ eventDate: Date?) -> String {
        guard let eventDate = eventDate else {
            return "TBD"
        }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(eventDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "Today \(formatter.string(from: eventDate))"
        } else if calendar.isDateInTomorrow(eventDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "Tomorrow \(formatter.string(from: eventDate))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM HH:mm"
            return formatter.string(from: eventDate)
        }
    }
    
    private static func isLiveMatch(_ selection: MyBetSelection) -> Bool {
        return selection.state == .opened && 
               selection.homeResult != nil && 
               selection.awayResult != nil
    }
    
    // MARK: - Image Resolution (Using Existing Systems)
    
    private static func extractSportIcon(from selection: MyBetSelection) -> String? {
        // Use the sport's alphaId or numeric ID, following existing pattern
        guard let sport = selection.sport else { return nil }
        return sport.alphaId ?? sport.numericId ?? "1"
    }
    
    private static func extractCountryFlag(from selection: MyBetSelection) -> String? {
        // Use the country's ISO code, following existing pattern
        guard let country = selection.country else { return nil }
        return country.iso2Code
    }
    
}

// MARK: - Factory Methods

extension TicketBetInfoViewModel {
    
    static func create(from myBet: MyBet, servicesProvider: ServicesProvider.Client) -> TicketBetInfoViewModel {
        return TicketBetInfoViewModel(myBet: myBet, servicesProvider: servicesProvider)
    }
}
