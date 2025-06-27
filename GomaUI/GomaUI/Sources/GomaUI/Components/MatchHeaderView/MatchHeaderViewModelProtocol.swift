import Combine
import UIKit

// MARK: - Visual State
public enum MatchHeaderVisualState: Equatable {
    case standard                // Show all available elements
    case disabled               // Gray out everything, disable interactions
    case favoriteOnly          // Only show favorite and competition name, hide other icons
    case minimal               // Hide all icons, show only competition name
}

// MARK: - Data Models
public struct MatchHeaderData: Equatable, Hashable {
    public let id: String
    public let competitionName: String
    public let countryFlagImageName: String?
    public let sportIconImageName: String?
    public let isFavorite: Bool
    public let visualState: MatchHeaderVisualState
    public let matchTime: String?
    public let isLive: Bool

    public init(
        id: String,
        competitionName: String,
        countryFlagImageName: String? = nil,
        sportIconImageName: String? = nil,
        isFavorite: Bool = false,
        visualState: MatchHeaderVisualState = .standard,
        matchTime: String? = nil,
        isLive: Bool = false
    ) {
        self.id = id
        self.competitionName = competitionName
        self.countryFlagImageName = countryFlagImageName
        self.sportIconImageName = sportIconImageName
        self.isFavorite = isFavorite
        self.visualState = visualState
        self.matchTime = matchTime
        self.isLive = isLive
    }
}

// MARK: - Hashable Conformance for MatchHeaderVisualState
extension MatchHeaderVisualState: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .standard:
            hasher.combine("standard")
        case .disabled:
            hasher.combine("disabled")
        case .favoriteOnly:
            hasher.combine("favoriteOnly")
        case .minimal:
            hasher.combine("minimal")
        }
    }
}

// MARK: - View Model Protocol
public protocol MatchHeaderViewModelProtocol {
    // Content publishers (can change independently)
    var competitionNamePublisher: AnyPublisher<String, Never> { get }
    var countryFlagImageNamePublisher: AnyPublisher<String?, Never> { get }
    var sportIconImageNamePublisher: AnyPublisher<String?, Never> { get }
    var isFavoritePublisher: AnyPublisher<Bool, Never> { get }
    var matchTimePublisher: AnyPublisher<String?, Never> { get }
    var isLivePublisher: AnyPublisher<Bool, Never> { get }
    
    // Custom image publishers for direct UIImage support
    var countryFlagImagePublisher: AnyPublisher<UIImage?, Never> { get }
    var sportIconImagePublisher: AnyPublisher<UIImage?, Never> { get }

    // Unified visual state publisher and current state access
    var visualStatePublisher: AnyPublisher<MatchHeaderVisualState, Never> { get }
    var currentVisualState: MatchHeaderVisualState { get }

    // Actions
    func toggleFavorite()
    
    func setVisualState(_ state: MatchHeaderVisualState)
    func updateCompetitionName(_ name: String)
    func updateCountryFlag(_ imageName: String?)
    func updateSportIcon(_ imageName: String?)
    func updateMatchTime(_ time: String?)
    func updateIsLive(_ isLive: Bool)
    
    // New methods for custom images
    func updateCountryFlagImage(_ image: UIImage?)
    func updateSportIconImage(_ image: UIImage?)

    // Convenience methods for common state transitions
    func setEnabled(_ enabled: Bool)
    func setMinimalMode(_ minimal: Bool)
    func setFavoriteOnlyMode(_ favoriteOnly: Bool)
} 
