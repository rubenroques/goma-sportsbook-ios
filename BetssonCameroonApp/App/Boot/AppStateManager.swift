//
//  AppStateManager.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 24/07/2025.
//

import Foundation
import Combine
import UIKit
import ServicesProvider
import GomaUI
import Reachability

// MARK: - App State Definition

enum AppState: Hashable {
    case initializing
    case splashLoading
    case networkUnavailable                         // No internet connection
    case maintenanceMode(message: String)           // Full screen root
    case updateRequired                             // Undismissible modal
    case updateAvailable                            // Dismissible modal
    case servicesConnecting                         // Parallel loading
    case ready                 // Main app ready
    case error(AppError)
}

enum AppError: Hashable {
    case sportsLoadingFailed
    case serviceConnectionFailed
    case configurationLoadFailed
    case maintenanceModeCheckFailed
}

// MARK: - App State Manager

class AppStateManager {
    
    // MARK: - Published Properties
    
    private var currentStateSubject: CurrentValueSubject<AppState, Never> = .init(.initializing)
    
    // MARK: - Private Properties
    
    private let environment: Environment
    private var cancellables = Set<AnyCancellable>()
    private var reachability: Reachability?
    
    private var sportsDataCancellable: AnyCancellable?
    private var bootTriggerCancellable: AnyCancellable?
    private var themeCancellable: AnyCancellable?
    
    // MARK: - Public Interface
    
    var currentStatePublisher: AnyPublisher<AppState, Never> {
        return self.currentStateSubject.eraseToAnyPublisher()
    }
    
    var currentState: AppState {
        return self.currentStateSubject.value
    }
    
    // MARK: - Initialization
    
    init(environment: Environment) {
        self.environment = environment
        
        setupEnvironment()
        setupSupportedLanguages()
    }
    
    // MARK: - Public Methods
    
    func initialize() {
        print("AppStateManager: Starting initialization")
        currentStateSubject.send(.splashLoading)
        setupNetworkMonitoring()
    }
    
    func retryFromError() {
        guard case .error = currentState else { return }
        initialize()
    }
    
    func dismissAvailableUpdate() {
        guard case .updateAvailable = currentState else { return }
        // Transition back to ready state - we need to get sports data from somewhere
        // For now, we'll re-trigger the services loading
        loadServicesInParallel()
    }
    
    // MARK: - Private Methods
    
    private func setupEnvironment() {
        // Setup GomaUI components (from Bootstrap.swift:64-79)
        setupGomaUIComponents()
        
        // Connect business settings socket for maintenance monitoring
        environment.businessSettingsSocket.connectAfterAuth()
    }
    
    private func setupNetworkMonitoring() {
        reachability = try? Reachability()
        
        guard let reachability = reachability else {
            currentStateSubject.send(.error(.configurationLoadFailed))
            return
        }
        
        reachability.whenReachable = { [weak self] _ in
            DispatchQueue.main.async {
                print("AppStateManager: Network is available, proceeding with setup")
                // Network is available, proceed with maintenance mode monitoring
                self?.setupMaintenanceModeMonitoring()
            }
        }
        
        reachability.whenUnreachable = { [weak self] _ in
            DispatchQueue.main.async {
                print("AppStateManager: Network unavailable")
                self?.currentStateSubject.send(.networkUnavailable)
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            self.currentStateSubject.send(.error(.configurationLoadFailed))
        }
    }
    
    private func setupSupportedLanguages() {
        // Force the target supported languages
        let targetSupportedLanguages = TargetVariables.supportedLanguages.map(\.languageCode)
        UserDefaults.standard.set(targetSupportedLanguages, forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    private func setupMaintenanceModeMonitoring() {
        // Boot-time maintenance check only (from Bootstrap.swift:40-53)
        // This blocks app progression during startup
        bootTriggerCancellable = environment.businessSettingsSocket.maintenanceModePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] maintenanceModeType in
                switch maintenanceModeType {
                case .enabled(let message):
                    self?.currentStateSubject.send(.maintenanceMode(message: message))
                case .disabled:
                    print("AppStateManager: Maintenance mode disabled, starting services")
                    self?.bootTriggerCancellable?.cancel()
                    self?.bootTriggerCancellable = nil
                    
                    self?.loadServicesInParallel()
                case .unknown:
                    break
                }
            })
    }
    
    func startRuntimeMonitoring() {
        // Runtime maintenance monitoring (from Router.swift:101-114)
        // Only started after main app is shown
        environment.businessSettingsSocket.maintenanceModePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] maintenanceMode in
                switch maintenanceMode {
                case .enabled(let message):
                    self?.currentStateSubject.send(.maintenanceMode(message: message))
                case .disabled:
                    // When maintenance ends, restore to ready state
                    self?.restoreFromRuntimeMaintenance()
                case .unknown:
                    break
                }
            }
            .store(in: &cancellables)

        // Runtime version monitoring (from Router.swift:116-140)
        // Only started after main app is shown
        environment.businessSettingsSocket.requiredVersionPublisher
            .receive(on: DispatchQueue.main)
            .delay(for: 5, scheduler: DispatchQueue.main)
            .sink { [weak self] serverVersion in
                guard
                    let currentVersion = Bundle.main.versionNumber,
                    let serverRequiredVersion = serverVersion.required,
                    let serverCurrentVersion = serverVersion.current
                else {
                    return
                }

                if currentVersion.compare(serverRequiredVersion, options: .numeric) == .orderedAscending {
                    self?.currentStateSubject.send(.updateRequired)
                }
                else if currentVersion.compare(serverCurrentVersion, options: .numeric) == .orderedAscending {
                    self?.currentStateSubject.send(.updateAvailable)
                }
                else {
                    // version ok
                    print("Correct version installed")
                }
            }
            .store(in: &cancellables)
    }
    
    private func restoreFromRuntimeMaintenance() {
        // When runtime maintenance ends, restore to ready state with current sports data
        self.currentStateSubject.send(.ready)
    }
    
    private func setupGomaUIComponents() {
        // Setup GomaUI components StyleProviderColors (from Bootstrap.swift:66-72)
        themeCancellable = ThemeService.shared.themePublisher
            .removeDuplicates()
            .map(StyleProviderColors.create(fromTheme:))
            .receive(on: DispatchQueue.main)
            .sink { (styleProviderColors: StyleProviderColors) in
                GomaUI.StyleProvider.customize(colors: styleProviderColors)
            }

        // Setup GomaUI components Fonts (from Bootstrap.swift:75-78)
        GomaUI.StyleProvider.setFontProvider({ (type: StyleProvider.FontType, size: CGFloat) -> UIFont in
            let appFont = AppFont.AppFontType.fontTypeFrom(styleProviderFontType: type)
            return AppFont.with(type: appFont, size: size)
        })
    }
    
    private func loadServicesInParallel() {
        print("AppStateManager: Starting parallel service loading")
        self.currentStateSubject.send(.servicesConnecting)
        
        // Start theme loading (from SplashInformativeViewController:79)
        print("AppStateManager: Starting theme loading")
        ThemeService.shared.fetchThemeFromServer()
        
        
        // Start configuration loading (from SplashInformativeViewController:82)
        print("AppStateManager: Starting configuration loading")
        environment.presentationConfigurationStore.loadConfiguration()
        
        // Wait for events connection, then perform health check before sports data
        print("AppStateManager: Monitoring events connection state")
        environment.servicesProvider.eventsConnectionStatePublisher
            .removeDuplicates()
            .filter { connectorState in
                print("AppStateManager: Events connection state: \(connectorState)")
                return connectorState == .connected
            }
            .sink { [weak self] _ in
                print("AppStateManager: Events connected, performing health check")
                // self?.performHealthCheckAndLoadSports()
                self?.environment.sportsStore.requestInitialSportsData()

            }
            .store(in: &cancellables)

        // Monitor sports data loading (from SplashInformativeViewController:84-99)
        print("AppStateManager: Monitoring sports data loading")
        self.sportsDataCancellable = environment.sportsStore.activeSportsPublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("AppStateManager: activeSportsPublisher completion \(completion)")
            } receiveValue: { [weak self] sportsLoadingState in
                switch sportsLoadingState {
                case .idle:
                    print("AppStateManager: Sports data idle")
                    break
                case .loading:
                    print("AppStateManager: Sports data loading...")
                    break
                case .loaded(let sportsData):
                    print("AppStateManager: Sports data loaded successfully (\(sportsData.count) sports)")
                    // We just need to have a valid list of sports, we can than ingore the updates
                    // and cancel the subscription
                    self?.sportsDataCancellable?.cancel()
                    self?.sportsDataCancellable = nil
                    
                    self?.transitionToReady(sports: sportsData)
                case .failed:
                    print("AppStateManager: Sports data loading failed")
                    self?.currentStateSubject.send(.error(.sportsLoadingFailed))
                }
            }

        // Connect modules for authenticated users (from Bootstrap:101-112)
        Publishers.CombineLatest(environment.servicesProvider.bettingConnectionStatePublisher,
                                 environment.userSessionStore.userProfilePublisher)
            .filter({ connectorState, userSession in
                return connectorState == .connected && userSession != nil
            })
            .map({ _ in return () })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.environment.favoritesManager.getUserFavorites()
            })
            .store(in: &cancellables)
        
        // Connect service provider (from Bootstrap:85-98)
        print("AppStateManager: Connecting services provider")
        environment.servicesProvider.connect()
        print("AppStateManager: Starting betslip manager")
        environment.betslipManager.start()
    }
    
    private func performHealthCheckAndLoadSports() {
        environment.servicesProvider.checkServicesHealth()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("AppStateManager: Health check failed: \(error)")
                    if case .maintenanceMode(let message) = error {
                        self?.currentStateSubject.send(.maintenanceMode(message: message))
                    } else {
                        self?.currentStateSubject.send(.error(.serviceConnectionFailed))
                    }
                }
            }, receiveValue: { [weak self] isHealthy in
                if isHealthy {
                    print("AppStateManager: Health check passed, requesting sports data")
                    self?.environment.sportsStore.requestInitialSportsData()
                } else {
                    print("AppStateManager: Health check failed")
                    self?.currentStateSubject.send(.error(.serviceConnectionFailed))
                }
            })
            .store(in: &cancellables)
    }
    
    private func transitionToReady(sports: [Sport]) {
        print("AppStateManager: Transitioning to ready state with \(sports.count) sports")
        // TODO: Check for app updates here using Firebase Remote Config
        // For now, we'll just transition to ready state
        self.currentStateSubject.send(.ready)
    }
    
    // MARK: - Cleanup
    
    deinit {
        bootTriggerCancellable?.cancel()
        themeCancellable?.cancel()
        cancellables.removeAll()
    }
}
