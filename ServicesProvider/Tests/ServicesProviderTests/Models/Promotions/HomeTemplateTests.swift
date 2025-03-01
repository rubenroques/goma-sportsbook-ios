import XCTest
@testable import ServicesProvider

final class HomeTemplateTests: XCTestCase {

    // MARK: - HomeTemplate Tests

    func testHomeTemplateInitialization() {
        // Given
        let widgetData = HomeWidget.WidgetData(
            id: 1,
            type: "banners",
            description: "Test Banners Widget",
            userState: "any",
            sortOrder: 1,
            orientation: "horizontal"
        )

        let widget = HomeWidget.banners(widgetData)

        // When
        let template = HomeTemplate(id: 101, type: "home", widgets: [widget])

        // Then
        XCTAssertEqual(template.id, 101)
        XCTAssertEqual(template.type, "home")
        XCTAssertEqual(template.widgets.count, 1)

        if case let .banners(data) = template.widgets[0] {
            XCTAssertEqual(data.id, 1)
            XCTAssertEqual(data.type, "banners")
            XCTAssertEqual(data.description, "Test Banners Widget")
            XCTAssertEqual(data.userState, HomeWidget.WidgetData.UserState.any)
            XCTAssertEqual(data.sortOrder, 1)
            XCTAssertEqual(data.orientation, HomeWidget.WidgetData.Orientation.horizontal)
        } else {
            XCTFail("Wrong widget type")
        }
    }

    // MARK: - HomeWidget Tests

    func testHomeWidgetFallibleInitializer() {
        // Test successful initialization for each widget type
        var widget: HomeWidget?

        // Alert banners
        widget = HomeWidget(
            id: 1,
            type: "alertbanners",
            description: "Alert Banners",
            userState: "any",
            sortOrder: 1,
            orientation: "horizontal"
        )
        XCTAssertNotNil(widget)
        if case .alertBanners = widget! {
            // Success
        } else {
            XCTFail("Wrong widget type")
        }

        // Banners
        widget = HomeWidget(
            id: 2,
            type: "banners",
            description: "Banners",
            userState: "authenticated",
            sortOrder: 2,
            orientation: "vertical"
        )
        XCTAssertNotNil(widget)
        if case .banners = widget! {
            // Success
        } else {
            XCTFail("Wrong widget type")
        }

        // Carousel Events
        widget = HomeWidget(
            id: 3,
            type: "carouselevents",
            description: "Carousel Events",
            userState: "anonymous",
            sortOrder: 3,
            orientation: nil
        )
        XCTAssertNotNil(widget)
        if case .carouselEvents = widget! {
            // Success
        } else {
            XCTFail("Wrong widget type")
        }

        // Invalid type
        widget = HomeWidget(
            id: 999,
            type: "invalidType",
            description: "Invalid",
            userState: "any",
            sortOrder: 999,
            orientation: "horizontal"
        )
        XCTAssertNil(widget)
    }

    func testHomeWidgetDataInitialization() {
        // Test with valid orientation
        let widgetData1 = HomeWidget.WidgetData(
            id: 1,
            type: "banners",
            description: "Banners Widget",
            userState: "horizontal",
            sortOrder: 1,
            orientation: "horizontal"
        )

        XCTAssertEqual(widgetData1.id, 1)
        XCTAssertEqual(widgetData1.type, "banners")
        XCTAssertEqual(widgetData1.description, "Banners Widget")
        XCTAssertEqual(widgetData1.userState, HomeWidget.WidgetData.UserState.any)  // Default is "any" when userState is not valid
        XCTAssertEqual(widgetData1.sortOrder, 1)
        XCTAssertEqual(widgetData1.orientation, HomeWidget.WidgetData.Orientation.horizontal)

        // Test with nil orientation
        let widgetData2 = HomeWidget.WidgetData(
            id: 2,
            type: "stories",
            description: "Stories Widget",
            userState: "authenticated",
            sortOrder: 2,
            orientation: nil
        )

        XCTAssertEqual(widgetData2.id, 2)
        XCTAssertEqual(widgetData2.type, "stories")
        XCTAssertEqual(widgetData2.description, "Stories Widget")
        XCTAssertEqual(widgetData2.userState, HomeWidget.WidgetData.UserState.authenticated)
        XCTAssertEqual(widgetData2.sortOrder, 2)
        XCTAssertNil(widgetData2.orientation)

        // Test with invalid orientation
        let widgetData3 = HomeWidget.WidgetData(
            id: 3,
            type: "betSwipe",
            description: "BetSwipe Widget",
            userState: "anonymous",
            sortOrder: 3,
            orientation: "diagonal"  // Invalid orientation
        )

        XCTAssertEqual(widgetData3.id, 3)
        XCTAssertEqual(widgetData3.type, "betSwipe")
        XCTAssertEqual(widgetData3.description, "BetSwipe Widget")
        XCTAssertEqual(widgetData3.userState, HomeWidget.WidgetData.UserState.anonymous)
        XCTAssertEqual(widgetData3.sortOrder, 3)
        XCTAssertNil(widgetData3.orientation)  // Should be nil for invalid orientation
    }

    func testHomeWidgetConvenienceAccessors() {
        // Given
        let widgetData = HomeWidget.WidgetData(
            id: 5,
            type: "highlightedEvents",
            description: "Highlighted Events Widget",
            userState: "any",
            sortOrder: 5,
            orientation: "vertical"
        )

        let widget = HomeWidget.highlightedEvents(widgetData)

        // When/Then - Test all convenience accessors
        XCTAssertEqual(widget.id, 5)
        XCTAssertEqual(widget.type, "highlightedEvents")
        XCTAssertEqual(widget.description, "Highlighted Events Widget")
        XCTAssertEqual(widget.userType, HomeWidget.WidgetData.UserState.any)
        XCTAssertEqual(widget.sortOrder, 5)
        XCTAssertEqual(widget.orientation, HomeWidget.WidgetData.Orientation.vertical)

        // Verify that widgetData accessor returns the associated value
        XCTAssertEqual(widget.widgetData.id, 5)
        XCTAssertEqual(widget.widgetData.type, "highlightedEvents")
        XCTAssertEqual(widget.widgetData.description, "Highlighted Events Widget")
        XCTAssertEqual(widget.widgetData.userState, HomeWidget.WidgetData.UserState.any)
        XCTAssertEqual(widget.widgetData.sortOrder, 5)
        XCTAssertEqual(widget.widgetData.orientation, HomeWidget.WidgetData.Orientation.vertical)
    }
}