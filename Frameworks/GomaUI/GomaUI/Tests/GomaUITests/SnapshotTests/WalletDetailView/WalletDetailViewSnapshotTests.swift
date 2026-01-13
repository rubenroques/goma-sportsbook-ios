import XCTest
import SnapshotTesting
@testable import GomaUI

final class WalletDetailViewSnapshotTests: XCTestCase {

    // WalletDetailView uses `.receive(on: DispatchQueue.main)` in setupBindings.
    // Requires RunLoop workaround for async rendering.

    // MARK: - Balance Variants

    func testWalletDetailView_BalanceVariants_Light() throws {
        let vc = WalletDetailViewSnapshotViewController(category: .balanceVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testWalletDetailView_BalanceVariants_Dark() throws {
        let vc = WalletDetailViewSnapshotViewController(category: .balanceVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Edge Cases

    func testWalletDetailView_EdgeCases_Light() throws {
        let vc = WalletDetailViewSnapshotViewController(category: .edgeCases)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testWalletDetailView_EdgeCases_Dark() throws {
        let vc = WalletDetailViewSnapshotViewController(category: .edgeCases)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - With Pending Withdraw

    func testWalletDetailView_WithPendingWithdraw_Light() throws {
        let vc = WalletDetailViewSnapshotViewController(category: .withPendingWithdraw)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testWalletDetailView_WithPendingWithdraw_Dark() throws {
        let vc = WalletDetailViewSnapshotViewController(category: .withPendingWithdraw)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
