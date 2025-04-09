import XCTest
@testable import EveryMatrixAPIClient

final class EveryMatrixAPIClientTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        print("EveryMatrixAPIClientTests.setUp")
    }
    
    override class func tearDown() {
        super.tearDown()
        
        print("EveryMatrixAPIClientTests.tearDown")
    }
    
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
    
    func testSimpleMath() throws {
        XCTAssertEqual(1 + 1, 2, "Simple math check failed")
    }
    
}
