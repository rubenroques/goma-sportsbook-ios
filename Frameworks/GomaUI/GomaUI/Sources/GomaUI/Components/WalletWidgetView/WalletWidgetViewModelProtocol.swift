//
//  WalletWidgetViewModelProtocol.swift
//  GomaUI
//

import Combine
import UIKit

// MARK: - Data Models
public struct WalletWidgetData: Equatable, Hashable {
    public let id: WidgetTypeIdentifier
    public let balance: String
    public let depositButtonTitle: String

    public init(id: WidgetTypeIdentifier, balance: String, depositButtonTitle: String = LocalizationProvider.string("deposit").uppercased()) {
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
    func updateBalance(_ balance: String)
} 