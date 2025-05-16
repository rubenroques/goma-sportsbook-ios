import XCTest
import Foundation
import Combine // Keep Combine for handling AnyPublisher
@testable import PresentationProvider

// Moved top-level tests into their own XCTestCase class
class PresentationModelLogicTests: XCTestCase {

    func testTabIdentifierDecoding() {
        let sportsId = TabIdentifier.sports
        XCTAssertEqual(sportsId.rawValue, "sports")
        XCTAssertNotEqual(TabIdentifier.sports, TabIdentifier.casino)
    }

    func testNavbarIdentifierDecoding() {
        let sportsNavbar = NavbarIdentifier.sports
        XCTAssertEqual(sportsNavbar.rawValue, "sports")
        XCTAssertNotEqual(NavbarIdentifier.sports, NavbarIdentifier.casino)
    }

    func testConvenienceMethods() {
        let sportsTab = TabItem(
            tabId: .sports,
            route: "sports",
            label: "Sports",
            icon: "sports_icon",
            context: "sports_ctx",
            switchToNavbar: .sports
        )
        
        let liveTab = TabItem(
            tabId: .live,
            route: "live",
            label: "Live",
            icon: "live_icon",
            context: "sports_ctx",
            switchToNavbar: nil
        )
        
        let sportsNavbar = NavigationBarLayout(
            id: .sports,
            route: "sports",
            tabs: [.sports, .live]
        )
        
        // Assuming PresentationConfiguration takes these specific model types based on these tests
        let config = PresentationConfiguration(
            tabItems: [sportsTab, liveTab], 
            navbars: [sportsNavbar]
        )
        
        let foundNavbar = config.navbar(withId: .sports)
        XCTAssertNotNil(foundNavbar)
        XCTAssertEqual(foundNavbar?.id, .sports)
        
        let foundSportsTab = config.tabItem(withId: .sports)
        XCTAssertNotNil(foundSportsTab)
        XCTAssertEqual(foundSportsTab?.tabId, .sports)
        
        let navbarTabs = config.tabItems(forNavbar: .sports)
        XCTAssertEqual(navbarTabs.count, 2)
        
        XCTAssertTrue(config.validate())
    }
}

// Helper function remains outside the class
func loadRawTestData(fileName: String, fileExtension: String = "json", fromBundle bundle: Bundle) throws -> Data {
    guard let url = bundle.url(forResource: fileName, withExtension: fileExtension) else {
        throw NSError(domain: "TestDataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "File \(fileName).\(fileExtension) not found in bundle \(bundle.bundlePath)"])
    }
    return try Data(contentsOf: url)
}


class LocalJSONPresentationFetcherTests: XCTestCase {
    
}
