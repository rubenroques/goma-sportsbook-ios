//
//  ViewModelCache.swift
//  Sportsbook
//
//  Created by Ruben Roques on 26/03/2025.
//


import Foundation

final class ViewModelCache<Key: Hashable, Value> {
    private var cache: [Key: Value] = [:]
    private let queue = DispatchQueue(
        label: "com.vaix.viewmodelcache.queue",
        attributes: .concurrent
    )
    
    // MARK: - Synchronous Methods
    
    func get(forKey key: Key) -> Value? {
        queue.sync {
            cache[key]
        }
    }
    
    func set(_ value: Value, forKey key: Key) {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache[key] = value
        }
    }
    
    func remove(forKey key: Key) {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache.removeValue(forKey: key)
        }
    }
    
    func clear() {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache.removeAll()
        }
    }
    
    // MARK: - Async/Await Methods
    
    @available(iOS 13.0, *)
    func get(forKey key: Key) async -> Value? {
        await withCheckedContinuation { continuation in
            queue.async {
                let value = self.cache[key]
                continuation.resume(returning: value)
            }
        }
    }
    
    @available(iOS 13.0, *)
    func set(_ value: Value, forKey key: Key) async {
        await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) { [weak self] in
                self?.cache[key] = value
                continuation.resume()
            }
        }
    }
    
    // MARK: - Subscript Access
    
    subscript(key: Key) -> Value? {
        get {
            get(forKey: key)
        }
        set {
            if let newValue = newValue {
                set(newValue, forKey: key)
            } else {
                remove(forKey: key)
            }
        }
    }
    
    // MARK: - Bulk Operations
    
    func set(_ dictionary: [Key: Value]) {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache = dictionary
        }
    }
    
    func getAll() -> [Key: Value] {
        queue.sync {
            cache
        }
    }
}