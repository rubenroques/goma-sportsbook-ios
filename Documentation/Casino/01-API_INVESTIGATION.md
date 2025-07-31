# Casino API Investigation

## Overview
This document contains the results of testing the EveryMatrix casino API endpoints and documenting the actual response structures for implementation.

## Base Configuration
- **Base URL**: `https://betsson-api.stage.norway.everymatrix.com`
- **Platform**: `PC` (needs to be changed to `iOS` for mobile)
- **Language**: `en` (dynamic based on locale)
- **Authentication**: Session-based with `sessionId` cookie (for authenticated endpoints)

## API Endpoints Tested

### 1. Get Casino Categories ✅ WORKING
**Endpoint**: `GET /v1/casino/categories`

**Working cURL Command**:
```bash
curl "https://betsson-api.stage.norway.everymatrix.com/v1/casino/categories?language=en&platform=PC&pagination=offset=0,games(offset=0,limit=0)&fields=id,name,href,games"
```

**Response Structure**:
```json
{
  "count": 17,
  "total": 17,
  "items": [
    {
      "href": "...",
      "id": "VIDEOSLOTS", 
      "name": "Video Slots",
      "games": {
        "count": 0,
        "total": 133,
        "items": [],
        "pages": {
          "first": "...",
          "next": "...",
          "previous": null,
          "last": "..."
        }
      }
    }
  ],
  "pages": {
    "first": "...",
    "next": null,
    "previous": null,
    "last": "..."
  }
}
```

**Key Findings**:
- Categories with `games.total > 0` should be displayed (e.g., VIDEOSLOTS has 133 games)
- Many categories have 0 games and should be filtered out
- Nested pagination structure for both main response and game subcollections

### 2. Get Games by Category ✅ WORKING  
**Endpoint**: `GET /v1/casino/games`

**Working cURL Command**:
```bash
curl "https://betsson-api.stage.norway.everymatrix.com/v1/casino/games?language=en&platform=PC&pagination=offset=0,limit=5&expand=vendor&filter=categories(id=VIDEOSLOTS)&sortedField=popularity"
```

**Response Structure** (truncated for brevity):
```json
{
  "count": 5,
  "total": 133,
  "items": [
    {
      "href": "...",
      "id": "34795",
      "name": "Lara Jones is Cleopatra",
      "launchUrl": "https://gamelaunch-stage.everymatrix.com/Loader/Start/4093/lara-jones-is-cleopatra-rgs",
      "backgroundImageUrl": "//static.everymatrix.com/cms2/base/_casino/B/B770214252B08BA7F36F1A417CAD57BD.jpg",
      "popularity": 0.0,
      "isNew": false,
      "width": 1280,
      "height": 720,
      "hasFunMode": true,
      "hasAnonymousFunMode": true,
      "thumbnail": "//static.everymatrix.com/cms2/base/_casino/C/C1CD17360B7F36FBF5AF69183620EBF4.jpg",
      "subVendor": "SpearheadStudios",
      "subVendorId": 249,
      "defaultThumbnail": "...",
      "type": "casino-games",
      "advancedTags": [],
      "logo": "...",
      "slug": "lara-jones-is-cleopatra-rgs",
      "theoreticalPayOut": 0.9646,
      "platform": ["PC", "iPad", "iPhone", "Android"],
      "maxBetRestriction": {
        "defaultMaxBet": {"EUR": 100.0},
        "defaultMaxWin": {"EUR": 1700000.0},
        "defaultMaxMultiplier": 17000.0
      },
      "vendor": {
        "href": "...",
        "id": "266",
        "name": "RGS_Matrix",
        "displayName": "Slotmatrix_RGS",
        "image": "...",
        "logo": "...",
        "isTopVendor": false
      },
      "tags": {
        "count": 3,
        "total": 3,
        "items": [
          {"href": "https://betsson-api.stage.norway.everymatrix.com/v1/casino/tags/Buy%20Feature"},
          {"href": "https://betsson-api.stage.norway.everymatrix.com/v1/casino/tags/Free%20Spins"},
          {"href": "https://betsson-api.stage.norway.everymatrix.com/v1/casino/tags/Sticky%20Symbols"}
        ]
      },
      "categories": {
        "count": 1,
        "total": 1,
        "items": [
          {"href": "https://betsson-api.stage.norway.everymatrix.com/v1/casino/categories/VIDEOSLOTS?language=en"}
        ]
      },
      "jackpots": {
        "count": 0,
        "total": 0,
        "items": []
      },
      "htmlDescription": "",
      "description": "Did you grow up playing Tomb Raider games?...",
      "promo": {"effective": false},
      "exclusive": {"effective": false},
      "gameCode": "Cleopatra",
      "helpUrl": "",
      "languages": [],
      "currencies": [],
      "realMode": {
        "fun": true,
        "anonymity": true,
        "realMoney": true
      },
      "license": "Malta",
      "minHitFrequency": 0,
      "maxHitFrequency": 0,
      "vendorGameID": "Cleopatra",
      "restrictedTerritories": ["AF", "AD", "AO", "DK", "LT", "CA-ON"],
      "gId": 34795,
      "gameId": 34795,
      "thumbnails": {},
      "fpp": 0.2,
      "bonusContribution": 1.0,
      "icons": {
        "88": "...",
        "44": "...",
        "22": "...",
        "57": "...",
        "114": "...",
        "72": "..."
      }
    }
  ]
}
```

**Key Findings**:
- Rich game object with multiple image URLs (thumbnail, backgroundImageUrl, icons)
- Launch URL format: `https://gamelaunch-stage.everymatrix.com/Loader/Start/{domainid}/{slug}`
- Platform support includes iPhone and Android
- Vendor information expanded as requested
- Complex nested structures for tags, categories, jackpots
- Multiple game modes: fun, anonymity, realMoney

### 3. Get Game Details (Pending Authentication)
**Endpoint**: `GET /v1/casino/games` (with gameId filter)

**Expected Parameters**:
```
language=en&platform=PC&expand=vendor&filter=id={{gameId}}
```

**Status**: Need to test with specific game ID

### 4. Get Recently Played Games (Pending Authentication)
**Endpoint**: `GET /v1/player/{playerId}/games/last-played`

**Expected Parameters**:
```
language=en&platform=PC&offset=0&limit=10&unique=true&hasGameModel=true&order=ASCENDING
```

**Status**: Requires authentication with sessionId and user ID

## Data Model Analysis

### Categories
**Required Fields**:
- `id`: String (e.g., "VIDEOSLOTS")
- `name`: String (e.g., "Video Slots")  
- `href`: String (API URL)
- `games.total`: Int (game count)

### Games
**Required Fields**:
- `id`: String
- `name`: String
- `launchUrl`: String
- `thumbnail`: String
- `backgroundImageUrl`: String
- `vendor`: Object with id, name, displayName
- `hasFunMode`: Bool
- `hasAnonymousFunMode`: Bool
- `platform`: Array of strings
- `description`: String
- `slug`: String
- `icons`: Dictionary of size:URL mappings

**Optional Fields**:
- `isNew`: Bool
- `popularity`: Double
- `theoreticalPayOut`: Double
- `tags`: Nested object with items array
- `maxBetRestriction`: Object with bet/win limits
- `realMode`: Object with mode availability

### Pagination
**Structure**:
- `count`: Int (items in current response)
- `total`: Int (total items available)
- `items`: Array (actual data)
- `pages`: Object with first/next/previous/last URLs

**Calculation**:
- `hasMore = (offset + limit) < total`
- `nextOffset = currentOffset + limit`

## Authentication Requirements

### Session-Based Authentication
- **Cookie Name**: `sessionId`
- **Additional**: User ID for player-specific endpoints
- **Guest Mode**: Available for categories and most games
- **Authenticated Mode**: Required for recently played games

### Platform Parameter
- **Current**: `PC` (web)
- **Mobile**: Likely needs `iOS` or `iPhone` for iOS app
- **Testing**: Should test platform-specific differences

## Next Steps

1. **✅ Test additional endpoints** with authentication
2. **✅ Create DTO models** based on actual response structures  
3. **✅ Implement ServicesProvider public models**
4. **✅ Create mapping functions** from DTOs to public models
5. **✅ Implement CasinoProvider protocol**

## Implementation Notes

### URL Construction
- Base URL should be configurable per environment
- Template variable replacement needed for `{{categoryId}}`, `{{gameId}}`
- Query parameter encoding for complex filters

### Error Handling
- Test rate limiting behavior
- Document authentication error responses
- Handle malformed/missing data gracefully

### Mobile Adaptations
- Test platform parameter variations
- Validate image URLs work on mobile
- Check if launch URLs need modification for mobile WebView

### Performance Considerations
- Large responses (133 games for VIDEOSLOTS)
- Nested object structures may need optimization
- Image preloading strategy needed