import Combine
import UIKit

public class MockMatchHeaderViewModel: MatchHeaderViewModelProtocol {
    
    // MARK: - Private Publishers
    private let competitionNameSubject = CurrentValueSubject<String, Never>("")
    private let countryFlagImageNameSubject = CurrentValueSubject<String?, Never>(nil)
    private let sportIconImageNameSubject = CurrentValueSubject<String?, Never>(nil)
    private let isFavoriteSubject = CurrentValueSubject<Bool, Never>(false)
    private let visualStateSubject = CurrentValueSubject<MatchHeaderVisualState, Never>(.standard)
    private let matchTimeSubject = CurrentValueSubject<String?, Never>(nil)
    private let isLiveSubject = CurrentValueSubject<Bool, Never>(false)
    
    // Custom image subjects
    private let countryFlagImageSubject = CurrentValueSubject<UIImage?, Never>(nil)
    private let sportIconImageSubject = CurrentValueSubject<UIImage?, Never>(nil)
    
    // MARK: - Public Publishers
    public var competitionNamePublisher: AnyPublisher<String, Never> {
        competitionNameSubject.eraseToAnyPublisher()
    }
    
    public var countryFlagImageNamePublisher: AnyPublisher<String?, Never> {
        countryFlagImageNameSubject.eraseToAnyPublisher()
    }
    
    public var sportIconImageNamePublisher: AnyPublisher<String?, Never> {
        sportIconImageNameSubject.eraseToAnyPublisher()
    }
    
    public var isFavoritePublisher: AnyPublisher<Bool, Never> {
        isFavoriteSubject.eraseToAnyPublisher()
    }
    
    public var visualStatePublisher: AnyPublisher<MatchHeaderVisualState, Never> {
        visualStateSubject.eraseToAnyPublisher()
    }
    
    public var matchTimePublisher: AnyPublisher<String?, Never> {
        matchTimeSubject.eraseToAnyPublisher()
    }
    
    public var isLivePublisher: AnyPublisher<Bool, Never> {
        isLiveSubject.eraseToAnyPublisher()
    }
    
    // Custom image publishers
    public var countryFlagImagePublisher: AnyPublisher<UIImage?, Never> {
        countryFlagImageSubject.eraseToAnyPublisher()
    }
    
    public var sportIconImagePublisher: AnyPublisher<UIImage?, Never> {
        sportIconImageSubject.eraseToAnyPublisher()
    }
    
    public var currentVisualState: MatchHeaderVisualState {
        visualStateSubject.value
    }
    
    // MARK: - Action Callback
    public var favoriteToggleCallback: ((Bool) -> Void)?
    
    // MARK: - Initialization
    public init(matchHeaderData: MatchHeaderData) {
        competitionNameSubject.send(matchHeaderData.competitionName)
        countryFlagImageNameSubject.send(matchHeaderData.countryFlagImageName)
        sportIconImageNameSubject.send(matchHeaderData.sportIconImageName)
        isFavoriteSubject.send(matchHeaderData.isFavorite)
        visualStateSubject.send(matchHeaderData.visualState)
        matchTimeSubject.send(matchHeaderData.matchTime)
        isLiveSubject.send(matchHeaderData.isLive)
    }
    
    // MARK: - Actions
    public func toggleFavorite() {
        let newValue = !isFavoriteSubject.value
        isFavoriteSubject.send(newValue)
        favoriteToggleCallback?(newValue)
    }
    
    public func setVisualState(_ state: MatchHeaderVisualState) {
        visualStateSubject.send(state)
    }
    
    public func updateCompetitionName(_ name: String) {
        competitionNameSubject.send(name)
    }
    
    public func updateCountryFlag(_ imageName: String?) {
        countryFlagImageNameSubject.send(imageName)
    }
    
    public func updateSportIcon(_ imageName: String?) {
        sportIconImageNameSubject.send(imageName)
    }
    
    public func updateMatchTime(_ time: String?) {
        matchTimeSubject.send(time)
    }
    
    public func updateIsLive(_ isLive: Bool) {
        isLiveSubject.send(isLive)
    }
    
    // New methods for custom images
    public func updateCountryFlagImage(_ image: UIImage?) {
        countryFlagImageSubject.send(image)
    }
    
    public func updateSportIconImage(_ image: UIImage?) {
        sportIconImageSubject.send(image)
    }
    
    // MARK: - Convenience Methods
    public func setEnabled(_ enabled: Bool) {
        setVisualState(enabled ? .standard : .disabled)
    }
    
    public func setMinimalMode(_ minimal: Bool) {
        setVisualState(minimal ? .minimal : .standard)
    }
    
    public func setFavoriteOnlyMode(_ favoriteOnly: Bool) {
        setVisualState(favoriteOnly ? .favoriteOnly : .standard)
    }
}

// MARK: - Factory Methods
extension MockMatchHeaderViewModel {
    
    /// Standard Premier League header with all elements visible
    public static var defaultMock: MockMatchHeaderViewModel {
        return MockMatchHeaderViewModel(
            matchHeaderData: MatchHeaderData(
                id: "premier_league",
                competitionName: "League",
                countryFlagImageName: "GB",
                sportIconImageName: "1", // Football icon
                isFavorite: false,
                visualState: .standard,
                matchTime: "16 April, 18:00",
                isLive: false
            )
        )
    }
    
    /// Standard Premier League header with all elements visible
    public static var premierLeagueHeader: MockMatchHeaderViewModel {
        return MockMatchHeaderViewModel(
            matchHeaderData: MatchHeaderData(
                id: "premier_league",
                competitionName: "Premier League",
                countryFlagImageName: "GB",
                sportIconImageName: "1", // Football icon
                isFavorite: false,
                visualState: .standard,
                matchTime: "16 April, 18:00",
                isLive: false
            )
        )
    }
    
    /// La Liga header marked as favorite and live
    public static var laLigaFavoriteHeader: MockMatchHeaderViewModel {
        let viewModel = MockMatchHeaderViewModel(
            matchHeaderData: MatchHeaderData(
                id: "la_liga",
                competitionName: "La Liga",
                countryFlagImageName: "ES",
                sportIconImageName: "1", // Football icon
                isFavorite: true,
                visualState: .standard,
                matchTime: "1st Half, 44 Min",
                isLive: true
            )
        )
        viewModel.favoriteToggleCallback = { isFavorite in
            print("La Liga favorite toggled: \(isFavorite)")
        }
        return viewModel
    }
    
    /// Serie A with basketball sport icon
    public static var serieABasketballHeader: MockMatchHeaderViewModel {
        return MockMatchHeaderViewModel(
            matchHeaderData: MatchHeaderData(
                id: "serie_a_basketball",
                competitionName: "Serie A Basketball",
                countryFlagImageName: "IT",
                sportIconImageName: "8", // Basketball icon
                isFavorite: false,
                visualState: .standard,
                matchTime: "20 April, 19:30",
                isLive: false
            )
        )
    }
    
    /// NBA header in disabled state
    public static var disabledNBAHeader: MockMatchHeaderViewModel {
        return MockMatchHeaderViewModel(
            matchHeaderData: MatchHeaderData(
                id: "nba_disabled",
                competitionName: "NBA",
                countryFlagImageName: "US",
                sportIconImageName: "8", // Basketball icon
                isFavorite: true,
                visualState: .disabled,
                matchTime: "22 April, 02:30",
                isLive: false
            )
        )
    }
    
    /// Minimal mode header - only competition name visible
    public static var minimalModeHeader: MockMatchHeaderViewModel {
        return MockMatchHeaderViewModel(
            matchHeaderData: MatchHeaderData(
                id: "minimal",
                competitionName: "Champions League",
                countryFlagImageName: "EU",
                sportIconImageName: "1", // Football icon
                isFavorite: false,
                visualState: .minimal,
                matchTime: "25 April, 21:00",
                isLive: false
            )
        )
    }
    
    /// Favorite-only mode header - only favorite and competition name visible
    public static var favoriteOnlyHeader: MockMatchHeaderViewModel {
        return MockMatchHeaderViewModel(
            matchHeaderData: MatchHeaderData(
                id: "favorite_only",
                competitionName: "ATP Tennis",
                countryFlagImageName: "FR",
                sportIconImageName: "5", // Tennis icon
                isFavorite: true,
                visualState: .favoriteOnly,
                matchTime: "28 April, 15:00",
                isLive: false
            )
        )
    }
    
    /// Long competition name to test text handling
    public static var longNameHeader: MockMatchHeaderViewModel {
        return MockMatchHeaderViewModel(
            matchHeaderData: MatchHeaderData(
                id: "long_name",
                competitionName: "UEFA Europa Conference League Championship",
                countryFlagImageName: "EU",
                sportIconImageName: "1", // Football icon
                isFavorite: false,
                visualState: .standard,
                matchTime: "30 April, 17:15",
                isLive: false
            )
        )
    }
    
    /// Header with no country flag or sport icon
    public static var basicHeader: MockMatchHeaderViewModel {
        return MockMatchHeaderViewModel(
            matchHeaderData: MatchHeaderData(
                id: "basic",
                competitionName: "Local Championship",
                countryFlagImageName: nil,
                sportIconImageName: nil,
                isFavorite: false,
                visualState: .standard,
                matchTime: "2 May, 14:00",
                isLive: false
            )
        )
    }
} 
