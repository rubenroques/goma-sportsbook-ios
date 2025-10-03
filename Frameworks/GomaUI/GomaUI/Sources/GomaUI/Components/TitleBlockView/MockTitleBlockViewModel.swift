//
//  MockTitleBlockViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 12/03/2025.
//

import Foundation

public class MockTitleBlockViewModel: TitleBlockViewModelProtocol {
    
    public let title: String
    public let isCentered: Bool
    
    public init(title: String, isCentered: Bool = true) {
        self.title = title
        self.isCentered = isCentered
    }
}

// MARK: - Mock Presets
extension MockTitleBlockViewModel {
    
    public static var defaultMock: MockTitleBlockViewModel {
        return MockTitleBlockViewModel(title: "Welcome Bonus")
    }
    
    public static var centeredMock: MockTitleBlockViewModel {
        return MockTitleBlockViewModel(title: "Centered Title", isCentered: true)
    }
    
    public static var leftAlignedMock: MockTitleBlockViewModel {
        return MockTitleBlockViewModel(title: "Left Aligned Title", isCentered: false)
    }
    
    public static var longTitleMock: MockTitleBlockViewModel {
        return MockTitleBlockViewModel(title: "Amazing Welcome Bonus Promotion")
    }
}
