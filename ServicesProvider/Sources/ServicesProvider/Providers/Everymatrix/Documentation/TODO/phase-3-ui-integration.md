# Phase 3: UI Integration & Cell-Level Subscriptions

## 🎯 Objective
Integrate the observable EntityStore with UI components to achieve granular, cell-level updates for betting odds and market changes.

---

## 📋 Implementation Checklist

### ✅ Prerequisites (Completed in Phase 2)
- [x] EntityStore emits change notifications
- [x] Provider methods for market/outcome observation
- [x] Memory management for publishers
- [x] Thread-safe observation methods

### 🚧 Phase 3 Tasks

#### Task 3.1: ViewModel Integration
- [ ] Update existing ViewModels to use granular subscriptions
- [ ] Add observation methods to ViewModels
- [ ] Implement proper Combine subscription management
- [ ] Handle subscription lifecycle in ViewModels

#### Task 3.2: Collection View Cell Updates
- [ ] Add observation capabilities to betting offer cells
- [ ] Implement smooth odds change animations
- [ ] Handle availability state changes in cells
- [ ] Add visual feedback for real-time updates

#### Task 3.3: Market Group Updates
- [ ] Observe market changes in group headers
- [ ] Handle market addition/removal from groups
- [ ] Update market ordering when mainLine changes
- [ ] Implement smooth group layout transitions

#### Task 3.4: Match Card Integration
- [ ] Subscribe to match statistics updates
- [ ] Update betting offer counters in real-time
- [ ] Handle match status changes
- [ ] Implement match card removal on deletion

#### Task 3.5: Performance Optimization
- [ ] Implement subscription batching for multiple cells
- [ ] Add debouncing for high-frequency updates
- [ ] Optimize for large collection views (100+ cells)
- [ ] Add memory pressure handling

#### Task 3.6: Error Handling & Fallbacks
- [ ] Handle subscription failures gracefully
- [ ] Implement fallback to full reloads when needed
- [ ] Add offline state handling
- [ ] Create reconnection strategies

#### Task 3.7: Animation & Visual Polish
- [ ] Add smooth odds change animations
- [ ] Implement suspension/availability visual states
- [ ] Add loading states for new entities
- [ ] Create deletion animations

#### Task 3.8: Testing & Validation
- [ ] UI automation tests for granular updates
- [ ] Performance testing with high-frequency changes
- [ ] Memory leak testing with long-running sessions
- [ ] Visual regression testing

---

## 🔧 Technical Implementation Details

### 3.1 Enhanced ViewModels

```swift
// MarketGroupViewModel.swift
class MarketGroupViewModel: ObservableObject {
    @Published var markets: [Market] = []
    @Published var isLoading = false
    
    private var marketSubscriptions: [String: AnyCancellable] = [:]
    private var cancellables = Set<AnyCancellable>()
    private let servicesProvider: ServicesProviderProtocol
    
    init(servicesProvider: ServicesProviderProtocol) {
        self.servicesProvider = servicesProvider
    }
    
    // NEW: Subscribe to individual market changes
    func observeMarket(id: String) {
        // Cancel existing subscription for this market
        marketSubscriptions[id]?.cancel()
        
        marketSubscriptions[id] = servicesProvider
            .subscribeToEventOnListsMarketUpdates(withId: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("Market observation failed for \(id): \(error)")
                        // Fallback to full reload if needed
                        self?.handleMarketObservationError(marketId: id, error: error)
                    }
                },
                receiveValue: { [weak self] market in
                    self?.updateMarket(market, id: id)
                }
            )
    }
    
    // NEW: Update specific market without full reload
    private func updateMarket(_ market: Market?, id: String) {
        guard let market = market else {
            // Market was deleted
            markets.removeAll { $0.id == id }
            return
        }
        
        if let index = markets.firstIndex(where: { $0.id == id }) {
            // Update existing market
            markets[index] = market
        } else {
            // Add new market
            markets.append(market)
            sortMarkets()
        }
    }
    
    private func sortMarkets() {
        markets.sort { market1, market2 in
            // Sort by mainLine first, then by name
            if market1.isMainLine != market2.isMainLine {
                return market1.isMainLine == true
            }
            return market1.name < market2.name
        }
    }
    
    deinit {
        // Clean up all subscriptions
        marketSubscriptions.values.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
```

### 3.2 Enhanced Collection View Cells

```swift
// OutcomeCollectionViewCell.swift
class OutcomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var oddsLabel: UILabel!
    @IBOutlet weak var outcomeNameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    private var outcomeSubscription: AnyCancellable?
    private var currentOutcomeId: String?
    private var servicesProvider: ServicesProviderProtocol?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        outcomeSubscription?.cancel()
        outcomeSubscription = nil
        currentOutcomeId = nil
    }
    
    // NEW: Configure with granular subscription
    func configure(
        outcomeId: String,
        servicesProvider: ServicesProviderProtocol,
        initialData: Outcome? = nil
    ) {
        self.currentOutcomeId = outcomeId
        self.servicesProvider = servicesProvider
        
        // Set initial data if provided
        if let outcome = initialData {
            updateUI(with: outcome)
        }
        
        // Subscribe to real-time updates
        subscribeToOutcomeUpdates(outcomeId: outcomeId)
    }
    
    private func subscribeToOutcomeUpdates(outcomeId: String) {
        outcomeSubscription?.cancel()
        
        outcomeSubscription = servicesProvider?
            .subscribeToEventOnListsOutcomeUpdates(withId: outcomeId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Outcome observation failed for \(outcomeId): \(error)")
                    }
                },
                receiveValue: { [weak self] outcome in
                    guard let self = self, 
                          self.currentOutcomeId == outcomeId else { return }
                    
                    if let outcome = outcome {
                        self.updateUI(with: outcome, animated: true)
                    } else {
                        // Outcome was deleted - handle gracefully
                        self.handleOutcomeDeletion()
                    }
                }
            )
    }
    
    private func updateUI(with outcome: Outcome, animated: Bool = false) {
        outcomeNameLabel.text = outcome.shortName ?? outcome.name
        
        // Update odds with animation if available
        if let firstOffer = outcome.bettingOffers.first {
            updateOdds(firstOffer.odds, isAvailable: firstOffer.isAvailable, animated: animated)
        }
        
        // Update availability state
        updateAvailabilityState(outcome.bettingOffers.first?.isAvailable ?? false)
    }
    
    private func updateOdds(_ newOdds: Double, isAvailable: Bool, animated: Bool) {
        let formattedOdds = OddFormatter.format(odds: newOdds)
        
        guard animated else {
            oddsLabel.text = formattedOdds
            return
        }
        
        // Animate odds change
        UIView.transition(with: oddsLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.oddsLabel.text = formattedOdds
        }
        
        // Add brief highlight effect
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.containerView.backgroundColor = .clear
            }
        }
    }
    
    private func updateAvailabilityState(_ isAvailable: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.containerView.alpha = isAvailable ? 1.0 : 0.6
            self.isUserInteractionEnabled = isAvailable
        }
    }
    
    private func handleOutcomeDeletion() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.3
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        })
    }
}
```

### 3.3 Collection View Integration

```swift
// NextUpEventsViewController.swift
extension NextUpEventsViewController {
    
    func configureCell(_ cell: OutcomeCollectionViewCell, at indexPath: IndexPath) {
        let outcome = outcomes[indexPath.item]
        
        // Configure with granular subscription
        cell.configure(
            outcomeId: outcome.id,
            servicesProvider: servicesProvider,
            initialData: outcome
        )
    }
    
    // NEW: Batch subscription management
    private func subscribeToCellUpdates() {
        // When view appears, ensure cells are subscribed
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            for cell in self.collectionView.visibleCells {
                if let outcomeCell = cell as? OutcomeCollectionViewCell,
                   let indexPath = self.collectionView.indexPath(for: cell) {
                    let outcome = self.outcomes[indexPath.item]
                    outcomeCell.configure(
                        outcomeId: outcome.id,
                        servicesProvider: self.servicesProvider,
                        initialData: outcome
                    )
                }
            }
        }
    }
    
    // NEW: Handle collection view scrolling efficiently
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        
        // Resubscribe visible cells after scrolling
        subscribeToCellUpdates()
    }
}
```

### 3.4 Match Card Updates

```swift
// TallOddsMatchCardCollectionViewCell.swift
class TallOddsMatchCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var matchNameLabel: UILabel!
    @IBOutlet weak var marketsCountLabel: UILabel!
    @IBOutlet weak var offersCountLabel: UILabel!
    
    private var matchSubscription: AnyCancellable?
    
    func configure(with match: Match, servicesProvider: ServicesProviderProtocol) {
        updateUI(with: match)
        subscribeToMatchUpdates(matchId: match.id, servicesProvider: servicesProvider)
    }
    
    private func subscribeToMatchUpdates(matchId: String, servicesProvider: ServicesProviderProtocol) {
        matchSubscription?.cancel()
        
        // Subscribe to match statistics updates
        matchSubscription = servicesProvider
            .subscribeToEventOnListsMatchUpdates(withId: matchId) // NEW method needed
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Match observation failed: \(error)")
                    }
                },
                receiveValue: { [weak self] match in
                    guard let match = match else {
                        // Match deleted - animate removal
                        self?.animateRemoval()
                        return
                    }
                    self?.updateMatchStatistics(match)
                }
            )
    }
    
    private func updateMatchStatistics(_ match: Match) {
        // Animate counter updates
        UIView.transition(with: marketsCountLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.marketsCountLabel.text = "\(match.numberOfMarkets ?? 0)"
        }
        
        UIView.transition(with: offersCountLabel, duration: 0.2, options: .transitionCrossDissolve) {
            self.offersCountLabel.text = "\(match.numberOfBettingOffers ?? 0)"
        }
    }
    
    private func animateRemoval() {
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.alpha = 0
        })
    }
}
```

---

## ⚡ Performance Optimizations

### 3.5 Subscription Batching

```swift
// SubscriptionManager.swift
class SubscriptionManager {
    private var batchedSubscriptions: [String: Set<String>] = [:]
    private let batchingQueue = DispatchQueue(label: "subscription.batching")
    private let batchInterval: TimeInterval = 0.1
    
    func requestSubscription(entityType: String, entityId: String, completion: @escaping () -> Void) {
        batchingQueue.async { [weak self] in
            if self?.batchedSubscriptions[entityType] == nil {
                self?.batchedSubscriptions[entityType] = Set()
            }
            
            self?.batchedSubscriptions[entityType]?.insert(entityId)
            
            // Debounce subscription requests
            DispatchQueue.main.asyncAfter(deadline: .now() + self?.batchInterval ?? 0.1) {
                self?.processBatchedSubscriptions(entityType: entityType)
                completion()
            }
        }
    }
    
    private func processBatchedSubscriptions(entityType: String) {
        guard let entityIds = batchedSubscriptions[entityType], !entityIds.isEmpty else { return }
        
        // Process all pending subscriptions for this entity type
        for entityId in entityIds {
            // Create individual subscriptions
            // Or implement bulk subscription API if available
        }
        
        batchedSubscriptions[entityType]?.removeAll()
    }
}
```

### 3.6 Memory Pressure Handling

```swift
// MemoryPressureManager.swift
class MemoryPressureManager {
    private let notificationCenter = NotificationCenter.default
    private var subscriptions: Set<AnyCancellable> = []
    
    init() {
        observeMemoryWarnings()
    }
    
    private func observeMemoryWarnings() {
        notificationCenter
            .publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .sink { [weak self] _ in
                self?.handleMemoryPressure()
            }
            .store(in: &subscriptions)
    }
    
    private func handleMemoryPressure() {
        // Cancel non-visible cell subscriptions
        // Clean up cached publishers
        // Reduce subscription count temporarily
        print("Memory pressure detected - optimizing subscriptions")
    }
}
```

---

## 🧪 Testing Strategy

### 3.7 UI Automation Tests

```swift
// GranularUpdatesUITests.swift
class GranularUpdatesUITests: XCTestCase {
    
    func testOddsUpdateWithoutCollectionReload() {
        // 1. Launch app and navigate to events list
        // 2. Capture initial collection view state
        // 3. Trigger odds update via mock WebSocket
        // 4. Verify only specific cell updated (no full reload)
        // 5. Verify animation played
        // 6. Verify other cells unchanged
    }
    
    func testMarketDeletionHandling() {
        // 1. Display market group with multiple markets
        // 2. Trigger market deletion via WebSocket
        // 3. Verify market removed from UI
        // 4. Verify layout updated smoothly
        // 5. Verify no crashes or visual artifacts
    }
    
    func testHighFrequencyUpdates() {
        // 1. Set up scenario with rapid odds changes
        // 2. Send 10 updates per second for 30 seconds
        // 3. Verify UI remains responsive
        // 4. Verify memory usage stable
        // 5. Verify all updates applied correctly
    }
}
```

### 3.8 Performance Benchmarks

```swift
// PerformanceTests.swift
class PerformanceTests: XCTestCase {
    
    func testCollectionViewScrollingPerformance() {
        // Measure scrolling FPS with active subscriptions
        measure {
            // Scroll through 100+ items with real-time updates
        }
    }
    
    func testSubscriptionCreationOverhead() {
        // Measure time to create 100 cell subscriptions
        measure {
            // Create subscriptions for visible cells
        }
    }
    
    func testMemoryUsageWithLongRunningSession() {
        // Monitor memory over 10-minute session
        // Verify no memory leaks
        // Verify stable memory usage
    }
}
```

---

## 📊 Success Criteria

### Functional Requirements
- [ ] Individual cells update without affecting neighboring cells
- [ ] Odds changes animate smoothly (< 300ms duration)
- [ ] Market deletions remove UI elements gracefully
- [ ] Match statistics update in real-time
- [ ] App remains responsive during high-frequency updates

### Performance Requirements
- [ ] Collection view maintains 60 FPS during updates
- [ ] Subscription creation < 5ms per cell
- [ ] Memory usage stable over 30-minute sessions
- [ ] No memory leaks with 1000+ subscription cycles
- [ ] UI responsiveness maintained with 100+ concurrent subscriptions

### Quality Requirements
- [ ] Zero crashes during granular updates
- [ ] Graceful fallback when subscriptions fail
- [ ] Visual consistency across all update scenarios
- [ ] Accessibility support maintained
- [ ] Dark mode support for all animations

---

## 🔄 Future Enhancements

### Phase 4 Potential Features
- **Smart Subscription Management**: Only subscribe to visible cells
- **Predictive Loading**: Preload subscriptions for upcoming scroll areas
- **Adaptive Batching**: Adjust batch sizes based on device performance
- **Offline Queue**: Queue updates when offline, replay when reconnected
- **Analytics Integration**: Track update frequencies and user interactions

---

## 🎯 Success Metrics

### User Experience Metrics
- **Perceived Performance**: 90% reduction in "loading feel" 
- **Scroll Smoothness**: Maintain 60 FPS during active updates
- **Visual Clarity**: Zero visual artifacts or glitches
- **Responsiveness**: UI responds to taps within 100ms

### Technical Metrics
- **Memory Efficiency**: < 50MB additional RAM for 100 subscriptions
- **CPU Usage**: < 5% additional CPU for real-time updates
- **Network Efficiency**: 80% reduction in redundant data
- **Battery Impact**: Negligible battery drain increase

The completion of Phase 3 will deliver a best-in-class betting interface with surgical precision updates and smooth, responsive user interactions.