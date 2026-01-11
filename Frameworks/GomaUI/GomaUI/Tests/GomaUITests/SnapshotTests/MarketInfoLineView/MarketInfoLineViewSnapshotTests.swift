import XCTest
import SnapshotTesting
@testable import GomaUI

final class MarketInfoLineViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Info Variants

    func testMarketInfoLineView_InfoVariants_Light() throws {
        let vc = MarketInfoLineViewSnapshotViewController(category: .infoVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMarketInfoLineView_InfoVariants_Dark() throws {
        let vc = MarketInfoLineViewSnapshotViewController(category: .infoVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
