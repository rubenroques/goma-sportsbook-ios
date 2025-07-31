import Combine
import UIKit

// MARK: - Data Models
public struct CasinoGameCardData: Equatable, Hashable, Identifiable {
    public let id: String           // gameId
    public let name: String         // gameName  
    public let gameURL: String      // for game launch
    public let imageURL: String?    // game image
    public let rating: Double       // 0.0 to 5.0
    
    public init(
        id: String,
        name: String,
        gameURL: String,
        imageURL: String? = nil,
        rating: Double
    ) {
        self.id = id
        self.name = name
        self.gameURL = gameURL
        self.imageURL = imageURL
        self.rating = max(0.0, min(5.0, rating)) // Clamp between 0-5
    }
}

// MARK: - Display State
public struct CasinoGameCardDisplayState: Equatable {
    public let isLoading: Bool
    public let imageLoadingFailed: Bool
    
    public init(
        isLoading: Bool = false,
        imageLoadingFailed: Bool = false
    ) {
        self.isLoading = isLoading
        self.imageLoadingFailed = imageLoadingFailed
    }
    
    public static let loading = CasinoGameCardDisplayState(isLoading: true, imageLoadingFailed: false)
    public static let normal = CasinoGameCardDisplayState(isLoading: false, imageLoadingFailed: false)
    public static let imageError = CasinoGameCardDisplayState(isLoading: false, imageLoadingFailed: true)
}

// MARK: - View Model Protocol
public protocol CasinoGameCardViewModelProtocol: AnyObject {
    // Main display state publisher
    var displayStatePublisher: AnyPublisher<CasinoGameCardDisplayState, Never> { get }
    
    // Individual property publishers for fine-grained updates
    var gameNamePublisher: AnyPublisher<String, Never> { get }
    var imageURLPublisher: AnyPublisher<String?, Never> { get }
    var ratingPublisher: AnyPublisher<Double, Never> { get }
    
    // Read-only properties
    var gameId: String { get }
    var gameURL: String { get }
    
    // Image loading callbacks
    func imageLoadingFailed()
    func imageLoadingSucceeded()
}