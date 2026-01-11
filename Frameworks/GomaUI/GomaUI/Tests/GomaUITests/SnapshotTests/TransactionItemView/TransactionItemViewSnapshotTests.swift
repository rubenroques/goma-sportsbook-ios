import XCTest
import SnapshotTesting
@testable import GomaUI

final class TransactionItemViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Transaction Types

    func testTransactionItemView_TransactionTypes_Light() throws {
        let vc = TransactionItemViewSnapshotViewController(category: .transactionTypes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTransactionItemView_TransactionTypes_Dark() throws {
        let vc = TransactionItemViewSnapshotViewController(category: .transactionTypes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
