import Foundation
import Combine

/// Example demonstrating how to use the SportsStore
class SportsStoreUsageExample {
    
    private let sportsStore: SportsStore
    private var cancellables = Set<AnyCancellable>()
    
    init(tsManager: TSManager) {
        // Initialize the SportsStore with the TSManager
        self.sportsStore = SportsStore(tsManager: tsManager, language: "en")
        
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Subscribe to sports updates
        sportsStore.sportsPublisher
            .sink { [weak self] sports in
                self?.handleSportsUpdate(sports)
            }
            .store(in: &cancellables)
        
        // Subscribe to loading state
        sportsStore.loadingPublisher
            .sink { isLoading in
                print("SportsStore loading state: \(isLoading)")
            }
            .store(in: &cancellables)
        
        // Subscribe to errors
        sportsStore.errorPublisher
            .compactMap { $0 }
            .sink { error in
                print("SportsStore error: \(error)")
            }
            .store(in: &cancellables)
        
        // Combined state subscription
        sportsStore.statePublisher
            .sink { state in
                print("SportsStore state - Sports: \(state.sports.count), Loading: \(state.isLoading), Error: \(state.error?.localizedDescription ?? "none")")
            }
            .store(in: &cancellables)
    }
    
    private func handleSportsUpdate(_ sports: [Sport]) {
        print("Received \(sports.count) sports")
        
        // Filter live sports
        let liveSports = sportsStore.liveSports
        print("Live sports: \(liveSports.count)")
        
        // Filter popular sports
        let popularSports = sportsStore.popularSports
        print("Popular sports: \(popularSports.count)")
        
        // Print some sport details
        for sport in sports.prefix(5) {
            print("Sport: \(sport.name) (ID: \(sport.id))")
            print("  - Live events: \(sport.numberOfLiveEvents)")
            print("  - Total events: \(sport.numberOfEvents)")
            print("  - Contexts: \(sport.contexts.keys.joined(separator: ", "))")
            print("  - Is Live: \(sport.isLive)")
            print("  - Is Popular: \(sport.isPopular)")
        }
    }
    
    /// Start the sports subscription
    func start() {
        sportsStore.startSubscription()
    }
    
    /// Stop the sports subscription
    func stop() {
        sportsStore.stopSubscription()
    }
    
    /// Change language
    func changeLanguage(to language: String) {
        sportsStore.updateLanguage(language)
    }
    
    /// Get a specific sport by ID
    func getSport(withId id: String) -> Sport? {
        return sportsStore.sport(withId: id)
    }
    
    /// Get current sports count
    var sportsCount: Int {
        return sportsStore.sports.count
    }
    
    /// Get live sports count
    var liveSportsCount: Int {
        return sportsStore.liveSports.count
    }
    
    /// Get popular sports count
    var popularSportsCount: Int {
        return sportsStore.popularSports.count
    }
} 
