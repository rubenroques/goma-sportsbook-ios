# Integration Tests for Managed Content Flow

## Introduction

This document outlines the comprehensive integration testing strategy for the managed content flow. The flow represents a clean architectural pattern that separates API data models from domain models, allowing for better maintainability and separation of concerns.

### Detailed Flow Description

```
API Request → Internal GomaModels → GomaModelMapper → Domain Models
```

Each endpoint in the system follows this consistent pattern:

1. **API Request Stage**:
   - The `GomaManagedContentProvider` initiates an API request using `GomaPromotionsAPIClient`
   - `GomaPromotionsAPIClient` constructs the appropriate URL with query parameters
   - Authentication is applied to the request via `GomaAPIAuthenticator`
   - The HTTP request is made with proper headers, method, and timeout settings

2. **Internal Model Decoding Stage**:
   - JSON responses from the API are parsed using `JSONDecoder`
   - Data is decoded into internal `GomaModels` structs (defined in `GomaModels+Promotions.swift`)
   - These internal models maintain direct mapping to the API's JSON structure using `CodingKeys`
   - Internal models may have nested structures for complex data (e.g., events containing teams)

3. **Model Transformation Stage**:
   - `GomaModelMapper` transforms internal models to domain models
   - Static mapper methods in `GomaModelMapper+Promotions.swift` handle different entity types
   - The mapper converts data types, handles optionals, and constructs more app-friendly structures
   - URL strings are converted to URL objects, date strings to Date objects, etc.

4. **Domain Model Return Stage**:
   - Clean domain models are returned to the caller via a Combine publisher
   - These models (like `HomeTemplate`, `Banner`, etc.) are what the app uses for presentation
   - Publishers may emit errors which need to be handled appropriately
   - Error types are unified as `ServiceProviderError` instances

The tests below are designed to verify each step of this flow for all endpoints, ensuring the integrity of the data pipeline from API to app.

## 0. Initial Setup

This section outlines critical preparatory tasks required before implementing the individual endpoint tests. We need to capture real API responses to ensure our test mocks accurately represent production data.

### 0.1 Authentication Setup

- [x] 0.1.1 Create a helper script to obtain authentication 'token' (it is a string) using the following cURL command:
```sh
curl --request POST \
  --url https://api.gomademo.com/api/auth/v1 \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --header 'x-api-key: i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi' \
  --data '{
    "device_uuid": "68de20be-0e53-3cac-a822-ad0414f13502",
    "device_type": "ios"
}'
```
Response:
```json
{
	"token": "5944|V61S5ZW8Cn98tup13y3TWaOT4yHdclRwDIPrNrPib4ae0087",
	"expires_at": 1741215693,
	"type": "bearer"
}
```

- [x] 0.1.2 Store authentication response in a secure location for test use
- [x] 0.1.3 Create a helper function to extract token from authentication response
- [x] 0.1.4 Add token refresh mechanism for tests that may run beyond token expiration

### 0.2 API Response Collection

- [x] 0.2.1 Create a directory structure for storing JSON response mocks:
```
/Tests/GomaTests/MockResponses/
  ├── HomeTemplate/
  ├── AlertBanner/
  ├── Banners/
  ├── SportBanners/
  ├── BoostedOddsBanners/
  ├── HeroCards/
  ├── Stories/
  ├── News/
  └── ProChoices/
```

- [x] 0.2.2 Create helper script to fetch and save responses for all endpoints
- [x] 0.2.3 Capture Home Template response:
```sh
curl --request GET \
  --url https://api.gomademo.com/api/home/v1/template?platform=ios \
  --header 'Accept: application/json' \
  --header 'Authorization: Bearer TOKEN_FROM_AUTH_STEP' \
  --header 'x-api-key: i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi' \
  > /Tests/GomaTests/MockResponses/HomeTemplate/response.json
```

- [x] 0.2.4 Capture Alert Banner response:
```sh
curl --request GET \
  --url https://api.gomademo.com/api/promotions/v1/alert-banner \
  --header 'Accept: application/json' \
  --header 'Authorization: Bearer TOKEN_FROM_AUTH_STEP' \
  --header 'x-api-key: i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi' \
  > /Tests/GomaTests/MockResponses/AlertBanner/response.json
```

- [x] 0.2.5 Capture Banners response:
```sh
curl --request GET \
  --url https://api.gomademo.com/api/promotions/v1/banners \
  --header 'Accept: application/json' \
  --header 'Authorization: Bearer TOKEN_FROM_AUTH_STEP' \
  --header 'x-api-key: i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi' \
  > /Tests/GomaTests/MockResponses/Banners/response.json
```

- [x] 0.2.6 Capture Sport Banners response:
```sh
curl --request GET \
  --url https://api.gomademo.com/api/promotions/v1/sport-banners \
  --header 'Accept: application/json' \
  --header 'Authorization: Bearer TOKEN_FROM_AUTH_STEP' \
  --header 'x-api-key: i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi' \
  > /Tests/GomaTests/MockResponses/SportBanners/response.json
```

- [x] 0.2.7 Capture Boosted Odds Banners response:
```sh
curl --request GET \
  --url https://api.gomademo.com/api/promotions/v1/boosted-odds-banners \
  --header 'Accept: application/json' \
  --header 'Authorization: Bearer TOKEN_FROM_AUTH_STEP' \
  --header 'x-api-key: i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi' \
  > /Tests/GomaTests/MockResponses/BoostedOddsBanners/response.json
```

- [x] 0.2.8 Capture Hero Cards response:
```sh
curl --request GET \
  --url https://api.gomademo.com/api/promotions/v1/hero-cards \
  --header 'Accept: application/json' \
  --header 'Authorization: Bearer TOKEN_FROM_AUTH_STEP' \
  --header 'x-api-key: i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi' \
  > /Tests/GomaTests/MockResponses/HeroCards/response.json
```

- [x] 0.2.9 Capture Stories response:
```sh
curl --request GET \
  --url https://api.gomademo.com/api/promotions/v1/stories \
  --header 'Accept: application/json' \
  --header 'Authorization: Bearer TOKEN_FROM_AUTH_STEP' \
  --header 'x-api-key: i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi' \
  > /Tests/GomaTests/MockResponses/Stories/response.json
```

- [x] 0.2.10 Capture News response (with pagination):
```sh
curl --request GET \
  --url 'https://api.gomademo.com/api/promotions/v1/news?pageIndex=0&pageSize=10' \
  --header 'Accept: application/json' \
  --header 'Authorization: Bearer TOKEN_FROM_AUTH_STEP' \
  --header 'x-api-key: i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi' \
  > /Tests/GomaTests/MockResponses/News/response.json
```

- [x] 0.2.11 Capture Pro Choices response:
```sh
curl --request GET \
  --url https://api.gomademo.com/api/promotions/v1/pro-choices \
  --header 'Accept: application/json' \
  --header 'Authorization: Bearer TOKEN_FROM_AUTH_STEP' \
  --header 'x-api-key: i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi' \
  > /Tests/GomaTests/MockResponses/ProChoices/response.json
```

### 0.3 Test Preparation

- [x] 0.3.1 Create a JSONLoader utility to load saved JSON files in tests
- [x] 0.3.2 Create a MockURLProtocol to intercept network requests and return saved JSON responses
- [x] 0.3.3 Create a test configuration file to manage paths to mock responses
- [x] 0.3.4 Add test extension to verify JSON is correctly parsed into internal models
- [x] 0.3.5 Create helper function to compare internal models with domain models after mapping
- [x] 0.3.6 Implement a standard test setup method to configure environment for all tests

## 1. Home Template Tests

- [x] 1.1 Verify GomaPromotionsAPIClient.homeTemplate endpoint builds the correct URL with query parameters
- [x] 1.2 Verify GomaPromotionsAPIClient.homeTemplate endpoint uses correct HTTP method (GET)
- [x] 1.3 Mock a JSON response for homeTemplate and verify it decodes to GomaModels.HomeTemplate
- [x] 1.4 Test GomaModelMapper.homeTemplate transforms GomaModels.HomeTemplate to HomeTemplate correctly
- [x] 1.5 Verify widget types are correctly mapped in the transformation
- [x] 1.6 Test GomaManagedContentProvider.getHomeTemplate() calls the correct API endpoint
- [x] 1.7 Test GomaManagedContentProvider.getHomeTemplate() handles successful responses
- [x] 1.8 Test GomaManagedContentProvider.getHomeTemplate() handles error responses
- [x] 1.9 Test GomaManagedContentProvider.getHomeTemplate() applies authentication correctly
- [x] 1.10 Verify end-to-end flow with mocked API response to final domain model

## 2. Alert Banner Tests

- [x] 2.1 Verify GomaPromotionsAPIClient.alertBanner endpoint builds the correct URL with query parameters
- [x] 2.2 Verify GomaPromotionsAPIClient.alertBanner endpoint uses correct HTTP method (GET)
- [x] 2.3 Mock a JSON response for alertBanner and verify it decodes to GomaModels.AlertBannerData
- [x] 2.4 Test GomaModelMapper.alertBanner transforms GomaModels.AlertBannerData to AlertBanner correctly
- [x] 2.5 Test transformation correctly sets isActive based on status field
- [x] 2.6 Test URL construction for imageUrl field
- [x] 2.7 Test GomaManagedContentProvider.getAlertBanner() calls the correct API endpoint
- [x] 2.8 Test GomaManagedContentProvider.getAlertBanner() handles successful responses
- [x] 2.9 Test GomaManagedContentProvider.getAlertBanner() handles error responses
- [x] 2.10 Test GomaManagedContentProvider.getAlertBanner() handles empty/null responses
- [x] 2.11 Verify end-to-end flow with mocked API response to final domain model

## 3. Banners Tests

- [x] 3.1 Verify GomaPromotionsAPIClient.banners endpoint builds the correct URL with query parameters
- [x] 3.2 Verify GomaPromotionsAPIClient.banners endpoint uses correct HTTP method (GET)
- [x] 3.3 Mock a JSON response for banners and verify it decodes to [GomaModels.BannerData]
- [x] 3.4 Test GomaModelMapper.banner transforms single GomaModels.BannerData to Banner correctly
- [x] 3.5 Test GomaModelMapper.banners transforms array of GomaModels.BannerData to [Banner] correctly
- [x] 3.6 Test transformation correctly sets isActive based on status field
- [x] 3.7 Test URL construction for imageUrl field
- [x] 3.8 Test GomaManagedContentProvider.getBanners() calls the correct API endpoint
- [x] 3.9 Test GomaManagedContentProvider.getBanners() handles successful responses
- [x] 3.10 Test GomaManagedContentProvider.getBanners() handles error responses
- [x] 3.11 Test GomaManagedContentProvider.getBanners() handles empty array responses
- [x] 3.12 Verify end-to-end flow with mocked API response to final domain model

## 4. Sport Banners Tests

- [x] 4.1 Verify GomaPromotionsAPIClient.sportBanners endpoint builds the correct URL with query parameters
- [x] 4.2 Verify GomaPromotionsAPIClient.sportBanners endpoint uses correct HTTP method (GET)
- [x] 4.3 Mock a JSON response for sportBanners and verify it decodes to [GomaModels.SportBannerData]
- [x] 4.4 Test GomaModelMapper.sportBanner transforms GomaModels.SportBannerData to SportBanner correctly
- [x] 4.5 Test GomaModelMapper.sportBanners transforms array of GomaModels.SportBannerData to [SportBanner] correctly
- [x] 4.6 Test nested SportEventData mapping to SportEventSummary
- [x] 4.7 Test team data mapping for home and away teams
- [x] 4.8 Test URL construction for imageUrl and team logo URLs
- [x] 4.9 Test GomaManagedContentProvider.getSportBanners() calls the correct API endpoint
- [x] 4.10 Test GomaManagedContentProvider.getSportBanners() handles successful responses
- [x] 4.11 Test GomaManagedContentProvider.getSportBanners() handles error responses
- [x] 4.12 Test GomaManagedContentProvider.getSportBanners() handles empty array responses
- [x] 4.13 Verify end-to-end flow with mocked API response to final domain model

## 5. Boosted Odds Banners Tests

- [ ] 5.1 Verify GomaPromotionsAPIClient.boostedOddsBanners endpoint builds the correct URL with query parameters
- [ ] 5.2 Verify GomaPromotionsAPIClient.boostedOddsBanners endpoint uses correct HTTP method (GET)
- [ ] 5.3 Mock a JSON response for boostedOddsBanners and verify it decodes to [GomaModels.BoostedOddsBannerData]
- [ ] 5.4 Test GomaModelMapper.boostedOddsBanner transforms GomaModels.BoostedOddsBannerData to BoostedOddsBanner correctly
- [ ] 5.5 Test GomaModelMapper.boostedOddsBanners transforms array of GomaModels.BoostedOddsBannerData to [BoostedOddsBanner] correctly
- [ ] 5.6 Test originalOdd and boostedOdd values are correctly mapped
- [ ] 5.7 Test nested SportEventData mapping to SportEventSummary
- [ ] 5.8 Test URL construction for imageUrl field
- [ ] 5.9 Test GomaManagedContentProvider.getBoostedOddsBanners() calls the correct API endpoint
- [ ] 5.10 Test GomaManagedContentProvider.getBoostedOddsBanners() handles successful responses
- [ ] 5.11 Test GomaManagedContentProvider.getBoostedOddsBanners() handles error responses
- [ ] 5.12 Test GomaManagedContentProvider.getBoostedOddsBanners() handles empty array responses
- [ ] 5.13 Verify end-to-end flow with mocked API response to final domain model

## 6. Hero Cards Tests

- [ ] 6.1 Verify GomaPromotionsAPIClient.heroCards endpoint builds the correct URL with query parameters
- [ ] 6.2 Verify GomaPromotionsAPIClient.heroCards endpoint uses correct HTTP method (GET)
- [ ] 6.3 Mock a JSON response for heroCards and verify it decodes to [GomaModels.HeroCardData]
- [ ] 6.4 Test GomaModelMapper.heroCard transforms GomaModels.HeroCardData to HeroCard correctly
- [ ] 6.5 Test GomaModelMapper.heroCards transforms array of GomaModels.HeroCardData to [HeroCard] correctly
- [ ] 6.6 Test actionType and actionTarget fields are correctly mapped
- [ ] 6.7 Test eventId and eventData fields are correctly mapped
- [ ] 6.8 Test URL construction for imageUrl field
- [ ] 6.9 Test GomaManagedContentProvider.getHeroCards() calls the correct API endpoint
- [ ] 6.10 Test GomaManagedContentProvider.getHeroCards() handles successful responses
- [ ] 6.11 Test GomaManagedContentProvider.getHeroCards() handles error responses
- [ ] 6.12 Test GomaManagedContentProvider.getHeroCards() handles empty array responses
- [ ] 6.13 Verify end-to-end flow with mocked API response to final domain model

## 7. Stories Tests

- [ ] 7.1 Verify GomaPromotionsAPIClient.stories endpoint builds the correct URL with query parameters
- [ ] 7.2 Verify GomaPromotionsAPIClient.stories endpoint uses correct HTTP method (GET)
- [ ] 7.3 Mock a JSON response for stories and verify it decodes to [GomaModels.StoryData]
- [ ] 7.4 Test GomaModelMapper.story transforms GomaModels.StoryData to Story correctly
- [ ] 7.5 Test GomaModelMapper.stories transforms array of GomaModels.StoryData to [Story] correctly
- [ ] 7.6 Test content field is correctly mapped
- [ ] 7.7 Test duration field is correctly mapped
- [ ] 7.8 Test URL construction for imageUrl field
- [ ] 7.9 Test GomaManagedContentProvider.getStories() calls the correct API endpoint
- [ ] 7.10 Test GomaManagedContentProvider.getStories() handles successful responses
- [ ] 7.11 Test GomaManagedContentProvider.getStories() handles error responses
- [ ] 7.12 Test GomaManagedContentProvider.getStories() handles empty array responses
- [ ] 7.13 Verify end-to-end flow with mocked API response to final domain model

## 8. News Tests

- [ ] 8.1 Verify GomaPromotionsAPIClient.news endpoint builds the correct URL with query parameters
- [ ] 8.2 Verify GomaPromotionsAPIClient.news endpoint uses correct HTTP method (GET)
- [ ] 8.3 Verify pagination parameters (pageIndex, pageSize) are correctly added to URL
- [ ] 8.4 Mock a JSON response for news and verify it decodes to [GomaModels.NewsItemData]
- [ ] 8.5 Test GomaModelMapper.newsItem transforms GomaModels.NewsItemData to NewsItem correctly
- [ ] 8.6 Test GomaModelMapper.newsItems transforms array of GomaModels.NewsItemData to [NewsItem] correctly
- [ ] 8.7 Test author and tags fields are correctly mapped
- [ ] 8.8 Test content field is correctly mapped
- [ ] 8.9 Test URL construction for imageUrl field
- [ ] 8.10 Test GomaManagedContentProvider.getNews() calls the correct API endpoint
- [ ] 8.11 Test GomaManagedContentProvider.getNews() handles successful responses
- [ ] 8.12 Test GomaManagedContentProvider.getNews() handles error responses
- [ ] 8.13 Test GomaManagedContentProvider.getNews() handles empty array responses
- [ ] 8.14 Test pagination works correctly with different page indexes and sizes
- [ ] 8.15 Verify end-to-end flow with mocked API response to final domain model

## 9. Pro Choices Tests

- [ ] 9.1 Verify GomaPromotionsAPIClient.proChoices endpoint builds the correct URL with query parameters
- [ ] 9.2 Verify GomaPromotionsAPIClient.proChoices endpoint uses correct HTTP method (GET)
- [ ] 9.3 Mock a JSON response for proChoices and verify it decodes to [GomaModels.ProChoiceData]
- [ ] 9.4 Test GomaModelMapper.proChoice transforms GomaModels.ProChoiceData to ProChoice correctly
- [ ] 9.5 Test GomaModelMapper.proChoices transforms array of GomaModels.ProChoiceData to [ProChoice] correctly
- [ ] 9.6 Test tipster data mapping (id, name, winRate, avatar)
- [ ] 9.7 Test event summary mapping (id, homeTeam, awayTeam, dateTime)
- [ ] 9.8 Test selection mapping (marketName, outcomeName, odds)
- [ ] 9.9 Test reasoning field is correctly mapped
- [ ] 9.10 Test URL construction for tipster avatar
- [ ] 9.11 Test GomaManagedContentProvider.getProChoices() calls the correct API endpoint
- [ ] 9.12 Test GomaManagedContentProvider.getProChoices() handles successful responses
- [ ] 9.13 Test GomaManagedContentProvider.getProChoices() handles error responses
- [ ] 9.14 Test GomaManagedContentProvider.getProChoices() handles empty array responses
- [ ] 9.15 Verify end-to-end flow with mocked API response to final domain model