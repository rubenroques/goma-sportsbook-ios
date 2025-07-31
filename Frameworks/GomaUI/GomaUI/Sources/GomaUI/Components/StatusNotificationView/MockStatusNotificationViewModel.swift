//
//  MockStatusNotificationViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 11/06/2025.
//

import Foundation
import UIKit
import Combine

public final class MockStatusNotificationViewModel: StatusNotificationViewModelProtocol {
    
    private let dataSubject: CurrentValueSubject<StatusNotificationData, Never>
    
    public var data: StatusNotificationData {
        dataSubject.value
    }
    
    public var dataPublisher: AnyPublisher<StatusNotificationData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public init(data: StatusNotificationData) {
        self.dataSubject = CurrentValueSubject(data)
    }
    
    public func configure(with data: StatusNotificationData) {
        dataSubject.send(data)
    }
}

// MARK: - Factory Methods
public extension MockStatusNotificationViewModel {
    
    static var successMock: MockStatusNotificationViewModel {
        let data = StatusNotificationData(
            type: .success,
            message: "Deposit Successful 🤑"
        )
        
        return MockStatusNotificationViewModel(data: data)
    }
    
    static var errorMock: MockStatusNotificationViewModel {
        let data = StatusNotificationData(
            type: .error,
            message: "Transaction Failed 😞"
        )
        
        return MockStatusNotificationViewModel(data: data)
    }
    
    static var warningMock: MockStatusNotificationViewModel {
        let data = StatusNotificationData(
            type: .warning,
            message: "Low Balance Warning ⚠️"
        )
        
        return MockStatusNotificationViewModel(data: data)
    }
    
}
