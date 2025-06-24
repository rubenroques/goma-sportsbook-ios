import Combine
import UIKit
import GomaUI

final class MatchHeaderViewModel: MatchHeaderViewModelProtocol {
    // MARK: - Private Properties
    private let competitionNameSubject: CurrentValueSubject<String, Never>
    private let countryFlagImageNameSubject: CurrentValueSubject<String?, Never>
    private let sportIconImageNameSubject: CurrentValueSubject<String?, Never>
    private let isFavoriteSubject: CurrentValueSubject<Bool, Never>
    private let matchTimeSubject: CurrentValueSubject<String?, Never>
    private let isLiveSubject: CurrentValueSubject<Bool, Never>
    private let visualStateSubject: CurrentValueSubject<MatchHeaderVisualState, Never>
    
    // Custom image subjects
    private let countryFlagImageSubject: CurrentValueSubject<UIImage?, Never>
    private let sportIconImageSubject: CurrentValueSubject<UIImage?, Never>
    
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
    
    public var countryFlagImagePublisher: AnyPublisher<UIImage?, Never> {
        return self.countryFlagImageSubject.eraseToAnyPublisher()
    }
    
    public var sportIconImagePublisher: AnyPublisher<UIImage?, Never> {
        return self.sportIconImageSubject.eraseToAnyPublisher()
    }
    
    public var visualStatePublisher: AnyPublisher<MatchHeaderVisualState, Never> {
        return self.visualStateSubject.eraseToAnyPublisher()
    }
    
    public var currentVisualState: MatchHeaderVisualState {
        return self.visualStateSubject.value
    }
    
    // MARK: - Initialization
    init(data: MatchHeaderData) {
        self.competitionNameSubject = CurrentValueSubject(data.competitionName)
        self.countryFlagImageNameSubject = CurrentValueSubject(data.countryFlagImageName)
        self.sportIconImageNameSubject = CurrentValueSubject(data.sportIconImageName)
        self.isFavoriteSubject = CurrentValueSubject(data.isFavorite)
        self.matchTimeSubject = CurrentValueSubject(data.matchTime)
        self.isLiveSubject = CurrentValueSubject(data.isLive)
        self.visualStateSubject = CurrentValueSubject(data.visualState)
        
        // Initialize custom image subjects
        self.countryFlagImageSubject = CurrentValueSubject(nil)
        self.sportIconImageSubject = CurrentValueSubject(nil)

        // Load images from image names if available
        loadInitialImages(data: data)
    }
    
    // MARK: - Actions
    func toggleFavorite() {
        let currentFavorite = isFavoriteSubject.value
        isFavoriteSubject.send(!currentFavorite)
        
        // TODO: Integrate with favorites service
    }
    
    func updateData(_ data: MatchHeaderData) {
        competitionNameSubject.send(data.competitionName)
        countryFlagImageNameSubject.send(data.countryFlagImageName)
        sportIconImageNameSubject.send(data.sportIconImageName)
        isFavoriteSubject.send(data.isFavorite)
        matchTimeSubject.send(data.matchTime)
        isLiveSubject.send(data.isLive)
        visualStateSubject.send(data.visualState)
        
        // Reload images
        loadInitialImages(data: data)
    }
    
    func setVisualState(_ state: MatchHeaderVisualState) {
        visualStateSubject.send(state)
    }
    
    func updateCompetitionName(_ name: String) {
        competitionNameSubject.send(name)
    }
    
    func updateCountryFlag(_ imageName: String?) {
        countryFlagImageNameSubject.send(imageName)
        loadCountryFlagImage(from: imageName)
    }
    
    func updateSportIcon(_ imageName: String?) {
        sportIconImageNameSubject.send(imageName)
        loadSportIconImage(from: imageName)
    }
    
    func updateMatchTime(_ time: String?) {
        matchTimeSubject.send(time)
    }
    
    func updateIsLive(_ isLive: Bool) {
        isLiveSubject.send(isLive)
    }
    
    func updateCountryFlagImage(_ image: UIImage?) {
        countryFlagImageSubject.send(image)
    }
    
    func updateSportIconImage(_ image: UIImage?) {
        sportIconImageSubject.send(image)
    }
    
    // MARK: - Convenience Methods
    func setEnabled(_ enabled: Bool) {
        let newState: MatchHeaderVisualState = enabled ? .standard : .disabled
        setVisualState(newState)
    }
    
    func setMinimalMode(_ minimal: Bool) {
        let newState: MatchHeaderVisualState = minimal ? .minimal : .standard
        setVisualState(newState)
    }
    
    func setFavoriteOnlyMode(_ favoriteOnly: Bool) {
        let newState: MatchHeaderVisualState = favoriteOnly ? .favoriteOnly : .standard
        setVisualState(newState)
    }
}

// MARK: - Private Image Loading
extension MatchHeaderViewModel {
    
    private func loadInitialImages(data: MatchHeaderData) {
        loadCountryFlagImage(from: data.countryFlagImageName)
        loadSportIconImage(from: data.sportIconImageName)
    }
    
    private func loadCountryFlagImage(from imageName: String?) {
        guard let imageName = imageName else {
            countryFlagImageSubject.send(nil)
            return
        }

        let assetName = Assets.flagName(withCountryCode: imageName)
        
        let image = UIImage(named: assetName) ?? UIImage(systemName: "globe")
        countryFlagImageSubject.send(image)
    }
    
    private func loadSportIconImage(from imageName: String?) {
        guard let imageName = imageName else {
            sportIconImageSubject.send(nil)
            return
        }
        
        let assetName =
        "sport_type_icon_\(imageName)"
        let image = UIImage(named: assetName) ?? UIImage(named: "sport_type_icon_default")
        sportIconImageSubject.send(image)
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
            isFavorite: false, // TODO: Check with favorites service when available
            visualState: .standard,
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
