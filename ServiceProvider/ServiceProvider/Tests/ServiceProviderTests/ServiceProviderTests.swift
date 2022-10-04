import XCTest
@testable import ServiceProvider

final class ServiceProviderTests: XCTestCase {
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual("!", "!")
    }
    
    func testConnection() {
        
        print("\n\n")
        
        let serviceProvider = ServiceProvider.init(providerType: .sportsradar)
        serviceProvider.connect()
        
        let exp = expectation(description: "Loading socket")
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            
            print("\n\n")
            exp.fulfill()
        }
        waitForExpectations(timeout: 10)
        
        
    }
    
}
