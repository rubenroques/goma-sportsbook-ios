import XCTest
import SnapshotTesting
@testable import GomaUI

final class PendingWithdrawViewSnapshotTests: XCTestCase {

    // PendingWithdrawViewModelProtocol has currentDisplayState for synchronous access.
    // PendingWithdrawView calls render(state: viewModel.currentDisplayState) in commonInit().
    // No RunLoop workaround needed.

    // MARK: - Basic States

    func testPendingWithdrawView_BasicStates_Light() throws {
        let vc = PendingWithdrawViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testPendingWithdrawView_BasicStates_Dark() throws {
        let vc = PendingWithdrawViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Status Styles

    func testPendingWithdrawView_StatusStyles_Light() throws {
        let vc = PendingWithdrawViewSnapshotViewController(category: .statusStyles)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testPendingWithdrawView_StatusStyles_Dark() throws {
        let vc = PendingWithdrawViewSnapshotViewController(category: .statusStyles)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Content Variants

    func testPendingWithdrawView_ContentVariants_Light() throws {
        let vc = PendingWithdrawViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testPendingWithdrawView_ContentVariants_Dark() throws {
        let vc = PendingWithdrawViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
