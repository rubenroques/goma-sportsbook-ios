import XCTest
import SnapshotTesting
@testable import GomaUI

final class DescriptionBlockViewSnapshotTests: XCTestCase {

    // MARK: - Content Variants

    func testDescriptionBlockView_ContentVariants_Light() throws {
        let vc = DescriptionBlockViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testDescriptionBlockView_ContentVariants_Dark() throws {
        let vc = DescriptionBlockViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
