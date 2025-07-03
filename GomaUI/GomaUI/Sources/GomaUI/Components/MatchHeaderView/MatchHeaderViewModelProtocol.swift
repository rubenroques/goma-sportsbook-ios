import Combine
import UIKit


// MARK: - Data Models
public struct MatchHeaderData: Equatable, Hashable {
    public let id: String
    public let competitionName: String
    public let countryFlagImageName: String?
    public let sportIconImageName: String?
    public let isFavorite: Bool
    public let matchTime: String?
    public let isLive: Bool

    public init(
        id: String,
        competitionName: String,
        countryFlagImageName: String? = nil,
        sportIconImageName: String? = nil,
        isFavorite: Bool = false,
        matchTime: String? = nil,
        isLive: Bool = false
    ) {
        self.id = id
        self.competitionName = competitionName
        self.countryFlagImageName = countryFlagImageName
        self.sportIconImageName = sportIconImageName
        self.isFavorite = isFavorite
        self.matchTime = matchTime
        self.isLive = isLive
    }
}


// MARK: - Image Resolver Protocol
public protocol MatchHeaderImageResolver {
    func countryFlagImage(for countryCode: String) -> UIImage?
    func sportIconImage(for sportId: String) -> UIImage?
    func favoriteIcon(isFavorite: Bool) -> UIImage?
    func liveIndicatorIcon() -> UIImage?
}

// MARK: - Default Image Resolver
public struct DefaultMatchHeaderImageResolver: MatchHeaderImageResolver {
    public init() {}
    
    public func countryFlagImage(for countryCode: String) -> UIImage? {
        return UIImage(systemName: "globe")
    }
    
    public func sportIconImage(for sportId: String) -> UIImage? {
        return UIImage(systemName: "soccerball")
    }
    
    public func favoriteIcon(isFavorite: Bool) -> UIImage? {
        let starSymbol = isFavorite ? "star.fill" : "star"
        let configuration = UIImage.SymbolConfiguration(weight: .semibold)
        return UIImage(systemName: starSymbol, withConfiguration: configuration)?.withRenderingMode(.alwaysTemplate)
    }
    
    public func liveIndicatorIcon() -> UIImage? {
        return UIImage(systemName: "play.fill")?.withRenderingMode(.alwaysTemplate)
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

    // Actions
    func toggleFavorite()
    
    func updateCompetitionName(_ name: String)
    func updateCountryFlag(_ imageName: String?)
    func updateSportIcon(_ imageName: String?)
    func updateMatchTime(_ time: String?)
    func updateIsLive(_ isLive: Bool)
} 
