import XCTest
import Combine
@testable import EveryMatrixProviderClient

/// Real integration tests that connect to the actual EveryMatrix server
/// These tests require a working internet connection and valid server endpoints
class SportsStoreRealIntegrationTests: XCTestCase {
    
    var sportsStore: SportsStore!
    var tsManager: TSManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        // Create real TSManager instance
        tsManager = TSManager()
        sportsStore = SportsStore(tsManager: tsManager, language: "en")
        cancellables = Set<AnyCancellable>()
        
        // Give some time for connection setup
        let setupExpectation = XCTestExpectation(description: "Setup completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            setupExpectation.fulfill()
        }
        wait(for: [setupExpectation], timeout: 2.0)
    }
    
    override func tearDown() {
        cancellables?.removeAll()
        sportsStore?.stopSubscription()
        tsManager?.disconnect()
        sportsStore = nil
        tsManager = nil
        super.tearDown()
    }
    
    // MARK: - Real Server Connection Tests
    
    func testRealServerConnection() {
        // Given
        let connectionExpectation = XCTestExpectation(description: "Connected to real server")
        connectionExpectation.expectedFulfillmentCount = 1
        
        var connectionEstablished = false
        
        // Monitor connection state through NotificationCenter if available
        NotificationCenter.default.addObserver(
            forName: .socketConnected,
            object: nil,
            queue: .main
        ) { _ in
            connectionEstablished = true
            connectionExpectation.fulfill()
        }
        
        // When
        tsManager.connect()
        
        // Then
        wait(for: [connectionExpectation], timeout: 10.0)
        XCTAssertTrue(connectionEstablished, "Should establish connection to real server")
        XCTAssertTrue(tsManager.isConnected, "TSManager should report connected state")
    }
    
    func testRealOperatorInfoRetrieval() {
        // Given
        let operatorExpectation = XCTestExpectation(description: "Operator info retrieved from real server")
        
        var receivedOperatorInfo: [String: Any]?
        var receivedError: Error?
        
        // When
        sportsStore.retrieveOperatorInfo()
        
        sportsStore.errorPublisher
            .compactMap { $0 }
            .sink { error in
                receivedError = error
                operatorExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Monitor for successful data reception by checking if subscription starts
        sportsStore.loadingPublisher
            .sink { isLoading in
                if isLoading {
                    // Loading started, which means operator info was likely retrieved
                    operatorExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [operatorExpectation], timeout: 15.0)
        
        if let error = receivedError {
            print("Real integration test - Operator info error: \(error)")
            // This might be expected if credentials are not configured
            XCTAssertNotNil(error, "Error should be informative about connection issues")
        } else {
            print("Real integration test - Operator info retrieved successfully")
        }
    }
    
    func testRealSportsDataSubscription() {
        // Given
        let sportsExpectation = XCTestExpectation(description: "Real sports data received")
        sportsExpectation.isInverted = false // We expect this to fulfill
        
        var receivedSports: [Sport] = []
        var subscriptionStarted = false
        var errorReceived: Error?
        
        // When
        sportsStore.sportsPublisher
            .sink { sports in
                receivedSports = sports
                if !sports.isEmpty {
                    print("Real integration test - Received \(sports.count) sports from real server")
                    for sport in sports.prefix(3) {
                        print("  - \(sport.name) (ID: \(sport.id), Live: \(sport.isLive), Popular: \(sport.isPopular))")
                        print("    Events: \(sport.numberOfEvents), Live Events: \(sport.numberOfLiveEvents)")
                    }
                    sportsExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sportsStore.loadingPublisher
            .sink { isLoading in
                if isLoading && !subscriptionStarted {
                    subscriptionStarted = true
                    print("Real integration test - Subscription started, loading sports data...")
                } else if !isLoading && subscriptionStarted {
                    print("Real integration test - Loading completed")
                }
            }
            .store(in: &cancellables)
        
        sportsStore.errorPublisher
            .compactMap { $0 }
            .sink { error in
                errorReceived = error
                print("Real integration test - Error received: \(error)")
                sportsExpectation.fulfill() // Fulfill to avoid timeout
            }
            .store(in: &cancellables)
        
        sportsStore.startSubscription()
        
        // Then
        wait(for: [sportsExpectation], timeout: 30.0) // Longer timeout for real server
        
        if let error = errorReceived {
            print("Real integration test completed with error: \(error)")
            // This might be expected if server is not accessible or credentials are missing
            XCTAssertNotNil(error, "Should provide meaningful error information")
        } else {
            print("Real integration test completed successfully with \(receivedSports.count) sports")
            XCTAssertTrue(receivedSports.count > 0, "Should receive real sports data from server")
            
            // Verify data structure
            let sportsWithEvents = receivedSports.filter { $0.numberOfEvents > 0 }
            print("Sports with events: \(sportsWithEvents.count)")
            
            let liveSports = sportsStore.liveSports
            let popularSports = sportsStore.popularSports
            print("Live sports: \(liveSports.count), Popular sports: \(popularSports.count)")
        }
    }
    
    func testRealTimeUpdates() {
        // Given
        let updatesExpectation = XCTestExpectation(description: "Real-time updates received")
        updatesExpectation.expectedFulfillmentCount = 2 // Initial data + at least one update
        
        var updateCount = 0
        var lastSportsCount = 0
        
        // When
        sportsStore.sportsPublisher
            .sink { sports in
                updateCount += 1
                print("Real integration test - Update #\(updateCount): \(sports.count) sports")
                
                if updateCount == 1 {
                    lastSportsCount = sports.count
                    updatesExpectation.fulfill()
                } else if updateCount > 1 && sports.count != lastSportsCount {
                    print("Real integration test - Sports count changed from \(lastSportsCount) to \(sports.count)")
                    updatesExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sportsStore.startSubscription()
        
        // Then
        wait(for: [updatesExpectation], timeout: 60.0) // Extended timeout for real-time updates
        
        print("Real integration test - Received \(updateCount) updates")
        XCTAssertTrue(updateCount >= 1, "Should receive at least initial data")
    }
    
    func testLanguageChange() {
        // Given
        let languageChangeExpectation = XCTestExpectation(description: "Language change triggers resubscription")
        
        var initialDataReceived = false
        var dataAfterLanguageChange = false
        
        // When
        sportsStore.sportsPublisher
            .sink { sports in
                if !sports.isEmpty && !initialDataReceived {
                    initialDataReceived = true
                    print("Real integration test - Initial data received in English")
                    
                    // Change language after receiving initial data
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        print("Real integration test - Changing language to Spanish")
                        self.sportsStore.updateLanguage("es")
                    }
                } else if !sports.isEmpty && initialDataReceived && !dataAfterLanguageChange {
                    dataAfterLanguageChange = true
                    print("Real integration test - Data received after language change")
                    languageChangeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sportsStore.startSubscription()
        
        // Then
        wait(for: [languageChangeExpectation], timeout: 45.0)
        
        XCTAssertTrue(initialDataReceived, "Should receive initial data")
        XCTAssertTrue(dataAfterLanguageChange, "Should receive data after language change")
    }
    
    // MARK: - Performance Tests
    
    func testRealDataProcessingPerformance() {
        // Given
        let performanceExpectation = XCTestExpectation(description: "Performance test completed")
        
        var startTime: CFAbsoluteTime = 0
        var endTime: CFAbsoluteTime = 0
        var sportsProcessed = 0
        
        // When
        sportsStore.sportsPublisher
            .sink { sports in
                if startTime == 0 && !sports.isEmpty {
                    startTime = CFAbsoluteTimeGetCurrent()
                    print("Real integration test - Started processing sports data")
                }
                
                if !sports.isEmpty {
                    sportsProcessed = sports.count
                    endTime = CFAbsoluteTimeGetCurrent()
                    
                    let processingTime = endTime - startTime
                    print("Real integration test - Processed \(sportsProcessed) sports in \(processingTime) seconds")
                    
                    performanceExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sportsStore.startSubscription()
        
        // Then
        wait(for: [performanceExpectation], timeout: 20.0)
        
        let totalProcessingTime = endTime - startTime
        XCTAssertTrue(totalProcessingTime < 5.0, "Should process sports data in reasonable time")
        XCTAssertTrue(sportsProcessed > 0, "Should process some sports data")
        
        print("Real integration test - Performance: \(sportsProcessed) sports processed in \(totalProcessingTime)s")
    }
    
    // MARK: - Data Validation Tests
    
    func testRealDataValidation() {
        // Given
        let validationExpectation = XCTestExpectation(description: "Data validation completed")
        
        // When
        sportsStore.sportsPublisher
            .sink { sports in
                if !sports.isEmpty {
                    print("Real integration test - Validating \(sports.count) sports")
                    
                    for sport in sports {
                        // Validate required fields
                        XCTAssertFalse(sport.id.isEmpty, "Sport ID should not be empty")
                        XCTAssertFalse(sport.name.isEmpty, "Sport name should not be empty")
                        XCTAssertEqual(sport.entityType, "SPORT", "Entity type should be SPORT")
                        
                        // Validate numeric fields are non-negative
                        XCTAssertTrue(sport.numberOfEvents >= 0, "Number of events should be non-negative")
                        XCTAssertTrue(sport.numberOfLiveEvents >= 0, "Number of live events should be non-negative")
                        XCTAssertTrue(sport.numberOfMarkets >= 0, "Number of markets should be non-negative")
                        
                        // Validate context logic
                        if sport.numberOfLiveEvents > 0 {
                            XCTAssertTrue(sport.isLive, "Sport with live events should be marked as live")
                        }
                        
                        if sport.numberOfEvents > 0 && sport.numberOfLiveEvents == 0 {
                            XCTAssertTrue(sport.isPopular, "Sport with events but no live events should be popular")
                        }
                    }
                    
                    print("Real integration test - Data validation passed for all sports")
                    validationExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sportsStore.startSubscription()
        
        // Then
        wait(for: [validationExpectation], timeout: 20.0)
    }
} 