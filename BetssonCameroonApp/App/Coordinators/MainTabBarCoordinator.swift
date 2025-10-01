//
//  MainCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 24/07/2025.
//

import UIKit
import Combine
import ServicesProvider
import GomaUI

class MainTabBarCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Properties
    private let environment: Environment
    private var mainTabBarViewController: MainTabBarViewController?
    
    // Filter State Management
    private var currentFilters: AppliedEventsFilters = {
        // Load filters from UserDefaults using Codable extension
        if let savedFilters: AppliedEventsFilters = UserDefaults.standard.codable(forKey: "AppliedEventsFilters") {
            return savedFilters
        }
        return AppliedEventsFilters.defaultFilters
    }()
    
    // MARK: - Navigation Closures
    // Authentication navigation - to be implemented by parent coordinator
    var onShowLogin: (() -> Void)?
    var onShowRegistration: (() -> Void)?
    
    // MARK: - Lazy Screen Coordinators
    // These are only created when the user navigates to the respective tabs
    
    private var nextUpEventsCoordinator: NextUpEventsCoordinator?
    private var inPlayEventsCoordinator: InPlayEventsCoordinator?

    private var myBetsCoordinator: MyBetsCoordinator?

    private var casinoSearchCoordinator: CasinoSearchCoordinator?
    private var sportsSearchCoordinator: SportsSearchCoordinator?

    private var traditionalCasinoCoordinator: CasinoCoordinator?
    private var virtualSportsCasinoCoordinator: CasinoCoordinator?

    private var betslipCoordinator: BetslipCoordinator?
    
    //
    // MARK: - Initialization
    
    init(navigationController: UINavigationController, environment: Environment) {
        self.navigationController = navigationController
        self.environment = environment
    }
    
    // MARK: - Coordinator Protocol
    
    func start() {
        // Create the main screen structure (equivalent to Router.showPostLoadingFlow)
        let viewModel = MainTabBarViewModel(userSessionStore: environment.userSessionStore)
        let mainTabBarViewController = MainTabBarViewController(viewModel: viewModel)
        
        
        // Create TopBar ViewModel
        let topBarViewModel = TopBarContainerViewModel(
            userSessionStore: environment.userSessionStore
        )

        // Wrap in TopBarContainerController
        let container = TopBarContainerController(
            contentViewController: mainTabBarViewController,
            viewModel: topBarViewModel
        )

        // Setup tab selection (stays on mainTabBarViewController)
        mainTabBarViewController.onTabSelected = { [weak self] tabItem in
            self?.handleTabSelection(tabItem)
        }

        mainTabBarViewController.onBetslipRequested = { [weak self] in
            self?.showBetslip()
        }

        // Setup navigation callbacks on container
        container.onLoginRequested = { [weak self] in
            self?.showLogin()
        }

        container.onRegistrationRequested = { [weak self] in
            self?.showRegistration()
        }

        container.onProfileRequested = { [weak self] in
            self?.showProfile()
        }

        container.onDepositRequested = { [weak self] in
            self?.presentDepositFlow()
        }

        container.onWithdrawRequested = { [weak self] in
            self?.presentWithdrawFlow()
        }

        self.mainTabBarViewController = mainTabBarViewController
        navigationController.setViewControllers([container], animated: false)
        
        // Show default screen on startup (NextUpEvents)
        self.showNextUpEventsScreen()
    }
    
    func finish() {
        childCoordinators.removeAll()
        
        // Clean up lazy coordinators
        nextUpEventsCoordinator = nil
        inPlayEventsCoordinator = nil
        myBetsCoordinator = nil
        traditionalCasinoCoordinator = nil
        virtualSportsCasinoCoordinator = nil
        sportsSearchCoordinator = nil
        mainTabBarViewController = nil
        betslipCoordinator = nil
    }
    
    // MARK: - Private Methods
  
        
    // MARK: - Tab Selection Handling
    
    private func handleTabSelection(_ tabItem: TabItem) {
        // Show the selected screen through coordinator
        // MainTabBarViewController will handle hiding other screens internally
        switch tabItem.identifier {
        case .nextUpEvents:
            showNextUpEventsScreen()
        case .inPlayEvents:
            showInPlayEventsScreen()
        case .myBets:
            showMyBetsScreen()
        case .sportsSearch:
            showSearchScreen()
        case .casinoHome:
            showCasinoHomeScreen()
        case .casinoVirtualSports:
            showCasinoVirtualSportsScreen()
        case .casinoAviatorGame:
            showCasinoAviatorGameScreen()
        case .casinoSearch:
            showCasinoSearchScreen()
        case .sportsHome:
            showNextUpEventsScreen() // Map sportsHome to nextUpEvents
        default:
            break
        }
    }
    
    // MARK: - Lazy Screen Loading
    
    private func showNextUpEventsScreen() {
        // Lazy loading: only create coordinator when needed
        if nextUpEventsCoordinator == nil {
            let coordinator = NextUpEventsCoordinator(
                navigationController: self.navigationController,
                environment: self.environment
            )
            
            // Set up navigation closures
            coordinator.onShowMatchDetail = { [weak self] matchId in
                self?.showMatchDetail(match: matchId)
            }
            
            coordinator.onShowSportsSelector = { [weak self] in
                self?.showPreLiveSportsSelector()
            }
            
            coordinator.onShowFilters = { [weak self] in
                self?.showFilters(isLiveMode: false)
            }
            
            coordinator.onShowBetslip = { [weak self] in
                self?.showBetslip()
            }
            
            coordinator.onShowCasinoTab = { [weak self] quickLinkType in
                self?.navigateToCasinoFromQuickLink(quickLinkType)
            }
            
            nextUpEventsCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
            
            // Apply current filters to the new coordinator
            coordinator.updateFilters(currentFilters)
        }
        
        // Show the screen through MainTabBarViewController
        if let viewController = nextUpEventsCoordinator?.viewController {
            mainTabBarViewController?.showNextUpEventsScreen(with: viewController)
        }
        
        // Refresh if needed
        nextUpEventsCoordinator?.refresh()
    }
    
    private func showInPlayEventsScreen() {
        // Lazy loading: only create coordinator when needed
        if inPlayEventsCoordinator == nil {
            let coordinator = InPlayEventsCoordinator(
                navigationController: self.navigationController,
                environment: self.environment
            )
            
            // Set up navigation closures
            coordinator.onShowMatchDetail = { [weak self] match in
                self?.showMatchDetail(match: match)
            }
            
            coordinator.onShowSportsSelector = { [weak self] in
                self?.showLiveSportsSelector()
            }
            
            coordinator.onShowFilters = { [weak self] in
                self?.showFilters(isLiveMode: true)
            }
            
            coordinator.onShowCasinoTab = { [weak self] quickLinkType in
                self?.navigateToCasinoFromQuickLink(quickLinkType)
            }
            
            inPlayEventsCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
            
            // Apply current filters to the new coordinator
            coordinator.updateFilters(currentFilters)
        }
        
        // Show the screen through MainTabBarViewController
        if let viewController = inPlayEventsCoordinator?.viewController {
            mainTabBarViewController?.showInPlayEventsScreen(with: viewController)
        }
        
        // Refresh if needed
        inPlayEventsCoordinator?.refresh()
    }
    
    // MARK: - Navigation Actions
    // These will be implemented based on the existing Router functionality
    
    private func showMatchDetail(match: Match) {
        let matchDetailsViewModel = MatchDetailsTextualViewModel(
            match: match,
            servicesProvider: environment.servicesProvider,
            userSessionStore: environment.userSessionStore  // Pass UserSessionStore for wallet functionality
        )
        
        // Setup navigation closures
        matchDetailsViewModel.onNavigateBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        // Create the clean MatchDetailsTextualViewController (no top bar code)
        let matchDetailsViewController = MatchDetailsTextualViewController(viewModel: matchDetailsViewModel)

        // Create TopBar ViewModel (handles all business logic)
        let topBarViewModel = TopBarContainerViewModel(
            userSessionStore: environment.userSessionStore
        )

        // Wrap in TopBarContainerController
        let container = TopBarContainerController(
            contentViewController: matchDetailsViewController,
            viewModel: topBarViewModel
        )

        // Setup navigation callbacks on container
        container.onLoginRequested = { [weak self] in
            self?.showLogin()
        }

        container.onRegistrationRequested = { [weak self] in
            self?.showRegistration()
        }

        container.onProfileRequested = { [weak self] in
            self?.showProfile()
        }

        container.onDepositRequested = { [weak self] in
            self?.presentDepositFlow()
        }

        container.onWithdrawRequested = { [weak self] in
            self?.presentWithdrawFlow()
        }

        // Setup betslip callback
        matchDetailsViewController.onBetslipRequested = { [weak self] in
            self?.showBetslip()
        }

        // Present the container using navigation stack
        navigationController.pushViewController(container, animated: true)
        print("🚀 MainCoordinator: Navigated to match detail for match: \(match.id)")
    }

    private func showBetDetail(for bet: MyBet) {
        let betDetailViewModel = MyBetDetailViewModel(
            bet: bet,
            servicesProvider: environment.servicesProvider,
            userSessionStore: environment.userSessionStore
        )
        
        // Setup back navigation
        betDetailViewModel.onNavigateBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        // Create the clean MyBetDetailViewController (no top bar code)
        let betDetailViewController = MyBetDetailViewController(viewModel: betDetailViewModel)

        // Create TopBar ViewModel (handles all business logic)
        let topBarViewModel = TopBarContainerViewModel(
            userSessionStore: environment.userSessionStore
        )

        // Wrap in TopBarContainerController
        let container = TopBarContainerController(
            contentViewController: betDetailViewController,
            viewModel: topBarViewModel
        )

        // Setup navigation callbacks on container
        container.onLoginRequested = { [weak self] in
            self?.showLogin()
        }

        container.onRegistrationRequested = { [weak self] in
            self?.showRegistration()
        }

        container.onProfileRequested = { [weak self] in
            self?.showProfile()
        }

        container.onDepositRequested = { [weak self] in
            self?.presentDepositFlow()
        }

        container.onWithdrawRequested = { [weak self] in
            self?.presentWithdrawFlow()
        }

        // Push the container onto navigation stack
        navigationController.pushViewController(container, animated: true)
        print("🎯 RootTabBarCoordinator: Navigated to bet detail for bet: \(bet.identifier)")
    }
   
    private func showPreLiveSportsSelector() {
        // Create fresh SportSelectorViewModel on-demand
        let sportSelectorViewModel = PreLiveSportSelectorViewModel()
        let sportsViewController = SportTypeSelectorViewController(viewModel: sportSelectorViewModel)
        
        // Use SportSelectorViewModel callback to get full Sport object
        sportSelectorViewModel.onSportSelected = { [weak self] sport in
            self?.updateCurrentSport(sport)
            sportsViewController.dismiss()
        }
        
        // Handle cancellation - presenter manages navigation
        sportsViewController.onCancel = {
            sportsViewController.dismiss()
        }
        
        // Present modally from navigationController
        sportsViewController.presentModally(from: navigationController)
        print("🚀 MainCoordinator: Presented sports selector modal")
    }
    
    private func showLiveSportsSelector() {
        // Create fresh SportSelectorViewModel on-demand
        let sportSelectorViewModel = LiveSportSelectorViewModel()
        let sportsViewController = SportTypeSelectorViewController(viewModel: sportSelectorViewModel)
        
        // Use SportSelectorViewModel callback to get full Sport object
        sportSelectorViewModel.onSportSelected = { [weak self] sport in
            self?.updateCurrentSport(sport)
            sportsViewController.dismiss()
        }
        
        // Handle cancellation - presenter manages navigation
        sportsViewController.onCancel = {
            sportsViewController.dismiss()
        }
        
        // Present modally from navigationController
        sportsViewController.presentModally(from: navigationController)
        print("🚀 MainCoordinator: Presented sports selector modal")
    }
    
    private func showFilters(isLiveMode: Bool) {
        // Create filters configuration using stateless approach
        let configuration = CombinedFiltersViewController.createMockFilterConfiguration()

        // Use the stored current filters instead of default
        let combinedFiltersViewController = CombinedFiltersViewController(
            currentFilters: self.currentFilters,
            filterConfiguration: configuration,
            servicesProvider: environment.servicesProvider,
            isLiveMode: isLiveMode,
            onApply: { [weak self] newFilters in
                // Update the current filters in the system
                self?.applyFilters(newFilters)
            }
        )
        
        // Present modally from navigationController
        navigationController.present(combinedFiltersViewController, animated: true)
    }
    
    private func showLogin() {
        if let onShowLogin = onShowLogin {
            onShowLogin()
        } else {
            // Temporary fallback - implement authentication presentation directly
            // This should be removed once parent coordinator implements onShowLogin
            presentAuthenticationDirectly(isLogin: true)
        }
        print("🚀 RootTabBarCoordinator: Login requested")
    }
    
    private func showRegistration() {
        if let onShowRegistration = onShowRegistration {
            onShowRegistration()
        } else {
            // Temporary fallback - implement authentication presentation directly
            // This should be removed once parent coordinator implements onShowRegistration
            presentAuthenticationDirectly(isLogin: false)
        }
        print("🚀 RootTabBarCoordinator: Registration requested")
    }
    
    private func showProfile() {

        // Create and present ProfileWalletCoordinator with closure-based pattern
        let profileCoordinator = ProfileWalletCoordinator(
            navigationController: navigationController,
            servicesProvider: environment.servicesProvider,
            userSessionStore: environment.userSessionStore
        )
        
        // Setup closure-based callbacks
        profileCoordinator.onProfileDismiss = { [weak self] in
            self?.removeChildCoordinator(profileCoordinator)
        }
        
        profileCoordinator.onDepositRequested = { [weak self] in
            print("🚀 RootTabBarCoordinator: Profile requested deposit")
            self?.presentDepositFlow()
        }
        
        profileCoordinator.onWithdrawRequested = { [weak self] in
            print("🚀 RootTabBarCoordinator: Profile requested withdraw") 
            self?.presentWithdrawFlow()
        }
        
        addChildCoordinator(profileCoordinator)
        profileCoordinator.start()
    }
    
    private func showBetslip() {
        if betslipCoordinator == nil {
            let coordinator = BetslipCoordinator(
                navigationController: self.navigationController,
                environment: self.environment
            )
            
            // Set up navigation closures
            coordinator.onCloseBetslip = { [weak self] in
                self?.removeChildCoordinator(coordinator)
                self?.betslipCoordinator = nil
                self?.navigationController.dismiss(animated: true)
            }
            
            coordinator.onShowLogin = { [weak self] in
                self?.removeChildCoordinator(coordinator)
                self?.betslipCoordinator = nil
                self?.navigationController.dismiss(animated: true)
                self?.showLogin()
            }
            
            coordinator.onShowRegistration = { [weak self] in
                self?.removeChildCoordinator(coordinator)
                self?.betslipCoordinator = nil
                self?.navigationController.dismiss(animated: true)
                self?.showRegistration()
            }
            
            betslipCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
        }
        
        if let viewController = betslipCoordinator?.betslipViewController {
            navigationController.present(viewController, animated: true)
        }
        
        print("🚀 MainCoordinator: Presented betslip modal")
    }
    
    // MARK: - Temporary Authentication Implementation
    // TODO: Remove this once parent coordinator implements authentication closures
    private func presentAuthenticationDirectly(isLogin: Bool) {
        if isLogin {
            var phoneLoginViewModel = PhoneLoginViewModel()
            let phoneLoginViewController = PhoneLoginViewController(viewModel: phoneLoginViewModel)
            let authNavigationController = Router.navigationController(with: phoneLoginViewController)
            navigationController.present(authNavigationController, animated: true)
        } else {
            presentRegistrationWithFirstDepositFlow()
        }
    }
    
    // MARK: - Registration with First Deposit Flow
    
    private func presentRegistrationWithFirstDepositFlow() {
        var phoneRegistrationViewModel: PhoneRegistrationViewModelProtocol = PhoneRegistrationViewModel()
        
        // Setup registration success callback to trigger first deposit flow
        phoneRegistrationViewModel.registerComplete = { [weak self] in
            self?.showFirstDepositPromotionsAfterRegistration()
        }
        
        let phoneRegistrationViewController = PhoneRegistrationViewController(viewModel: phoneRegistrationViewModel)
        let authNavigationController = Router.navigationController(with: phoneRegistrationViewController)
        navigationController.present(authNavigationController, animated: true)
        
        print("🚀 RootTabBarCoordinator: Presented registration with first deposit integration")
    }
    
    private func showFirstDepositPromotionsAfterRegistration() {
        // Dismiss the registration screen first
        navigationController.dismiss(animated: true) { [weak self] in
            self?.presentFirstDepositPromotionsFlow()
        }
    }
    
    private func presentFirstDepositPromotionsFlow() {
        let firstDepositCoordinator = FirstDepositPromotionsCoordinator(
            navigationController: navigationController,
            environment: environment
        )
        
        // Setup completion callbacks
        firstDepositCoordinator.onFirstDepositComplete = { [weak self] in
            self?.handleFirstDepositComplete()
        }
        
        firstDepositCoordinator.onFirstDepositSkipped = { [weak self] in
            self?.handleFirstDepositSkipped()
        }
        
        // Add as child coordinator
        addChildCoordinator(firstDepositCoordinator)
        
        // Start the first deposit flow
        firstDepositCoordinator.startFromRegistration()
        
        print("🎁 RootTabBarCoordinator: Started first deposit promotions flow after registration")
    }
    
    private func handleFirstDepositComplete() {
        // User completed first deposit - dismiss flow and return to main app
        navigationController.dismiss(animated: true) { [weak self] in
            self?.cleanupFirstDepositFlow()
            // User is now logged in with first deposit bonus
            print("🎁 RootTabBarCoordinator: First deposit completed - returning to main app")
        }
    }
    
    private func handleFirstDepositSkipped() {
        // User skipped first deposit - dismiss flow and return to main app
        navigationController.dismiss(animated: true) { [weak self] in
            self?.cleanupFirstDepositFlow()
            // User is now logged in without first deposit bonus
            print("🎁 RootTabBarCoordinator: First deposit skipped - returning to main app")
        }
    }
    
    private func cleanupFirstDepositFlow() {
        // Remove any first deposit coordinators from child coordinators
        childCoordinators.removeAll { coordinator in
            coordinator is FirstDepositPromotionsCoordinator
        }
    }
    
    // MARK: - Helper Methods
    
    private func findMatchById(_ matchId: String) -> Match? {
        // Try to find match in NextUpEvents coordinator first
        if let match = nextUpEventsCoordinator?.findMatch(withId: matchId) {
            return match
        }
        
        // Try to find match in InPlayEvents coordinator
        if let match = inPlayEventsCoordinator?.findMatch(withId: matchId) {
            return match
        }
        
        return nil
    }
    
    private func updateCurrentSport(_ sport: Sport) {
        // Update the sport in current filters
        currentFilters.sportId = sport.id
        
        // Update sport in both coordinators if they exist and are active
        nextUpEventsCoordinator?.updateSport(sport)
        inPlayEventsCoordinator?.updateSport(sport)
        sportsSearchCoordinator?.updateSport(sport)
        print("🚀 MainCoordinator: Updated current sport to: \(sport.name) and filters")
    }
    
    private func applyFilters(_ filterSelection: AppliedEventsFilters) {
        // Store the new filters
        self.currentFilters = filterSelection
        print("🚀 MainCoordinator: Applied filters: \(filterSelection)")
        
        // Update filters in child coordinators and refresh with new filters
        nextUpEventsCoordinator?.updateFilters(filterSelection)
        inPlayEventsCoordinator?.updateFilters(filterSelection)
        sportsSearchCoordinator?.updateFilters(filterSelection)
    }
        
    private func showMyBetsScreen() {
        // Lazy loading: only create coordinator when needed
        if myBetsCoordinator == nil {
            let coordinator = MyBetsCoordinator(
                navigationController: self.navigationController,
                environment: self.environment
            )
            
            // Set up navigation closures
            coordinator.onShowLogin = { [weak self] in
                self?.showLogin()
            }
            
            coordinator.onNavigateToBetDetail = { [weak self] bet in
                self?.showBetDetail(for: bet)
            }
            
            myBetsCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
        }
        
        // Show the screen through MainTabBarViewController
        if let viewController = myBetsCoordinator?.viewController {
            mainTabBarViewController?.showMyBetsScreen(with: viewController)
        }
        
        // Refresh if needed
        myBetsCoordinator?.refresh()
    }
    
    private func showSearchScreen() {
        // Lazy loading: only create coordinator when needed
        if sportsSearchCoordinator == nil {
            let coordinator = SportsSearchCoordinator(
                navigationController: self.navigationController,
                environment: self.environment
            )
            
            // Set up navigation closures
            coordinator.onShowMatchDetail = { [weak self] match in
                self?.showMatchDetail(match: match)
            }
            
            coordinator.onShowSportsSelector = { [weak self] in
                self?.showPreLiveSportsSelector()
            }
            
            coordinator.onShowFilters = { [weak self] in
                self?.showFilters(isLiveMode: false)
            }
            
            sportsSearchCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
        }
        
        // Show the screen through RootTabBarViewController
        if let viewController = sportsSearchCoordinator?.viewController {
            mainTabBarViewController?.showSearchScreen(with: viewController)
        }
        
        // Refresh if needed
        sportsSearchCoordinator?.refresh()
    }
    
    private func showCasinoHomeScreen() {
        // Lazy loading: only create coordinator when needed
        if traditionalCasinoCoordinator == nil {
            let coordinator = CasinoCoordinator(
                navigationController: self.navigationController,
                environment: self.environment,
                lobbyType: .casino
            )

            // Set up navigation closures
            coordinator.onShowGamePlay = { [weak self] gameId in
                print("🎰 Casino: Game play started for game: \(gameId)")
                // Additional game play handling if needed
            }

            traditionalCasinoCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
        }

        // Show the screen through MainTabBarViewController
        if let viewController = traditionalCasinoCoordinator?.viewController {
            mainTabBarViewController?.showCasinoHomeScreen(with: viewController)
        }

        // Refresh if needed
        traditionalCasinoCoordinator?.refresh()
    }
    
    private func showCasinoVirtualSportsScreen() {
        // Lazy loading: only create coordinator when needed
        if virtualSportsCasinoCoordinator == nil {
            let coordinator = CasinoCoordinator(
                navigationController: self.navigationController,
                environment: self.environment,
                lobbyType: .virtuals
            )

            // Set up navigation closures
            coordinator.onShowGamePlay = { [weak self] gameId in
                print("🎰 Virtual Sports: Game play started for game: \(gameId)")
                // Additional game play handling if needed
            }

            virtualSportsCasinoCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
        }

        // Get the view controller from coordinator
        guard let viewController = virtualSportsCasinoCoordinator?.viewController else {
            print("⚠️ MainTabBarCoordinator: Virtual Sports Casino Coordinator view controller is nil")
            return
        }

        mainTabBarViewController?.showCasinoVirtualSportsScreen(with: viewController)
        print("🎯 MainTabBarCoordinator: Showed virtual sports screen")
    }
    
    private func showCasinoAviatorGameScreen() {
        let dummyViewController = DummyViewController(displayText: "Aviator")
        mainTabBarViewController?.showCasinoAviatorGameScreen(with: dummyViewController)
    }
    
    private func showCasinoSearchScreen() {
        // Lazy loading: only create coordinator when needed
        if casinoSearchCoordinator == nil {
            let coordinator = CasinoSearchCoordinator(
                navigationController: self.navigationController,
                environment: self.environment
            )
            casinoSearchCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
        }
        
        if let viewController = casinoSearchCoordinator?.viewController {
            mainTabBarViewController?.showCasinoSearchScreen(with: viewController)
        }
        
        casinoSearchCoordinator?.refresh()
    }
    
    // MARK: - Banking Flow Methods
    
    private func presentDepositFlow() {
        let bankingCoordinator = BankingCoordinator.forDeposit(
            navigationController: navigationController,
            client: environment.servicesProvider
        )
        
        setupBankingCoordinatorCallbacks(bankingCoordinator)
        addChildCoordinator(bankingCoordinator)
        bankingCoordinator.start()
    }
    
    private func presentWithdrawFlow() {
        let bankingCoordinator = BankingCoordinator.forWithdraw(
            navigationController: navigationController,
            client: environment.servicesProvider
        )
        
        setupBankingCoordinatorCallbacks(bankingCoordinator)
        addChildCoordinator(bankingCoordinator)
        bankingCoordinator.start()
    }
    
    private func setupBankingCoordinatorCallbacks(_ coordinator: BankingCoordinator) {
        coordinator.onTransactionComplete = { [weak self] in
            print("🏦 RootTabBarCoordinator: Banking transaction completed")
            self?.environment.userSessionStore.refreshUserWallet()
            self?.removeChildCoordinator(coordinator)
        }
        
        coordinator.onTransactionCancel = { [weak self] in
            print("🏦 RootTabBarCoordinator: Banking transaction cancelled")
            self?.removeChildCoordinator(coordinator)
        }
        
        coordinator.onTransactionError = { [weak self] error in
            print("🏦 RootTabBarCoordinator: Banking transaction failed: \(error)")
            self?.removeChildCoordinator(coordinator)
        }
    }
    
    // MARK: - QuickLinks Casino Navigation
    
    private func navigateToCasinoFromQuickLink(_ quickLinkType: QuickLinkType) {
        print("🎰 RootTabBarCoordinator: Navigating to casino from QuickLink - \(quickLinkType.rawValue)")
        
        // First, ensure casino coordinator is loaded
        
        
        switch quickLinkType {
        case .aviator:
            self.showCasinoAviatorGameScreen()
        case .virtual:
            self.showCasinoVirtualSportsScreen()
        case .slots:
            self.showCasinoHomeScreen()
        case .crash:
            self.showCasinoHomeScreen()
        case .promos:
            self.showCasinoHomeScreen()
        default:
            break
        }
    }
}
