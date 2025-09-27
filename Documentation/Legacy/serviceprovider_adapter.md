Now let me create a detailed implementation plan based on this comprehensive analysis:

⏺ Update Todos
  ⎿  ☒ Deep analysis: Map all ServicesProvider methods used across the codebase
     ☒ Identify all ViewModels that need refactoring beyond NextUp/InPlay
     ☒ Analyze ServicesProvider return types and subscription patterns
     ☐ Design protocol hierarchy with proper segregation
     ☐ Plan migration strategy to avoid breaking existing code
     ☐ Identify potential circular dependencies and coupling issues
     ☐ PHASE 1: Create core protocol abstractions for Events and Betting
     ☐ PHASE 1: Implement RealApp adapters for Events and Betting providers
     ☐ PHASE 1: Create MockApp implementations with closure-based testing
     ☐ PHASE 1: Refactor NextUpEventsViewModel with dependency injection
     ☐ PHASE 1: Refactor InPlayEventsViewModel with dependency injection
     ☐ PHASE 1: Update ViewControllers to inject dependencies
     ☐ PHASE 1: Create unit tests for refactored ViewModels
     ☐ PHASE 2: Extend protocols for User, Content, and Connection providers
     ☐ PHASE 2: Refactor Core/ViewModels/* classes
     ☐ PHASE 3: Create service store abstractions (UserSession, Betslip, etc)
     ☐ PHASE 3: Complete ecosystem dependency injection

⏺ Detailed Implementation Plan: Dependency Injection with Adapter Pattern

  Based on my comprehensive analysis, here's a detailed, phased implementation plan that we can iterate on together:

  Executive Summary

  This is a complex, multi-phase project that will transform the testability of your iOS sports betting app. The current codebase has 112+ files using Env.servicesProvider with deep integration across ViewModels,
  requiring careful planning to avoid breaking existing functionality.

  Phase 1: Foundation (NextUp/InPlay ViewModels) - 2-3 weeks

  Step 1A: Protocol Design & File Structure

  Location: /sportsbook-ios/Core/DependencyInjection/Protocols/

  // Core/DependencyInjection/Protocols/AppEventsDataProvider.swift
  protocol AppEventsDataProvider {
      // Real-time subscriptions (primary usage pattern)
      func subscribeLiveMatches(forSportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
      func subscribePreLiveMatches(forSportType: SportType, sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>
      func subscribeEventDetails(eventId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError>
      func subscribeToMarketDetails(withId: String, onEventId: String) -> AnyPublisher<SubscribableContent<Market>, ServiceProviderError>
      func subscribeToEventOnListsOutcomeUpdates(withId: String) -> AnyPublisher<Outcome?, ServiceProviderError>

      // One-time calls
      func getSportRegions(sportId: String) -> AnyPublisher<[SportRegion], ServiceProviderError>
      func getEventDetails(eventId: String) -> AnyPublisher<Event, ServiceProviderError>
  }

  // Core/DependencyInjection/Protocols/AppBettingDataProvider.swift
  protocol AppBettingDataProvider {
      func placeBets(betTickets: [BetTicket], useFreebetBalance: Bool) -> AnyPublisher<PlacedBetsResponse, ServiceProviderError>
      func calculatePotentialReturn(forBetTicket: BetTicket) -> AnyPublisher<BetslipPotentialReturn, ServiceProviderError>
      func getAllowedBetTypes(withBetTicketSelections: [BetTicketSelection]) -> AnyPublisher<[BetType], ServiceProviderError>
  }

  // Core/DependencyInjection/Protocols/AppServicesProviderClient.swift
  protocol AppServicesProviderClient {
      var eventsDataProvider: AppEventsDataProvider { get }
      var bettingDataProvider: AppBettingDataProvider { get }
      var eventsConnectionStatePublisher: AnyPublisher<ConnectorState, Never> { get }
      var bettingConnectionStatePublisher: AnyPublisher<ConnectorState, Never> { get }
  }

  Step 1B: Real Adapter Implementation

  Location: /sportsbook-ios/Core/DependencyInjection/Adapters/

  // Core/DependencyInjection/Adapters/RealAppEventsDataProvider.swift
  final class RealAppEventsDataProvider: AppEventsDataProvider {
      private let realProvider: ServicesProvider.Client

      init(realProvider: ServicesProvider.Client) {
          self.realProvider = realProvider
      }

      func subscribeLiveMatches(forSportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
          return realProvider.subscribeLiveMatches(forSportType: forSportType)
      }

      func subscribePreLiveMatches(forSportType: SportType, sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
          return realProvider.subscribePreLiveMatches(forSportType: forSportType, sortType: sortType)
      }

      // ... implement all other methods
  }

  // Core/DependencyInjection/Adapters/RealAppServicesProviderClient.swift
  final class RealAppServicesProviderClient: AppServicesProviderClient {
      private let realClient: ServicesProvider.Client

      init(realClient: ServicesProvider.Client) {
          self.realClient = realClient
      }

      lazy var eventsDataProvider: AppEventsDataProvider = {
          RealAppEventsDataProvider(realProvider: realClient)
      }()

      lazy var bettingDataProvider: AppBettingDataProvider = {
          RealAppBettingDataProvider(realProvider: realClient)
      }()

      var eventsConnectionStatePublisher: AnyPublisher<ConnectorState, Never> {
          realClient.eventsConnectionStatePublisher
      }

      var bettingConnectionStatePublisher: AnyPublisher<ConnectorState, Never> {
          realClient.bettingConnectionStatePublisher
      }
  }

  Step 1C: Mock Implementation with Closures

  Location: /sportsbook-iosTests/Mocks/

  // sportsbook-iosTests/Mocks/MockAppEventsDataProvider.swift
  final class MockAppEventsDataProvider: AppEventsDataProvider {

      // Closure-based mocking for maximum flexibility
      var subscribeLiveMatchesHandler: ((SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>)?
      var subscribePreLiveMatchesHandler: ((SportType, EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>)?
      var subscribeEventDetailsHandler: ((String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError>)?

      // Default implementations for unused methods
      static func empty() -> MockAppEventsDataProvider {
          let mock = MockAppEventsDataProvider()

          // Provide sensible defaults
          mock.subscribeLiveMatchesHandler = { _ in
              Empty(completeImmediately: true).eraseToAnyPublisher()
          }

          mock.subscribePreLiveMatchesHandler = { _, _ in
              Empty(completeImmediately: true).eraseToAnyPublisher()
          }

          // ... set defaults for other methods
          return mock
      }

      // Protocol implementation delegates to closures
      func subscribeLiveMatches(forSportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
          guard let handler = subscribeLiveMatchesHandler else {
              XCTFail("subscribeLiveMatchesHandler was not set on MockAppEventsDataProvider")
              return Fail(error: ServiceProviderError.notImplemented).eraseToAnyPublisher()
          }
          return handler(forSportType)
      }

      func subscribePreLiveMatches(forSportType: SportType, sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
          guard let handler = subscribePreLiveMatchesHandler else {
              XCTFail("subscribePreLiveMatchesHandler was not set on MockAppEventsDataProvider")
              return Fail(error: ServiceProviderError.notImplemented).eraseToAnyPublisher()
          }
          return handler(forSportType, sortType)
      }

      // ... implement other methods
  }

  Step 1D: ViewModel Refactoring

  Critical Change: Modify NextUpEventsViewModel to accept dependencies via initializer

  // Core/Screens/NextUpEvents/NextUpEventsViewModel.swift
  class NextUpEventsViewModel: ObservableObject {

      // MARK: - Dependencies (Injected)
      private let appServicesProvider: AppServicesProviderClient

      // MARK: - Published Properties (unchanged)
      @Published var allMatches: [Match] = []
      @Published var marketGroups: [MarketGroupTabItemData] = []
      @Published var selectedMarketGroupId: String?
      @Published var isLoading: Bool = false

      // ... rest of properties unchanged

      // MARK: - New Dependency Injection Initializer
      init(
          sportType: SportType = SportType.defaultFootball,
          appServicesProvider: AppServicesProviderClient
      ) {
          self.sportType = sportType
          self.appServicesProvider = appServicesProvider

          // Initialize other dependencies (unchanged)
          self.quickLinksTabBarViewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
          self.pillSelectorBarViewModel = PillSelectorBarViewModel()
          self.marketGroupSelectorViewModel = NextUpEventsMarketGroupSelectorViewModel()

          let mainFilter = MainFilterItem(type: .mainFilter, title: "Filter", icon: "filter_icon", actionIcon: "right_arrow_icon")
          self.generalFiltersBarViewModel = MockGeneralFilterBarViewModel(items: [], mainFilterItem: mainFilter)

          setupBindings()
          setupFilters()
      }

      // MARK: - Legacy Initializer (for backward compatibility during migration)
      convenience init(sportType: SportType = SportType.defaultFootball) {
          let realProvider = RealAppServicesProviderClient(realClient: Env.servicesProvider)
          self.init(sportType: sportType, appServicesProvider: realProvider)
      }

      // MARK: - Updated loadEvents method
      private func loadEvents() {
          isLoading = true
          eventsStateSubject.send(.loading)

          preLiveMatchesCancellable?.cancel()

          // Use injected dependency instead of Env.servicesProvider
          preLiveMatchesCancellable = appServicesProvider.eventsDataProvider.subscribePreLiveMatches(
              forSportType: sportType,
              sortType: EventListSort.popular
          )
          .receive(on: DispatchQueue.main)
          .sink { completion in
              print("subscribePreLiveMatches \(completion)")
          } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
              switch subscribableContent {
              case .connected(let subscription):
                  print("Connected to pre-live matches subscription \(subscription.id)")

              case .contentUpdate(let content):
                  let matches = ServiceProviderModelMapper.matches(fromEventsGroups: content)
                  self?.processMatches(matches)

              case .disconnected:
                  print("Disconnected from pre-live matches subscription")
              }
          }
      }

      // MARK: - Other Dependencies Still Global (Phase 2)
      private func setupFilters() {
          // These remain global for now, will be addressed in Phase 2
          let sportFilterOption = self.getSportOption(for: Env.filterStorage.currentFilterSelection.sportId)
          let sortOption = self.getSortOption(for: Env.filterStorage.currentFilterSelection.sortTypeId)
          let leagueOption = self.getLeagueOption(for: Env.filterStorage.currentFilterSelection.leagueId)

          self.generalFiltersBarViewModel.updateFilterOptionItems(filterOptionItems: [sportFilterOption])
      }

      // ... rest of implementation unchanged
  }

  Step 1E: ViewController Updates

  Location: ViewControllers that create ViewModels

  // Core/Screens/NextUpEvents/NextUpEventsViewController.swift
  class NextUpEventsViewController: UIViewController {

      // MARK: - Dependencies
      private let appServicesProvider: AppServicesProviderClient

      // MARK: - ViewModels
      private var nextUpEventsViewModel: NextUpEventsViewModel!

      // MARK: - Dependency Injection Initializer
      init(appServicesProvider: AppServicesProviderClient, sportType: SportType = SportType.defaultFootball) {
          self.appServicesProvider = appServicesProvider
          super.init(nibName: nil, bundle: nil)

          // Inject dependencies into ViewModel
          self.nextUpEventsViewModel = NextUpEventsViewModel(
              sportType: sportType,
              appServicesProvider: appServicesProvider
          )
      }

      // Legacy initializer for backward compatibility
      convenience init(sportType: SportType = SportType.defaultFootball) {
          let realProvider = RealAppServicesProviderClient(realClient: Env.servicesProvider)
          self.init(appServicesProvider: realProvider, sportType: sportType)
      }

      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }

      // ... rest of implementation unchanged
  }

  Step 1F: Unit Tests

  // sportsbook-iosTests/ViewModels/NextUpEventsViewModelTests.swift
  final class NextUpEventsViewModelTests: XCTestCase {

      private var mockAppServicesProvider: MockAppServicesProviderClient!
      private var mockEventsProvider: MockAppEventsDataProvider!
      private var viewModel: NextUpEventsViewModel!
      private var cancellables: Set<AnyCancellable>!

      override func setUp() {
          super.setUp()

          // Create mock providers
          mockEventsProvider = MockAppEventsDataProvider.empty()
          mockAppServicesProvider = MockAppServicesProviderClient.empty()
          mockAppServicesProvider.mockEventsDataProvider = mockEventsProvider

          cancellables = Set<AnyCancellable>()
      }

      override func tearDown() {
          cancellables.removeAll()
          viewModel = nil
          mockAppServicesProvider = nil
          mockEventsProvider = nil
          super.tearDown()
      }

      func testLoadEventsSuccess() {
          // Given: Mock data
          let expectedMatches = [
              createMockMatch(id: "1", homeTeam: "Team A", awayTeam: "Team B"),
              createMockMatch(id: "2", homeTeam: "Team C", awayTeam: "Team D")
          ]
          let eventsGroups = createMockEventsGroups(matches: expectedMatches)

          // Configure mock to return test data
          mockEventsProvider.subscribePreLiveMatchesHandler = { sportType, sortType in
              let subscribableContent = SubscribableContent<[EventsGroup]>.contentUpdate(eventsGroups)
              return Just(subscribableContent)
                  .setFailureType(to: ServiceProviderError.self)
                  .delay(for: .milliseconds(100), scheduler: RunLoop.main)
                  .eraseToAnyPublisher()
          }

          // When: Initialize ViewModel (triggers loadEvents)
          viewModel = NextUpEventsViewModel(
              sportType: SportType.defaultFootball,
              appServicesProvider: mockAppServicesProvider
          )

          let expectation = XCTestExpectation(description: "Events loaded")

          // Then: Verify loading state and final data
          viewModel.eventsState
              .sink { loadableContent in
                  switch loadableContent {
                  case .loading:
                      XCTAssertTrue(self.viewModel.isLoading)
                  case .loaded(let matches):
                      XCTAssertFalse(self.viewModel.isLoading)
                      XCTAssertEqual(matches.count, 2)
                      XCTAssertEqual(matches[0].homeTeam.name, "Team A")
                      expectation.fulfill()
                  case .idle, .failed:
                      break
                  }
              }
              .store(in: &cancellables)

          wait(for: [expectation], timeout: 1.0)
      }

      func testLoadEventsError() {
          // Given: Mock error
          let testError = ServiceProviderError.networkError

          mockEventsProvider.subscribePreLiveMatchesHandler = { _, _ in
              return Fail(error: testError).eraseToAnyPublisher()
          }

          // When: Initialize ViewModel
          viewModel = NextUpEventsViewModel(
              sportType: SportType.defaultFootball,
              appServicesProvider: mockAppServicesProvider
          )

          let expectation = XCTestExpectation(description: "Error handled")

          // Then: Verify error handling
          viewModel.eventsState
              .sink { loadableContent in
                  switch loadableContent {
                  case .failed:
                      expectation.fulfill()
                  default:
                      break
                  }
              }
              .store(in: &cancellables)

          wait(for: [expectation], timeout: 1.0)
      }

      // Helper methods
      private func createMockMatch(id: String, homeTeam: String, awayTeam: String) -> Match {
          // Create mock Match object
          // Implementation depends on your Match model structure
      }

      private func createMockEventsGroups(matches: [Match]) -> [EventsGroup] {
          // Create mock EventsGroup objects
          // Implementation depends on your EventsGroup model structure
      }
  }

  Step 1G: Production Wiring

  Location: App composition root

  // Core/Environment/Environment.swift
  class Environment {

      // Keep existing servicesProvider for backward compatibility
      lazy var servicesProvider: ServicesProvider.Client = {
          // existing implementation
      }()

      // New dependency injection entry point
      lazy var appServicesProvider: AppServicesProviderClient = {
          return RealAppServicesProviderClient(realClient: servicesProvider)
      }()

      // ... rest unchanged
  }

  // Usage in ViewControllers/Coordinators
  let nextUpViewController = NextUpEventsViewController(
      appServicesProvider: Env.appServicesProvider,
      sportType: selectedSport
  )

  Phase 2: Extended Protocols (Weeks 4-6)

  Step 2A: Additional Protocol Layer

  // Core/DependencyInjection/Protocols/AppUserDataProvider.swift
  protocol AppUserDataProvider {
      func loginUser(withUsername: String, andPassword: String) -> AnyPublisher<UserProfile, ServiceProviderError>
      func getProfile() -> AnyPublisher<UserProfile, ServiceProviderError>
      func getUserBalance() -> AnyPublisher<UserWallet, ServiceProviderError>
      func signUp(withRegistrationData: UserRegistrationData) -> AnyPublisher<UserProfile, ServiceProviderError>
  }

  // Core/DependencyInjection/Protocols/AppContentDataProvider.swift
  protocol AppContentDataProvider {
      func getHomeTemplate() -> AnyPublisher<HomeTemplate, ServiceProviderError>
      func getBanners() -> AnyPublisher<[Banner], ServiceProviderError>
      func getStories() -> AnyPublisher<[Story], ServiceProviderError>
      func getCarouselEvents() -> AnyPublisher<[CarouselEvent], ServiceProviderError>
      func getPromotedSports() -> AnyPublisher<[PromotedSport], ServiceProviderError>
  }

  Step 2B: Refactor Core/ViewModels Classes

  Priority order based on complexity:
  1. OutcomeItemViewModel - Real-time outcome subscriptions
  2. MarketOutcomesLineViewModel - Market data subscriptions
  3. TallOddsMatchCardViewModel - Match display logic
  4. SportSelectorViewModel - Sports data handling

  Phase 3: Service Store Abstractions (Weeks 7-9)

  Step 3A: Service Store Protocols

  // Core/DependencyInjection/Protocols/ServiceStores.swift
  protocol AppUserSessionStore {
      var userProfilePublisher: CurrentValueSubject<UserProfile?, Never> { get }
      var userWalletPublisher: CurrentValueSubject<UserWallet?, Never> { get }
      func isUserLogged() -> Bool
      func login(withUsername: String, password: String) -> AnyPublisher<Void, UserSessionError>
      func logout()
  }

  protocol AppBetslipManager {
      var bettingTicketsPublisher: CurrentValueSubject<[BettingTicket], Never> { get }
      func addBettingTicket(_ bettingTicket: BettingTicket)
      func removeBettingTicket(_ bettingTicket: BettingTicket)
      func placeBets() -> AnyPublisher<[BetPlacedDetails], BetslipErrorType>
  }

  protocol AppSportTypeStore {
      var activeSportsPublisher: AnyPublisher<LoadableContent<[Sport]>, ServiceProviderError> { get }
      func getActiveSports() -> [Sport]
      var defaultSport: Sport { get }
  }

  protocol AppFilterStorage {
      var currentFilterSelection: GeneralFilterSelection { get }
      var currentCompetitions: [Competition] { get }
      func updateFilterSelection(_ newSelection: GeneralFilterSelection)
  }

  Step 3B: Complete Ecosystem Refactoring

  This phase involves:
  - Creating adapters for all service stores
  - Comprehensive ViewModel refactoring
  - Complete elimination of global Env dependencies
  - Full test coverage across all components

  Migration Strategy & Risk Mitigation

  Backward Compatibility

  - Keep existing Env.servicesProvider intact during migration
  - Provide convenience initializers for all refactored classes
  - Gradual rollout with feature flags if needed

  Testing Strategy

  - Unit tests for each protocol/adapter pair
  - Integration tests for ViewModel behavior
  - Performance tests for subscription handling
  - Mock data validation tests

  Potential Risks & Mitigation

  1. Breaking Changes:
    - Use convenience initializers for backward compatibility
    - Gradual migration of call sites
  2. Performance Impact:
    - Profile subscription handling performance
    - Monitor memory usage during testing
    - Optimize adapter implementations
  3. Complex Dependencies:
    - Map all cross-dependencies before refactoring
    - Create dependency graphs to identify circular references
    - Implement interfaces before concrete classes
  4. Test Data Management:
    - Create comprehensive mock data factories
    - Establish testing data standards
    - Implement test utility helpers

  Success Metrics

  - Unit Test Coverage: 90%+ on refactored ViewModels
  - Test Execution Time: <30 seconds for full ViewModel test suite
  - Mock Flexibility: Ability to simulate any data scenario
  - Code Maintainability: Reduced coupling between ViewModels and data layer
  - Development Velocity: Faster feature development due to better testability

  Next Steps for Iteration

  1. Review this plan - Does the phased approach work for you?
  2. Validate protocol design - Do the protocol abstractions capture your needs?
  3. Confirm file structure - Are the proposed locations appropriate?
  4. Discuss testing strategy - What level of test coverage do you want?
  5. Plan implementation timeline - How does this fit your development schedule?

  This plan provides a solid foundation that we can refine together. What aspects would you like to dive deeper into or modify?