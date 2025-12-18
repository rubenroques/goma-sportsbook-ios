import XCTest
import SnapshotTesting
@testable import GomaUI

final class CashoutAmountViewSnapshotTests: XCTestCase {

    func testCashoutAmountView() throws {
        let vc = CashoutAmountViewSnapshotViewController()

        // CashoutAmountView uses Combine publisher without synchronous state access
        // Need RunLoop workaround to allow Combine to dispatch initial state
        vc.loadViewIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size), record: SnapshotTestConfig.record)
    }
}
