//
//  BetssonCameroonAppTests.swift
//  BetssonCameroonAppTests
//
//  Created by Ruben Roques on 21/07/2025.
//

import XCTest
@testable import BetssonCameroonApp

final class BetssonCameroonAppTests: XCTestCase {

    func testTestConfigurationIsWorking() throws {
        XCTAssertTrue(true, "Test configuration is working correctly")
    }

    func testCanImportAppModule() throws {
        XCTAssertNotNil(Bundle.main)
    }
}
