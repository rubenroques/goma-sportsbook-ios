//
//  MockImageSectionViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 13/03/2025.
//

import Foundation

public class MockImageSectionViewModel: ImageSectionViewModelProtocol {
    
    public let imageUrl: String
    
    public init(imageUrl: String) {
        self.imageUrl = imageUrl
    }
}

// MARK: - Mock Presets
extension MockImageSectionViewModel {
    
    public static var defaultMock: MockImageSectionViewModel {
        return MockImageSectionViewModel(imageUrl: "https://example.com/section-image.jpg")
    }
    
    public static var validUrlMock: MockImageSectionViewModel {
        return MockImageSectionViewModel(imageUrl: "https://picsum.photos/600/300")
    }
    
    public static var invalidUrlMock: MockImageSectionViewModel {
        return MockImageSectionViewModel(imageUrl: "invalid-url")
    }
}
