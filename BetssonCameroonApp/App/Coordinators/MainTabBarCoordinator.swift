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
import SharedModels

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
    
    private var cancellables = Set<AnyCancellable>()
    
    //
    // MARK: - Initialization
    
    init(navigationController: UINavigationController, environment: Environment) {
        self.navigationController = navigationController
        self.environment = environment
    }
    
    // MARK: - Coordinator Protocol
    
    func start() {
        // Create the main screen structure (equivalent to Router.showPostLoadingFlow)
        let adaptiveTabBarViewModel = AdaptiveTabBarViewModel.defaultConfiguration
        let viewModel = MainTabBarViewModel(
            userSessionStore: environment.userSessionStore,
            adaptiveTabBarViewModel: adaptiveTabBarViewModel
        )
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

        container.onSupportRequested = { [weak self] in
            self?.openSupportURL()
        }

        container.onDebugScreenRequested = { [weak self] in
            self?.showPerformanceDebugScreen()
        }

        self.mainTabBarViewController = mainTabBarViewController
        navigationController.setViewControllers([container], animated: false)
        
        environment.userSessionStore.passwordChanged
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.presentAuthenticationDirectly(isLogin: true)
            })
            .store(in: &cancellables)
        
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
    
    func showNextUpEventsScreen(withContextChange: Bool = false) {
        let isLoggedIn = environment.userSessionStore.loggedUserProfile != nil
        print("[SessionExpiredDebug] 📍 showNextUpEventsScreen() - User logged in: \(isLoggedIn), withContextChange: \(withContextChange)")

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

            coordinator.onShowBannerURL = { [weak self] url, target in
                self?.openBannerURL(url, target: target)
            }

            nextUpEventsCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
            
            // Apply current filters to the new coordinator
            coordinator.updateFilters(currentFilters)
        }
        
        // Show the screen through MainTabBarViewController
        if let viewController = nextUpEventsCoordinator?.viewController {
            mainTabBarViewController?.showNextUpEventsScreen(with: viewController, withContextChange: withContextChange)
        }
        
        // Refresh if needed
        print("[SessionExpiredDebug] 🔄 Calling nextUpEventsCoordinator.refresh() - User logged in: \(environment.userSessionStore.loggedUserProfile != nil)")
        nextUpEventsCoordinator?.refresh()
    }
    
    func showInPlayEventsScreen(withContextChange: Bool = false) {
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
            
            coordinator.onShowCasinoTab = { [weak self] quickLinkType in
                self?.navigateToCasinoFromQuickLink(quickLinkType)
            }

            coordinator.onShowBannerURL = { [weak self] url, target in
                self?.openBannerURL(url, target: target)
            }

            inPlayEventsCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
            
            // Apply current filters to the new coordinator
            coordinator.updateFilters(currentFilters)
        }
        
        // Show the screen through MainTabBarViewController
        if let viewController = inPlayEventsCoordinator?.viewController {
            mainTabBarViewController?.showInPlayEventsScreen(with: viewController, withContextChange: withContextChange)
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

        matchDetailsViewModel.onNavigateToNextUpWithCountry = { [weak self] countryId in
            guard let self = self else { return }

            let filters = AppliedEventsFilters(
                sportId: self.currentFilters.sportId,
                timeFilter: .all,
                sortType: .popular,
                leagueFilter: .allInCountry(countryId: countryId)
            )

            self.applyFilters(filters)
            self.navigationController.popViewController(animated: true)
            self.showNextUpEventsScreen(withContextChange: true)
        }

        matchDetailsViewModel.onNavigateToNextUpWithLeague = { [weak self] leagueId in
            guard let self = self else { return }

            let filters = AppliedEventsFilters(
                sportId: self.currentFilters.sportId,
                timeFilter: .all,
                sortType: .popular,
                leagueFilter: .singleLeague(id: leagueId)
            )

            self.applyFilters(filters)
            self.navigationController.popViewController(animated: true)
            self.showNextUpEventsScreen(withContextChange: true)
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
    
    func showLogin() {
        if let onShowLogin = onShowLogin {
            onShowLogin()
        } else {
            // Temporary fallback - implement authentication presentation directly
            // This should be removed once parent coordinator implements onShowLogin
            presentAuthenticationDirectly(isLogin: true)
        }
        print("🚀 RootTabBarCoordinator: Login requested")
    }
    
    func showRegistration() {
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
    
    private func showBetslip(rebetSuccessCount: Int? = nil, rebetFailCount: Int? = nil) {
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
            navigationController.present(viewController, animated: true) { [weak self] in
                // Show alert after betslip is presented if there were rebet failures
                if let successCount = rebetSuccessCount, let failCount = rebetFailCount {
                    self?.showRebetPartialFailureAlert(
                        successCount: successCount,
                        failCount: failCount,
                        on: viewController
                    )
                }
            }
        }
        
        print("🚀 MainCoordinator: Presented betslip modal")
    }
    
    private func showRebetPartialFailureAlert(successCount: Int, failCount: Int, on viewController: UIViewController) {
        let message = localized("partial_rebet_description")
        
        let alert = UIAlertController(
            title: localized("partial_rebet"),
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: localized("ok"), style: .default)
        alert.addAction(okAction)
        
        viewController.present(alert, animated: true)
    }

    // MARK: - Banner URL Handling

    private func openBannerURL(_ urlString: String, target: String?) {
        // Check if it's an internal deep link
        if let route = parseURLToRoute(urlString) {
            handleRoute(route)
            return
        }

        // Otherwise, treat as external URL
        openExternalURL(urlString)
    }

    private func parseURLToRoute(_ urlString: String) -> Route? {
        // Handle relative paths or app scheme URLs as internal deep links
        guard let url = URL(string: urlString) else { return nil }

        // Check for app-specific schemes
        if url.scheme == "betssoncm" || url.scheme == "app" {
            return parseDeepLinkPath(url.path)
        }

        // Check for relative paths (starting with /)
        if urlString.hasPrefix("/") {
            return parseDeepLinkPath(urlString)
        }

        // Check for internal web URLs - redirect internally instead of opening browser
        if let host = url.host?.lowercased(), Self.isInternalWebDomain(host) {
            let path = Self.stripLanguagePrefix(from: url.path)
            return parseDeepLinkPath(path)
        }

        // Not an internal deep link
        return nil
    }

    // MARK: - Internal Web Domain Handling

    /// Web domains that should be handled internally instead of opening in browser.
    /// Add new domains here when needed (e.g., for different markets or environments).
    private static let internalWebDomains: Set<String> = [
        "betssonem.com",
        "www.betssonem.com"
    ]

    private static func isInternalWebDomain(_ host: String) -> Bool {
        internalWebDomains.contains(host.lowercased())
    }

    private static func stripLanguagePrefix(from path: String) -> String {
        // Remove language prefixes like /en/, /fr/, /pt/ from the path
        // Pattern matches: /en, /en/, /fr, /fr/, etc. at the start of the path
        let languagePrefixPattern = #"^/(en|fr|pt|es|de)(/|$)"#
        guard let regex = try? NSRegularExpression(pattern: languagePrefixPattern, options: .caseInsensitive) else {
            return path
        }
        let range = NSRange(path.startIndex..., in: path)
        let stripped = regex.stringByReplacingMatches(in: path, options: [], range: range, withTemplate: "/")
        return stripped.isEmpty ? "/" : stripped
    }

    private func parseDeepLinkPath(_ path: String) -> Route? {
        let components = path.components(separatedBy: "/").filter { !$0.isEmpty }

        guard !components.isEmpty else { return nil }

        switch components[0].lowercased() {
        case "deposit":
            return .deposit
        case "promotions":
            return .promotions
        case "bonus":
            return .bonus
        case "event", "match":
            if components.count > 1 {
                return .event(id: components[1])
            }
        case "competition":
            if components.count > 1 {
                return .competition(id: components[1])
            }
        case "register", "signup":
            return .register
        case "login", "signin":
            return .login
        case "sports":
            return .sportsHome
        case "live":
            return .liveGames
        case "casino":
            if components.count > 1 && components[1].lowercased() == "virtuals" {
                return .casinoVirtuals
            }
            return .casinoHome
        case "mybets", "my-bets":
            return .myBets
        default:
            break
        }

        return nil
    }

    private func handleRoute(_ route: Route) {
        switch route {
        case .deposit:
            presentDepositFlow()
        case .promotions:
            showPromotionsScreen()
        case .bonus:
            showPromotionsScreen()
        case .event(let matchId):
            navigateToMatchDetail(withId: matchId)
        case .competition:
            break
        case .register:
            showRegistration()
        case .login:
            showLogin()
        case .sportsHome:
            showNextUpEventsScreen()
        case .liveGames:
            showInPlayEventsScreen()
        case .myBets:
            showMyBetsScreen()
        case .casinoHome:
            showCasinoHomeScreen()
        case .casinoVirtuals:
            showCasinoVirtualSportsScreen()
        case .casinoGame(let gameId):
            showCasinoGameScreen(gameId: gameId)
        case .casinoSearch, .sportsSearch:
            showSearchScreen()
        case .none:
            break
        }
    }

    private func showCasinoGameScreen(gameId: String) {
        // First ensure casino home is shown, then open the game
        showCasinoHomeScreen()
        traditionalCasinoCoordinator?.showGamePrePlay(gameId: gameId)
    }

    private func navigateToMatchDetail(withId matchId: String) {
        // Try to find the match in active coordinators
        if let match = inPlayEventsCoordinator?.findMatch(withId: matchId) {
            showMatchDetail(match: match)
        } else if let match = nextUpEventsCoordinator?.findMatch(withId: matchId) {
            showMatchDetail(match: match)
        } else {
            print("MainTabBarCoordinator: Match not found for deep link: \(matchId)")
        }
    }

    private func openExternalURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { success in
                if !success {
                    print("MainTabBarCoordinator: Failed to open URL: \(urlString)")
                }
            }
        }
    }

    // MARK: - Temporary Authentication Implementation
    // TODO: Remove this once parent coordinator implements authentication closures
    private func presentAuthenticationDirectly(isLogin: Bool) {
        if isLogin {
            var phoneLoginViewModel = PhoneLoginViewModel()
            let phoneLoginViewController = PhoneLoginViewController(viewModel: phoneLoginViewModel)
            let authNavigationController = AppCoordinator.navigationController(with: phoneLoginViewController)
            navigationController.present(authNavigationController, animated: true)
        } else {
            presentRegistrationWithFirstDepositFlow()
        }
    }
    
    // MARK: - Registration with First Deposit Flow
    
    private func presentRegistrationWithFirstDepositFlow() {
        var phoneRegistrationViewModel: PhoneRegistrationViewModelProtocol = PhoneRegistrationViewModel()
        
        // Setup registration success callback to trigger first deposit flow
        phoneRegistrationViewModel.showBonusOnRegister = { [weak self] in
            self?.showFirstDepositPromotionsAfterRegistration()
        }
        
        let phoneRegistrationViewController = PhoneRegistrationViewController(viewModel: phoneRegistrationViewModel)
        let authNavigationController = AppCoordinator.navigationController(with: phoneRegistrationViewController)
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
        
        // Create and start BonusCoordinator
        let bonusCoordinator = BonusCoordinator(
            navigationController: navigationController,
            servicesProvider: environment.servicesProvider,
            displayType: .register
        )
        
        // Setup callbacks
        bonusCoordinator.onDepositComplete = { [weak self] in
            print("🏦 ProfileWalletCoordinator: Deposit completed from bonus")
            // Refresh user wallet after deposit
            self?.environment.userSessionStore.refreshUserWallet()
        }
        
        bonusCoordinator.onTermsURLRequested = { urlString in
            print("📄 ProfileWalletCoordinator: Terms URL requested: \(urlString)")
            // URL is already opened in the coordinator
        }
        
        bonusCoordinator.onBonusDismiss = { [weak self] in
            self?.removeChildCoordinator(bonusCoordinator)
        }
        
        bonusCoordinator.onDepositBonusRequested = { [weak self] bonusCode in
            self?.removeChildCoordinator(bonusCoordinator)
            self?.presentDepositFlow(bonusCode: bonusCode)
        }
        
        bonusCoordinator.onDepositBonusSkipRequested = { [weak self] in
            self?.removeChildCoordinator(bonusCoordinator)
            self?.presentDepositFlow()
        }
        
        // Add as child coordinator
        addChildCoordinator(bonusCoordinator)
        
        // Start the coordinator
        bonusCoordinator.start()
        
        print("🎁 RootTabBarCoordinator: Started BonusCoordinator")
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
        currentFilters.sportId = FilterIdentifier(stringValue: sport.id)
        
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
        
    func showMyBetsScreen() {
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
            
            coordinator.onNavigateToBetslip = { [weak self] successCount, failCount in
                self?.showBetslip(rebetSuccessCount: successCount, rebetFailCount: failCount)
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
    
    func showSearchScreen() {
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
    
    func showPromotionsScreen() {
        // Create and start PromotionsCoordinator
        let promotionsCoordinator = PromotionsCoordinator(
            navigationController: navigationController,
            environment: environment
        )
        
        // Setup TopBar container callbacks to delegate to MainTabBarCoordinator
        promotionsCoordinator.onLoginRequested = { [weak self] in
            self?.showLogin()
        }
        
        promotionsCoordinator.onRegistrationRequested = { [weak self] in
            self?.showRegistration()
        }
        
        promotionsCoordinator.onProfileRequested = { [weak self] in
            self?.showProfile()
        }
        
        promotionsCoordinator.onDepositRequested = { [weak self] in
            self?.presentDepositFlow()
        }
        
        promotionsCoordinator.onWithdrawRequested = { [weak self] in
            self?.presentWithdrawFlow()
        }
        
        // Add as child coordinator for proper lifecycle management
        addChildCoordinator(promotionsCoordinator)
        
        // Start the coordinator (which will handle the entire promotions flow)
        promotionsCoordinator.start()
        
        print("🚀 MainTabBarCoordinator: Started PromotionsCoordinator")
    }
    
    func showCasinoHomeScreen() {
        // Lazy loading: only create coordinator when needed
        if traditionalCasinoCoordinator == nil {
            let coordinator = CasinoCoordinator(
                navigationController: self.navigationController,
                environment: self.environment,
                lobbyType: .casino
            )

            // Set up navigation closures
            coordinator.onShowGamePlay = { [weak self] gameId in
                print(" Casino: Game play started for game: \(gameId)")
                // Additional game play handling if needed
            }

            coordinator.onShowSportsQuickLinkScreen = { [weak self] quickLinkType in
                self?.navigateToSportsFromQuickLinkType(quickLinkType: quickLinkType)
            }

            coordinator.onDepositRequested = { [weak self] in
                self?.presentDepositFlow()
            }

            coordinator.onLoginRequested = { [weak self] in
                self?.showLogin()
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
    
    func showCasinoVirtualSportsScreen() {
        // Lazy loading: only create coordinator when needed
        if virtualSportsCasinoCoordinator == nil {
            let coordinator = CasinoCoordinator(
                navigationController: self.navigationController,
                environment: self.environment,
                lobbyType: .virtuals
            )

            // Set up navigation closures
            coordinator.onShowGamePlay = { [weak self] gameId in
                print("Virtual Sports: Game play started for game: \(gameId)")
                // Additional game play handling if needed
            }

            coordinator.onShowSportsQuickLinkScreen = { [weak self] quickLinkType in
                self?.navigateToSportsFromQuickLinkType(quickLinkType: quickLinkType)
            }

            coordinator.onDepositRequested = { [weak self] in
                self?.presentDepositFlow()
            }

            coordinator.onLoginRequested = { [weak self] in
                self?.showLogin()
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
    
    func showCasinoAviatorGameScreen() {

        if traditionalCasinoCoordinator == nil {
            let coordinator = CasinoCoordinator(
                navigationController: self.navigationController,
                environment: self.environment,
                lobbyType: .casino
            )

            // Set up navigation closures
            coordinator.onShowGamePlay = { [weak self] gameId in
                print(" Casino: Game play started for game: \(gameId)")
                // Additional game play handling if needed
            }

            coordinator.onShowSportsQuickLinkScreen = { [weak self] quickLinkType in
                self?.navigateToSportsFromQuickLinkType(quickLinkType: quickLinkType)
            }

            coordinator.onDepositRequested = { [weak self] in
                self?.presentDepositFlow()
            }

            coordinator.onLoginRequested = { [weak self] in
                self?.showLogin()
            }

            traditionalCasinoCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
            coordinator.showAviatorGame()
        }
        else {
            traditionalCasinoCoordinator?.showAviatorGame()
        }

        // Show the screen through MainTabBarViewController
        if let viewController = traditionalCasinoCoordinator?.viewController {
            mainTabBarViewController?.showCasinoAviatorGameScreen(with: viewController)
        }

        // Refresh if needed
        traditionalCasinoCoordinator?.refresh()
    }
    
    func showCasinoSearchScreen() {
        // Lazy loading: only create coordinator when needed
        if casinoSearchCoordinator == nil {
            let coordinator = CasinoSearchCoordinator(
                navigationController: self.navigationController,
                servicesProvider: environment.servicesProvider,
                userSessionStore: environment.userSessionStore
            )

            coordinator.onLoginRequested = { [weak self] in
                self?.showLogin()
            }

            coordinator.onDepositRequested = { [weak self] in
                self?.presentDepositFlow()
            }

            casinoSearchCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
        }
        
        if let viewController = casinoSearchCoordinator?.viewController {
            mainTabBarViewController?.showCasinoSearchScreen(with: viewController)
        }
        
        casinoSearchCoordinator?.refresh()
    }
    
    private func showCasinoSlotsGamesScreen() {

        if traditionalCasinoCoordinator == nil {
            let coordinator = CasinoCoordinator(
                navigationController: self.navigationController,
                environment: self.environment,
                lobbyType: .casino
            )

            // Set up navigation closures
            coordinator.onShowGamePlay = { [weak self] gameId in
                print(" Casino: Game play started for game: \(gameId)")
                // Additional game play handling if needed
            }

            coordinator.onShowSportsQuickLinkScreen = { [weak self] quickLinkType in
                self?.navigateToSportsFromQuickLinkType(quickLinkType: quickLinkType)
            }

            coordinator.onDepositRequested = { [weak self] in
                self?.presentDepositFlow()
            }

            coordinator.onLoginRequested = { [weak self] in
                self?.showLogin()
            }

            traditionalCasinoCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
//            coordinator.showCategoryGamesList(categoryId: "Lobby1$videoslots", categoryTitle: "videoslots")
            coordinator.showSlotsGames()
        }
        else {
            traditionalCasinoCoordinator?.showSlotsGames()
        }

        // Show the screen through MainTabBarViewController
        if let viewController = traditionalCasinoCoordinator?.viewController {
            mainTabBarViewController?.showCasinoSlotsGamesScreen(with: viewController)
        }

        // Refresh if needed
        traditionalCasinoCoordinator?.refresh()
    }
    
    private func showCasinoCrashGamesScreen() {

        if traditionalCasinoCoordinator == nil {
            let coordinator = CasinoCoordinator(
                navigationController: self.navigationController,
                environment: self.environment,
                lobbyType: .casino
            )

            // Set up navigation closures
            coordinator.onShowGamePlay = { [weak self] gameId in
                print(" Casino: Game play started for game: \(gameId)")
                // Additional game play handling if needed
            }

            coordinator.onShowSportsQuickLinkScreen = { [weak self] quickLinkType in
                self?.navigateToSportsFromQuickLinkType(quickLinkType: quickLinkType)
            }

            coordinator.onDepositRequested = { [weak self] in
                self?.presentDepositFlow()
            }

            coordinator.onLoginRequested = { [weak self] in
                self?.showLogin()
            }

            traditionalCasinoCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
//            coordinator.showCategoryGamesList(categoryId: "Lobby1$crashgames", categoryTitle: "CRASHGAMES")
            coordinator.showCrashGames()
        }
        else {
            traditionalCasinoCoordinator?.showCrashGames()
        }

        // Show the screen through MainTabBarViewController
        if let viewController = traditionalCasinoCoordinator?.viewController {
            mainTabBarViewController?.showCasinoCrashGamesScreen(with: viewController)
        }

        // Refresh if needed
        traditionalCasinoCoordinator?.refresh()
    }
    
    // MARK: - Banking Flow Methods
    
    func presentDepositFlow(bonusCode: String? = nil) {
        let bankingCoordinator = BankingCoordinator.forDeposit(
            navigationController: navigationController,
            client: environment.servicesProvider
        )
        
        bankingCoordinator.bonusCode = bonusCode
        
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

    // MARK: - Support Methods

    private func openSupportURL() {
        let supportURL = environment.linksProvider.links.getURL(for: .helpCenter)

        guard !supportURL.isEmpty, let url = URL(string: supportURL) else {
            print("❌ MainTabBarCoordinator: Invalid support URL: '\(supportURL)'")
            return
        }

        guard UIApplication.shared.canOpenURL(url) else {
            print("❌ MainTabBarCoordinator: Cannot open URL: \(supportURL)")
            return
        }

        UIApplication.shared.open(url, options: [:]) { success in
            if success {
                print("✅ MainTabBarCoordinator: Opened support URL: \(supportURL)")
            } else {
                print("❌ MainTabBarCoordinator: Failed to open support URL")
            }
        }
    }

    private func showPerformanceDebugScreen() {
        let debugViewController = PerformanceDebugViewController()
        debugViewController.modalPresentationStyle = .fullScreen
        navigationController.present(debugViewController, animated: true)
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
        
        switch quickLinkType {
        case .aviator:
            self.showCasinoAviatorGameScreen()
        case .virtual:
            self.showCasinoVirtualSportsScreen()
        case .slots:
            self.showCasinoSlotsGamesScreen()
        case .crash:
            self.showCasinoCrashGamesScreen()
        case .promos:
            self.showPromotionsScreen()
        default:
            break
        }
    }
    
    private func navigateToSportsFromQuickLinkType(quickLinkType: QuickLinkType) {
        
        switch quickLinkType {
        case .sports:
            if let viewController = self.nextUpEventsCoordinator?.viewController {
                mainTabBarViewController?.showNextUpEventsScreen(with: viewController, withContextChange: true)
            }
            else {
                self.showNextUpEventsScreen(withContextChange: true)
            }
        case .live:
            if let viewController = self.inPlayEventsCoordinator?.viewController {
                mainTabBarViewController?.showInPlayEventsScreen(with: viewController, withContextChange: true)
            }
            else {
                self.showInPlayEventsScreen(withContextChange: true)
            }
        case .favourites:
            // TODO: Show favourites when available
            if let viewController = self.nextUpEventsCoordinator?.viewController {
                mainTabBarViewController?.showNextUpEventsScreen(with: viewController, withContextChange: true)
            }
            else {
                self.showNextUpEventsScreen(withContextChange: true)
            }
            var currentFilters = self.currentFilters
            currentFilters.sortType = .favorites
            self.applyFilters(currentFilters)

        case .lite:
            // TODO: Show lite(?) when available
            break
        case .promos:
            if let viewController = self.nextUpEventsCoordinator?.viewController {
                mainTabBarViewController?.showNextUpEventsScreen(with: viewController, withContextChange: true)
            }
            else {
                self.showNextUpEventsScreen(withContextChange: true)
            }
            
            self.showPromotionsScreen()
        default:
            break
        }
    }
}
