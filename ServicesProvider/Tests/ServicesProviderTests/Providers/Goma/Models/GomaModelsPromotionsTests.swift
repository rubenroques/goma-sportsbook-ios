import XCTest
@testable import ServicesProvider

final class GomaModelsPromotionsTests: XCTestCase {
    
    // MARK: - HomeTemplate Tests
    
    func testHomeTemplateDecoding() {
        // Given
        let json = """
        {
            "id": 101,
            "name": "home",
            "widgets": [
                {
                    "id": "1",
                    "name": "banners",
                    "description": "Rotating banners",
                    "user_type": "any",
                    "sort_order": 1,
                    "orientation": "horizontal"
                },
                {
                    "id": "2",
                    "name": "alertbanners",
                    "description": "Alert messages",
                    "user_type": "authenticated",
                    "sort_order": 2,
                    "orientation": null
                }
            ]
        }
        """
        
        let jsonData = json.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let template = try! decoder.decode(GomaModels.HomeTemplate.self, from: jsonData)
        
        // Then
        XCTAssertEqual(template.id, 101)
        XCTAssertEqual(template.type, "home")
        XCTAssertEqual(template.widgets.count, 2)
        
        // First widget
        XCTAssertEqual(template.widgets[0].id, "1")
        XCTAssertEqual(template.widgets[0].type, "banners")
        XCTAssertEqual(template.widgets[0].description, "Rotating banners")
        XCTAssertEqual(template.widgets[0].userType, "any")
        XCTAssertEqual(template.widgets[0].sortOrder, 1)
        XCTAssertEqual(template.widgets[0].orientation, "horizontal")
        
        // Second widget
        XCTAssertEqual(template.widgets[1].id, "2")
        XCTAssertEqual(template.widgets[1].type, "alertbanners")
        XCTAssertEqual(template.widgets[1].description, "Alert messages")
        XCTAssertEqual(template.widgets[1].userType, "authenticated")
        XCTAssertEqual(template.widgets[1].sortOrder, 2)
        XCTAssertNil(template.widgets[1].orientation)
    }
    
    // MARK: - AlertBanner Tests
    
    func testAlertBannerDecoding() {
        // Given
        let json = """
        {
            "id": 123,
            "title": "Important Notice",
            "content": "This is an important notice for all users",
            "background_color": "#FF0000",
            "text_color": "#FFFFFF",
            "action_type": "deeplink",
            "action_target": "app://settings",
            "start_date": "2024-05-10T10:00:00Z",
            "end_date": "2024-05-20T10:00:00Z",
            "status": "active",
            "image_url": "https://example.com/notice.jpg"
        }
        """
        
        let jsonData = json.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let banner = try! decoder.decode(GomaModels.AlertBannerData.self, from: jsonData)
        
        // Then
        XCTAssertEqual(banner.id, 123)
        XCTAssertEqual(banner.title, "Important Notice")
        XCTAssertEqual(banner.content, "This is an important notice for all users")
        XCTAssertEqual(banner.backgroundColor, "#FF0000")
        XCTAssertEqual(banner.textColor, "#FFFFFF")
        XCTAssertEqual(banner.actionType, "deeplink")
        XCTAssertEqual(banner.actionTarget, "app://settings")
        XCTAssertEqual(banner.startDate, "2024-05-10T10:00:00Z")
        XCTAssertEqual(banner.endDate, "2024-05-20T10:00:00Z")
        XCTAssertEqual(banner.status, "active")
        XCTAssertEqual(banner.imageUrl, "https://example.com/notice.jpg")
    }
    
    // MARK: - Banner Tests
    
    func testBannerDecoding() {
        // Given
        let json = """
        {
            "id": 456,
            "title": "Special Offer",
            "subtitle": "Limited time only",
            "action_type": "url",
            "action_target": "https://example.com/offer",
            "start_date": "2024-05-10T10:00:00Z",
            "end_date": "2024-05-20T10:00:00Z",
            "status": "active",
            "image_url": "https://example.com/offer.jpg"
        }
        """
        
        let jsonData = json.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let banner = try! decoder.decode(GomaModels.BannerData.self, from: jsonData)
        
        // Then
        XCTAssertEqual(banner.id, 456)
        XCTAssertEqual(banner.title, "Special Offer")
        XCTAssertEqual(banner.subtitle, "Limited time only")
        XCTAssertEqual(banner.actionType, "url")
        XCTAssertEqual(banner.actionTarget, "https://example.com/offer")
        XCTAssertEqual(banner.startDate, "2024-05-10T10:00:00Z")
        XCTAssertEqual(banner.endDate, "2024-05-20T10:00:00Z")
        XCTAssertEqual(banner.status, "active")
        XCTAssertEqual(banner.imageUrl, "https://example.com/offer.jpg")
    }
    
    // MARK: - SportEvent Tests
    
    func testSportEventDecoding() {
        // Given
        let json = """
        {
            "id": 789,
            "sport_id": 1,
            "home_team_id": 101,
            "away_team_id": 102,
            "date_time": "2024-05-15T15:00:00Z",
            "home_team": {
                "id": 101,
                "name": "Home Team",
                "logo": "https://example.com/home-logo.png"
            },
            "away_team": {
                "id": 102,
                "name": "Away Team",
                "logo": "https://example.com/away-logo.png"
            },
            "market": {
                "id": 1001,
                "name": "Match Result",
                "outcomes": [
                    {
                        "id": 2001,
                        "name": "Home Win",
                        "price": 2.1
                    },
                    {
                        "id": 2002,
                        "name": "Draw",
                        "price": 3.4
                    },
                    {
                        "id": 2003,
                        "name": "Away Win",
                        "price": 3.8
                    }
                ]
            }
        }
        """
        
        let jsonData = json.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let sportEvent = try! decoder.decode(GomaModels.SportEventData.self, from: jsonData)
        
        // Then
        XCTAssertEqual(sportEvent.id, 789)
        XCTAssertEqual(sportEvent.sportId, 1)
        XCTAssertEqual(sportEvent.homeTeamId, 101)
        XCTAssertEqual(sportEvent.awayTeamId, 102)
        XCTAssertEqual(sportEvent.dateTime, "2024-05-15T15:00:00Z")
        
        // Home team
        XCTAssertEqual(sportEvent.homeTeam.id, 101)
        XCTAssertEqual(sportEvent.homeTeam.name, "Home Team")
        XCTAssertEqual(sportEvent.homeTeam.logo, "https://example.com/home-logo.png")
        
        // Away team
        XCTAssertEqual(sportEvent.awayTeam.id, 102)
        XCTAssertEqual(sportEvent.awayTeam.name, "Away Team")
        XCTAssertEqual(sportEvent.awayTeam.logo, "https://example.com/away-logo.png")
        
        // Market
        XCTAssertNotNil(sportEvent.market)
        XCTAssertEqual(sportEvent.market?.id, 1001)
        XCTAssertEqual(sportEvent.market?.name, "Match Result")
        XCTAssertEqual(sportEvent.market?.outcomes.count, 3)
        
        // Outcomes
        XCTAssertEqual(sportEvent.market?.outcomes[0].id, 2001)
        XCTAssertEqual(sportEvent.market?.outcomes[0].name, "Home Win")
        XCTAssertEqual(sportEvent.market?.outcomes[0].price, 2.1)
        
        XCTAssertEqual(sportEvent.market?.outcomes[1].id, 2002)
        XCTAssertEqual(sportEvent.market?.outcomes[1].name, "Draw")
        XCTAssertEqual(sportEvent.market?.outcomes[1].price, 3.4)
        
        XCTAssertEqual(sportEvent.market?.outcomes[2].id, 2003)
        XCTAssertEqual(sportEvent.market?.outcomes[2].name, "Away Win")
        XCTAssertEqual(sportEvent.market?.outcomes[2].price, 3.8)
    }
    
    // MARK: - ProChoice Tests
    
    func testProChoiceDecoding() {
        // Given
        let json = """
        {
            "id": 555,
            "title": "Top Pick of the Day",
            "tipster": {
                "id": 123,
                "name": "Expert Tipster",
                "win_rate": 0.75,
                "avatar": "https://example.com/avatar.jpg"
            },
            "event": {
                "id": 789,
                "home_team": "Home Team",
                "away_team": "Away Team",
                "date_time": "2024-05-15T15:00:00Z"
            },
            "selection": {
                "market_name": "Match Result",
                "outcome_name": "Home Win",
                "odds": 2.1
            },
            "reasoning": "The home team has been in excellent form, winning their last 5 matches."
        }
        """
        
        let jsonData = json.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let proChoice = try! decoder.decode(GomaModels.ProChoiceData.self, from: jsonData)
        
        // Then
        XCTAssertEqual(proChoice.id, 555)
        XCTAssertEqual(proChoice.title, "Top Pick of the Day")
        XCTAssertEqual(proChoice.reasoning, "The home team has been in excellent form, winning their last 5 matches.")
        
        // Tipster
        XCTAssertEqual(proChoice.tipster.id, 123)
        XCTAssertEqual(proChoice.tipster.name, "Expert Tipster")
        XCTAssertEqual(proChoice.tipster.winRate, 0.75)
        XCTAssertEqual(proChoice.tipster.avatar, "https://example.com/avatar.jpg")
        
        // Event
        XCTAssertEqual(proChoice.event.id, 789)
        XCTAssertEqual(proChoice.event.homeTeam, "Home Team")
        XCTAssertEqual(proChoice.event.awayTeam, "Away Team")
        XCTAssertEqual(proChoice.event.dateTime, "2024-05-15T15:00:00Z")
        
        // Selection
        XCTAssertEqual(proChoice.selection.marketName, "Match Result")
        XCTAssertEqual(proChoice.selection.outcomeName, "Home Win")
        XCTAssertEqual(proChoice.selection.odds, 2.1)
    }
} 