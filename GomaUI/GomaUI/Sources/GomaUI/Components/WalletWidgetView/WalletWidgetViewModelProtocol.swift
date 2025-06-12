//
//  WalletWidgetViewModelProtocol.swift
//  GomaUI
//

import Combine
import UIKit

// MARK: - Data Models
public struct WalletWidgetData: Equatable, Hashable {
    public let id: String
    public let balance: String
    public let depositButtonTitle: String
    
    public init(id: String, balance: String, depositButtonTitle: String = "DEPOSIT") {
        self.id = id
        self.balance = balance
        self.depositButtonTitle = depositButtonTitle
    }
}

// MARK: - Display State
public struct WalletWidgetDisplayState: Equatable {
    public let walletData: WalletWidgetData
    
    public init(walletData: WalletWidgetData) {
        self.walletData = walletData
    }
}

// MARK: - View Model Protocol
public protocol WalletWidgetViewModelProtocol {
    var displayStatePublisher: AnyPublisher<WalletWidgetDisplayState, Never> { get }
    func deposit()
} 