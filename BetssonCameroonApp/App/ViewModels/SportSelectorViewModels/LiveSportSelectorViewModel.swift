import Combine
import UIKit
import GomaUI

final class LiveSportSelectorViewModel: SportTypeSelectorViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<SportTypeSelectorDisplayState, Never>
    private let sportTypeStore: SportTypeStore
    private var cancellables = Set<AnyCancellable>()
    
    public var displayStatePublisher: AnyPublisher<SportTypeSelectorDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    // Internal state
    private var internalSports: [SportTypeData] = []
    private var originalSportsMap: [String: Sport] = [:]
    
    // MARK: - Callbacks
    var onSportSelected: ((Sport) -> Void)?
    
    // MARK: - Current Selection
    private var currentSelectedSport: Sport?
    
    // MARK: - Initialization
    init(sportTypeStore: SportTypeStore = Env.sportsStore) {
        self.sportTypeStore = sportTypeStore
        
        // Get sports synchronously - no need for live updates in modal
        let activeSports = sportTypeStore.getActiveSports().filter { sport in
            sport.liveEventsCount > 0
        }
        self.internalSports = activeSports.map { Self.sportToSportTypeData($0) }
        
        // Store original sports for data preservation
        for sport in activeSports {
            self.originalSportsMap[sport.id] = sport
        }

        let initialState = SportTypeSelectorDisplayState(sports: internalSports)
        self.displayStateSubject = CurrentValueSubject(initialState)
        
        print("🏁 SportSelectorViewModel: Initialized with \(activeSports.count) sports")
    }
    
    // MARK: - Setup - No longer needed since we load synchronously
    
    // MARK: - Public Methods
    public func updateSports(_ sports: [SportTypeData]) {
        self.internalSports = sports
        publishNewState()
    }
    
    public func addSport(_ sport: SportTypeData) {
        if !internalSports.contains(where: { $0.id == sport.id }) {
            internalSports.append(sport)
            publishNewState()
        }
    }
    
    public func removeSport(withId id: String) {
        internalSports.removeAll { $0.id == id }
        publishNewState()
    }
    
    public func selectSport(_ sportTypeData: SportTypeData) {
        // Retrieve the original Sport object with all its data intact
        guard let originalSport = originalSportsMap[sportTypeData.id] else {
            print("⚠️ SportSelectorViewModel: Could not find original sport data for ID: \(sportTypeData.id)")
            return
        }
        
        currentSelectedSport = originalSport
        print("🏆 SportSelectorViewModel: Sport selected - \(originalSport.name) (ID: \(originalSport.id), Events: \(originalSport.eventsCount), Live: \(originalSport.liveEventsCount))")
        onSportSelected?(originalSport)
    }
    
    public func getCurrentSelectedSport() -> Sport? {
        return currentSelectedSport
    }
    
    // MARK: - Helper Methods
    private func publishNewState() {
        let newState = SportTypeSelectorDisplayState(sports: internalSports)
        displayStateSubject.send(newState)
    }
    
    
    // MARK: - Utility Methods
    public static func sportToSportTypeData(_ sport: Sport) -> SportTypeData {
        let preferredIconName = "sport_type_icon_\(sport.id)"
        let iconName = UIImage(named: preferredIconName) != nil ? preferredIconName : "sport_type_icon_default"
        
        return SportTypeData(
            id: sport.id,
            name: sport.name,
            iconName: iconName
        )
    }
}
