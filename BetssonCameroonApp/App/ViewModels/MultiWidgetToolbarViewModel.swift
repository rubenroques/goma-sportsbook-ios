import Foundation
import Combine
import GomaUI

final class MultiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol {
    
    // MARK: - Properties
    
    private let displayStateSubject: CurrentValueSubject<MultiWidgetToolbarDisplayState, Never>
    var displayStatePublisher: AnyPublisher<MultiWidgetToolbarDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }
    
    // Configuration and state
    private let config: MultiWidgetToolbarConfig
    private var currentState: LayoutState
    
    // Widget view models
    // This is required by the protocol and used by MultiWidgetToolbarView
    // to update the wallet balance
    var walletViewModel: MockWalletWidgetViewModel? {
        didSet {
            // Apply pending balance update if any
            if let pendingBalance = pendingWalletBalance {
                walletViewModel?.updateBalance(CurrencyFormater.formatWalletAmount(pendingBalance))
                pendingWalletBalance = nil
                print("💰 MultiWidgetToolbarViewModel: Applied pending wallet balance: \(pendingBalance)")
            }
        }
    }
    
    // Store pending balance update if wallet view model not yet assigned
    private var pendingWalletBalance: Double?
    
    // MARK: - Initialization
    
    init(config: MultiWidgetToolbarConfig? = nil, initialState: LayoutState = .loggedOut) {
        // Use provided config or create default config
        self.config = config ?? Self.createDefaultConfig()
        self.currentState = initialState
        
        // Create initial display state
        let initialDisplayState = Self.createDisplayState(from: self.config, for: initialState)
        self.displayStateSubject = CurrentValueSubject(initialDisplayState)
    }
    
    // MARK: - MultiWidgetToolbarViewModelProtocol
    
    func selectWidget(id: String) {
        print("🔧 MultiWidgetToolbarViewModel: Widget selected: \(id)")
        // Handle widget selection - this could trigger navigation or other actions
        // In a real implementation, this might use delegates or closures
    }
    
    func setLayoutState(_ state: LayoutState) {
        guard state != currentState else { return }
        
        currentState = state
        let newDisplayState = Self.createDisplayState(from: config, for: state)
        displayStateSubject.send(newDisplayState)
        
        print("🔧 MultiWidgetToolbarViewModel: Layout state changed to: \(state)")
    }
    
    func setWalletBalance(balance: Double) {
        if let walletViewModel = walletViewModel {
            // Update the wallet view model if it exists
            walletViewModel.updateBalance(CurrencyFormater.formatWalletAmount(balance))
            print("💰 MultiWidgetToolbarViewModel: Wallet balance updated to: \(balance)")
            pendingWalletBalance = nil
        } else {
            // Store the balance to apply when wallet view model is assigned
            pendingWalletBalance = balance
            print("💰 MultiWidgetToolbarViewModel: Wallet balance stored for later update: \(balance)")
        }
    }
    
    // MARK: - Helper Methods
    
    private static func createDisplayState(from config: MultiWidgetToolbarConfig, for state: LayoutState) -> MultiWidgetToolbarDisplayState {
        let stateKey = state.rawValue
        
        // Get layout config for current state
        guard let layoutConfig = config.layouts[stateKey] else {
            // Fallback to empty state if layout not found
            return MultiWidgetToolbarDisplayState(lines: [], currentState: state)
        }
        
        // Create line display data from layout config
        let lines = layoutConfig.lines.map { lineConfig -> LineDisplayData in
            let widgetDisplayData = lineConfig.widgets.compactMap { widgetID -> WidgetDisplayData? in
                guard let widget = config.widgets.first(where: { $0.id == widgetID }) else {
                    return nil
                }
                return WidgetDisplayData(widget: widget)
            }
            
            return LineDisplayData(mode: lineConfig.mode, widgets: widgetDisplayData)
        }
        
        return MultiWidgetToolbarDisplayState(lines: lines, currentState: state)
    }
    
    // MARK: - Default Configuration
    
    private static func createDefaultConfig() -> MultiWidgetToolbarConfig {
        // Define widgets
        let widgets: [Widget] = [
            // Logo
            Widget(
                id: "logo",
                type: .image,
                src: "default_brand_horizontal",
                alt: "Betsson"
            ),
            
            // Wallet
            Widget(
                id: "wallet",
                type: .wallet,
                details: [
                    WidgetDetail(isButton: true, container: "balanceContainer", route: "/balance"),
                    WidgetDetail(isButton: true, container: "depositContainer", label: "DEPOSIT", route: "/deposit")
                ]
            ),
            
            // Avatar
            Widget(
                id: "avatar",
                type: .avatar,
                route: "/user",
                container: "avatarContainer"
            ),
            
            // Support
            Widget(
                id: "support",
                type: .support
            ),
            
            // Language Switcher
            Widget(
                id: "language",
                type: .languageSwitcher
            ),
            
            // Login Button
            Widget(
                id: "loginButton",
                type: .loginButton,
                route: "/login",
                container: "loginContainer",
                label: "LOGIN"
            ),
            
            // Join Now Button
            Widget(
                id: "joinButton",
                type: .signUpButton,
                route: "/register",
                container: "registerContainer",
                label: "JOIN NOW"
            ),
            
            // Flexible space
            Widget(
                id: "flexSpace",
                type: .space
            )
        ]
        
        // Define layouts
        let layouts: [String: LayoutConfig] = [
            LayoutState.loggedIn.rawValue: LayoutConfig(
                lines: [
                    // Just one row for logged in - logo, space, wallet, avatar
                    LineConfig(mode: .flex, widgets: ["logo", "flexSpace", "wallet", "avatar"])
                ]
            ),
            LayoutState.loggedOut.rawValue: LayoutConfig(
                lines: [
                    // Top row - logo, flexible space, support, language
                    LineConfig(mode: .flex, widgets: ["logo", "flexSpace", "support", "language"]),
                    // Bottom row - login and join now buttons (equal width)
                    LineConfig(mode: .split, widgets: ["loginButton", "joinButton"])
                ]
            )
        ]
        
        // Create config
        return MultiWidgetToolbarConfig(
            name: "topbar",
            widgets: widgets,
            layouts: layouts
        )
    }
}
