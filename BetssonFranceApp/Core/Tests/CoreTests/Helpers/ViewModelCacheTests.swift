//
//  ViewModelCacheTests.swift
//  Sportsbook
//
//  Created by Ruben Roques on 26/03/2025.
//

import XCTest
@testable import Betsson

// Helper type for testing different data types
private struct CustomObject: Equatable {
    let id: String
}

//
final class ViewModelCacheTests: XCTestCase {
    var sut: ViewModelCache<String, String>! // Subject Under Test
    
    override func setUp() {
        super.setUp()
        sut = ViewModelCache<String, String>()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - 1. Synchronous Methods Tests
    
    func testGetForNonExistentKey() {
        // When
        let result = sut.get(forKey: "nonexistent")
        
        // Then
        XCTAssertNil(result)
    }
    
    func testSetAndGetSynchronous() {
        // Given
        let expectation = XCTestExpectation(description: "Set operation completed")
        
        // When
        sut.set("value", forKey: "key")
        
        // Then
        // Wait briefly for the async barrier to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let result = self.sut.get(forKey: "key")
            XCTAssertEqual(result, "value")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRemoveKey() {
        // Given
        let expectation = XCTestExpectation(description: "Remove operation completed")
        sut.set("value", forKey: "key")
        
        // When
        sut.remove(forKey: "key")
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let result = self.sut.get(forKey: "key")
            XCTAssertNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testClearCache() {
        // Given
        let expectation = XCTestExpectation(description: "Clear operation completed")
        sut.set("value1", forKey: "key1")
        sut.set("value2", forKey: "key2")
        
        // When
        sut.clear()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let allValues = self.sut.getAll()
            XCTAssertTrue(allValues.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testBulkSet() {
        // Given
        let expectation = XCTestExpectation(description: "Bulk set operation completed")
        let dictionary = ["key1": "value1", "key2": "value2"]
        
        // When
        sut.set(dictionary)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let result = self.sut.getAll()
            XCTAssertEqual(result, dictionary)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - 2. Async/Await Methods Tests
    
    @available(iOS 13.0, *)
    func testAsyncSetAndGet() async {
        // When
        await sut.set("asyncValue", forKey: "asyncKey")
        let result = await sut.get(forKey: "asyncKey")
        
        // Then
        XCTAssertEqual(result, "asyncValue")
    }
    
    @available(iOS 13.0, *)
    func testAsyncConsistencyWithMultipleKeys() async {
        // Given
        let operations = (0..<10).map { index in
            return Task {
                await sut.set("value\(index)", forKey: "key\(index)")
            }
        }
        
        // When
        await withTaskGroup(of: Void.self) { group in
            for operation in operations {
                group.addTask {
                    await operation.value
                }
            }
        }
        
        // Then
        for i in 0..<10 {
            let value = await sut.get(forKey: "key\(i)")
            XCTAssertEqual(value, "value\(i)")
        }
    }
    
    // MARK: - 3. Subscript Access Tests
    
    func testSubscriptGetterAndSetter() {
        // Given
        let expectation = XCTestExpectation(description: "Subscript operation completed")
        
        // When
        sut["subscriptKey"] = "subscriptValue"
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let result = self.sut["subscriptKey"]
            XCTAssertEqual(result, "subscriptValue")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSubscriptRemoval() {
        // Given
        let expectation = XCTestExpectation(description: "Subscript removal completed")
        sut["removeKey"] = "value"
        
        // When
        sut["removeKey"] = nil
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let result = self.sut["removeKey"]
            XCTAssertNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - 4. Concurrent and Thread Safety Tests
    
    func testConcurrentWritesAndReads() {
        // Given
        let expectation = XCTestExpectation(description: "Concurrent operations completed")
        expectation.expectedFulfillmentCount = 100
        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        
        // When
        for i in 0..<100 {
            queue.async {
                self.sut.set("value\(i)", forKey: "key\(i)")
                _ = self.sut.get(forKey: "key\(i)")
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        
        // Verify final state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let allValues = self.sut.getAll()
            XCTAssertEqual(allValues.count, 100)
        }
    }
    
    func testStressUnderHighConcurrency() {
        // Given
        let expectation = XCTestExpectation(description: "Stress test completed")
        expectation.expectedFulfillmentCount = 1000
        let queue = DispatchQueue(label: "test.stress", attributes: .concurrent)
        
        // When
        for i in 0..<1000 {
            queue.async {
                self.sut.set("value\(i)", forKey: "key\(i)")
                _ = self.sut.get(forKey: "key\(i)")
                self.sut.remove(forKey: "key\(i)")
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - 5. Edge Cases Tests
    
    func testDifferentDataTypes() {
        // Test with different generic types
        let intCache = ViewModelCache<Int, String>()
        let customCache = ViewModelCache<String, CustomObject>()
        
        // Test operations with different types
        intCache.set("intValue", forKey: 1)
        XCTAssertEqual(intCache.get(forKey: 1), "intValue")
        
        let customObject = CustomObject(id: "test")
        customCache.set(customObject, forKey: "customKey")
        XCTAssertEqual(customCache.get(forKey: "customKey")?.id, "test")
    }
    
    func testMultipleSequentialUpdatesOnSameKey() {
        // Given
        let expectation = XCTestExpectation(description: "Sequential updates completed")
        let iterations = 100
        
        // When
        for i in 0..<iterations {
            sut.set("value\(i)", forKey: "sameKey")
        }
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let finalValue = self.sut.get(forKey: "sameKey")
            XCTAssertEqual(finalValue, "value\(iterations - 1)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - 6. Performance Tests
    
    func testPerformanceUnderLoad() {
        measure {
            let group = DispatchGroup()
            for i in 0..<1000 {
                group.enter()
                DispatchQueue.global().async {
                    self.sut.set("value\(i)", forKey: "key\(i)")
                    _ = self.sut.get(forKey: "key\(i)")
                    group.leave()
                }
            }
            group.wait()
        }
    }

    
    // MARK: - Advanced Concurrency Tests
    func testRaceConditionBetweenSetAndGet() {
        // This test simulates race conditions between sets and gets
        let iterations = 1000
        let expectation = XCTestExpectation(description: "Race condition test")
        expectation.expectedFulfillmentCount = iterations * 2
        
        for i in 0..<iterations {
            // Set and immediately get on different threads
            DispatchQueue.global().async {
                self.sut.set("value\(i)", forKey: "raceKey")
                expectation.fulfill()
            }
            
            DispatchQueue.global().async {
                _ = self.sut.get(forKey: "raceKey")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
        // If we get here without crashes, deadlocks, or assertion failures, test passes
    }
    
    func testConcurrentSetAndClear() {
        // Simulates concurrent sets while clearing the cache
        let iterations = 500
        let expectation = XCTestExpectation(description: "Concurrent set and clear")
        expectation.expectedFulfillmentCount = iterations + 10
        
        // Set operations
        for i in 0..<iterations {
            DispatchQueue.global().async {
                self.sut.set("value\(i)", forKey: "key\(i % 100)")
                expectation.fulfill()
            }
        }
        
        // Intermittent clear operations
        for _ in 0..<10 {
            DispatchQueue.global().async {
                self.sut.clear()
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testConcurrentRemovalAndAccess() {
        // Setup with some data
        for i in 0..<100 {
            sut.set("value\(i)", forKey: "removalKey\(i)")
        }
        
        let expectation = XCTestExpectation(description: "Concurrent removal and access")
        expectation.expectedFulfillmentCount = 300
        
        // Concurrent access to the same keys while removing
        for i in 0..<100 {
            // Remove
            DispatchQueue.global().async {
                self.sut.remove(forKey: "removalKey\(i)")
                expectation.fulfill()
            }
            
            // Read
            DispatchQueue.global().async {
                _ = self.sut.get(forKey: "removalKey\(i)")
                expectation.fulfill()
            }
            
            // Write again
            DispatchQueue.global().async {
                self.sut.set("newValue\(i)", forKey: "removalKey\(i)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testReliabilityUnderExtremeConcurrentLoad() {
        // This creates extreme load with lots of threads and operations
        let expectation = XCTestExpectation(description: "Extreme concurrent load")
        expectation.expectedFulfillmentCount = 5000
        
        // Create 50 dispatch queues to maximize contention
        let queues = (0..<50).map { i in
            DispatchQueue(label: "test.queue.\(i)", attributes: .concurrent)
        }
        
        for i in 0..<5000 {
            let queueIndex = i % 50
            queues[queueIndex].async {
                // Perform a random operation
                let operation = i % 4
                let key = "key\(i % 100)" // Ensure key contention
                
                switch operation {
                case 0: // Set
                    self.sut.set("value\(i)", forKey: key)
                case 1: // Get
                    _ = self.sut.get(forKey: key)
                case 2: // Remove
                    self.sut.remove(forKey: key)
                case 3: // Use subscript
                    self.sut[key] = "subscript\(i)"
                default:
                    break
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 60.0)
    }
    
    @available(iOS 13.0, *)
    func testConcurrentAsyncOperations() async {
        let taskCount = 1000
        
        // Create a bunch of concurrent tasks
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<taskCount {
                group.addTask {
                    if i % 3 == 0 {
                        await self.sut.set("asyncValue\(i)", forKey: "asyncKey\(i % 100)")
                    } else if i % 3 == 1 {
                        _ = await self.sut.get(forKey: "asyncKey\(i % 100)")
                    } else {
                        // Simulate mixed operations
                        await self.sut.set("tempValue", forKey: "tempKey")
                        _ = await self.sut.get(forKey: "tempKey")
                    }
                }
            }
        }
        
        // Verify we can still access the cache normally after stress test
        await sut.set("finalValue", forKey: "finalKey")
        let result = await sut.get(forKey: "finalKey")
        XCTAssertEqual(result, "finalValue")
    }
    
    // MARK: - Advanced Edge Cases
    
    func testRecursiveOperations() {
        let recursionDepth = 100
        let expectation = XCTestExpectation(description: "Recursive operations")
        
        func recursiveSet(depth: Int) {
            if depth <= 0 {
                expectation.fulfill()
                return
            }
            
            sut.set("depth\(depth)", forKey: "recursive")
            DispatchQueue.global().async {
                self.sut.get(forKey: "recursive")
                recursiveSet(depth: depth - 1)
            }
        }
        
        recursiveSet(depth: recursionDepth)
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testLongRunningOperations() {
        // Simulates long-running operations with other accesses happening during them
        let expectation = XCTestExpectation(description: "Long running operations")
        expectation.expectedFulfillmentCount = 101
        
        // Start a "long" barrier operation
        DispatchQueue.global().async {
            self.sut.set(Array(repeating: "x", count: 1000000).joined(), forKey: "largeValue")
            // Simulate a complex operation that takes time
            Thread.sleep(forTimeInterval: 0.5)
            expectation.fulfill()
        }
        
        // Try to perform 100 quick operations while the long one is running
        for i in 0..<100 {
            DispatchQueue.global().async {
                self.sut.set("quickValue\(i)", forKey: "quickKey\(i)")
                _ = self.sut.get(forKey: "quickKey\(i)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testContinuousUpdatesToDifferentKeys() {
        // Test continuously updating different keys
        var operations = [() -> Void]()
        let keyCount = 100
        let iterations = 100
        
        let expectation = XCTestExpectation(description: "Continuous updates")
        expectation.expectedFulfillmentCount = keyCount * iterations
        
        for key in 0..<keyCount {
            for i in 0..<iterations {
                operations.append {
                    self.sut.set("value\(i)", forKey: "continuous\(key)")
                    expectation.fulfill()
                }
            }
        }
        
        // Shuffle operations to maximize randomness
        operations.shuffle()
        
        // Execute all operations concurrently
        let queue = DispatchQueue(label: "test.continuous", attributes: .concurrent)
        operations.forEach { operation in
            queue.async { operation() }
        }
        
        wait(for: [expectation], timeout: 60.0)
        
        // Verify final state
        for key in 0..<keyCount {
            // The last value should be iterations-1
            XCTAssertEqual(sut.get(forKey: "continuous\(key)"), "value\(iterations-1)")
        }
    }
    
    // MARK: - Memory and Performance Tests
    
    func testMemoryPressure() {
        // Create memory pressure by rapidly creating and discarding large values
        autoreleasepool {
            for i in 0..<1000 {
                // Create a large string value (~10KB each)
                let largeValue = String(repeating: "x", count: 10 * 1024)
                sut.set(largeValue, forKey: "memoryTest\(i)")
            }
        }
        
        // Verify cache still works after memory pressure
        sut.set("afterPressure", forKey: "pressureKey")
        XCTAssertEqual(sut.get(forKey: "pressureKey"), "afterPressure")
    }
    
    func testLargeNumberOfEntries() {
        // Test with a very large number of entries
        let entryCount = 10_000
        
        measure {
            for i in 0..<entryCount {
                sut.set("value\(i)", forKey: "largeCount\(i)")
            }
            
            // Random access
            for _ in 0..<100 {
                let randomIndex = Int.random(in: 0..<entryCount)
                XCTAssertEqual(sut.get(forKey: "largeCount\(randomIndex)"), "value\(randomIndex)")
            }
        }
    }
    
    // MARK: - Real-world Simulation Tests
    
    func testSimulatedRealWorldUsage() {
        let expectation = XCTestExpectation(description: "Real world simulation")
        
        // Simulate a realistic workload with mixed read/write patterns
        let readHeavyQueue = DispatchQueue(label: "read.heavy", attributes: .concurrent)
        let writeHeavyQueue = DispatchQueue(label: "write.heavy", attributes: .concurrent)
        let mixedQueue = DispatchQueue(label: "mixed", attributes: .concurrent)
        
        // 1. Initial population (startup)
        for i in 0..<500 {
            sut.set("initial\(i)", forKey: "startup\(i)")
        }
        
        // 2. Read-heavy pattern (80% reads, 20% writes)
        for i in 0..<1000 {
            readHeavyQueue.async {
                if i % 5 == 0 {
                    // 20% writes
                    self.sut.set("readHeavy\(i)", forKey: "key\(i % 100)")
                } else {
                    // 80% reads
                    _ = self.sut.get(forKey: "key\(i % 100)")
                }
            }
        }
        
        // 3. Write-heavy pattern (20% reads, 80% writes)
        for i in 0..<1000 {
            writeHeavyQueue.async {
                if i % 5 != 0 {
                    // 80% writes
                    self.sut.set("writeHeavy\(i)", forKey: "key\(i % 100 + 100)")
                } else {
                    // 20% reads
                    _ = self.sut.get(forKey: "key\(i % 100 + 100)")
                }
            }
        }
        
        // 4. Mixed operations including bulk operations
        mixedQueue.async {
            self.sut.clear()
            self.sut.set(["bulk1": "value1", "bulk2": "value2"])
            _ = self.sut.getAll()
            
            for i in 0..<100 {
                self.sut["\(i)"] = "mixed\(i)"
                self.sut["\(i*2)"] = nil
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 60.0)
    }

    
}
