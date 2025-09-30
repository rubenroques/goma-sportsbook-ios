//
//  MockListBlockViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit

public class MockListBlockViewModel: ListBlockViewModelProtocol {
    
    public let iconUrl: String
    public let views: [UIView]
    
    public init(iconUrl: String, views: [UIView]) {
        self.iconUrl = iconUrl
        self.views = views
    }
}

// MARK: - Mock Presets
extension MockListBlockViewModel {
    
    public static var defaultMock: MockListBlockViewModel {
        let bulletView1 = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.defaultMock)
        let bulletView2 = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.shortMock)
        
        return MockListBlockViewModel(
            iconUrl: "https://example.com/icon.jpg",
            views: [bulletView1, bulletView2]
        )
    }
    
    public static var withIconMock: MockListBlockViewModel {
        let bulletView1 = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.defaultMock)
        let bulletView2 = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.longMock)
        
        return MockListBlockViewModel(
            iconUrl: "https://picsum.photos/40/40",
            views: [bulletView1, bulletView2]
        )
    }
    
    public static var noIconMock: MockListBlockViewModel {
        let bulletView1 = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.defaultMock)
        
        return MockListBlockViewModel(
            iconUrl: "",
            views: [bulletView1]
        )
    }
}
