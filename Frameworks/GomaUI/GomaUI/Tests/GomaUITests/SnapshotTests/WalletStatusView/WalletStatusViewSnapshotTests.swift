import XCTest
import SnapshotTesting
@testable import GomaUI

final class WalletStatusViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Balance Variants

    func testWalletStatusView_BalanceVariants_Light() throws {
        let vc = WalletStatusViewSnapshotViewController(category: .balanceVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testWalletStatusView_BalanceVariants_Dark() throws {
        let vc = WalletStatusViewSnapshotViewController(category: .balanceVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
