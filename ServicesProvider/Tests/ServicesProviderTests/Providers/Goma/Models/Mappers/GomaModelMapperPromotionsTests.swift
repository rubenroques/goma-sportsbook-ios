import XCTest
@testable import ServicesProvider

final class GomaModelMapperPromotionsTests: XCTestCase {
    
    // MARK: - Home Template Tests
    
    func testHomeTemplateMapping() {
        // Given
        let internalWidget = GomaModels.HomeWidget(
            id: "1",
            type: "banners",
            description: "Test Banner Widget",
            userType: "any",
            sortOrder: 1,
            orientation: "horizontal"
        )
        
        let internalTemplate = GomaModels.HomeTemplate(
            id: 101,
            type: "home",
            widgets: [internalWidget]
        )
        
        // When
        let result = GomaModelMapper.homeTemplate(fromInternalHomeTemplate: internalTemplate)
        
        // Then
        XCTAssertEqual(result.id, 101)
        XCTAssertEqual(result.type, "home")
        XCTAssertEqual(result.widgets.count, 1)
        
        if case let .banners(widgetData) = result.widgets.first! {
            XCTAssertEqual(widgetData.id, 1)
            XCTAssertEqual(widgetData.type, "banners")
            XCTAssertEqual(widgetData.description, "Test Banner Widget")
            XCTAssertEqual(widgetData.userState, .any)
            XCTAssertEqual(widgetData.sortOrder, 1)
            XCTAssertEqual(widgetData.orientation, .horizontal)
        } else {
            XCTFail("Wrong widget type")
        }
    }
    
    // MARK: - Alert Banner Tests
    
    func testAlertBannerMapping() {
        // Given
        let internalBanner = GomaModels.AlertBannerData(
            id: 123,
            title: "Alert Title",
            content: "Alert Content",
            backgroundColor: "#FF0000",
            textColor: "#FFFFFF",
            actionType: "deeplink",
            actionTarget: "app://promo/1",
            startDate: "2024-05-10T10:00:00Z",
            endDate: "2024-05-20T10:00:00Z",
            status: "active",
            imageUrl: "https://example.com/image.jpg"
        )
        
        // When
        let result = GomaModelMapper.alertBanner(fromInternalAlertBanner: internalBanner)
        
        // Then
        XCTAssertEqual(result.id, "123")
        XCTAssertEqual(result.title, "Alert Title")
        XCTAssertNil(result.subtitle)
        XCTAssertEqual(result.content, "Alert Content")
        XCTAssertEqual(result.backgroundColor, "#FF0000")
        XCTAssertEqual(result.textColor, "#FFFFFF")
        XCTAssertNil(result.callToActionText)
        XCTAssertEqual(result.actionType, "deeplink")
        XCTAssertEqual(result.actionTarget, "app://promo/1")
        XCTAssertTrue(result.isActive)
        XCTAssertEqual(result.status, "active")
        XCTAssertEqual(result.imageUrl?.absoluteString, "https://example.com/image.jpg")
    }
    
    // MARK: - Banner Tests
    
    func testBannerMapping() {
        // Given
        let internalBanner = GomaModels.BannerData(
            id: 456,
            title: "Banner Title",
            subtitle: "Banner Subtitle",
            actionType: "url",
            actionTarget: "https://example.com",
            startDate: "2024-05-10T10:00:00Z",
            endDate: "2024-05-20T10:00:00Z",
            status: "active",
            imageUrl: "https://example.com/banner.jpg"
        )
        
        // When
        let result = GomaModelMapper.banner(fromInternalBanner: internalBanner)
        
        // Then
        XCTAssertEqual(result.id, "456")
        XCTAssertEqual(result.title, "Banner Title")
        XCTAssertEqual(result.subtitle, "Banner Subtitle")
        XCTAssertEqual(result.actionType, "url")
        XCTAssertEqual(result.actionTarget, "https://example.com")
        XCTAssertNil(result.callToActionText)
        XCTAssertTrue(result.isActive)
        XCTAssertEqual(result.status, "active")
        XCTAssertEqual(result.imageUrl?.absoluteString, "https://example.com/banner.jpg")
    }
    
    func testBannersMapping() {
        // Given
        let internalBanners = [
            GomaModels.BannerData(
                id: 456,
                title: "Banner Title 1",
                subtitle: "Banner Subtitle 1",
                actionType: "url",
                actionTarget: "https://example.com/1",
                startDate: "2024-05-10T10:00:00Z",
                endDate: "2024-05-20T10:00:00Z",
                status: "active",
                imageUrl: "https://example.com/banner1.jpg"
            ),
            GomaModels.BannerData(
                id: 457,
                title: "Banner Title 2",
                subtitle: "Banner Subtitle 2",
                actionType: "deeplink",
                actionTarget: "app://promo/2",
                startDate: "2024-05-10T10:00:00Z",
                endDate: "2024-05-20T10:00:00Z",
                status: "inactive",
                imageUrl: nil
            )
        ]
        
        // When
        let results = GomaModelMapper.banners(fromInternalBanners: internalBanners)
        
        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].id, "456")
        XCTAssertEqual(results[0].title, "Banner Title 1")
        XCTAssertEqual(results[1].id, "457")
        XCTAssertEqual(results[1].title, "Banner Title 2")
        XCTAssertFalse(results[1].isActive)
        XCTAssertNil(results[1].imageUrl)
    }
    
    // MARK: - Sport Banner Tests
    
    func testSportBannerMapping() {
        // Given
        let internalTeamHome = GomaModels.TeamData(
            id: 11,
            name: "Home Team",
            logo: "https://example.com/home-logo.png"
        )
        
        let internalTeamAway = GomaModels.TeamData(
            id: 22,
            name: "Away Team",
            logo: "https://example.com/away-logo.png"
        )
        
        let internalEvent = GomaModels.SportEventData(
            id: 555,
            sportId: 1,
            homeTeamId: 11,
            awayTeamId: 22,
            dateTime: "2024-05-15T15:00:00Z",
            homeTeam: internalTeamHome,
            awayTeam: internalTeamAway,
            market: nil
        )
        
        let internalBanner = GomaModels.SportBannerData(
            id: 789,
            title: "Sport Banner Title",
            subtitle: "Sport Banner Subtitle",
            startDate: "2024-05-10T10:00:00Z",
            endDate: "2024-05-20T10:00:00Z",
            status: "active",
            imageUrl: "https://example.com/sport-banner.jpg",
            sportEventId: 555,
            event: internalEvent
        )
        
        // When
        let result = GomaModelMapper.sportBanner(fromInternalSportBanner: internalBanner)
        
        // Then
        XCTAssertEqual(result.id, 789)
        XCTAssertEqual(result.title, "Sport Banner Title")
        XCTAssertEqual(result.subtitle, "Sport Banner Subtitle")
        XCTAssertEqual(result.sportEventId, 555)
        XCTAssertEqual(result.status, "active")
        XCTAssertEqual(result.imageUrl?.absoluteString, "https://example.com/sport-banner.jpg")
        
        XCTAssertNotNil(result.event)
        XCTAssertEqual(result.event?.id, 555)
        XCTAssertEqual(result.event?.homeTeam, "Home Team")
        XCTAssertEqual(result.event?.awayTeam, "Away Team")
        XCTAssertEqual(result.event?.homeTeamLogo?.absoluteString, "https://example.com/home-logo.png")
        XCTAssertEqual(result.event?.awayTeamLogo?.absoluteString, "https://example.com/away-logo.png")
    }
    
    // MARK: - Pro Choice Tests
    
    func testProChoiceMapping() {
        // Given
        let internalTipster = GomaModels.ProChoiceData.TipsterData(
            id: 123,
            name: "Expert Tipster",
            winRate: 0.75,
            avatar: "https://example.com/avatar.jpg"
        )
        
        let internalEvent = GomaModels.ProChoiceData.EventSummaryData(
            id: 456,
            homeTeam: "Home Team",
            awayTeam: "Away Team",
            dateTime: "2024-05-15T15:00:00Z"
        )
        
        let internalSelection = GomaModels.ProChoiceData.SelectionData(
            marketName: "Match Result",
            outcomeName: "Home Win",
            odds: 2.1
        )
        
        let internalProChoice = GomaModels.ProChoiceData(
            id: 789,
            title: "Top Pick of the Day",
            tipster: internalTipster,
            event: internalEvent,
            selection: internalSelection,
            reasoning: "The home team has been in excellent form."
        )
        
        // When
        let result = GomaModelMapper.proChoice(fromInternalProChoice: internalProChoice)
        
        // Then
        XCTAssertEqual(result.id, 789)
        XCTAssertEqual(result.title, "Top Pick of the Day")
        XCTAssertEqual(result.reasoning, "The home team has been in excellent form.")
        
        XCTAssertEqual(result.tipster.id, 123)
        XCTAssertEqual(result.tipster.name, "Expert Tipster")
        XCTAssertEqual(result.tipster.winRate, 0.75)
        XCTAssertEqual(result.tipster.avatar?.absoluteString, "https://example.com/avatar.jpg")
        
        XCTAssertEqual(result.event.id, 456)
        XCTAssertEqual(result.event.homeTeam, "Home Team")
        XCTAssertEqual(result.event.awayTeam, "Away Team")
        
        XCTAssertEqual(result.selection.marketName, "Match Result")
        XCTAssertEqual(result.selection.outcomeName, "Home Win")
        XCTAssertEqual(result.selection.odds, 2.1)
    }
} 