import XCTest
import SnapshotTesting
@testable import GomaUI

final class QuickLinksTabBarSnapshotTests: XCTestCase {

    // MARK: - Link Types

    func testQuickLinksTabBar_LinkTypes_Light() throws {
        let vc = QuickLinksTabBarSnapshotViewController(category: .linkTypes)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testQuickLinksTabBar_LinkTypes_Dark() throws {
        let vc = QuickLinksTabBarSnapshotViewController(category: .linkTypes)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
