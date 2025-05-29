import Foundation
import Combine

/// Store for managing sports/disciplines data with real-time updates
final class SportsStore: ObservableObject {

    // MARK: - Published Properties

    /// Array of all sports (both live and non-live)
    @Published private(set) var sports: [Sport] = []

    /// Loading state for sports data
    @Published private(set) var isLoading: Bool = false

    /// Error state
    @Published private(set) var error: Error?

    // MARK: - Private Properties

    private let tsManager: TSManager
    private var cancellables = Set<AnyCancellable>()
    private var subscription: Subscription?
    private let queue = DispatchQueue(label: "com.goma.sportsstore", qos: .userInitiated)

    // Configuration
    private var operatorId: String?
    private var language: String
    private var hasStartedSubscription = false

    // MARK: - Initialization

    /// Initialize the SportsStore
    /// - Parameters:
    ///   - tsManager: The TSManager instance for WAMP communication
    ///   - language: Language code for localization (default: "en")
    init(tsManager: TSManager, language: String = "en") {
        self.tsManager = tsManager
        self.language = language

        setupOperatorInfoRetrieval()
    }

    // MARK: - Public Methods

    /// Start subscribing to sports data (both live and non-live)
    func startSubscription() {
        guard !hasStartedSubscription else {
            print("SportsStore: Subscription already started")
            return
        }

        guard let operatorId = operatorId else {
            print("SportsStore: Cannot start subscription - operatorId not available")
            // Try to get operator info first
            retrieveOperatorInfo()
            return
        }

        hasStartedSubscription = true
        isLoading = true
        error = nil

        subscribeToAllSports()
    }

    /// Stop the subscription
    func stopSubscription() {
        hasStartedSubscription = false

        // Unsubscribe from the active subscription
        if let subscription = subscription {
            tsManager.unsubscribeFromSports(subscription)
            print("SportsStore: Unsubscribed from sports")
        }

        subscription = nil
        isLoading = false
    }

    /// Update the language and restart subscription if needed
    /// - Parameter language: New language code
    func updateLanguage(_ language: String) {
        self.language = language
        if hasStartedSubscription {
            stopSubscription()
            startSubscription()
        }
    }

    /// Manually trigger operator info retrieval
    func retrieveOperatorInfo() {
        tsManager.getOperatorInfo()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("SportsStore: Failed to get operator info: \(error)")
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] operatorInfo in
                    self?.handleOperatorInfo(operatorInfo)
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Private Methods

    private func setupOperatorInfoRetrieval() {
        // Automatically try to get operator info when TSManager connects
        // This could be enhanced to listen for connection state changes
        retrieveOperatorInfo()
    }

    private func handleOperatorInfo(_ operatorInfo: [String: Any]) {
        if let ucsOperatorId = operatorInfo["ucsOperatorId"] as? Int {
            self.operatorId = String(ucsOperatorId)
            print("SportsStore: Got operator ID: \(ucsOperatorId)")

            // Start subscription if it hasn't been started yet
            if !hasStartedSubscription {
                startSubscription()
            }
        } else {
            print("SportsStore: No ucsOperatorId found in operator info: \(operatorInfo)")
        }
    }

    /// Subscribe to all sports (both live and non-live) using a single subscription
    private func subscribeToAllSports() {
        guard let operatorId = operatorId else { return }

        queue.async { [weak self] in
            guard let self = self else { return }

            let subscription = self.tsManager.subscribeToAllSports(
                operatorId: operatorId,
                language: self.language,
                onInitialDump: { [weak self] sportsData in
                    print("SportsStore: Received sports initial dump")
                    self?.handleSportsData(sportsData, isInitialDump: true)
                },
                onUpdate: { [weak self] updateData in
                    print("SportsStore: Received sports update")
                    self?.handleSportsUpdate(updateData)
                },
                onError: { [weak self] error in
                    print("SportsStore: Sports subscription error: \(error)")
                    DispatchQueue.main.async {
                        self?.error = error
                        self?.isLoading = false
                    }
                }
            )

            if let subscription = subscription {
                self.subscription = subscription
                print("SportsStore: Successfully subscribed to all sports")
            }
        }
    }

    /// Handle initial sports data dump
    private func handleSportsData(_ data: [String: Any], isInitialDump: Bool) {
        queue.async { [weak self] in
            guard let self = self else { return }

            print("SportsStore: Processing sports data")
            print("SportsStore: Data keys: \(data.keys)")

            // Parse the data to determine context for each sport
            var currentSports: [Sport] = []
            
            // The BOTH/BOTH subscription should return sports with context information
            // We need to determine if each sport is live or not based on the data structure
            if let records = data["records"] as? [[String: Any]] {
                for record in records {
                    // Determine context based on sport properties
                    let context = self.determineSportContext(from: record)
                    
                    if let mappedSport = SportMapper.mapSport(
                        from: record,
                        context: context,
                        existingSports: &currentSports
                    ) {
                        print("SportsStore: Mapped sport \(mappedSport.name) with context: \(context)")
                    }
                }
            } else {
                // Handle other possible data formats
                let mappedSports = SportMapper.mapSportsFromSocketResponse(
                    data,
                    context: "all", // Default context for mixed data
                    existingSports: &currentSports
                )
                print("SportsStore: Mapped \(mappedSports.count) sports with default context")
            }

            print("SportsStore: Total sports processed: \(currentSports.count)")

            DispatchQueue.main.async {
                self.sports = currentSports
                if isInitialDump {
                    self.isLoading = false
                    print("SportsStore: Initial dump completed - Loading finished")
                }
            }
        }
    }

    /// Determine the context of a sport based on its properties
    private func determineSportContext(from sportData: [String: Any]) -> String {
        // Check if the sport has live events or markets
        let numberOfLiveEvents = sportData["numberOfLiveEvents"] as? Int ?? 0
        let numberOfLiveMarkets = sportData["numberOfLiveMarkets"] as? Int ?? 0
        let numberOfEvents = sportData["numberOfEvents"] as? Int ?? 0
        
        if numberOfLiveEvents > 0 || numberOfLiveMarkets > 0 {
            return "live"
        } else if numberOfEvents > 0 {
            return "popular"
        } else {
            return "all"
        }
    }

    /// Handle real-time sports updates
    private func handleSportsUpdate(_ data: [String: Any]) {
        queue.async { [weak self] in
            guard let self = self else { return }

            print("SportsStore: Processing sports update")

            // Handle different types of updates (CREATE, UPDATE, DELETE)
            if let changeType = data["changeType"] as? String,
               let entityType = data["entityType"] as? String,
               entityType == "SPORT" {

                print("SportsStore: Handling \(changeType) for SPORT entity")

                switch changeType {
                case "CREATE":
                    if let entity = data["entity"] as? [String: Any] {
                        let context = self.determineSportContext(from: entity)
                        var currentSports = self.sports
                        if let newSport = SportMapper.mapSport(
                            from: entity,
                            context: context,
                            existingSports: &currentSports
                        ) {
                            DispatchQueue.main.async {
                                self.sports = currentSports
                            }
                        }
                    }

                case "UPDATE":
                    if let id = data["id"] as? String,
                       let changedProperties = data["changedProperties"] as? [String: Any] {
                        let context = self.determineSportContext(from: changedProperties)
                        self.updateSport(id: id, properties: changedProperties, context: context)
                    }

                case "DELETE":
                    if let id = data["id"] as? String {
                        self.deleteSport(id: id)
                    }

                default:
                    print("SportsStore: Unknown change type: \(changeType)")
                }
            } else {
                // Handle bulk updates or other formats
                var currentSports = self.sports
                let mappedSports = SportMapper.mapSportsFromSocketResponse(
                    data,
                    context: "all",
                    existingSports: &currentSports
                )

                if !mappedSports.isEmpty {
                    DispatchQueue.main.async {
                        self.sports = currentSports
                    }
                }
            }
        }
    }

    /// Update an existing sport with new properties
    private func updateSport(id: String, properties: [String: Any], context: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if let index = self.sports.firstIndex(where: { $0.id == id }) {
                var updatedSport = self.sports[index]

                // Update properties and context
                updatedSport = updatedSport.withContext(context)

                self.sports[index] = updatedSport
                print("SportsStore: Updated sport \(id) in context \(context)")
            }
        }
    }

    /// Remove a sport entirely
    private func deleteSport(id: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if let index = self.sports.firstIndex(where: { $0.id == id }) {
                self.sports.remove(at: index)
                print("SportsStore: Removed sport \(id)")
            }
        }
    }
}

// MARK: - Public Publishers

extension SportsStore {

    /// Publisher for sports array changes
    var sportsPublisher: AnyPublisher<[Sport], Never> {
        $sports.eraseToAnyPublisher()
    }

    /// Publisher for loading state changes
    var loadingPublisher: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }

    /// Publisher for error state changes
    var errorPublisher: AnyPublisher<Error?, Never> {
        $error.eraseToAnyPublisher()
    }

    /// Combined publisher for all state changes
    var statePublisher: AnyPublisher<(sports: [Sport], isLoading: Bool, error: Error?), Never> {
        Publishers.CombineLatest3($sports, $isLoading, $error)
            .map { (sports: $0, isLoading: $1, error: $2) }
            .eraseToAnyPublisher()
    }
}

// MARK: - Convenience Methods

extension SportsStore {

    /// Get sports filtered by context
    /// - Parameter context: The context to filter by ("live", "popular")
    /// - Returns: Array of sports for the specified context
    func sports(for context: String) -> [Sport] {
        return sports.filter { $0.contexts[context] != nil }
    }

    /// Get live sports only
    var liveSports: [Sport] {
        return sports(for: "live")
    }

    /// Get popular/pre-live sports only
    var popularSports: [Sport] {
        return sports(for: "popular")
    }

    /// Get a sport by ID
    /// - Parameter id: The sport ID
    /// - Returns: The sport if found
    func sport(withId id: String) -> Sport? {
        return sports.first { $0.id == id }
    }
}
