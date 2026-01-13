import XCTest
import SnapshotTesting
@testable import GomaUI

final class PromotionalBonusCardsScrollViewSnapshotTests: XCTestCase {

    // PromotionalBonusCardsScrollView uses `.receive(on: DispatchQueue.main)` without
    // synchronous initial rendering. Requires RunLoop workaround for snapshots.

    // MARK: - Default Layout

    func testPromotionalBonusCardsScrollView_DefaultLayout_Light() throws {
        let vc = PromotionalBonusCardsScrollViewSnapshotViewController(category: .defaultLayout)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPromotionalBonusCardsScrollView_DefaultLayout_Dark() throws {
        let vc = PromotionalBonusCardsScrollViewSnapshotViewController(category: .defaultLayout)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Short List

    func testPromotionalBonusCardsScrollView_ShortList_Light() throws {
        let vc = PromotionalBonusCardsScrollViewSnapshotViewController(category: .shortList)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPromotionalBonusCardsScrollView_ShortList_Dark() throws {
        let vc = PromotionalBonusCardsScrollViewSnapshotViewController(category: .shortList)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
