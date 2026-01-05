import XCTest
import SnapshotTesting
@testable import GomaUI

final class CashoutSubmissionInfoViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testCashoutSubmissionInfoView_BasicStates_Light() throws {
        let vc = CashoutSubmissionInfoViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testCashoutSubmissionInfoView_BasicStates_Dark() throws {
        let vc = CashoutSubmissionInfoViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
