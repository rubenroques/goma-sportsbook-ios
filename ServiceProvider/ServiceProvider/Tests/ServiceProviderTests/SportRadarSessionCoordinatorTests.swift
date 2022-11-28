//
//  SportRadarSessionCoordinatorTests.swift
//  
//
//  Created by Ruben Roques on 16/11/2022.
//

import XCTest
import Combine

@testable import ServiceProvider

final class SportRadarSessionCoordinatorTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    func testClear() throws {
        let expectation = self.expectation(description: "Tokenization")
        
        var output: [String?] = []
        
        let sessionCoordinator = SportRadarSessionCoordinator()
        
        sessionCoordinator.token(forKey: .launchToken)
            .sink { completion in
                expectation.fulfill()
            } receiveValue: { launchToken in
                output.append(launchToken)
            }
            .store(in: &cancellables)
        
        sessionCoordinator.saveToken("abc", withKey: .launchToken)
        sessionCoordinator.clearSession()
                
        waitForExpectations(timeout: 2)
        
        XCTAssertEqual(output.count, 3, "Incorrect elements count")
        XCTAssertEqual(output, [nil, Optional<String>("abc"), nil], "Incorrect elements \(dump(sessionCoordinator))")
    }

}
