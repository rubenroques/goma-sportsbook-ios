import XCTest
import SnapshotTesting
@testable import GomaUI

final class QuickAddButtonViewSnapshotTests: XCTestCase {

    // QuickAddButtonView uses `.receive(on: DispatchQueue.main)` without synchronous initial render.
    // Uses waitForCombineRendering workaround.

    // MARK: - Amount Variants

    func testQuickAddButtonView_AmountVariants_Light() throws {
        let vc = QuickAddButtonViewSnapshotViewController(category: .amountVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testQuickAddButtonView_AmountVariants_Dark() throws {
        let vc = QuickAddButtonViewSnapshotViewController(category: .amountVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - State Variants

    func testQuickAddButtonView_StateVariants_Light() throws {
        let vc = QuickAddButtonViewSnapshotViewController(category: .stateVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testQuickAddButtonView_StateVariants_Dark() throws {
        let vc = QuickAddButtonViewSnapshotViewController(category: .stateVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
