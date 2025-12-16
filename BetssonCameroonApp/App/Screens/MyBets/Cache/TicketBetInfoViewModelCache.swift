import Foundation

/// LRU (Least Recently Used) cache for TicketBetInfoViewModel instances.
/// Prevents constant ViewModel recreation and SSE reconnection cycles when scrolling.
final class TicketBetInfoViewModelCache {

    // MARK: - Types

    private struct CacheEntry {
        let viewModel: TicketBetInfoViewModel
        let createdAt: Date
    }

    // MARK: - Properties

    private let maxSize: Int
    private var cache: [String: CacheEntry] = [:]
    private var accessOrder: [String] = []  // LRU tracking: first = oldest, last = newest
    private let queue = DispatchQueue(label: "com.betsson.mybets.vmcache", attributes: .concurrent)

    // MARK: - Initialization

    /// Creates a new cache with the specified maximum size.
    /// - Parameter maxSize: Maximum number of ViewModels to cache. Default is 20 (1 page worth).
    init(maxSize: Int = 20) {
        self.maxSize = maxSize
    }

    // MARK: - Public Methods

    /// Retrieves a cached ViewModel for the given bet ID.
    /// Updates access order (marks as most recently used).
    /// - Parameter betId: The bet identifier to look up.
    /// - Returns: The cached ViewModel if found, nil otherwise.
    func get(forBetId betId: String) -> TicketBetInfoViewModel? {
        var result: TicketBetInfoViewModel?
        queue.sync {
            guard let entry = cache[betId] else { return }
            result = entry.viewModel
        }

        // Update access order outside sync to avoid nested sync
        if result != nil {
            queue.async(flags: .barrier) { [weak self] in
                self?.updateAccessOrder(forBetId: betId)
            }
        }

        return result
    }

    /// Caches a ViewModel for the given bet ID.
    /// Evicts the least recently used entry if at capacity.
    /// - Parameters:
    ///   - viewModel: The ViewModel to cache.
    ///   - betId: The bet identifier to use as cache key.
    func set(_ viewModel: TicketBetInfoViewModel, forBetId betId: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            // Evict LRU if at capacity and this is a new entry
            if self.cache[betId] == nil && self.cache.count >= self.maxSize {
                self.evictLRU()
            }

            // Store entry
            self.cache[betId] = CacheEntry(viewModel: viewModel, createdAt: Date())
            self.updateAccessOrder(forBetId: betId)
        }
    }

    /// Removes a specific bet's ViewModel from the cache.
    /// Call this after a full cashout to ensure the ViewModel is deallocated.
    /// - Parameter betId: The bet identifier to invalidate.
    func invalidate(forBetId betId: String) {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache.removeValue(forKey: betId)
            self?.accessOrder.removeAll { $0 == betId }
        }
    }

    /// Removes all cached ViewModels.
    /// Call this on logout or when clearing user data.
    func invalidateAll() {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache.removeAll()
            self?.accessOrder.removeAll()
        }
    }

    /// Returns the current number of cached ViewModels.
    var count: Int {
        var result = 0
        queue.sync {
            result = cache.count
        }
        return result
    }

    // MARK: - Private Methods

    /// Updates the access order for a bet ID (moves to end = most recently used).
    /// Must be called within a barrier block.
    private func updateAccessOrder(forBetId betId: String) {
        accessOrder.removeAll { $0 == betId }
        accessOrder.append(betId)
    }

    /// Evicts the least recently used entry.
    /// Must be called within a barrier block.
    private func evictLRU() {
        guard let lruKey = accessOrder.first else { return }
        cache.removeValue(forKey: lruKey)
        accessOrder.removeFirst()
    }
}
