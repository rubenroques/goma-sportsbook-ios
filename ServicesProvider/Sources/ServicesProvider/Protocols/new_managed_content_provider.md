# Sportsbook iOS Integration Guide
## Promotions and Home Template API Reference

This document provides a comprehensive reference for integrating the promotions and home template features of the Sportsbook Backend API into your iOS application. It includes detailed information about available endpoints, request parameters, authentication requirements, and response structures.

## Table of Contents

1. [Authentication](#authentication)
2. [Common Parameters](#common-parameters)
3. [Home Template API](#home-template-api)
4. [Promotions APIs](#promotions-apis)
   - [All Promotions](#all-promotions)
   - [Alert Banner](#alert-banner)
   - [Banners](#banners)
   - [Sport Banners](#sport-banners)
   - [Boosted Odds Banners](#boosted-odds-banners)
   - [Hero Cards](#hero-cards)
   - [Stories](#stories)
   - [News](#news)
   - [Pro Choices](#pro-choices)
5. [Data Models](#data-models)
6. [Error Handling](#error-handling)
7. [Caching Strategies](#caching-strategies)
8. [Sample Swift Code](#sample-swift-code)

---

## Authentication

All API endpoints require authentication using Laravel Sanctum. You need to include a valid Bearer token in the Authorization header.

### Authentication Request

```http
POST /api/auth/v1/login
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "password"
}
```

### Authentication Response

```json
{
  "token": "YOUR_API_TOKEN",
  "user": {
    "id": 1,
    "name": "User Name",
    // other user details
  }
}
```

### Using the Token

In all subsequent requests, include the token in the Authorization header:

```
Authorization: Bearer YOUR_API_TOKEN
```

---

## Common Parameters

These parameters are common to most promotional endpoints:

| Parameter  | Type   | Required | Description                                         |
|------------|--------|----------|-----------------------------------------------------|
| `client_id`| Number | Optional | Identifies the client application making the request |
| `platform` | String | Optional | One of: `web`, `ios`, `android`, `mobile`           |
| `user_type`| String | Optional | Type of user making the request                     |

---

## Home Template API

The Home Template API returns a configuration object that defines how the home screen should be structured based on the platform.

### Endpoint

```
GET /api/home/v1/template
```

### Parameters

| Parameter  | Type   | Required | Description                                                 |
|------------|--------|----------|-------------------------------------------------------------|
| `client_id`| Number | Optional | Identifies the client application making the request         |
| `platform` | String | Required | One of: `web`, `ios`, `android`, `mobile`. Use `ios` for iOS apps |
| `user_type`| String | Optional | Type of user making the request                             |

### Response

```json
{
  "id": 1,
  "client_id": 1,
  "title": "iOS Home Template",
  "platform": "ios",
  "sections": [
    {
      "type": "hero_carousel",
      "title": "Featured",
      "source": "promotions/v1/hero-cards",
      "options": {
        "autoplay": true,
        "interval": 5000
      }
    },
    {
      "type": "sport_banners",
      "title": "Today's Top Events",
      "source": "promotions/v1/sport-banners",
      "options": {
        "layout": "horizontal"
      }
    },
    {
      "type": "stories",
      "title": "Stories",
      "source": "promotions/v1/stories",
      "options": {
        "item_count": 5
      }
    },
    {
      "type": "news",
      "title": "News",
      "source": "promotions/v1/news",
      "options": {
        "display_mode": "card"
      }
    }
  ],
  "created_at": "2023-10-15T14:30:00.000000Z",
  "updated_at": "2024-05-01T09:15:00.000000Z"
}
```

---

## Promotions APIs

### All Promotions

Returns a combination of all promotion types in a single request. Useful for initializing the home screen.

#### Endpoint

```
GET /api/promotions/v1
```

#### Response

```json
{
  "bannerAlert": { /* Alert banner data */ },
  "banners": [ /* Regular banners */ ],
  "sportBanners": [ /* Sport-specific banners */ ],
  "stories": [ /* Stories */ ]
}
```

### Alert Banner

Returns the active alert banner (if any) that should be displayed prominently.

#### Endpoint

```
GET /api/promotions/v1/alert-banner
```

#### Response

```json
{
  "id": 1,
  "title": "Special Offer",
  "content": "Get 50% bonus on your first deposit!",
  "background_color": "#FF5500",
  "text_color": "#FFFFFF",
  "action_type": "internal_link",
  "action_target": "/promotions/details/1",
  "start_date": "2024-05-01T00:00:00.000000Z",
  "end_date": "2024-05-31T23:59:59.000000Z",
  "status": "published",
  "image_url": "https://example.com/images/promo-banner.jpg"
}
```

### Banners

Returns rotational promotional banners that typically appear at the top of the home screen.

#### Endpoint

```
GET /api/promotions/v1/banners
```

#### Response

```json
[
  {
    "id": 1,
    "title": "Summer Promotion",
    "subtitle": "Hot Odds for Hot Days",
    "action_type": "internal_link",
    "action_target": "/promotions/summer",
    "start_date": "2024-05-01T00:00:00.000000Z",
    "end_date": "2024-08-31T23:59:59.000000Z",
    "status": "published",
    "image_url": "https://example.com/images/summer-promo.jpg"
  }
]
```

### Sport Banners

Returns promotional banners specific to sports events.

#### Endpoint

```
GET /api/promotions/v1/sport-banners
```

#### Response

```json
[
  {
    "id": 1,
    "title": "Champions League Final",
    "subtitle": "Real Madrid vs Liverpool",
    "start_date": "2024-05-01T00:00:00.000000Z",
    "end_date": "2024-05-31T23:59:59.000000Z",
    "status": "published",
    "image_url": "https://example.com/images/cl-final.jpg",
    "sport_event_id": 12345,
    "event": {
      "id": 12345,
      "sport_id": 1,
      "home_team_id": 101,
      "away_team_id": 102,
      "date_time": "2024-05-25T20:00:00.000000Z",
      "home_team": {
        "id": 101,
        "name": "Real Madrid",
        "logo": "https://example.com/teams/real-madrid.png"
      },
      "away_team": {
        "id": 102,
        "name": "Liverpool",
        "logo": "https://example.com/teams/liverpool.png"
      },
      "market": {
        "id": 201,
        "name": "1X2",
        "outcomes": [
          {
            "id": 301,
            "name": "1",
            "price": 2.1
          },
          {
            "id": 302,
            "name": "X",
            "price": 3.5
          },
          {
            "id": 303,
            "name": "2",
            "price": 2.8
          }
        ]
      }
    }
  }
]
```

### Boosted Odds Banners

Returns banners featuring boosted odds for specific events.

#### Endpoint

```
GET /api/promotions/v1/boosted-odds-banners
```

#### Response

```json
[
  {
    "id": 1,
    "title": "Boosted: Real Madrid to Win + Both Teams to Score",
    "original_odd": 3.5,
    "boosted_odd": 4.2,
    "start_date": "2024-05-20T00:00:00.000000Z",
    "end_date": "2024-05-25T19:59:59.000000Z",
    "status": "published",
    "image_url": "https://example.com/images/boosted-madrid.jpg",
    "sport_event_id": 12345,
    "event": {
      "id": 12345,
      // Event details similar to sport banners
    }
  }
]
```

### Hero Cards

Returns hero cards for featured events or promotions.

#### Endpoint

```
GET /api/promotions/v1/hero-cards
```

#### Response

```json
[
  {
    "id": 1,
    "title": "NBA Finals Game 7",
    "subtitle": "Celtics vs Lakers",
    "action_type": "event_link",
    "action_target": "12346",
    "start_date": "2024-06-15T00:00:00.000000Z",
    "end_date": "2024-06-18T23:59:59.000000Z",
    "status": "published",
    "image_url": "https://example.com/images/nba-finals.jpg",
    "event_id": 12346,
    "event_data": {
      // Event details if applicable
    }
  }
]
```

### Stories

Returns ephemeral promotional content in a stories format (similar to Instagram/Facebook stories).

#### Endpoint

```
GET /api/promotions/v1/stories
```

#### Response

```json
[
  {
    "id": 1,
    "title": "Player Spotlight: Ronaldo",
    "content": "Cristiano Ronaldo's career achievements",
    "action_type": "external_link",
    "action_target": "https://example.com/articles/ronaldo-career",
    "start_date": "2024-05-01T00:00:00.000000Z",
    "end_date": "2024-05-08T23:59:59.000000Z",
    "status": "published",
    "image_url": "https://example.com/images/ronaldo-story.jpg",
    "duration": 5
  }
]
```

### News

Returns sports news articles promoted within the app.

#### Endpoint

```
GET /api/promotions/v1/news
```

#### Response

```json
[
  {
    "id": 1,
    "title": "Transfer News: Mbappe to Real Madrid",
    "subtitle": "French superstar set to join Spanish giants",
    "content": "Paris Saint-Germain forward Kylian Mbappe has agreed to join Real Madrid...",
    "author": "Sports Desk",
    "published_date": "2024-05-15T09:30:00.000000Z",
    "status": "published",
    "image_url": "https://example.com/images/mbappe-transfer.jpg",
    "tags": ["transfer", "football", "LaLiga", "Ligue1"]
  }
]
```

### Pro Choices

Returns curated betting suggestions from professional tipsters.

#### Endpoint

```
GET /api/promotions/v1/pro-choices
```

#### Response

```json
[
  {
    "id": 1,
    "title": "Expert Pick of the Day",
    "tipster": {
      "id": 101,
      "name": "John Expert",
      "win_rate": 0.68,
      "avatar": "https://example.com/tipsters/john.jpg"
    },
    "event": {
      "id": 12345,
      "home_team": "Real Madrid",
      "away_team": "Liverpool",
      "date_time": "2024-05-25T20:00:00.000000Z"
    },
    "selection": {
      "market_name": "1X2",
      "outcome_name": "1",
      "odds": 2.1
    },
    "reasoning": "Real Madrid has a strong home record in Champions League finals..."
  }
]
```

---

## Data Models

Here are the key data structures you'll need to implement in Swift for your iOS app:

### HomeTemplate

```swift
struct HomeTemplate: Codable {
    let id: Int
    let clientId: Int
    let title: String
    let platform: String
    let sections: [TemplateSection]
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, platform, sections
        case clientId = "client_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct TemplateSection: Codable {
    let type: String
    let title: String
    let source: String
}
```

### Promotion Models

```swift
struct AlertBanner: Codable {
    let id: Int
    let title: String
    let content: String
    let backgroundColor: String
    let textColor: String
    let actionType: String
    let actionTarget: String
    let startDate: Date
    let endDate: Date
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

struct Banner: Codable {
    let id: Int
    let title: String
    let subtitle: String?
    let actionType: String
    let actionTarget: String
    let startDate: Date
    let endDate: Date
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

struct SportBanner: Codable {
    let id: Int
    let title: String
    let subtitle: String?
    let startDate: Date
    let endDate: Date
    let status: String
    let imageUrl: String?
    let sportEventId: Int
    let event: SportEvent?

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, status, event
        case startDate = "start_date"
        case endDate = "end_date"
        case imageUrl = "image_url"
        case sportEventId = "sport_event_id"
    }
}

struct Story: Codable {
    let id: Int
    let title: String
    let content: String
    let actionType: String
    let actionTarget: String
    let startDate: Date
    let endDate: Date
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

struct NewsItem: Codable {
    let id: Int
    let title: String
    let subtitle: String?
    let content: String
    let author: String
    let publishedDate: Date
    let status: String
    let imageUrl: String?
    let tags: [String]?

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, content, author, status, tags
        case publishedDate = "published_date"
        case imageUrl = "image_url"
    }
}

struct ProChoice: Codable {
    let id: Int
    let title: String
    let tipster: Tipster
    let event: EventSummary
    let selection: Selection
    let reasoning: String

    struct Tipster: Codable {
        let id: Int
        let name: String
        let winRate: Double
        let avatar: String?

        enum CodingKeys: String, CodingKey {
            case id, name, avatar
            case winRate = "win_rate"
        }
    }

    struct EventSummary: Codable {
        let id: Int
        let homeTeam: String
        let awayTeam: String
        let dateTime: Date

        enum CodingKeys: String, CodingKey {
            case id
            case homeTeam = "home_team"
            case awayTeam = "away_team"
            case dateTime = "date_time"
        }
    }

    struct Selection: Codable {
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
```

---

## Error Handling

All endpoints may return standard HTTP error responses:

- **401 Unauthorized**: Authentication token is missing or invalid
- **403 Forbidden**: Not authorized to access this resource
- **404 Not Found**: Resource not found
- **422 Unprocessable Entity**: Validation errors
- **500 Internal Server Error**: Server-side error

Example error response:

```json
{
  "message": "Unauthenticated",
  "errors": {
    "token": ["The token has expired"]
  }
}
```

---

## Caching Strategies

The backend API implements server-side caching for most endpoints. You should implement client-side caching to optimize performance:

1. Cache home template responses with a TTL of 1 hour
2. Cache promotional content with appropriate TTLs:
   - Alert banners: 5 minutes
   - General banners: 15 minutes
   - Sport banners: 15 minutes
   - Stories: 30 minutes
   - News: 1 hour

Implement cache invalidation when:
- User logs out
- App is restarted
- Cache TTL expires


This guide should provide all the information needed to integrate the promotions and home template features into your iOS application. The API endpoints are designed to be consistent and follow RESTful patterns, making integration straightforward with Swift's modern async/await capabilities.

If you have specific questions or need further clarification about any part of the integration, please don't hesitate to ask.