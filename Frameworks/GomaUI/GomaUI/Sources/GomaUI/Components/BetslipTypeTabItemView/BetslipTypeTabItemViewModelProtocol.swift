//
//  BetslipTypeTabItemViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 14/08/2025.
//

import UIKit

// MARK: - View Model Protocol
public protocol BetslipTypeTabItemViewModelProtocol {
    // Content properties
    var title: String { get }
    var icon: String { get }
    var isSelected: Bool { get }
    
    // Actions
    var onTabTapped: (() -> Void)? { get set }
} 