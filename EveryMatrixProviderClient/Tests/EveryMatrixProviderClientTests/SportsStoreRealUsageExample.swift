import XCTest
import Combine
@testable import EveryMatrixProviderClient

/// Real usage example demonstrating how to use SportsStore with actual EveryMatrix server
/// This is more of a demonstration/manual test than an automated test
class SportsStoreRealUsageExample: XCTestCase {
    
    var sportsStore: SportsStore!
    var tsManager: TSManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        tsManager = TSManager()
        sportsStore = SportsStore(tsManager: tsManager, language: "en")
        cancellables = Set<AnyCancellable>()
        
        tsManager.connect()
    }
    
    override func tearDown() {
        cancellables?.removeAll()
        sportsStore?.stopSubscription()
        tsManager?.disconnect()
        sportsStore = nil
        tsManager = nil
        super.tearDown()
    }
    
    /// Manual test to demonstrate basic SportsStore usage
    /// Run this to see real sports data from EveryMatrix server
    func testManualSportsStoreUsage() {
        // Given
        let manualTestExpectation = XCTestExpectation(description: "Manual test - observe console output")
        
        print("=== SportsStore Real Usage Example ===")
        print("Starting connection to EveryMatrix server...")
        
        // Subscribe to all state changes
        sportsStore.statePublisher
            .sink { state in
                self.printStateUpdate(state)
            }
            .store(in: &cancellables)
        
        // Subscribe to sports updates for detailed logging
        sportsStore.sportsPublisher
            .sink { sports in
                self.logSportsData(sports)
                
                // Complete the test after receiving data or after timeout
                if !sports.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                        print("=== Stopping subscription ===")
                        self.sportsStore.stopSubscription()
                        manualTestExpectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)
        
        // Subscribe to errors
        sportsStore.errorPublisher
            .compactMap { $0 }
            .sink { error in
                print("❌ Error received: \(error)")
                manualTestExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        print("📱 Starting sports subscription...")
        sportsStore.startSubscription()
        
        // Then
        wait(for: [manualTestExpectation], timeout: 60.0)
        
        print("=== SportsStore Usage Example Completed ===")
    }
    
    /// Test to demonstrate filtering capabilities
    func testSportsFiltering() {
        let filteringExpectation = XCTestExpectation(description: "Sports filtering demonstration")
        
        print("=== Sports Filtering Example ===")
        
        sportsStore.sportsPublisher
            .sink { sports in
                if !sports.isEmpty {
                    self.demonstrateFiltering(sports)
                    filteringExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sportsStore.startSubscription()
        
        wait(for: [filteringExpectation], timeout: 30.0)
    }
    
    /// Test to demonstrate language switching
    func testLanguageSwitching() {
        let languageExpectation = XCTestExpectation(description: "Language switching demonstration")
        languageExpectation.expectedFulfillmentCount = 2
        
        print("=== Language Switching Example ===")
        
        var receivedEnglishData = false
        
        sportsStore.sportsPublisher
            .sink { sports in
                if !sports.isEmpty && !receivedEnglishData {
                    receivedEnglishData = true
                    print("📊 Received sports data in English (\(sports.count) sports)")
                    self.printSampleSports(sports, language: "English")
                    languageExpectation.fulfill()
                    
                    // Switch to Spanish after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        print("🔄 Switching to Spanish...")
                        self.sportsStore.updateLanguage("es")
                    }
                } else if !sports.isEmpty && receivedEnglishData {
                    print("📊 Received sports data in Spanish (\(sports.count) sports)")
                    self.printSampleSports(sports, language: "Spanish")
                    languageExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sportsStore.startSubscription()
        
        wait(for: [languageExpectation], timeout: 45.0)
    }
    
    // MARK: - Helper Methods
    
    private func printStateUpdate(_ state: (sports: [Sport], isLoading: Bool, error: Error?)) {
        let timestamp = DateFormatter.timestamp.string(from: Date())
        
        print("\n[\(timestamp)] State Update:")
        print("  📊 Sports count: \(state.sports.count)")
        print("  ⏳ Loading: \(state.isLoading)")
        
        if let error = state.error {
            print("  ❌ Error: \(error)")
        } else {
            print("  ✅ No errors")
        }
    }
    
    private func logSportsData(_ sports: [Sport]) {
        guard !sports.isEmpty else { return }
        
        let timestamp = DateFormatter.timestamp.string(from: Date())
        
        print("\n[\(timestamp)] Sports Data Update:")
        print("  📊 Total sports: \(sports.count)")
        
        let liveSports = sportsStore.liveSports
        let popularSports = sportsStore.popularSports
        
        print("  🔴 Live sports: \(liveSports.count)")
        print("  ⭐ Popular sports: \(popularSports.count)")
        
        // Show top 5 sports with most events
        let topSports = sports
            .sorted { $0.numberOfEvents > $1.numberOfEvents }
            .prefix(5)
        
        print("  🏆 Top sports by events:")
        for sport in topSports {
            let liveIndicator = sport.isLive ? "🔴" : ""
            let popularIndicator = sport.isPopular ? "⭐" : ""
            print("    \(liveIndicator)\(popularIndicator) \(sport.name): \(sport.numberOfEvents) events (\(sport.numberOfLiveEvents) live)")
        }
    }
    
    private func demonstrateFiltering(_ sports: [Sport]) {
        print("\n=== Filtering Demonstration ===")
        print("Total sports: \(sports.count)")
        
        // Live sports
        let liveSports = sportsStore.liveSports
        print("\n🔴 Live Sports (\(liveSports.count)):")
        for sport in liveSports.prefix(5) {
            print("  - \(sport.name): \(sport.numberOfLiveEvents) live events")
        }
        
        // Popular sports
        let popularSports = sportsStore.popularSports
        print("\n⭐ Popular Sports (\(popularSports.count)):")
        for sport in popularSports.prefix(5) {
            print("  - \(sport.name): \(sport.numberOfEvents) total events")
        }
        
        // Sports with outrights
        let sportsWithOutrights = sports.filter { $0.hasOutrights }
        print("\n🎯 Sports with Outrights (\(sportsWithOutrights.count)):")
        for sport in sportsWithOutrights.prefix(3) {
            print("  - \(sport.name): \(sport.numberOfOutrightsEvents) outright events")
        }
        
        // Virtual sports
        let virtualSports = sports.filter { $0.isVirtual }
        print("\n🎮 Virtual Sports (\(virtualSports.count)):")
        for sport in virtualSports.prefix(3) {
            print("  - \(sport.name)")
        }
        
        // Example: Find a specific sport by ID
        if let footballSport = sportsStore.sport(withId: "1") {
            print("\n⚽ Found Football (ID=1):")
            print("  - Events: \(footballSport.numberOfEvents)")
            print("  - Live events: \(footballSport.numberOfLiveEvents)")
            print("  - Markets: \(footballSport.numberOfMarkets)")
        }
    }
    
    private func printSampleSports(_ sports: [Sport], language: String) {
        print("\n--- Sample Sports in \(language) ---")
        for sport in sports.prefix(3) {
            print("  - \(sport.name) (ID: \(sport.id))")
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let timestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
} 
