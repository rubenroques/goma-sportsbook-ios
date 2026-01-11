import XCTest
import SnapshotTesting
@testable import GomaUI

final class CashoutSliderViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Basic States

    func testCashoutSliderView_BasicStates_Light() throws {
        let vc = CashoutSliderViewSnapshotViewController(category: .basicStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testCashoutSliderView_BasicStates_Dark() throws {
        let vc = CashoutSliderViewSnapshotViewController(category: .basicStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Value Variants

    func testCashoutSliderView_ValueVariants_Light() throws {
        let vc = CashoutSliderViewSnapshotViewController(category: .valueVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testCashoutSliderView_ValueVariants_Dark() throws {
        let vc = CashoutSliderViewSnapshotViewController(category: .valueVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
