//
//  MockVideoBlockViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 14/03/2025.
//

import Foundation

public class MockVideoBlockViewModel: VideoBlockViewModelProtocol {
    
    public let videoURL: URL?
    
    public init(videoURL: URL?) {
        self.videoURL = videoURL
    }
}

// MARK: - Mock Presets
extension MockVideoBlockViewModel {
    
    public static var defaultMock: MockVideoBlockViewModel {
        // Using a sample video URL for testing
        let sampleVideoURL = URL(string: "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4")
        return MockVideoBlockViewModel(videoURL: sampleVideoURL)
    }
    
    public static var validUrlMock: MockVideoBlockViewModel {
        let validURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        return MockVideoBlockViewModel(videoURL: validURL)
    }
    
    public static var invalidUrlMock: MockVideoBlockViewModel {
        return MockVideoBlockViewModel(videoURL: nil)
    }
}
