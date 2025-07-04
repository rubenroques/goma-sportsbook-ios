//
//  WalletStatusViewModelProtocol.swift
//  GomaUI
//
//  Created by Claude on 04/07/2025.
//

import Foundation
import Combine

/// Protocol defining the data contract for WalletStatusView
public protocol WalletStatusViewModelProtocol {
    
    // MARK: - Balance Publishers
    /// Publisher for total balance updates
    var totalBalancePublisher: AnyPublisher<String, Never> { get }
    
    /// Publisher for current balance updates
    var currentBalancePublisher: AnyPublisher<String, Never> { get }
    
    /// Publisher for bonus balance updates
    var bonusBalancePublisher: AnyPublisher<String, Never> { get }
    
    /// Publisher for cashback balance updates
    var cashbackBalancePublisher: AnyPublisher<String, Never> { get }
    
    /// Publisher for withdrawable amount updates
    var withdrawableAmountPublisher: AnyPublisher<String, Never> { get }
    
    // MARK: - Button View Models
    /// View model for the deposit button
    var depositButtonViewModel: ButtonViewModelProtocol { get }
    
    /// View model for the withdraw button
    var withdrawButtonViewModel: ButtonViewModelProtocol { get }
}