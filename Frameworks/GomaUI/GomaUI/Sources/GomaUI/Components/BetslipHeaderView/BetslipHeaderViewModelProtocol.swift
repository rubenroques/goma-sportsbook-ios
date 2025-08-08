//
//  BetslipHeaderViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 06/08/2025.
//

import Foundation
import UIKit
import Combine

// MARK: - Data Models

/// Represents the state of the betslip header view
public enum BetslipHeaderState: Equatable {
    case notLoggedIn
    case loggedIn(balance: String)
}

/// Data model for the betslip header view
public struct BetslipHeaderData: Equatable {
    public let state: BetslipHeaderState
    public let isEnabled: Bool
    
    public init(state: BetslipHeaderState, isEnabled: Bool = true) {
        self.state = state
        self.isEnabled = isEnabled
    }
}

// MARK: - View Model Protocol

/// Protocol defining the interface for BetslipHeaderView ViewModels
public protocol BetslipHeaderViewModelProtocol {
    /// Publisher for the betslip header data
    var dataPublisher: AnyPublisher<BetslipHeaderData, Never> { get }
    
    /// Current data (for immediate access)
    var currentData: BetslipHeaderData { get }
    
    /// Update the header state
    func updateState(_ state: BetslipHeaderState)
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
    
    /// Handle tap on join now button
    func onJoinNowTapped()
    
    /// Handle tap on log in button
    func onLogInTapped()
    
    /// Handle tap on close button
    func onCloseTapped()
} 