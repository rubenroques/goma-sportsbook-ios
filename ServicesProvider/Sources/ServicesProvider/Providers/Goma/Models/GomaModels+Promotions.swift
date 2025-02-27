//
//  GomaModels+Promotions.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

extension GomaModels {
    // MARK: - Home Template

    struct HomeTemplate: Codable {
        let id: Int
        let type: String
        let widgets: [HomeWidget]

        enum CodingKeys: String, CodingKey {
            case id
            case type = "name"
            case widgets
        }
    }

    struct HomeWidget: Codable {
        
        let id: String
        let type: String
        let description: String
        let userType: String
        let sortOrder: Int
        let orientation: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case type = "name"
            case description = "description"
            case userType = "user_type"
            case sortOrder = "sort_order"
            case orientation = "orientation"
        }
    }

    // MARK: - Alert Banner

    struct AlertBannerData: Codable {
        let id: Int
        let title: String
        let content: String
        let backgroundColor: String
        let textColor: String
        let actionType: String
        let actionTarget: String
        let startDate: String
        let endDate: String
        let status: String
        let imageUrl: String?

        enum CodingKeys: String, CodingKey {
            case id, title, content, status
            case backgroundColor = "background_color"
            case textColor = "text_color"
            case actionType = "action_type"
            case actionTarget = "action_target"
            case startDate = "start_date"
            case endDate = "end_date"
            case imageUrl = "image_url"
        }
    }

    // MARK: - Banners

    struct BannerData: Codable {
        let id: Int
        let title: String
        let subtitle: String?
        let actionType: String
        let actionTarget: String
        let startDate: String
        let endDate: String
        let status: String
        let imageUrl: String?

        enum CodingKeys: String, CodingKey {
            case id, title, subtitle, status
            case actionType = "action_type"
            case actionTarget = "action_target"
            case startDate = "start_date"
            case endDate = "end_date"
            case imageUrl = "image_url"
        }
    }

    // MARK: - Sport Banners

    struct SportBannerData: Codable {
        let id: Int
        let title: String
        let subtitle: String?
        let startDate: String
        let endDate: String
        let status: String
        let imageUrl: String?
        let sportEventId: Int
        let event: SportEventData?

        enum CodingKeys: String, CodingKey {
            case id, title, subtitle, status, event
            case startDate = "start_date"
            case endDate = "end_date"
            case imageUrl = "image_url"
            case sportEventId = "sport_event_id"
        }
    }

    struct SportEventData: Codable {
        let id: Int
        let sportId: Int
        let homeTeamId: Int
        let awayTeamId: Int
        let dateTime: String
        let homeTeam: TeamData
        let awayTeam: TeamData
        let market: MarketData?

        enum CodingKeys: String, CodingKey {
            case id
            case sportId = "sport_id"
            case homeTeamId = "home_team_id"
            case awayTeamId = "away_team_id"
            case dateTime = "date_time"
            case homeTeam = "home_team"
            case awayTeam = "away_team"
            case market
        }
    }

    struct TeamData: Codable {
        let id: Int
        let name: String
        let logo: String?
    }

    struct MarketData: Codable {
        let id: Int
        let name: String
        let outcomes: [OutcomeData]
    }

    struct OutcomeData: Codable {
        let id: Int
        let name: String
        let price: Double
    }

    // MARK: - Boosted Odds Banners

    struct BoostedOddsBannerData: Codable {
        let id: Int
        let title: String
        let originalOdd: Double
        let boostedOdd: Double
        let startDate: String
        let endDate: String
        let status: String
        let imageUrl: String?
        let sportEventId: Int
        let event: SportEventData?

        enum CodingKeys: String, CodingKey {
            case id, title, status, event
            case originalOdd = "original_odd"
            case boostedOdd = "boosted_odd"
            case startDate = "start_date"
            case endDate = "end_date"
            case imageUrl = "image_url"
            case sportEventId = "sport_event_id"
        }
    }

    // MARK: - Hero Cards

    struct HeroCardData: Codable {
        let id: Int
        let title: String
        let subtitle: String?
        let actionType: String
        let actionTarget: String
        let startDate: String
        let endDate: String
        let status: String
        let imageUrl: String?
        let eventId: Int?
        let eventData: SportEventData?

        enum CodingKeys: String, CodingKey {
            case id, title, subtitle, status
            case actionType = "action_type"
            case actionTarget = "action_target"
            case startDate = "start_date"
            case endDate = "end_date"
            case imageUrl = "image_url"
            case eventId = "event_id"
            case eventData = "event_data"
        }
    }

    // MARK: - Stories

    struct StoryData: Codable {
        let id: Int
        let title: String
        let content: String
        let actionType: String
        let actionTarget: String
        let startDate: String
        let endDate: String
        let status: String
        let imageUrl: String?
        let duration: Int

        enum CodingKeys: String, CodingKey {
            case id, title, content, status, duration
            case actionType = "action_type"
            case actionTarget = "action_target"
            case startDate = "start_date"
            case endDate = "end_date"
            case imageUrl = "image_url"
        }
    }

    // MARK: - News

    struct NewsItemData: Codable {
        let id: Int
        let title: String
        let subtitle: String?
        let content: String
        let author: String
        let publishedDate: String
        let status: String
        let imageUrl: String?
        let tags: [String]?

        enum CodingKeys: String, CodingKey {
            case id, title, subtitle, content, author, status, tags
            case publishedDate = "published_date"
            case imageUrl = "image_url"
        }
    }

    // MARK: - Pro Choices

    struct ProChoiceData: Codable {
        let id: Int
        let title: String
        let tipster: TipsterData
        let event: EventSummaryData
        let selection: SelectionData
        let reasoning: String

        struct TipsterData: Codable {
            let id: Int
            let name: String
            let winRate: Double
            let avatar: String?

            enum CodingKeys: String, CodingKey {
                case id, name, avatar
                case winRate = "win_rate"
            }
        }

        struct EventSummaryData: Codable {
            let id: Int
            let homeTeam: String
            let awayTeam: String
            let dateTime: String

            enum CodingKeys: String, CodingKey {
                case id
                case homeTeam = "home_team"
                case awayTeam = "away_team"
                case dateTime = "date_time"
            }
        }

        struct SelectionData: Codable {
            let marketName: String
            let outcomeName: String
            let odds: Double

            enum CodingKeys: String, CodingKey {
                case marketName = "market_name"
                case outcomeName = "outcome_name"
                case odds
            }
        }
    }
}
