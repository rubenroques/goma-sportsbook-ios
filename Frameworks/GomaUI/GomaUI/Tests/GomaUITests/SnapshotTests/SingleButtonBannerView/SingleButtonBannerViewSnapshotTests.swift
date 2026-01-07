import XCTest
import SnapshotTesting
@testable import GomaUI

final class SingleButtonBannerViewSnapshotTests: XCTestCase {

    // MARK: - Banner Variants

    func testSingleButtonBannerView_BannerVariants_Light() throws {
        let vc = SingleButtonBannerViewSnapshotViewController(category: .bannerVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSingleButtonBannerView_BannerVariants_Dark() throws {
        let vc = SingleButtonBannerViewSnapshotViewController(category: .bannerVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
