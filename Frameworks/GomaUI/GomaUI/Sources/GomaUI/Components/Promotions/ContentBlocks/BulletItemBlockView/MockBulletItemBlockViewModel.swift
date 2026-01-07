//
//  MockBulletItemBlockViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 14/03/2025.
//

import Foundation

public class MockBulletItemBlockViewModel: BulletItemBlockViewModelProtocol {
    
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}

// MARK: - Mock Presets
extension MockBulletItemBlockViewModel {
    
    public static var defaultMock: MockBulletItemBlockViewModel {
        return MockBulletItemBlockViewModel(title: "Welcome bonus up to €100")
    }
    
    public static var shortMock: MockBulletItemBlockViewModel {
        return MockBulletItemBlockViewModel(title: "Free spins")
    }
    
    public static var longMock: MockBulletItemBlockViewModel {
        return MockBulletItemBlockViewModel(title: "Get 50 free spins on your first deposit plus a 100% match bonus up to €200")
    }
}
