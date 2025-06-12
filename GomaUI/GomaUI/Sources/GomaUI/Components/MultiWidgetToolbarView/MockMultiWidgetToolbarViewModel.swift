//
//  MockMultiWidgetToolbarViewModel.swift
//  GomaUI
//
//  Created by Claude on 29/08/2023.
//

import Combine
import UIKit

/// Mock implementation of `MultiWidgetToolbarViewModelProtocol` for testing and previews.
final public class MockMultiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol {
    
    // MARK: - Properties
    
    private let displayStateSubject: CurrentValueSubject<MultiWidgetToolbarDisplayState, Never>
    public var displayStatePublisher: AnyPublisher<MultiWidgetToolbarDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    // Configuration and state
    private let config: MultiWidgetToolbarConfig
    private var currentState: LayoutState
    
    // MARK: - Initialization
    
    public init(config: MultiWidgetToolbarConfig, initialState: LayoutState = .loggedOut) {
        self.config = config
        self.currentState = initialState
        
        // Create initial display state
        let initialDisplayState = Self.createDisplayState(from: config, for: initialState)
        self.displayStateSubject = CurrentValueSubject(initialDisplayState)
    }
    
    // MARK: - MultiWidgetToolbarViewModelProtocol
    
    public func selectWidget(id: String) {
        // In a real implementation, this might trigger side effects
        print("Widget selected: \(id)")
        
        // For demonstration purposes, toggle login state if login/logout buttons are tapped
        if id == "loginButton" {
            setLayoutState(.loggedIn)
        } else if id == "avatar" {
            setLayoutState(.loggedOut)
        }
    }
    
    public func setLayoutState(_ state: LayoutState) {
        guard state != currentState else { return }
        
        currentState = state
        let newDisplayState = Self.createDisplayState(from: config, for: state)
        displayStateSubject.send(newDisplayState)
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
}

// MARK: - Mock Factory

extension MockMultiWidgetToolbarViewModel {
    
    public static var defaultMock: MockMultiWidgetToolbarViewModel {
        // Define widgets
        let widgets: [Widget] = [
            // Logo
            Widget(
                id: "logo",
                type: .image,
                src: "https://www.example.com/images/logo.png",
                alt: "Betsson"
            ),
            
            // Wallet
            Widget(
                id: "wallet",
                type: .wallet,
                details: [
                    WidgetDetail(isButton: true, container: "balanceContainer", route: "/balance", icon: "https://www.example.com/images/plus.png"),
                    WidgetDetail(isButton: true, container: "depositContainer", label: "Deposit", route: "/deposit")
                ]
            ),
            
            // Avatar
            Widget(
                id: "avatar",
                type: .avatar,
                route: "/user",
                container: "avatarContainer",
                icon: "https://www.example.com/images/avatar.png"
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
            
            // Join Now Button (renamed from registerButton)
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
        let config = MultiWidgetToolbarConfig(
            name: "topbar",
            widgets: widgets,
            layouts: layouts
        )
        
        return MockMultiWidgetToolbarViewModel(config: config)
    }
    
    public static var complexMock: MockMultiWidgetToolbarViewModel {
        // Define more widgets for a complex version
        var widgets = defaultMock.config.widgets
        
        // Add additional widgets
        let additionalWidgets: [Widget] = [
            // Search
            Widget(
                id: "search",
                type: .button,
                label: "Search",
                icon: "https://www.example.com/images/search.png"
            ),
            
            // Notifications
            Widget(
                id: "notifications",
                type: .button,
                route: "/notifications",
                label: "Notifications",
                icon: "https://www.example.com/images/bell.png"
            )
        ]
        
        widgets.append(contentsOf: additionalWidgets)
        
        // Define complex layouts
        let layouts: [String: LayoutConfig] = [
            LayoutState.loggedIn.rawValue: LayoutConfig(
                lines: [
                    LineConfig(mode: .flex, widgets: ["logo", "search", "flexSpace", "notifications", "wallet", "avatar"])
                ]
            ),
            LayoutState.loggedOut.rawValue: LayoutConfig(
                lines: [
                    LineConfig(mode: .flex, widgets: ["logo", "search", "flexSpace", "support", "language"]),
                    LineConfig(mode: .split, widgets: ["loginButton", "registerButton"])
                ]
            )
        ]
        
        // Create complex config
        let config = MultiWidgetToolbarConfig(
            name: "complex-topbar",
            widgets: widgets,
            layouts: layouts
        )
        
        return MockMultiWidgetToolbarViewModel(config: config)
    }
} 
