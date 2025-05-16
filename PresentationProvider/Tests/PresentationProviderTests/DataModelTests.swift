import XCTest
@testable import PresentationProvider
import Foundation

class DataModelTests: XCTestCase {

    func testTabBarItemConfigCodable() throws {
        let originalItem = TabBarItemConfig(
            id: "testTab",
            title: "Test Tab",
            iconName: "test.icon",
            viewControllerIdentifier: "TestViewController",
            order: 1
        )

        // Encode
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys // For consistent output for comparison
        let jsonData = try encoder.encode(originalItem)

        // Decode
        let decoder = JSONDecoder()
        let decodedItem = try decoder.decode(TabBarItemConfig.self, from: jsonData)

        // Assert
        XCTAssertEqual(decodedItem.id, originalItem.id, "Decoded id should match original")
        XCTAssertEqual(decodedItem.title, originalItem.title, "Decoded title should match original")
        XCTAssertEqual(decodedItem.iconName, originalItem.iconName, "Decoded iconName should match original")
        XCTAssertEqual(decodedItem.viewControllerIdentifier, originalItem.viewControllerIdentifier, "Decoded viewControllerIdentifier should match original")
        XCTAssertEqual(decodedItem.order, originalItem.order, "Decoded order should match original")
        
        // Check Identifiable conformance (id property)
        XCTAssertEqual(decodedItem.id, "testTab", "ID should be 'testTab' for Identifiable conformance check")
    }

    func testPresentationConfigurationCodable() throws {
        let item1 = TabBarItemConfig(id: "home", title: "Home", iconName: "home.fill", viewControllerIdentifier: "HomeVC", order: 0)
        let item2 = TabBarItemConfig(id: "profile", title: "Profile", iconName: "person.fill", viewControllerIdentifier: "ProfileVC", order: 1)
        
        // As per your original LocalJSONPresentationFetcherTests, PresentationConfiguration seems to have `tabItems` and `navbars`
        // Let's assume this is the actual structure. If it's `tabBarItems` from the README, this needs to match.
        // For now, matching the README's `PresentationConfiguration` which only had `tabBarItems`.
        // The `valid_config.json` includes `navbars`, but `PresentationConfiguration` in README did not.
        // `JSONDecoder` ignores unknown keys by default.
        let originalConfig = PresentationConfiguration(tabBarItems: [item1, item2]) // Using tabBarItems as per earlier assumptions

        // Encode
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let jsonData = try encoder.encode(originalConfig)

        // Decode
        let decoder = JSONDecoder()
        let decodedConfig = try decoder.decode(PresentationConfiguration.self, from: jsonData)

        // Assert
        XCTAssertEqual(decodedConfig.tabBarItems.count, originalConfig.tabBarItems.count, "Decoded tabBarItems count should match original")
        
        guard decodedConfig.tabBarItems.count == 2 else {
            XCTFail("Incorrect number of items after decoding PresentationConfiguration. Expected 2, got \(decodedConfig.tabBarItems.count)")
            return
        }

        XCTAssertEqual(decodedConfig.tabBarItems[0].id, item1.id, "First decoded item's id should match original item1 id")
        XCTAssertEqual(decodedConfig.tabBarItems[0].title, item1.title, "First decoded item's title should match original item1 title")
        XCTAssertEqual(decodedConfig.tabBarItems[1].id, item2.id, "Second decoded item's id should match original item2 id")
        XCTAssertEqual(decodedConfig.tabBarItems[1].title, item2.title, "Second decoded item's title should match original item2 title")
    }
    
    func testPresentationConfigurationDecodingIgnoresExtraKeys() throws {
        let jsonString = """
        {
            "tabBarItems": [
                {
                    "id": "discover",
                    "title": "Discover",
                    "iconName": "magnifyingglass",
                    "viewControllerIdentifier": "DiscoverVC",
                    "order": 0
                }
            ],
            "someOtherFutureKey": "someValue",
            "featureFlags": {
                "newHomePage": true
            },
            "navbars": [] // Added to reflect it could be in JSON, but ignored by current model
        }
        """
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        
        // Act: Attempt to decode
        let decodedConfig = try decoder.decode(PresentationConfiguration.self, from: jsonData)
        
        // Assert: Decoding succeeded and known properties are present
        XCTAssertEqual(decodedConfig.tabBarItems.count, 1, "Should decode 1 tab item despite extra keys.")
        if !decodedConfig.tabBarItems.isEmpty {
            XCTAssertEqual(decodedConfig.tabBarItems[0].id, "discover", "Tab item ID should be 'discover'")
        }
        // This implicitly tests that no error was thrown due to extra keys, as decode would throw.
    }
} 