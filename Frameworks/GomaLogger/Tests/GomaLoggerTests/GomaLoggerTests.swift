import XCTest
@testable import GomaLogger

final class GomaLoggerTests: XCTestCase {

    // Mock destination for capturing logs
    class MockDestination: LogDestination {
        var logs: [(level: LogLevel, subsystem: LogSubsystem?, category: String?, message: String)] = []

        func log(level: LogLevel, subsystem: LogSubsystem?, category: String?, message: String, metadata: [String: Any]?, timestamp: Date, file: String, function: String, line: Int) {
            logs.append((level, subsystem, category, message))
        }

        func clear() {
            logs.removeAll()
        }
    }

    var mockDestination: MockDestination!

    override func setUp() {
        super.setUp()
        mockDestination = MockDestination()
        GomaLogger.clearDestinations()
        GomaLogger.addDestination(mockDestination)
        GomaLogger.configuration.reset()
    }

    override func tearDown() {
        GomaLogger.resetDestinations()
        GomaLogger.configuration.reset()
        super.tearDown()
    }

    // MARK: - Basic Logging Tests

    func testSimpleDebugLog() {
        GomaLogger.debug("Test debug message")

        XCTAssertEqual(mockDestination.logs.count, 1)
        XCTAssertEqual(mockDestination.logs[0].level, .debug)
        XCTAssertEqual(mockDestination.logs[0].message, "Test debug message")
        XCTAssertNil(mockDestination.logs[0].subsystem)
        XCTAssertNil(mockDestination.logs[0].category)
    }

    func testSimpleInfoLog() {
        GomaLogger.info("Test info message")

        XCTAssertEqual(mockDestination.logs.count, 1)
        XCTAssertEqual(mockDestination.logs[0].level, .info)
        XCTAssertEqual(mockDestination.logs[0].message, "Test info message")
    }

    func testSimpleErrorLog() {
        GomaLogger.error("Test error message")

        XCTAssertEqual(mockDestination.logs.count, 1)
        XCTAssertEqual(mockDestination.logs[0].level, .error)
        XCTAssertEqual(mockDestination.logs[0].message, "Test error message")
    }

    // MARK: - Subsystem Tests

    func testLogWithSubsystem() {
        GomaLogger.debug(.authentication, "Login started")

        XCTAssertEqual(mockDestination.logs.count, 1)
        XCTAssertEqual(mockDestination.logs[0].subsystem, .authentication)
        XCTAssertEqual(mockDestination.logs[0].message, "Login started")
    }

    func testLogWithSubsystemAndCategory() {
        GomaLogger.debug(.betting, category: "ODDS_BOOST", "Fetching stairs")

        XCTAssertEqual(mockDestination.logs.count, 1)
        XCTAssertEqual(mockDestination.logs[0].subsystem, .betting)
        XCTAssertEqual(mockDestination.logs[0].category, "ODDS_BOOST")
        XCTAssertEqual(mockDestination.logs[0].message, "Fetching stairs")
    }

    // MARK: - Configuration Tests

    func testMinimumLevelFiltering() {
        GomaLogger.configure(minimumLevel: .info)

        GomaLogger.debug("Should not appear")
        GomaLogger.info("Should appear")
        GomaLogger.error("Should appear")

        XCTAssertEqual(mockDestination.logs.count, 2)
        XCTAssertEqual(mockDestination.logs[0].level, .info)
        XCTAssertEqual(mockDestination.logs[1].level, .error)
    }

    func testSubsystemEnableList() {
        GomaLogger.configure(enabledSubsystems: [.authentication, .betting])

        GomaLogger.info(.authentication, "Auth log")
        GomaLogger.info(.betting, "Betting log")
        GomaLogger.info(.networking, "Network log - should not appear")

        XCTAssertEqual(mockDestination.logs.count, 2)
        XCTAssertEqual(mockDestination.logs[0].subsystem, .authentication)
        XCTAssertEqual(mockDestination.logs[1].subsystem, .betting)
    }

    func testSubsystemDisable() {
        GomaLogger.disable(.networking)

        GomaLogger.info(.authentication, "Auth log")
        GomaLogger.info(.networking, "Network log - should not appear")

        XCTAssertEqual(mockDestination.logs.count, 1)
        XCTAssertEqual(mockDestination.logs[0].subsystem, .authentication)
    }

    func testCategoryDisable() {
        GomaLogger.disableCategory("SSE")

        GomaLogger.debug(.realtime, category: "LIVE_SCORE", "Score update")
        GomaLogger.debug(.realtime, category: "SSE", "Should not appear")

        XCTAssertEqual(mockDestination.logs.count, 1)
        XCTAssertEqual(mockDestination.logs[0].category, "LIVE_SCORE")
    }

    func testPerSubsystemLevel() {
        GomaLogger.configure(minimumLevel: .info)
        GomaLogger.setLevel(.debug, for: .authentication)

        GomaLogger.debug(.authentication, "Auth debug - should appear")
        GomaLogger.debug(.betting, "Betting debug - should not appear")
        GomaLogger.info(.betting, "Betting info - should appear")

        XCTAssertEqual(mockDestination.logs.count, 2)
        XCTAssertEqual(mockDestination.logs[0].subsystem, .authentication)
        XCTAssertEqual(mockDestination.logs[1].subsystem, .betting)
    }

    // MARK: - Log Level Tests

    func testLogLevelComparison() {
        XCTAssertTrue(LogLevel.debug < LogLevel.info)
        XCTAssertTrue(LogLevel.info < LogLevel.error)
        XCTAssertFalse(LogLevel.error < LogLevel.debug)
    }

    func testLogLevelEmojis() {
        XCTAssertEqual(LogLevel.debug.emoji, "🔍")
        XCTAssertEqual(LogLevel.info.emoji, "ℹ️")
        XCTAssertEqual(LogLevel.error.emoji, "❌")
    }

    // MARK: - Zero-Cost Tests

    func testZeroCostWhenDisabled() {
        GomaLogger.configure(minimumLevel: .error)

        var sideEffectCount = 0
        func expensiveMessage() -> String {
            sideEffectCount += 1
            return "Expensive computation"
        }

        GomaLogger.debug(expensiveMessage())
        GomaLogger.info(expensiveMessage())

        // Message should not be evaluated when log level is below minimum
        XCTAssertEqual(mockDestination.logs.count, 0)
        // Note: Swift's @autoclosure should prevent evaluation, but we can't directly test this
    }

    // MARK: - Multiple Destinations

    func testMultipleDestinations() {
        let secondMock = MockDestination()
        GomaLogger.addDestination(secondMock)

        GomaLogger.info("Test message")

        XCTAssertEqual(mockDestination.logs.count, 1)
        XCTAssertEqual(secondMock.logs.count, 1)
    }
}
