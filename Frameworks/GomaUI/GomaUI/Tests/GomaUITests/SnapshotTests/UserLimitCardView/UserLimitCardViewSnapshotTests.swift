import XCTest
import SnapshotTesting
@testable import GomaUI

final class UserLimitCardViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Limit Variants

    func testUserLimitCardView_LimitVariants_Light() throws {
        let vc = UserLimitCardViewSnapshotViewController(category: .limitVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testUserLimitCardView_LimitVariants_Dark() throws {
        let vc = UserLimitCardViewSnapshotViewController(category: .limitVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
