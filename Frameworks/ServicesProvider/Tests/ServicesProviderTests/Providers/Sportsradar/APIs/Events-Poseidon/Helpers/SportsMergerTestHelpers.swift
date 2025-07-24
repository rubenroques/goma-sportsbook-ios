import Foundation
import XCTest
import Combine
@testable import ServicesProvider

// MARK: - Test Sport Creation
extension SportType {
    static func createTestSport(
        id: String = UUID().uuidString,
        name: String = "Test Sport",
        alphaId: String? = nil,
        numericId: String? = nil,
        iconId: String? = nil,
        showEventCategory: Bool = false,
        numberEvents: Int = 0,
        numberLiveEvents: Int = 0,
        numberOutrightEvents: Int = 0,
        numberOutrightMarkets: Int = 0
    ) -> SportType {
        return SportType(
            name: name,
            numericId: numericId ?? id,
            alphaId: alphaId ?? "TST",
            iconId: iconId,
            showEventCategory: showEventCategory,
            numberEvents: numberEvents,
            numberOutrightEvents: numberOutrightEvents,
            numberOutrightMarkets: numberOutrightMarkets,
            numberLiveEvents: numberLiveEvents
        )
    }
}

// MARK: - Test Content Identifiers
extension ContentIdentifier {
    static var allSports: ContentIdentifier {
        ContentIdentifier(contentType: .allSports, contentRoute: .allSports)
    }
    
    static var liveSports: ContentIdentifier {
        ContentIdentifier(contentType: .liveSports, contentRoute: .liveSports)
    }
}

// MARK: - Test Assertions
extension XCTestCase {
    func assertSportsEqual(
        _ actual: [SportType],
        _ expected: [SportType],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(actual.count, expected.count, "Sport count mismatch", file: file, line: line)
        
        for (actualSport, expectedSport) in zip(actual, expected) {
            XCTAssertEqual(actualSport.name, expectedSport.name, "Sport name mismatch", file: file, line: line)
            XCTAssertEqual(actualSport.alphaId, expectedSport.alphaId, "Sport alphaId mismatch", file: file, line: line)
            XCTAssertEqual(actualSport.numericId, expectedSport.numericId, "Sport numericId mismatch", file: file, line: line)
            XCTAssertEqual(actualSport.numberEvents, expectedSport.numberEvents, "Sport events count mismatch", file: file, line: line)
            XCTAssertEqual(actualSport.numberLiveEvents, expectedSport.numberLiveEvents, "Sport live events count mismatch", file: file, line: line)
            XCTAssertEqual(actualSport.numberOutrightEvents, expectedSport.numberOutrightEvents, "Sport outright events count mismatch", file: file, line: line)
            XCTAssertEqual(actualSport.numberOutrightMarkets, expectedSport.numberOutrightMarkets, "Sport outright markets count mismatch", file: file, line: line)
        }
    }
    
    func waitForPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) -> T.Output? {
        let expectation = expectation(description: "Waiting for publisher")
        var result: T.Output?
        
        let cancellable = publisher.sink(
            receiveCompletion: { _ in
                expectation.fulfill()
            },
            receiveValue: { value in
                result = value
                expectation.fulfill()
            }
        )
        
        wait(for: [expectation], timeout: timeout)
        cancellable.cancel()
        
        return result
    }
    
    func waitForPublisherError<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Error? {
        let expectation = expectation(description: "Waiting for publisher error")
        var receivedError: Error?
        
        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                }
                expectation.fulfill()
            },
            receiveValue: { _ in }
        )
        
        wait(for: [expectation], timeout: timeout)
        cancellable.cancel()
        
        return receivedError
    }
}

// MARK: - Test Constants
enum TestConstants {
    static let defaultTimeout: TimeInterval = 1.0
    static let extendedTimeout: TimeInterval = 5.0
    
    static let mockSessionToken = "test_session_token"
    
    // Common errors used in tests
    static let onSubscribeError = ServiceProviderError.onSubscribe
    static let invalidResponseError = ServiceProviderError.invalidResponse
    static let subscriptionNotFoundError = ServiceProviderError.subscriptionNotFound
    static let userSessionNotFoundError = ServiceProviderError.userSessionNotFound
    static let incompletedSportDataError = ServiceProviderError.incompletedSportData
    
    static func createTestSports(count: Int = 3) -> [SportType] {
        return (0..<count).map { i in
            SportType.createTestSport(
                id: "sport_\(i)",
                name: "Sport \(i)",
                alphaId: "SP\(i)",
                numericId: "\(i)",
                iconId: "icon_\(i)",
                showEventCategory: i % 2 == 0,
                numberEvents: 10,
                numberLiveEvents: i % 2 == 0 ? 5 : 0
            )
        }
    }
} 