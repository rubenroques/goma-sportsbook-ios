//
//  BetSuccessViewModelProtocol.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import GomaUI

/// Protocol defining the interface for BetSuccessViewController ViewModels
public protocol BetSuccessViewModelProtocol {
    /// Status notification view model for displaying success information
    var statusNotificationViewModel: StatusNotificationViewModelProtocol { get }
} 