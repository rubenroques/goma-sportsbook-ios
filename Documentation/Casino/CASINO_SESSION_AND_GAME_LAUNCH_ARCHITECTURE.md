# Casino Session Management & Game Launch Architecture

## Overview

This document provides a comprehensive analysis of the current casino session management and game launching mechanisms as implemented in both iOS and Web platforms. It documents the exact state of the codebase as of January 2025.

## Table of Contents

1. [Session Management Architecture](#session-management-architecture)
2. [Casino Game Modes](#casino-game-modes)
3. [Game Launch URL Construction](#game-launch-url-construction)
4. [Recently Played Games Integration](#recently-played-games-integration)
5. [Platform Comparison: iOS vs Web](#platform-comparison-ios-vs-web)
6. [Critical Implementation Details](#critical-implementation-details)

---

## Session Management Architecture

### Web Implementation (Vue.js)

The web platform uses a **cookie-based authentication system** that automatically handles session management through browser cookies.

#### Core Session Components

```javascript
// Location: src/composables/auth/useCookies.js
export default {
  getCookie(cname) {
    // Retrieves cookie value from document.cookie
    // Returns empty string if not found
  },
  setCookie(cname, cvalue, exdays) {
    // Sets cookie with expiration
    // Automatically handled by browser
  }
}
```

#### Session Cookies Structure

| Cookie Name | Purpose | Required For |
|------------|---------|--------------|
| `sessionId` | Primary EveryMatrix session token | All authenticated API calls |
| `id` | Additional user identifier | Recently played games |
| `user_cookie_consent` | GDPR compliance tracking | Legal requirement |

#### Authentication Validation Pattern

The web implementation uses a **triple-check authentication pattern** for sensitive operations:

```javascript
// Location: src/api/everymatrix/modules/casino.js:237-278
async getRecentlyPlayed(params = {}) {
  // Triple authentication check - all three must be present
  if (!userStore?.user?.id ||                    // Check 1: User store has ID
      !useCookies.getCookie('sessionId') ||      // Check 2: Session cookie exists
      !useCookies.getCookie('id')) {             // Check 3: ID cookie exists
    store.setRecentlyPlayed([])
    return []
  }

  // Proceed with authenticated API call
  const result = await apiSession.casinoApi('get',
    `/v1/player/${userStore?.user?.id}/games/last-played?${queryParams}`
  )
}
```

### iOS Implementation (Current)

The iOS platform has implemented casino game display with WKWebView but lacks session management integration.

#### Current iOS Casino Components

**CasinoGamePlayViewController** - Full WKWebView implementation:
```swift
// Location: BetssonCameroonApp/App/Screens/Casino/CasinoGamePlay/CasinoGamePlayViewController.swift
private var webView: WKWebView!
private let bottomBarView = UIView() // Contains Exit, Deposit, Timer
private let timerLabel = UILabel()   // Shows session elapsed time
```

**CasinoGamePlayViewModel** - Game URL handling:
```swift
// Location: BetssonCameroonApp/App/Screens/Casino/CasinoGamePlay/CasinoGamePlayViewModel.swift
// Supports both real launchUrl from API and mock URLs
init(casinoGame: CasinoGame, servicesProvider: ServicesProvider.Client) {
    if let url = URL(string: casinoGame.launchUrl) {
        gameURL = url // Uses real API launchUrl
    }
}

// Fallback mock URLs when no CasinoGame object
private func getGameData(for gameId: String) -> (title: String, url: String) {
    switch gameId {
    case "new-001": return ("Dragon's Fortune", "https://demo.pragmaticplay.net/...")
    // ... more mock games
    }
}
```

#### Current iOS Limitations

1. **No session parameter injection** - Game URLs don't include `_sid` parameter
2. **No authentication headers** in WKWebView requests
3. **Recently played uses fallback** - Takes first game from each category
4. **Mock URLs for testing** - Hardcoded demo URLs in fallback scenarios

---

## Casino Game Modes

### Three Distinct Game Modes

The casino system supports three distinct game modes, each with specific authentication requirements and URL construction patterns.

#### Mode Definitions

```javascript
// Web: src/composables/casino/useCasinoGameDetails.js:21-25
const GAME_MODES = {
  FUN_GUEST: 'fun_guest',        // Anonymous demo play
  FUN_LOGGED_IN: 'fun_logged_in', // Authenticated demo play
  REAL_MONEY: 'real_money'        // Live betting with real funds
}
```

#### Mode Characteristics

| Mode | Authentication Required | Session Required | User Balance Used | Progress Tracked |
|------|------------------------|------------------|-------------------|------------------|
| **FUN_GUEST** | No | No | No | No |
| **FUN_LOGGED_IN** | Yes | Yes | No | Yes |
| **REAL_MONEY** | Yes | Yes | Yes | Yes |

### Mode Selection Logic

The system intelligently selects the appropriate mode based on user authentication state:

```javascript
// Web: src/composables/casino/useCasinoGameDetails.js:189-213
function launchGame(gameId, mode = null) {
  // Automatic mode detection if not specified
  if (!mode) {
    mode = userLoggedIn.value
      ? GAME_MODES.FUN_LOGGED_IN  // Authenticated users get tracked demo
      : GAME_MODES.FUN_GUEST       // Anonymous users get basic demo
  }

  switch (mode) {
    case GAME_MODES.FUN_GUEST:
      return launchGameFunModeGuest(gameId)
    case GAME_MODES.FUN_LOGGED_IN:
      return launchGameFunModeLoggedIn(gameId)
    case GAME_MODES.REAL_MONEY:
      return launchGameRealMoney(gameId)
    default:
      console.error('Invalid game mode:', mode)
      return false
  }
}
```

---

## Game Launch URL Construction

### Base URL Pattern

All game launches start with a base URL provided by the EveryMatrix API:

```
https://gamelaunch-stage.everymatrix.com/Loader/Start/{domainid}/{slug}
```

### URL Parameters by Mode

#### FUN_GUEST Mode (Anonymous)

No additional parameters required:
```
https://gamelaunch-stage.everymatrix.com/Loader/Start/{domainid}/{slug}
```

#### FUN_LOGGED_IN Mode (Authenticated Demo)

Requires session and fun mode flag:
```
https://gamelaunch-stage.everymatrix.com/Loader/Start/{domainid}/{slug}
  ?funMode=True
  &language={locale}
  &_sid={sessionId}
```

#### REAL_MONEY Mode (Live Play)

Requires session without fun mode flag:
```
https://gamelaunch-stage.everymatrix.com/Loader/Start/{domainid}/{slug}
  ?language={locale}
  &_sid={sessionId}
```

### Web Implementation: URL Builder

```javascript
// Location: src/composables/casino/useCasinoGameDetails.js:74-113
function buildGameLaunchUrl(gameDetails, mode = GAME_MODES.FUN_GUEST) {
  if (!gameDetails?.launchUrl) {
    console.error('Game launch URL not available')
    return null
  }

  const baseUrl = gameDetails.launchUrl

  // Guest mode uses base URL as-is
  if (mode === GAME_MODES.FUN_GUEST) {
    return baseUrl
  }

  // Authenticated modes require session
  const sessionId = getSessionId()
  if (!sessionId) {
    console.warn('No session ID found, falling back to guest mode')
    return baseUrl
  }

  const url = new URL(baseUrl)

  // Add funMode flag for logged-in demo play
  if (mode === GAME_MODES.FUN_LOGGED_IN) {
    url.searchParams.set('funMode', 'True')
  }

  // Add language if available
  if (locale.value) {
    url.searchParams.set('language', locale.value)
  }

  // CRITICAL: Session ID parameter name is '_sid' not 'sessionId'
  url.searchParams.set('_sid', sessionId)

  return url.toString()
}
```

---

## Recently Played Games Integration

### API Endpoint

```
GET /v1/player/{playerId}/games/last-played
```

### Authentication Requirements

The Recently Played API has **strict authentication requirements**:

1. **User must be logged in** (userStore has valid user ID)
2. **Session cookie must exist** (`sessionId` in browser cookies)
3. **ID cookie must exist** (`id` in browser cookies)

### Web Implementation

```javascript
// Location: src/api/everymatrix/modules/casino.js:237-278
async getRecentlyPlayed(params = {}) {
  const store = casinoStore

  try {
    store.setRecentlyPlayedLoading(true)
    store.setRecentlyPlayedError(null)

    // Triple authentication check
    if (!userStore?.user?.id ||
        !useCookies.getCookie('sessionId') ||
        !useCookies.getCookie('id')) {
      store.setRecentlyPlayed([])  // Return empty for unauthenticated
      return []
    }

    const processedParams = replaceTemplateVars(params)
    const queryParams = Object.entries(processedParams)
      .map(([key, value]) => `${key}=${value}`)
      .join('&')

    const result = await apiSession.casinoApi('get',
      `/v1/player/${userStore?.user?.id}/games/last-played?${queryParams}`
    )

    // Map API response to UI models
    const mappedGames = result?.data?.items?.map((game) =>
      mapCasinoGame(game?.gameModel, store.recentlyPlayed)
    )

    store.setRecentlyPlayed(mappedGames)

    // Handle pagination
    const pagination = result?.data?.pagination || {}
    const limit = parseInt(processedParams.limit || '10')
    const offset = parseInt(processedParams.offset || '0')
    const total = pagination.total || result?.data?.total || 0
    const hasMore = total ? ((offset + limit) < total) : result?.data?.pages?.next !== null

    store.setRecentlyPlayedPagination({
      offset,
      limit,
      hasMore,
      total
    })

    return mappedGames

  } catch (error) {
    console.log('Error fetching recently played games:', error)
    store.setRecentlyPlayedError(error)
    return []
  } finally {
    store.setRecentlyPlayedLoading(false)
  }
}
```

### Default Query Parameters

```javascript
const defaultRecentlyPlayedParams = {
  language: locale.value,
  platform: 'PC',
  offset: '0',
  limit: '10',
  unique: true,           // Deduplicate games
  hasGameModel: true,     // Include full game details
  order: 'ASCENDING'      // Oldest to newest
}
```

### iOS Current Implementation (Fallback)

The iOS app currently uses a **fallback strategy** instead of the actual API:

```swift
// Location: BetssonCameroonApp/App/Screens/Casino/CasinoCategoriesList/CasinoCategoriesListViewModel.swift:215-232
private func updateRecentlyPlayedFromCategories() {
    // Extract first game from each loaded category
    let recentGames = categorySections.compactMap { section -> RecentlyPlayedGameData? in
        guard let firstGame = section.sectionData.games.first(where: {
            !$0.id.contains("see-more")
        }) else {
            return nil
        }
        return ServiceProviderModelMapper.recentlyPlayedGameData(
            fromCasinoGameCardData: firstGame
        )
    }

    // Limit to 5 games maximum
    let limitedGames = Array(recentGames.prefix(5))
    recentlyPlayedGamesViewModel.updateGames(limitedGames)
}
```

---

## Platform Comparison: iOS vs Web

### Architecture Differences

| Component | iOS (Swift) | Web (Vue.js) |
|-----------|-------------|--------------|
| **Session Storage** | KeychainStore (planned) | Browser Cookies |
| **Session Transmission** | Manual header injection needed | Automatic via cookies |
| **API Client** | URLSession with Combine | Axios with interceptors |
| **State Management** | @Published properties | Pinia stores |
| **UI Framework** | UIKit components | Vue components |
| **Game Display** | WKWebView (planned) | iframe element |
| **Error Handling** | ServiceProviderError enum | Try-catch with status codes |

### Session Management Comparison

#### Web Session Flow
```
Login → Set Cookies → Browser Auto-Sends → API Validates → Response
```

#### iOS Session Flow (Proposed)
```
Login → Store in Keychain → Manual Header Injection → API Validates → Response
```

### API Request Comparison

#### Web API Request
```javascript
// Cookies automatically sent by browser
const result = await apiSession.casinoApi('get', `/v1/casino/games?${queryParams}`)
```

#### iOS API Request (Proposed Enhancement)
```swift
// Manual session injection required
var request = URLRequest(url: endpoint)
if let sessionId = userSessionStore.sessionId {
    request.setValue("sessionId=\(sessionId)", forHTTPHeaderField: "Cookie")
}
return session.dataTaskPublisher(for: request)
```

---

## Implementation Guidelines

### For iOS Development

#### 1. Enhance Session Management

```swift
// Proposed: ServicesProvider enhancement
extension EveryMatrixConnector {
    func authenticatedRequest(_ endpoint: Endpoint) -> AnyPublisher<Data, ServiceProviderError> {
        var request = URLRequest(url: buildURL(for: endpoint))

        // Inject session if available
        if let sessionToken = sessionToken {
            request.setValue("sessionId=\(sessionToken)", forHTTPHeaderField: "Cookie")
        }

        // Add other required headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(language, forHTTPHeaderField: "Accept-Language")

        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .mapError { ServiceProviderError.networkError($0) }
            .eraseToAnyPublisher()
    }
}
```

#### 2. Implement Game Mode Enum

```swift
// Proposed: CasinoGameMode enhancement
enum CasinoGameMode {
    case funGuest       // No authentication required
    case funLoggedIn    // Requires session, demo play
    case realMoney      // Requires session, real money

    var requiresAuthentication: Bool {
        switch self {
        case .funGuest: return false
        case .funLoggedIn, .realMoney: return true
        }
    }

    var urlParameters: [URLQueryItem] {
        switch self {
        case .funGuest:
            return []
        case .funLoggedIn:
            return [
                URLQueryItem(name: "funMode", value: "True"),
                URLQueryItem(name: "language", value: Locale.current.languageCode)
            ]
        case .realMoney:
            return [
                URLQueryItem(name: "language", value: Locale.current.languageCode)
            ]
        }
    }
}
```

#### 3. Build Game Launch URLs

```swift
// Proposed: Game URL builder
extension CasinoGame {
    func buildLaunchURL(
        mode: CasinoGameMode,
        sessionId: String? = nil
    ) -> URL? {
        guard var urlComponents = URLComponents(string: launchUrl) else {
            return nil
        }

        // Add mode-specific parameters
        var queryItems = mode.urlParameters

        // Add session for authenticated modes
        if mode.requiresAuthentication {
            guard let sessionId = sessionId else {
                print("Warning: Authenticated mode requires session ID")
                return nil
            }
            queryItems.append(URLQueryItem(name: "_sid", value: sessionId))
        }

        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
}
```

#### 4. Implement Recently Played with Authentication

```swift
// Proposed: Recently played implementation
class CasinoCategoriesListViewModel {
    func loadRecentlyPlayedGames() {
        // Check authentication state
        guard userSessionStore.isAuthenticated,
              let userId = userSessionStore.userId,
              let sessionId = userSessionStore.sessionId else {
            // Fallback to category-based approach for unauthenticated users
            updateRecentlyPlayedFromCategories()
            return
        }

        // Load actual recently played from API
        servicesProvider.getRecentlyPlayedGames(
            playerId: userId,
            language: "en",
            platform: "iOS",
            pagination: CasinoPaginationParams(offset: 0, limit: 10)
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    // Fallback on error
                    self?.updateRecentlyPlayedFromCategories()
                }
            },
            receiveValue: { [weak self] response in
                let recentlyPlayedData = response.games.map { game in
                    ServiceProviderModelMapper.recentlyPlayedGameData(
                        fromCasinoGame: game
                    )
                }
                self?.recentlyPlayedGamesViewModel.updateGames(recentlyPlayedData)
            }
        )
        .store(in: &cancellables)
    }
}
```

---

## Critical Implementation Details

### Session Parameter Naming

⚠️ **CRITICAL**: The session ID parameter in URLs must be `_sid`, not `sessionId`:

```javascript
// ✅ CORRECT
url.searchParams.set('_sid', sessionId)

// ❌ WRONG
url.searchParams.set('sessionId', sessionId)
```

### Session Expiration Handling

The web implementation includes automatic session expiration detection:

```javascript
// Location: src/api/everymatrix/client.js:235-302
async function handleSessionExpiration(result) {
  if (result.status === 401) {
    const errorData = result.data?.data
    const isSessionExpired = errorData?.errorCode === 1 &&
      errorData?.thirdPartyResponse?.errorCode === 'InvalidSession'

    if (isSessionExpired) {
      // Clear user session
      oddsApi.user.clearUserSession()

      // Show session expiration dialog
      await showAlert({
        icon: 'warning',
        title: t('you_have_been_signed_out'),
        description: t('your_session_timed_out'),
        primaryButton: {
          text: t('login'),
          action: () => router.push({ name: 'Login' })
        }
      })

      return true
    }
  }
  return false
}
```

### Game Launch Validation

Always validate game details before launching:

```javascript
function openGameIframe(gameId, mode) {
  const game = getGameDetails(gameId)

  // Validation checks
  if (!game) {
    console.error('Game details not found for ID:', gameId)
    return false
  }

  if (!game.launchUrl) {
    console.error('Game launch URL not available')
    return false
  }

  if (mode.requiresAuthentication && !getSessionId()) {
    console.error('Authentication required but no session found')
    return false
  }

  // Proceed with launch
  const launchUrl = buildGameLaunchUrl(game, mode)
  // ...
}
```

### Platform-Specific Considerations

#### iOS Considerations

1. **WKWebView Configuration**: Must enable JavaScript and handle navigation delegates
2. **Cookie Management**: May need to manually sync cookies between URLSession and WKWebView
3. **Deep Linking**: Handle casino game URLs from external sources
4. **Background Handling**: Pause game when app enters background

#### Web Considerations

1. **Cross-Origin Issues**: iframe sandbox attributes must be configured correctly
2. **Cookie SameSite**: Ensure cookies work across game provider domains
3. **Popup Blockers**: Handle cases where iframe might be blocked
4. **Responsive Design**: Game iframe must adapt to different screen sizes

---

## Troubleshooting Guide

### Common Issues and Solutions

| Issue | Symptom | Solution |
|-------|---------|----------|
| **Session Not Found** | Games launch in guest mode unexpectedly | Verify session cookie exists and hasn't expired |
| **401 Unauthorized** | API calls fail with 401 | Check session validity and refresh if needed |
| **Recently Played Empty** | No games shown despite play history | Verify all three authentication checks pass |
| **Wrong Game Mode** | Real money game opens in fun mode | Check `funMode` parameter not incorrectly set |
| **Game Won't Load** | Blank iframe/webview | Verify launch URL is complete with all parameters |

### Debug Logging

Enable verbose logging for casino operations:

```swift
// iOS Debug logging
extension CasinoGameLauncher {
    private func debugLog(_ message: String) {
        #if DEBUG
        print("🎰 [CasinoGameLauncher] \(message)")
        #endif
    }
}
```

```javascript
// Web Debug logging
if (process.env.NODE_ENV !== 'production') {
  console.log('🎰 [Casino]', {
    mode,
    sessionId: sessionId ? 'present' : 'missing',
    launchUrl
  })
}
```

---

## Future Enhancements

### Planned Improvements

1. **Biometric Authentication**: Use Face ID/Touch ID for session refresh
2. **Offline Mode**: Cache recently played games for offline viewing
3. **Session Refresh**: Automatic token refresh before expiration
4. **Game Favorites**: Persistent favorites across devices
5. **Play History**: Complete game session history with analytics
6. **Multi-Window Support**: iPad split-screen casino gaming
7. **Progressive Web App**: Installable web casino experience

### API Enhancements Wishlist

1. **Batch Game Details**: Fetch multiple games in single request
2. **WebSocket Updates**: Real-time game availability updates
3. **Session Status Endpoint**: Check session validity without side effects
4. **Game Recommendations**: ML-based game suggestions
5. **Tournament Integration**: Live tournament participation

---

## References

### Internal Documentation

- [MVVM Architecture Guide](../MVVM.md)
- [API Development Guide](../API_DEVELOPMENT_GUIDE.md)
- [UI Component Guide](../UI_COMPONENT_GUIDE.md)

### External Resources

- [EveryMatrix API Documentation](https://docs.everymatrix.com)
- [WAMP Protocol Specification](https://wamp-proto.org)
- [iOS WKWebView Guide](https://developer.apple.com/documentation/webkit/wkwebview)
- [Vue.js Composition API](https://vuejs.org/guide/extras/composition-api-faq.html)

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-27 | Claude | Initial comprehensive documentation |

---

## Appendix: Code Snippets

### Complete Session Management Flow (Web)

```javascript
// 1. User Login
async function login(credentials) {
  const response = await api.post('/auth/login', credentials)

  // Server sets cookies automatically via Set-Cookie headers
  // sessionId, id, and other auth cookies are now available

  // Update user store
  userStore.user = response.data.user
  userStore.userId = response.data.user.id
}

// 2. Authenticated API Call
async function loadCasinoGames() {
  // Cookies automatically included by browser
  const response = await apiSession.casinoApi('get', '/v1/casino/games')
  return response.data
}

// 3. Game Launch with Session
function launchCasinoGame(gameId) {
  const sessionId = useCookies.getCookie('sessionId')

  if (!sessionId) {
    router.push('/login')
    return
  }

  const gameUrl = buildGameUrl(gameId, sessionId)
  openGameIframe(gameUrl)
}

// 4. Session Expiration Handling
axios.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      handleSessionExpiration()
    }
    return Promise.reject(error)
  }
)
```

### Complete Game Launch Flow (iOS Proposed)

```swift
// 1. User Login
func login(credentials: LoginCredentials) -> AnyPublisher<User, Error> {
    return api.post("/auth/login", body: credentials)
        .map { response in
            // Store session in Keychain
            KeychainStore.shared.set(response.sessionId, for: .sessionId)
            KeychainStore.shared.set(response.userId, for: .userId)

            // Update user session store
            userSessionStore.sessionId = response.sessionId
            userSessionStore.userId = response.userId
            userSessionStore.isAuthenticated = true

            return response.user
        }
        .eraseToAnyPublisher()
}

// 2. Authenticated API Call
func loadCasinoGames() -> AnyPublisher<[CasinoGame], Error> {
    // Session automatically injected by enhanced connector
    return casinoProvider.getGames(
        language: "en",
        platform: "iOS",
        pagination: .init(offset: 0, limit: 20)
    )
}

// 3. Game Launch with Session
func launchCasinoGame(gameId: String, mode: CasinoGameMode) {
    guard let sessionId = userSessionStore.sessionId else {
        coordinator.navigateToLogin()
        return
    }

    guard let game = gameStore.getGame(by: gameId),
          let gameUrl = game.buildLaunchURL(mode: mode, sessionId: sessionId) else {
        showError("Failed to launch game")
        return
    }

    presentGameWebView(url: gameUrl)
}

// 4. Session Expiration Handling
extension URLSession {
    func authenticatedDataTaskPublisher(for request: URLRequest) -> AnyPublisher<Data, Error> {
        return dataTaskPublisher(for: request)
            .tryMap { data, response in
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 401 {
                    throw ServiceProviderError.sessionExpired
                }
                return data
            }
            .catch { error -> AnyPublisher<Data, Error> in
                if case ServiceProviderError.sessionExpired = error {
                    NotificationCenter.default.post(name: .sessionExpired, object: nil)
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
```

---

*End of Document*