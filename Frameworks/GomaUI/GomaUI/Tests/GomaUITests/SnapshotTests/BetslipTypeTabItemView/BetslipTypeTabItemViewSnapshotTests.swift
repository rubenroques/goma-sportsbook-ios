import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetslipTypeTabItemViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testBetslipTypeTabItemView_BasicStates_Light() throws {
        let vc = BetslipTypeTabItemViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testBetslipTypeTabItemView_BasicStates_Dark() throws {
        let vc = BetslipTypeTabItemViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Tab Variants

    func testBetslipTypeTabItemView_TabVariants_Light() throws {
        let vc = BetslipTypeTabItemViewSnapshotViewController(category: .tabVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testBetslipTypeTabItemView_TabVariants_Dark() throws {
        let vc = BetslipTypeTabItemViewSnapshotViewController(category: .tabVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
