import XCTest
import SnapshotTesting
@testable import GomaUI

final class WalletStatusViewSnapshotTests: XCTestCase {

    // MARK: - Balance Variants

    func testWalletStatusView_BalanceVariants_Light() throws {
        let vc = WalletStatusViewSnapshotViewController(category: .balanceVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testWalletStatusView_BalanceVariants_Dark() throws {
        let vc = WalletStatusViewSnapshotViewController(category: .balanceVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
