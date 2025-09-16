import Combine

public class MockMatchHeaderViewModel: MatchHeaderViewModelProtocol {
    
    // MARK: - Private Publishers
    private let competitionNameSubject = CurrentValueSubject<String, Never>("")
    private let countryFlagImageNameSubject = CurrentValueSubject<String?, Never>(nil)
    private let sportIconImageNameSubject = CurrentValueSubject<String?, Never>(nil)
    private let isFavoriteSubject = CurrentValueSubject<Bool, Never>(false)
    private let matchTimeSubject = CurrentValueSubject<String?, Never>(nil)
    private let isLiveSubject = CurrentValueSubject<Bool, Never>(false)
    
    // MARK: - Private Visibility Publishers
    private let isCountryFlagVisibleSubject = CurrentValueSubject<Bool, Never>(true)
    private let isSportIconVisibleSubject = CurrentValueSubject<Bool, Never>(true)
    private let isFavoriteButtonVisibleSubject = CurrentValueSubject<Bool, Never>(true)
    
    
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
    
    
    public var matchTimePublisher: AnyPublisher<String?, Never> {
        matchTimeSubject.eraseToAnyPublisher()
    }
    
    public var isLivePublisher: AnyPublisher<Bool, Never> {
        isLiveSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Visibility Publishers
    public var isCountryFlagVisiblePublisher: AnyPublisher<Bool, Never> {
        isCountryFlagVisibleSubject.eraseToAnyPublisher()
    }
    
    public var isSportIconVisiblePublisher: AnyPublisher<Bool, Never> {
        isSportIconVisibleSubject.eraseToAnyPublisher()
    }
    
    public var isFavoriteButtonVisiblePublisher: AnyPublisher<Bool, Never> {
        isFavoriteButtonVisibleSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Action Callback
    public var favoriteToggleCallback: ((Bool) -> Void)?
    
    // MARK: - Initialization
    public init(matchHeaderData: MatchHeaderData) {
        competitionNameSubject.send(matchHeaderData.competitionName)
        countryFlagImageNameSubject.send(matchHeaderData.countryFlagImageName)
        sportIconImageNameSubject.send(matchHeaderData.sportIconImageName)
        isFavoriteSubject.send(matchHeaderData.isFavorite)
        matchTimeSubject.send(matchHeaderData.matchTime)
        isLiveSubject.send(matchHeaderData.isLive)
    }
    
    // MARK: - Actions
    public func toggleFavorite() {
        let newValue = !isFavoriteSubject.value
        isFavoriteSubject.send(newValue)
        favoriteToggleCallback?(newValue)
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
    
    // MARK: - Visibility Actions
    public func setCountryFlagVisible(_ visible: Bool) {
        isCountryFlagVisibleSubject.send(visible)
    }
    
    public func setSportIconVisible(_ visible: Bool) {
        isSportIconVisibleSubject.send(visible)
    }
    
    public func setFavoriteButtonVisible(_ visible: Bool) {
        isFavoriteButtonVisibleSubject.send(visible)
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
                matchTime: "2 May, 14:00",
                isLive: false
            )
        )
    }
    
    /// Header with hidden country flag
    public static var noCountryFlagHeader: MockMatchHeaderViewModel {
        let viewModel = MockMatchHeaderViewModel(
            matchHeaderData: MatchHeaderData(
                id: "no_country_flag",
                competitionName: "International League",
                countryFlagImageName: "GB",
                sportIconImageName: "1",
                isFavorite: false,
                matchTime: "15 May, 20:00",
                isLive: false
            )
        )
        viewModel.setCountryFlagVisible(false)
        return viewModel
    }
    
    /// Header with hidden sport icon
    public static var noSportIconHeader: MockMatchHeaderViewModel {
        let viewModel = MockMatchHeaderViewModel(
            matchHeaderData: MatchHeaderData(
                id: "no_sport_icon",
                competitionName: "Mixed Sports League",
                countryFlagImageName: "US",
                sportIconImageName: "1",
                isFavorite: true,
                matchTime: "20 May, 14:30",
                isLive: false
            )
        )
        viewModel.setSportIconVisible(false)
        return viewModel
    }
    
    /// Header with hidden favorite button
    public static var noFavoriteButtonHeader: MockMatchHeaderViewModel {
        let viewModel = MockMatchHeaderViewModel(
            matchHeaderData: MatchHeaderData(
                id: "no_favorite",
                competitionName: "Corporate League",
                countryFlagImageName: "CA",
                sportIconImageName: "1",
                isFavorite: false,
                matchTime: "25 May, 18:00",
                isLive: false
            )
        )
        viewModel.setFavoriteButtonVisible(false)
        return viewModel
    }
    
    /// Header with only competition name (all icons hidden)
    public static var minimalVisibilityHeader: MockMatchHeaderViewModel {
        let viewModel = MockMatchHeaderViewModel(
            matchHeaderData: MatchHeaderData(
                id: "minimal_visibility",
                competitionName: "Text Only Championship",
                countryFlagImageName: "FR",
                sportIconImageName: "8",
                isFavorite: true,
                matchTime: "30 May, 21:45",
                isLive: false
            )
        )
        viewModel.setCountryFlagVisible(false)
        viewModel.setSportIconVisible(false)
        viewModel.setFavoriteButtonVisible(false)
        return viewModel
    }
} 
