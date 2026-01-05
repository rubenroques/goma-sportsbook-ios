//
//  MockImageBlockViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 12/03/2025.
//

import Foundation

public class MockImageBlockViewModel: ImageBlockViewModelProtocol {
    
    public let imageUrl: String
    
    public init(imageUrl: String) {
        self.imageUrl = imageUrl
    }
}

// MARK: - Mock Presets
extension MockImageBlockViewModel {
    
    public static var defaultMock: MockImageBlockViewModel {
        return MockImageBlockViewModel(imageUrl: "https://example.com/promo-image.jpg")
    }
    
    public static var validUrlMock: MockImageBlockViewModel {
        return MockImageBlockViewModel(imageUrl: "https://picsum.photos/400/200")
    }
    
    public static var invalidUrlMock: MockImageBlockViewModel {
        return MockImageBlockViewModel(imageUrl: "invalid-url")
    }
}
