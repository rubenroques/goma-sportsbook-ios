import Combine
import UIKit

// MARK: - Data Models
public struct CasinoGameSearchedData: Equatable, Hashable, Identifiable {
    public let id: String
    public let title: String
    public let provider: String?
    public let iconURL: String?     // square icon image (114x114)

    public init(
        id: String,
        title: String,
        provider: String? = nil,
        iconURL: String? = nil
    ) {
        self.id = id
        self.title = title
        self.provider = provider
        self.iconURL = iconURL
    }
}

// MARK: - Display State
public struct CasinoGameSearchedDisplayState: Equatable {
    public let isLoading: Bool
    public let imageLoadingFailed: Bool
    
    public init(
        isLoading: Bool = false,
        imageLoadingFailed: Bool = false
    ) {
        self.isLoading = isLoading
        self.imageLoadingFailed = imageLoadingFailed
    }
    
    public static let loading = CasinoGameSearchedDisplayState(isLoading: true, imageLoadingFailed: false)
    public static let normal = CasinoGameSearchedDisplayState(isLoading: false, imageLoadingFailed: false)
    public static let imageError = CasinoGameSearchedDisplayState(isLoading: false, imageLoadingFailed: true)
}

// MARK: - ViewModel Protocol
public protocol CasinoGameSearchedViewModelProtocol: AnyObject {
    // Inputs
    func didSelect()
    func imageLoadingSucceeded()
    func imageLoadingFailed()
    
    // Outputs
    var dataPublisher: AnyPublisher<CasinoGameSearchedData, Never> { get }
    var displayStatePublisher: AnyPublisher<CasinoGameSearchedDisplayState, Never> { get }
    var onSelected: AnyPublisher<String, Never> { get }
}


