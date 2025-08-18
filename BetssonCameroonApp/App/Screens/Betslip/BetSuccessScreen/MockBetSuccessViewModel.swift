//
//  MockBetSuccessViewModel.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import GomaUI

public final class MockBetSuccessViewModel: BetSuccessViewModelProtocol {
    
    // MARK: - Child View Models
    public let statusNotificationViewModel: StatusNotificationViewModelProtocol
    
    // MARK: - Initialization
    public init() {
        // Initialize status notification view model with success state
        self.statusNotificationViewModel = MockStatusNotificationViewModel.successMock
    }
} 
