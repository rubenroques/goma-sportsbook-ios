import XCTest
import SnapshotTesting
@testable import GomaUI

final class MarketOutcomesMultiLineViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Market Group Variants

    func testMarketOutcomesMultiLineView_MarketGroupVariants_Light() throws {
        let vc = MarketOutcomesMultiLineViewSnapshotViewController(category: .marketGroupVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMarketOutcomesMultiLineView_MarketGroupVariants_Dark() throws {
        let vc = MarketOutcomesMultiLineViewSnapshotViewController(category: .marketGroupVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Special States

    func testMarketOutcomesMultiLineView_SpecialStates_Light() throws {
        let vc = MarketOutcomesMultiLineViewSnapshotViewController(category: .specialStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMarketOutcomesMultiLineView_SpecialStates_Dark() throws {
        let vc = MarketOutcomesMultiLineViewSnapshotViewController(category: .specialStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
