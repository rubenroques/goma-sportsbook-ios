import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetDetailRowViewSnapshotTests: XCTestCase {

    func testBetDetailRowView() throws {
        let vc = BetDetailRowViewSnapshotViewController()

        // BetDetailRowViewModelProtocol does NOT have currentDisplayState for synchronous access
        // It only has dataPublisher (Combine), which has a micro-delay
        // We need the RunLoop workaround to ensure views are rendered before snapshot
        vc.loadViewIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size), record: SnapshotTestConfig.record)
    }
}
