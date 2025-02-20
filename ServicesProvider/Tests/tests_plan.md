# Sports Merger State Management Design

## Testing Strategy

### 1. Test Infrastructure

#### MockSportRadarSocket
```swift
// Conceptual structure - not actual implementation
protocol SportRadarSocketProtocol {
    func simulateUpdate(sports: [SportType], identifier: ContentIdentifier)
    func simulateDisconnect()
    func simulateReconnect()
    func simulateSubscriptionSuccess()
    func simulateSubscriptionFailure(error: Error)
}
```

#### TestableSubscription
```swift
// Allows tracking subscription lifecycle
class TestableSubscription: Subscription {
    var isActive: Bool
    var wasUnsubscribed: Bool
    var receivedUpdates: [(sports: [SportType], timestamp: Date)]
}
```

### 2. Test Categories

#### A. Connection State Tests
1. Initial Connection
   - Verify correct state transitions: disconnected -> connecting -> connected
   - Verify subscription objects are created and stored
   - Test both subscriptions succeeding
   - Test all sports subscription failing
   - Test live sports subscription failing

2. Reconnection
   - Verify state handling during reconnection
   - Test pending updates are preserved
   - Verify subscription objects are properly recreated

#### B. Update Processing Tests
1. Base Sports List Updates
   - Test adding new sports
   - Test removing sports
   - Test updating existing sports
   - Verify live counts are preserved during updates

2. Live Counts Updates
   - Test updating live counts for existing sports
   - Test live counts for new sports
   - Test removing live counts
   - Verify base sports list is preserved

3. Race Condition Tests
   - Updates arriving before connection
   - Updates during reconnection
   - Multiple rapid updates
   - Out-of-order updates

#### C. Edge Case Tests
1. State Management
   - Test all possible state transitions
   - Verify invalid state transitions are prevented
   - Test error recovery paths

2. Memory Management
   - Test cleanup of subscription objects
   - Verify no memory leaks in update queue
   - Test proper deallocation

3. Error Handling
   - Network errors
   - Invalid data format
   - Timeout scenarios
   - Recovery procedures

### 3. Test Implementation Strategy

#### A. Test Setup
```swift
class SportsMergerTests: XCTestCase {
    var sut: SportsMerger!
    var mockSocket: MockSportRadarSocket!
    var testScheduler: TestScheduler!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        mockSocket = MockSportRadarSocket()
        testScheduler = TestScheduler(initialClock: 0)
        cancellables = []
        sut = SportsMerger(socket: mockSocket)
    }
}
```

#### B. Test Helpers
```swift
extension SportsMergerTests {
    func createTestSport(_ id: String) -> SportType
    func simulateSuccessfulConnection()
    func simulateFailedConnection()
    func verifyState(_ expected: MergerState)
    func verifyUpdates(_ expected: [SportType])
}
```

#### C. Test Scenarios
1. Normal Operation Flow
   ```swift
   func testSuccessfulConnectionAndUpdates()
   func testLiveCountsUpdate()
   func testSportRemoval()
   func testSportAddition()
   ```

2. Error Handling Flow
   ```swift
   func testConnectionFailure()
   func testReconnectionFlow()
   func testInvalidDataHandling()
   ```

3. Race Condition Scenarios
   ```swift
   func testUpdatesBeforeConnection()
   func testUpdatesWhileReconnecting()
   func testRapidSuccessiveUpdates()
   ```

### 4. Verification Methods

#### A. State Verification
- Use state history tracking
- Verify correct order of state transitions
- Check timing of state changes

#### B. Data Verification
- Compare sport lists before/after updates
- Verify live counts are correctly merged
- Check for data consistency

#### C. Performance Verification
- Measure update processing time
- Track memory usage
- Monitor subscription lifecycle

### 5. Implementation Guidelines

1. Test Independence
   - Each test should be self-contained
   - Clean state between tests
   - No dependencies between tests

2. Test Coverage
   - Aim for 100% code coverage
   - Include both success and failure paths
   - Test edge cases and boundary conditions

3. Test Performance
   - Use async/await for asynchronous tests
   - Implement timeout handling
   - Control timing with TestScheduler

### 6. Expected Outcomes

1. Reliability
   - No lost updates
   - Consistent state management
   - Proper error handling

2. Performance
   - Quick update processing
   - Efficient memory usage
   - Smooth reconnection handling

3. Maintainability
   - Clear test structure
   - Easy to add new tests
   - Simple debugging

This testing strategy ensures comprehensive coverage of the SportsMerger functionality while maintaining code quality and reliability. The mock system allows for controlled testing of all scenarios without depending on actual network connections.