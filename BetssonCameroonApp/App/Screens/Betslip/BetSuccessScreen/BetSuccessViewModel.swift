//
//  BetSuccessViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import GomaUI

public final class BetSuccessViewModel: BetSuccessViewModelProtocol {
    
    // MARK: - Child View Models
    public let statusNotificationViewModel: StatusNotificationViewModelProtocol
    
    // MARK: - Initialization
    public init() {
        // Initialize status notification view model with success state
        let statusNotificationData = StatusNotificationData(type: .success, message: "Bet Placed", icon: "success_circle_icon")
        
        self.statusNotificationViewModel = MockStatusNotificationViewModel(data: statusNotificationData)
        
    }
} 
