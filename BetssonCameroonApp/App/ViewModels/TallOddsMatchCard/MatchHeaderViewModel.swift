import Foundation
import Combine
import GomaUI

final class MatchHeaderViewModel: MatchHeaderViewModelProtocol {
    // MARK: - Private Properties
    private let competitionNameSubject: CurrentValueSubject<String, Never>
    private let countryFlagImageNameSubject: CurrentValueSubject<String?, Never>
    private let sportIconImageNameSubject: CurrentValueSubject<String?, Never>
    private let isFavoriteSubject: CurrentValueSubject<Bool, Never>
    private let matchTimeSubject: CurrentValueSubject<String?, Never>
    private let isLiveSubject: CurrentValueSubject<Bool, Never>
    private let favoritesManager: FavoritesManager
    private let matchId: String
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published Properties
    public var competitionNamePublisher: AnyPublisher<String, Never> {
        return self.competitionNameSubject.eraseToAnyPublisher()
    }
    
    public var countryFlagImageNamePublisher: AnyPublisher<String?, Never> {
        return self.countryFlagImageNameSubject.eraseToAnyPublisher()
    }
    
    public var sportIconImageNamePublisher: AnyPublisher<String?, Never> {
        return self.sportIconImageNameSubject.eraseToAnyPublisher()
    }
    
    public var isFavoritePublisher: AnyPublisher<Bool, Never> {
        return self.isFavoriteSubject.eraseToAnyPublisher()
    }
    
    public var matchTimePublisher: AnyPublisher<String?, Never> {
        return self.matchTimeSubject.eraseToAnyPublisher()
    }
    
    public var isLivePublisher: AnyPublisher<Bool, Never> {
        return self.isLiveSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Visibility Publishers
    public var isCountryFlagVisiblePublisher: AnyPublisher<Bool, Never> {
        return Just(false).eraseToAnyPublisher()
    }
    
    public var isSportIconVisiblePublisher: AnyPublisher<Bool, Never> {
        return Just(false).eraseToAnyPublisher()
    }
    
    public var isFavoriteButtonVisiblePublisher: AnyPublisher<Bool, Never> {
        return Just(false).eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(data: MatchHeaderData, favoritesManager: FavoritesManager = Env.favoritesManager) {
        self.matchId = data.id
        self.favoritesManager = favoritesManager
        self.competitionNameSubject = CurrentValueSubject(data.competitionName)
        self.countryFlagImageNameSubject = CurrentValueSubject(data.countryFlagImageName)
        self.sportIconImageNameSubject = CurrentValueSubject(data.sportIconImageName)
        let initialFavoriteState = favoritesManager.isEventFavorite(eventId: data.id) || data.isFavorite
        self.isFavoriteSubject = CurrentValueSubject(initialFavoriteState)
       
        self.matchTimeSubject = CurrentValueSubject(data.matchTime)
        self.isLiveSubject = CurrentValueSubject(data.isLive)
        self.bindFavorites()
    }
    
    // Binding
    func bindFavorites() {
        self.favoritesManager.favoriteEventsIdPublisher
            .map { $0.contains(self.matchId) }
            .removeDuplicates()
            .sink { [weak self] isFavorite in
                self?.isFavoriteSubject.send(isFavorite)
            }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Actions
    func toggleFavorite() {
        if self.isFavoriteSubject.value {
            self.favoritesManager.removeUserFavorite(eventId: self.matchId)
        } else {
            self.favoritesManager.addUserFavorite(eventId: self.matchId)
        }
    }
    
    
    func updateCompetitionName(_ name: String) {
        competitionNameSubject.send(name)
    }
    
    func updateCountryFlag(_ imageName: String?) {
        countryFlagImageNameSubject.send(imageName)
    }
    
    func updateSportIcon(_ imageName: String?) {
        sportIconImageNameSubject.send(imageName)
    }
    
    func updateMatchTime(_ time: String?) {
        matchTimeSubject.send(time)
    }
    
    func updateIsLive(_ isLive: Bool) {
        isLiveSubject.send(isLive)
    }
    
}


// MARK: - Factory for Creating from Match Data
extension MatchHeaderViewModel {
    
    /// Creates a MatchHeaderViewModel from real Match data
    static func create(from match: Match) -> MatchHeaderViewModel {
        let headerData = MatchHeaderData(
            id: match.id,
            competitionName: match.competitionName,
            countryFlagImageName: extractCountryFlag(from: match),
            sportIconImageName: extractSportIcon(from: match),
            isFavorite: Env.favoritesManager.isEventFavorite(eventId: match.id),
            matchTime: formatMatchTime(from: match),
            isLive: match.status.isLive
        )
        
        return MatchHeaderViewModel(data: headerData)
    }
    
    // MARK: - Helper Methods
    private static func extractCountryFlag(from match: Match) -> String? {
        return match.venue?.isoCode
    }
    
    private static func extractSportIcon(from match: Match) -> String? {
        return match.sport.alphaId ?? match.sportIdCode ?? "1"
    }
    
    private static func formatMatchTime(from match: Match) -> String? {
        if let matchTime = match.matchTime {
            return matchTime
        }
        if let date = match.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM, HH:mm"
            return formatter.string(from: date)
        }
        return nil
    }
}
