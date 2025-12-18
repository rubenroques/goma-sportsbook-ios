import XCTest
import SnapshotTesting
@testable import GomaUI

final class OutcomeItemViewSnapshotTests: XCTestCase {

    func testOutcomeItemView() {
        let vc = OutcomeItemViewSnapshotViewController()

        // WORKAROUND: OutcomeItemView relies solely on async Combine bindings
        // (.receive(on: DispatchQueue.main)) without synchronous initial rendering.
        // See PillItemViewSnapshotTests for detailed explanation.
        vc.loadViewIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size), record: SnapshotTestConfig.record)
    }
}
