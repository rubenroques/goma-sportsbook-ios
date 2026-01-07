//
//  MockFloatingOverlayViewModel.swift
//  GomaUI
//
//  Created on 06/04/2025.
//

import Combine
import UIKit

/// Mock implementation of `FloatingOverlayViewModelProtocol` for testing.
final public class MockFloatingOverlayViewModel: FloatingOverlayViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<FloatingOverlayDisplayState, Never>
    public var displayStatePublisher: AnyPublisher<FloatingOverlayDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init(initialState: FloatingOverlayDisplayState = FloatingOverlayDisplayState(mode: .sportsbook, duration: nil, isVisible: false)) {
        self.displayStateSubject = CurrentValueSubject(initialState)
    }
    
    // MARK: - FloatingOverlayViewModelProtocol
    public func show(mode: FloatingOverlayMode, duration: TimeInterval?) {
        let newState = FloatingOverlayDisplayState(
            mode: mode,
            duration: duration,
            isVisible: true
        )
        displayStateSubject.send(newState)
    }
    
    public func hide() {
        let currentState = displayStateSubject.value
        let newState = FloatingOverlayDisplayState(
            mode: currentState.mode,
            duration: currentState.duration,
            isVisible: false
        )
        displayStateSubject.send(newState)
    }
}

// MARK: - Mock Factory
extension MockFloatingOverlayViewModel {
    /// Default sportsbook mode mock
    public static var sportsbookMode: MockFloatingOverlayViewModel {
        return MockFloatingOverlayViewModel(
            initialState: FloatingOverlayDisplayState(
                mode: .sportsbook,
                duration: 3.0,
                isVisible: false
            )
        )
    }
    
    /// Casino mode mock
    public static var casinoMode: MockFloatingOverlayViewModel {
        return MockFloatingOverlayViewModel(
            initialState: FloatingOverlayDisplayState(
                mode: .casino,
                duration: nil,
                isVisible: false
            )
        )
    }
    
    /// Custom mode mock
    public static var customMode: MockFloatingOverlayViewModel {
        let customIcon = UIImage(systemName: "star.fill") ?? UIImage()
        return MockFloatingOverlayViewModel(
            initialState: FloatingOverlayDisplayState(
                mode: .custom(icon: customIcon, message: "Welcome to VIP Lounge ⭐"),
                duration: 5.0,
                isVisible: false
            )
        )
    }
    
    /// Always visible mock (for preview)
    public static var alwaysVisible: MockFloatingOverlayViewModel {
        return MockFloatingOverlayViewModel(
            initialState: FloatingOverlayDisplayState(
                mode: .sportsbook,
                duration: nil,
                isVisible: true
            )
        )
    }
}