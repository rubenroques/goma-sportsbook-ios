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
    
    let rebetButtonViewModel: ButtonIconViewModelProtocol
    let cashoutButtonViewModel: ButtonIconViewModelProtocol
    
    // MARK: - Publishers
    
    var betInfoPublisher: AnyPublisher<TicketBetInfoData, Never> {
        betInfoSubject.eraseToAnyPublisher()
    }
    
    var currentBetInfo: TicketBetInfoData {
        betInfoSubject.value
    }
    
    // MARK: - Callbacks
    
    var onNavigationTap: ((MyBet) -> Void)?
    var onRebetTap: ((MyBet) -> Void)?
    var onCashoutTap: ((MyBet) -> Void)?
    
    // MARK: - Initialization
    
    init(myBet: MyBet, servicesProvider: ServicesProvider.Client) {
        self.myBet = myBet
        self.servicesProvider = servicesProvider
        
        // Create initial ticket bet info data
        let initialBetInfo = TicketBetInfoViewModelMapper.mapMyBetToTicketBetInfoData(myBet)
        self.betInfoSubject = CurrentValueSubject(initialBetInfo)
        
        // Create button view models
        self.rebetButtonViewModel = ButtonIconViewModel.rebetButton(
            isEnabled: false // TODO
        )
        
        self.cashoutButtonViewModel = ButtonIconViewModel.cashoutButton(
            isEnabled: false // TODO
        )
        
        setupButtonActions()
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
        let updatedBetInfo = TicketBetInfoViewModelMapper.mapMyBetToTicketBetInfoData(updatedBet)
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
    
    private func setupButtonActions() {
        // Setup rebet button action
        if let rebetVM = rebetButtonViewModel as? ButtonIconViewModel {
            rebetVM.onButtonTapped = { [weak self] in
                self?.handleRebetTap()
            }
        }
        
        // Setup cashout button action
        if let cashoutVM = cashoutButtonViewModel as? ButtonIconViewModel {
            cashoutVM.onButtonTapped = { [weak self] in
                self?.handleCashoutTap()
            }
        }
    }
    
    private func canRebet(_ bet: MyBet) -> Bool {
        // Can rebet if bet is settled (won, lost, or cashed out)
        return bet.isSettled
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
}

// MARK: - Factory Methods

extension TicketBetInfoViewModel {
    
    static func create(from myBet: MyBet, servicesProvider: ServicesProvider.Client) -> TicketBetInfoViewModel {
        return TicketBetInfoViewModel(myBet: myBet, servicesProvider: servicesProvider)
    }
}
