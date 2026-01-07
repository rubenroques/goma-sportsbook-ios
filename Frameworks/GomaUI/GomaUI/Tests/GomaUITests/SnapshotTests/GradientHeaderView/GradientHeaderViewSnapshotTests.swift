import XCTest
import SnapshotTesting
@testable import GomaUI

final class GradientHeaderViewSnapshotTests: XCTestCase {

    // MARK: - Gradient Variants

    func testGradientHeaderView_GradientVariants_Light() throws {
        let vc = GradientHeaderViewSnapshotViewController(category: .gradientVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testGradientHeaderView_GradientVariants_Dark() throws {
        let vc = GradientHeaderViewSnapshotViewController(category: .gradientVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
