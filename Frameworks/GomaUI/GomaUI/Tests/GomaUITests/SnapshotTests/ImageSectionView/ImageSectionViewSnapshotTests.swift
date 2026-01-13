import XCTest
import SnapshotTesting
@testable import GomaUI

final class ImageSectionViewSnapshotTests: XCTestCase {

    // ImageSectionView loads images asynchronously via Kingfisher.
    // Snapshots capture the view structure/background without actual network images.

    // MARK: - URL Variants

    func testImageSectionView_UrlVariants_Light() throws {
        let vc = ImageSectionViewSnapshotViewController(category: .urlVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testImageSectionView_UrlVariants_Dark() throws {
        let vc = ImageSectionViewSnapshotViewController(category: .urlVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
