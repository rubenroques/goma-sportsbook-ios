import XCTest
import SnapshotTesting
@testable import GomaUI

final class ImageBlockViewSnapshotTests: XCTestCase {

    // ImageBlockView renders synchronously in configure() - no RunLoop workaround needed.

    // MARK: - URL Variants

    func testImageBlockView_UrlVariants_Light() throws {
        let vc = ImageBlockViewSnapshotViewController(category: .urlVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testImageBlockView_UrlVariants_Dark() throws {
        let vc = ImageBlockViewSnapshotViewController(category: .urlVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
