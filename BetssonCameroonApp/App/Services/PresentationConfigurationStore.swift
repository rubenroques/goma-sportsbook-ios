import Foundation
import Combine
import PresentationProvider

/// Loading state for the presentation configuration
public enum PresentationConfigLoadState {
    case initial
    case loading
    case loaded(PresentationConfiguration)
    case error(Error)

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    var configuration: PresentationConfiguration? {
        if case .loaded(let config) = self {
            return config
        }
        return nil
    }

    var error: Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
}

/// A class that manages presentation configuration with caching and loading state
///
/// This class serves as a centralized store for the presentation configuration,
/// providing caching, state management, and exposing a clean interface for the app.
public class PresentationConfigurationStore {

    // MARK: - Properties

    /// The configuration service provided by the PresentationProvider package
    private let configurationService: PresentationConfigurationServicing

    /// The cache key for UserDefaults
    private let cacheKey = "PresentationConfigurationCache"

    /// The current load state subject
    private let loadStateSubject = CurrentValueSubject<PresentationConfigLoadState, Never>(.initial)

    /// The load state publisher
    public var loadState: AnyPublisher<PresentationConfigLoadState, Never> {
        return self.loadStateSubject.eraseToAnyPublisher()
    }

    /// Access to the current load state value
    public var currentLoadState: PresentationConfigLoadState {
        return self.loadStateSubject.value
    }

    /// A publisher that only emits successful configurations
    public var configuration: AnyPublisher<PresentationConfiguration, Never> {
        return loadStateSubject
            .compactMap { state -> PresentationConfiguration? in
                if case .loaded(let config) = state {
                    return config
                }
                return nil
            }
            .eraseToAnyPublisher()
    }

    /// Private set of cancellables
    private var cancellables = Set<AnyCancellable>()

    /// The cache timeout in seconds (default: 1 hour)
    private let cacheTimeout: TimeInterval

    /// The timestamp when the cache was last updated
    private var lastCacheUpdate: Date? {
        get { UserDefaults.standard.object(forKey: "\(cacheKey)_timestamp") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "\(cacheKey)_timestamp") }
    }

    // MARK: - Initialization

    /// Initializes a new PresentationConfigurationStore
    ///
    /// - Parameters:
    ///   - configurationService: The service to fetch configuration from
    ///   - cacheTimeout: The cache timeout in seconds (default: 1 hour)
    public init(configurationService: PresentationConfigurationServicing = PresentationManager(),
                cacheTimeout: TimeInterval = 3600) {
        self.configurationService = configurationService
        self.cacheTimeout = cacheTimeout

        // Try to load from cache initially
        self.loadFromCache()
    }

    // MARK: - Public Methods

    /// Loads the presentation configuration, using cache if valid
    ///
    /// This method will first check if there's a valid cache. If not, it will fetch
    /// from the provider and update the cache.
    ///
    /// - Parameter forceRefresh: If true, ignores the cache and fetches fresh data
    public func loadConfiguration(forceRefresh: Bool = false) {
        // If we're already loading, don't start another load
        if case .loading = loadStateSubject.value, !forceRefresh {
            return
        }

        // If we have valid cache and aren't forcing a refresh, use it
        if !forceRefresh,
           let lastUpdate = lastCacheUpdate,
           Date().timeIntervalSince(lastUpdate) < cacheTimeout,
           case .loaded = loadStateSubject.value {
            return
        }

        // Otherwise, fetch fresh data
        self.loadStateSubject.send(.loading)

        self.configurationService.fetchPresentationConfiguration()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.loadStateSubject.send(.error(error))
                    }
                },
                receiveValue: { [weak self] config in
                    self?.updateCache(with: config)
                    self?.loadStateSubject.send(.loaded(config))
                }
            )
            .store(in: &cancellables)
    }

    /// Clears the configuration cache and resets to initial state
    public func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: "\(cacheKey)_timestamp")
        loadStateSubject.send(.initial)
    }

    /// Returns a specific navbar configuration if available
    ///
    /// - Parameter navbarId: The ID of the navbar to retrieve
    /// - Returns: The navbar configuration or nil if not found or not loaded
    public func navbar(withId navbarId: NavbarIdentifier) -> NavigationBarLayout? {
        if case .loaded(let config) = loadStateSubject.value {
            return config.navbar(withId: navbarId)
        }
        return nil
    }

    /// Returns tab items for a specific navbar if available
    ///
    /// - Parameter navbarId: The ID of the navbar to get tabs for
    /// - Returns: Array of tab items or empty array if not found or not loaded
    public func tabItems(forNavbar navbarId: NavbarIdentifier) -> [TabItem] {
        if case .loaded(let config) = loadStateSubject.value {
            return config.tabItems(forNavbar: navbarId)
        }
        return []
    }

    // MARK: - Private Methods

    /// Loads the presentation configuration from cache if available
    private func loadFromCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            let config = try decoder.decode(PresentationConfiguration.self, from: data)
            loadStateSubject.send(.loaded(config))
        } catch {
            print("Failed to decode cached presentation configuration: \(error)")
            // Don't update load state - stay in .initial
            clearCache() // Clear invalid cache
        }
    }

    /// Updates the cache with a new configuration
    ///
    /// - Parameter config: The configuration to cache
    private func updateCache(with config: PresentationConfiguration) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(config)
            UserDefaults.standard.set(data, forKey: cacheKey)
            lastCacheUpdate = Date()
        } catch {
            print("Failed to encode presentation configuration for caching: \(error)")
        }
    }
}
