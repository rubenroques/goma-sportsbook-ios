import XCTest
@testable import EveryMatrixProviderClient

class SportModelTests: XCTestCase {
    
    // MARK: - Sport Model Tests
    
    func testSportInitialization() {
        // Given
        let sport = Sport(
            id: "1",
            name: "Football",
            shortName: "FB",
            iconId: "football_icon",
            numberOfEvents: 10,
            numberOfLiveEvents: 5,
            contexts: ["live": 1, "popular": 1]
        )
        
        // Then
        XCTAssertEqual(sport.id, "1")
        XCTAssertEqual(sport.name, "Football")
        XCTAssertEqual(sport.shortName, "FB")
        XCTAssertEqual(sport.iconId, "football_icon")
        XCTAssertEqual(sport.numberOfEvents, 10)
        XCTAssertEqual(sport.numberOfLiveEvents, 5)
        XCTAssertTrue(sport.isLive)
        XCTAssertTrue(sport.isPopular)
        XCTAssertEqual(sport.entityType, "SPORT")
    }
    
    func testSportDefaultValues() {
        // Given
        let sport = Sport(id: "1", name: "Tennis")
        
        // Then
        XCTAssertEqual(sport.id, "1")
        XCTAssertEqual(sport.originalId, "1")
        XCTAssertEqual(sport.boNavigationId, "1")
        XCTAssertEqual(sport.name, "Tennis")
        XCTAssertNil(sport.shortName)
        XCTAssertEqual(sport.iconId, "noicon")
        XCTAssertFalse(sport.isVirtual)
        XCTAssertEqual(sport.numberOfEvents, 0)
        XCTAssertEqual(sport.numberOfLiveEvents, 0)
        XCTAssertFalse(sport.isLive)
        XCTAssertFalse(sport.isPopular)
    }
    
    func testSportWithContext() {
        // Given
        let sport = Sport(id: "1", name: "Basketball")
        
        // When
        let sportWithLiveContext = sport.withContext("live")
        let sportWithBothContexts = sportWithLiveContext.withContext("popular")
        
        // Then
        XCTAssertFalse(sport.isLive)
        XCTAssertTrue(sportWithLiveContext.isLive)
        XCTAssertFalse(sportWithLiveContext.isPopular)
        XCTAssertTrue(sportWithBothContexts.isLive)
        XCTAssertTrue(sportWithBothContexts.isPopular)
    }
    
    func testSportCodable() {
        // Given
        let originalSport = Sport(
            id: "1",
            name: "Football",
            shortName: "FB",
            iconId: "1",
            numberOfEvents: 10,
            numberOfLiveEvents: 5,
            contexts: ["live": 1]
        )
        
        // When
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(originalSport)
            let decodedSport = try decoder.decode(Sport.self, from: data)
            
            // Then
            XCTAssertEqual(decodedSport.id, originalSport.id)
            XCTAssertEqual(decodedSport.name, originalSport.name)
            XCTAssertEqual(decodedSport.shortName, originalSport.shortName)
            XCTAssertEqual(decodedSport.iconId, originalSport.iconId)
            XCTAssertEqual(decodedSport.numberOfEvents, originalSport.numberOfEvents)
            XCTAssertEqual(decodedSport.numberOfLiveEvents, originalSport.numberOfLiveEvents)
            XCTAssertEqual(decodedSport.contexts, originalSport.contexts)
        } catch {
            XCTFail("Failed to encode/decode Sport: \(error)")
        }
    }
    
    // MARK: - SportMapper Tests
    
    func testMapSportFromRawData() {
        // Given
        let rawSport: [String: Any] = [
            "id": "1",
            "name": "Football",
            "shortName": "FB",
            "iconId": "football",
            "isVirtual": false,
            "numberOfEvents": 25,
            "numberOfLiveEvents": 10,
            "numberOfMarkets": 100,
            "numberOfBettingOffers": 200,
            "hasMatches": true,
            "hasOutrights": false
        ]
        
        var existingSports: [Sport] = []
        
        // When
        let mappedSport = SportMapper.mapSport(
            from: rawSport,
            context: "live",
            existingSports: &existingSports
        )
        
        // Then
        XCTAssertNotNil(mappedSport)
        XCTAssertEqual(mappedSport?.id, "1")
        XCTAssertEqual(mappedSport?.name, "Football")
        XCTAssertEqual(mappedSport?.shortName, "FB")
        XCTAssertEqual(mappedSport?.iconId, "football")
        XCTAssertFalse(mappedSport?.isVirtual ?? true)
        XCTAssertEqual(mappedSport?.numberOfEvents, 25)
        XCTAssertEqual(mappedSport?.numberOfLiveEvents, 10)
        XCTAssertTrue(mappedSport?.isLive ?? false)
        XCTAssertEqual(existingSports.count, 1)
    }
    
    func testMapSportWithMissingData() {
        // Given
        let rawSport: [String: Any] = [
            "id": "2",
            "name": "Basketball"
            // Missing other fields to test defaults
        ]
        
        var existingSports: [Sport] = []
        
        // When
        let mappedSport = SportMapper.mapSport(
            from: rawSport,
            context: "popular",
            existingSports: &existingSports
        )
        
        // Then
        XCTAssertNotNil(mappedSport)
        XCTAssertEqual(mappedSport?.id, "2")
        XCTAssertEqual(mappedSport?.name, "Basketball")
        XCTAssertNil(mappedSport?.shortName)
        XCTAssertEqual(mappedSport?.iconId, "noicon") // Default for non-numeric ID
        XCTAssertFalse(mappedSport?.isVirtual ?? true)
        XCTAssertEqual(mappedSport?.numberOfEvents, 0) // Default
        XCTAssertTrue(mappedSport?.isPopular ?? false)
    }
    
    func testMapSportWithNumericId() {
        // Given
        let rawSport: [String: Any] = [
            "id": 123,
            "name": "Tennis"
        ]
        
        var existingSports: [Sport] = []
        
        // When
        let mappedSport = SportMapper.mapSport(
            from: rawSport,
            context: "all",
            existingSports: &existingSports
        )
        
        // Then
        XCTAssertNotNil(mappedSport)
        XCTAssertEqual(mappedSport?.id, "123")
        XCTAssertEqual(mappedSport?.iconId, "123") // Numeric ID as icon
    }
    
    func testMapSportInvalidData() {
        // Given
        let rawSport: [String: Any] = [
            "name": "Invalid Sport"
            // Missing ID - should return nil
        ]
        
        var existingSports: [Sport] = []
        
        // When
        let mappedSport = SportMapper.mapSport(
            from: rawSport,
            context: "popular",
            existingSports: &existingSports
        )
        
        // Then
        XCTAssertNil(mappedSport)
        XCTAssertEqual(existingSports.count, 0)
    }
    
    func testMapExistingSport() {
        // Given
        let existingSport = Sport(
            id: "1",
            name: "Football",
            contexts: ["live": 1]
        )
        var existingSports = [existingSport]
        
        let rawSport: [String: Any] = [
            "id": "1",
            "name": "Football Updated"
        ]
        
        // When
        let mappedSport = SportMapper.mapSport(
            from: rawSport,
            context: "popular",
            existingSports: &existingSports
        )
        
        // Then
        XCTAssertNotNil(mappedSport)
        XCTAssertEqual(existingSports.count, 1) // Should update existing, not add new
        XCTAssertTrue(mappedSport?.isLive ?? false)
        XCTAssertTrue(mappedSport?.isPopular ?? false) // Should have both contexts
    }
    
    func testMapSportsArray() {
        // Given
        let rawSports: [[String: Any]] = [
            [
                "id": "1",
                "name": "Football",
                "numberOfLiveEvents": 10
            ],
            [
                "id": "2", 
                "name": "Basketball",
                "numberOfEvents": 15
            ]
        ]
        
        var existingSports: [Sport] = []
        
        // When
        let mappedSports = SportMapper.mapSports(
            from: rawSports,
            context: "mixed",
            existingSports: &existingSports
        )
        
        // Then
        XCTAssertEqual(mappedSports.count, 2)
        XCTAssertEqual(existingSports.count, 2)
        
        let footballSport = mappedSports.first { $0.name == "Football" }
        let basketballSport = mappedSports.first { $0.name == "Basketball" }
        
        XCTAssertNotNil(footballSport)
        XCTAssertNotNil(basketballSport)
        XCTAssertEqual(footballSport?.numberOfLiveEvents, 10)
        XCTAssertEqual(basketballSport?.numberOfEvents, 15)
    }
    
    func testMapSportsFromSocketResponse() {
        // Given
        let socketResponse: [String: Any] = [
            "kwargs": [
                "records": [
                    [
                        "id": "1",
                        "name": "Football"
                    ],
                    [
                        "id": "2",
                        "name": "Basketball" 
                    ]
                ]
            ]
        ]
        
        var existingSports: [Sport] = []
        
        // When
        let mappedSports = SportMapper.mapSportsFromSocketResponse(
            socketResponse,
            context: "live",
            existingSports: &existingSports
        )
        
        // Then
        XCTAssertEqual(mappedSports.count, 2)
        XCTAssertEqual(existingSports.count, 2)
        
        // Test alternative format
        let directResponse: [String: Any] = [
            "records": [
                [
                    "id": "3",
                    "name": "Tennis"
                ]
            ]
        ]
        
        let moreMappedSports = SportMapper.mapSportsFromSocketResponse(
            directResponse,
            context: "popular",
            existingSports: &existingSports
        )
        
        XCTAssertEqual(moreMappedSports.count, 1)
        XCTAssertEqual(existingSports.count, 3)
    }
    
    func testMapSportsFromEmptySocketResponse() {
        // Given
        let emptyResponse: [String: Any] = [:]
        var existingSports: [Sport] = []
        
        // When
        let mappedSports = SportMapper.mapSportsFromSocketResponse(
            emptyResponse,
            context: "test",
            existingSports: &existingSports
        )
        
        // Then
        XCTAssertEqual(mappedSports.count, 0)
        XCTAssertEqual(existingSports.count, 0)
    }
} 