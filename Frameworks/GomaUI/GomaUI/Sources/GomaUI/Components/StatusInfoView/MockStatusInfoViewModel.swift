//
//  MockStatusInfoViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 30/06/2025.
//

import Foundation

public class MockStatusInfoViewModel: StatusInfoViewModelProtocol {
    public let statusInfo: StatusInfo

    public init(statusInfo: StatusInfo) {
        self.statusInfo = statusInfo
    }
}

public extension MockStatusInfoViewModel {
    
    static var successMock: MockStatusInfoViewModel {
        let statusInfo = StatusInfo(
            icon: "checkmark.circle.fill",
            title: "Password Changed Successfully",
            message: "Your password has been updated. You can now log in with your new password."
        )
        
        return MockStatusInfoViewModel(statusInfo: statusInfo)
    }
    
}
