//
//  MockStackViewBlockViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit

public class MockStackViewBlockViewModel: StackViewBlockViewModelProtocol {
    
    public let views: [UIView]
    
    public init(views: [UIView]) {
        self.views = views
    }
}

// MARK: - Mock Presets
extension MockStackViewBlockViewModel {
    
    public static var defaultMock: MockStackViewBlockViewModel {
        let titleView = TitleBlockView(viewModel: MockTitleBlockViewModel.defaultMock)
        let descriptionView = DescriptionBlockView(viewModel: MockDescriptionBlockViewModel.defaultMock)
        
        return MockStackViewBlockViewModel(views: [titleView, descriptionView])
    }
    
    public static var multipleViewsMock: MockStackViewBlockViewModel {
        let titleView = TitleBlockView(viewModel: MockTitleBlockViewModel.defaultMock)
        let descriptionView = DescriptionBlockView(viewModel: MockDescriptionBlockViewModel.defaultMock)
        let bulletView1 = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.defaultMock)
        let bulletView2 = BulletItemBlockView(viewModel: MockBulletItemBlockViewModel.shortMock)
        
        return MockStackViewBlockViewModel(views: [titleView, descriptionView, bulletView1, bulletView2])
    }
    
    public static var singleViewMock: MockStackViewBlockViewModel {
        let titleView = TitleBlockView(viewModel: MockTitleBlockViewModel.defaultMock)
        
        return MockStackViewBlockViewModel(views: [titleView])
    }
}
