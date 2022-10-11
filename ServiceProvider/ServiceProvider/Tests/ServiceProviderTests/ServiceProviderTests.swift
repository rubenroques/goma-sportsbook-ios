import XCTest
import Combine

@testable import ServiceProvider

final class ServiceProviderTests: XCTestCase {
    
    private var cancellables: Set<AnyCancellable> = []
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual("!", "!")
    }
    
    func testConnection() {
        
        print("\n\n")
        
        let serviceProvider = ServiceProvider(providerType: .sportradar)
        serviceProvider.connect()
        
        serviceProvider.eventsConnectionStatePublisher?.sink(receiveCompletion: { completion in
            print("eventsConnectionStatePublisher completion")
        }, receiveValue: { connectionState in
            if connectionState == .connected {
                serviceProvider.subscribeLiveMatches(forSportType: .football)?.sink(receiveCompletion: { completion in
                        print("subscribeLiveMatches completion")
                    }, receiveValue: { eventsGroups in
                        switch eventsGroups {
                        case .connected:
                            print("subscribeLiveMatches connected")
                        case .content(let eventsGroup):
                            print("subscribeLiveMatches content \(eventsGroup)")
                        case .disconnected:
                            print("subscribeLiveMatches disconnected")
                        }
                    }).store(in: &self.cancellables)
            }
        })
        .store(in: &self.cancellables)
        
        let exp = expectation(description: "Loading socket")
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            
            print("\n\n")
            exp.fulfill()
        }
        waitForExpectations(timeout: 20)
        
        
    }
    
}
