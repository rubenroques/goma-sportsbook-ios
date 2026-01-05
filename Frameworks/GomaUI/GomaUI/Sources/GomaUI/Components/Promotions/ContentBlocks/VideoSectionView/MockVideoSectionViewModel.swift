//
//  MockVideoSectionViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 13/03/2025.
//

import Foundation

public class MockVideoSectionViewModel: VideoSectionViewModelProtocol {
    
    public let videoURL: URL?
    
    public init(videoURL: URL?) {
        self.videoURL = videoURL
    }
}

// MARK: - Mock Presets
extension MockVideoSectionViewModel {
    
    public static var defaultMock: MockVideoSectionViewModel {
        // Using a sample video URL for testing
        let sampleVideoURL = URL(string: "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4")
        return MockVideoSectionViewModel(videoURL: sampleVideoURL)
    }
    
    public static var validUrlMock: MockVideoSectionViewModel {
        let validURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        return MockVideoSectionViewModel(videoURL: validURL)
    }
    
    public static var invalidUrlMock: MockVideoSectionViewModel {
        return MockVideoSectionViewModel(videoURL: nil)
    }
}
