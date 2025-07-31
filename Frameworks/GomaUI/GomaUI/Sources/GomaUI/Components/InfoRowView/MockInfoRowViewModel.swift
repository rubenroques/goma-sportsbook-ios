//
//  MockInfoRowViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 11/06/2025.
//

import Foundation
import UIKit
import Combine

public final class MockInfoRowViewModel: InfoRowViewModelProtocol {
    
    private let dataSubject: CurrentValueSubject<InfoRowData, Never>
    
    public var data: InfoRowData {
        dataSubject.value
    }
    
    public var dataPublisher: AnyPublisher<InfoRowData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public init(data: InfoRowData) {
        self.dataSubject = CurrentValueSubject(data)
    }
    
    public func configure(with data: InfoRowData) {
        dataSubject.send(data)
    }
}

// MARK: - Factory Methods
extension MockInfoRowViewModel {
    public static var defaultMock: MockInfoRowViewModel {
        let data = InfoRowData(
            leftText: "Your Deposit",
            rightText: "XAF 1000"
        )
        
        return MockInfoRowViewModel(data: data)
    }
    
    public static var balanceMock: MockInfoRowViewModel {
        let data = InfoRowData(
            leftText: "Account Balance",
            rightText: "XAF 25,000"
        )
        
        return MockInfoRowViewModel(data: data)
    }
    
    public static var customBackgroundMock: MockInfoRowViewModel {
        let data = InfoRowData(
            leftText: "Bonus Balance",
            rightText: "XAF 500",
            leftTextColor: StyleProvider.Color.highlightTertiary,
            rightTextColor: StyleProvider.Color.highlightSecondary,
            backgroundColor: StyleProvider.Color.highlightSecondary.withAlphaComponent(0.1)
        )
        
        return MockInfoRowViewModel(data: data)
    }
}
