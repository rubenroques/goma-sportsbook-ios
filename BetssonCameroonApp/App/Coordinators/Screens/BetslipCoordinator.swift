import Foundation
import UIKit
import Combine

/// Coordinator for the betslip screen
class BetslipCoordinator: Coordinator {
    
    // MARK: - Properties
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController

    // Services (for production ViewModel)
    private let environment: Environment

    // View model and view controller references
    private var betslipViewModel: BetslipViewModel?
    public var betslipViewController: BetslipViewController?

    // Combine
    private var cancellables = Set<AnyCancellable>()
    
    // Navigation closures
    public var onCloseBetslip: (() -> Void)?
    public var onShowRegistration: (() -> Void)?
    public var onShowLogin: (() -> Void)?
    public var onEmptyStateAction: (() -> Void)?
    public var onBetPlaced: (() -> Void)?
    
    // MARK: - Initialization
    public init(
        navigationController: UINavigationController,
        environment: Environment
    ) {
        self.navigationController = navigationController
        self.environment = environment
    }
    
    // MARK: - Coordinator
    public func start() {
        // Create appropriate ViewModel based on available services
        var viewModel: BetslipViewModelProtocol

        let betslipViewModel = BetslipViewModel(environment: environment)
        viewModel = betslipViewModel
        
        self.betslipViewModel = betslipViewModel
                
        // Setup navigation closures in ViewModel
        viewModel.onHeaderCloseTapped = { [weak self] in
            self?.finish()
            self?.onCloseBetslip?()
        }
        
        viewModel.onHeaderJoinNowTapped = { [weak self] in
            self?.onShowRegistration?()
        }
        
        viewModel.onHeaderLogInTapped = { [weak self] in
            self?.onShowLogin?()
        }
        
        viewModel.onEmptyStateActionTapped = { [weak self] in
//            self?.onEmptyStateAction?()
            self?.onShowLogin?()
        }
        
        viewModel.onPlaceBetTapped = { [weak self] betPlacedState in
            switch betPlacedState {
            case .success(let betId, let betslipId, let bettingTickets):
                print("[BET_PLACEMENT] 🎯 Coordinator received success - betId: \(betId ?? "nil"), betslipId: \(betslipId ?? "nil"), tickets: \(bettingTickets.count)")
                self?.showBetslipSuccessScreen(betId: betId, betslipId: betslipId, bettingTickets: bettingTickets)
            case .error(let message):
                print("[BET_PLACEMENT] ❌ Coordinator received error: \(message)")
                self?.showBetslipErrorAlert(message: message)
            }

        }
        
        
        let viewController = BetslipViewController(viewModel: viewModel)
        self.betslipViewController = viewController

    }
    
    public func finish() {
        childCoordinators.removeAll()
        betslipViewController = nil
        betslipViewModel = nil
    }
    
    // MARK: - Public Methods
    public func showBetslipSuccessScreen(betId: String?, betslipId: String?, bettingTickets: [BettingTicket]) {
        print("[BET_PLACEMENT] 🎬 Showing success screen - betId: \(betId ?? "nil"), betslipId: \(betslipId ?? "nil"), tickets: \(bettingTickets.count)")

        // Clear betslip
        Env.betslipManager.clearAllBettingTickets()

        let betSuccessViewModel = BetSuccessViewModel(
            betId: betId,
            betslipId: betslipId,
            bettingTickets: bettingTickets
        )

        let betSuccessViewController = BetSuccessViewController(viewModel: betSuccessViewModel)

        self.betslipViewController?.present(betSuccessViewController, animated: true)

        // Setup navigation closures
        betSuccessViewController.onContinueRequested = { [weak self] in
            self?.finish()
            self?.onCloseBetslip?()
        }

        betSuccessViewController.onOpenDetails = { [weak self] in
            // TODO: Navigate to bet details screen
            let displayId = betId ?? betslipId ?? "unknown"
            print("[BET_PLACEMENT] 📋 Open Betslip Details tapped - ID: \(displayId)")
            // For now, just dismiss the success screen
            betSuccessViewController.dismiss(animated: true) {
                self?.finish()
                self?.onCloseBetslip?()
            }
        }

        betSuccessViewController.onShareBetslip = { [weak self] in
            self?.createBookingCodeAndShare(
                bettingTickets: bettingTickets,
                from: betSuccessViewController
            )
        }
    }

    private func createBookingCodeAndShare(
        bettingTickets: [BettingTicket],
        from viewController: BetSuccessViewController
    ) {
        guard !bettingTickets.isEmpty else {
            print("[BET_PLACEMENT] ⚠️ No tickets to create booking code")
            showBookingCodeError(from: viewController)
            return
        }

        // Show loading indicator
        viewController.setShareLoading(true)

        // Extract betting offer IDs from tickets
        let bettingOfferIds = bettingTickets.map { $0.bettingId }
        let originalSelectionsLength = bettingTickets.count

        print("[BET_PLACEMENT] 📋 Creating booking code for \(bettingOfferIds.count) offers (original: \(originalSelectionsLength)):")
        bettingOfferIds.enumerated().forEach { index, id in
            print("[BET_PLACEMENT]   [\(index+1)] \(id)")
        }

        // Call API to create booking code
        environment.servicesProvider.createBookingCode(
            bettingOfferIds: bettingOfferIds,
            originalSelectionsLength: originalSelectionsLength
        )
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self, weak viewController] completion in
                    guard let self = self, let viewController = viewController else { return }

                    // Hide loading indicator
                    viewController.setShareLoading(false)

                    switch completion {
                    case .finished:
                        print("[BET_PLACEMENT] ✅ Booking code request completed")
                    case .failure(let error):
                        print("[BET_PLACEMENT] ❌ Booking code creation failed: \(error)")
                        self.showBookingCodeError(from: viewController)
                    }
                },
                receiveValue: { [weak self, weak viewController] response in
                    guard let self = self, let viewController = viewController else { return }

                    print("[BET_PLACEMENT] 🎉 Booking code created: \(response.code)")
                    if let message = response.message {
                        print("[BET_PLACEMENT]   Message: \(message)")
                    }

                    // Show share sheet with booking code
                    self.shareBetslip(code: response.code, from: viewController)
                }
            )
            .store(in: &cancellables)
    }

    private func shareBetslip(code: String, from viewController: UIViewController) {
        // Present the ShareBookingCodeView instead of immediate share sheet
        let shareViewModel = ShareBookingCodeViewModel(bookingCode: code)
        let shareViewController = ShareBookingCodeViewController(viewModel: shareViewModel)
        viewController.present(shareViewController, animated: true)
    }

    private func showBookingCodeError(from viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Booking Code Error",
            message: "Failed to create booking code",
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )

        alert.addAction(okAction)
        viewController.present(alert, animated: true)
    }
    
    public func showBetslipErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Bet Placement Error",
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )
        
        alert.addAction(okAction)
        
        // Present the alert from the betslip view controller
        betslipViewController?.present(alert, animated: true)
    }
    
}
