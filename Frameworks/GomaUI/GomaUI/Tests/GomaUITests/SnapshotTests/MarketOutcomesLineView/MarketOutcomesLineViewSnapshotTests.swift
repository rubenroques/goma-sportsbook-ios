import XCTest
import SnapshotTesting
@testable import GomaUI

final class MarketOutcomesLineViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Market Variants

    func testMarketOutcomesLineView_MarketVariants_Light() throws {
        let vc = MarketOutcomesLineViewSnapshotViewController(category: .marketVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMarketOutcomesLineView_MarketVariants_Dark() throws {
        let vc = MarketOutcomesLineViewSnapshotViewController(category: .marketVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - State Variants

    func testMarketOutcomesLineView_StateVariants_Light() throws {
        let vc = MarketOutcomesLineViewSnapshotViewController(category: .stateVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMarketOutcomesLineView_StateVariants_Dark() throws {
        let vc = MarketOutcomesLineViewSnapshotViewController(category: .stateVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
