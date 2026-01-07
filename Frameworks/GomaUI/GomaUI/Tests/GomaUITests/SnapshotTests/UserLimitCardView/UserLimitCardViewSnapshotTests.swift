import XCTest
import SnapshotTesting
@testable import GomaUI

final class UserLimitCardViewSnapshotTests: XCTestCase {

    // MARK: - Limit Variants

    func testUserLimitCardView_LimitVariants_Light() throws {
        let vc = UserLimitCardViewSnapshotViewController(category: .limitVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testUserLimitCardView_LimitVariants_Dark() throws {
        let vc = UserLimitCardViewSnapshotViewController(category: .limitVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
