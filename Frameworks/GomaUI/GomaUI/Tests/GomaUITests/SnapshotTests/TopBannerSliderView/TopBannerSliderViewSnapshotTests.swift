import XCTest
import SnapshotTesting
@testable import GomaUI

final class TopBannerSliderViewSnapshotTests: XCTestCase {

    // MARK: - Banner Variants

    func testTopBannerSliderView_BannerVariants_Light() throws {
        let vc = TopBannerSliderViewSnapshotViewController(category: .bannerVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTopBannerSliderView_BannerVariants_Dark() throws {
        let vc = TopBannerSliderViewSnapshotViewController(category: .bannerVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
