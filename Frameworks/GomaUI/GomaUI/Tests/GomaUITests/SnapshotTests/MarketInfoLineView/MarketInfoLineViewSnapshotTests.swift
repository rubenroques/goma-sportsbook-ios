import XCTest
import SnapshotTesting
@testable import GomaUI

final class MarketInfoLineViewSnapshotTests: XCTestCase {

    // MARK: - Info Variants

    func testMarketInfoLineView_InfoVariants_Light() throws {
        let vc = MarketInfoLineViewSnapshotViewController(category: .infoVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMarketInfoLineView_InfoVariants_Dark() throws {
        let vc = MarketInfoLineViewSnapshotViewController(category: .infoVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
