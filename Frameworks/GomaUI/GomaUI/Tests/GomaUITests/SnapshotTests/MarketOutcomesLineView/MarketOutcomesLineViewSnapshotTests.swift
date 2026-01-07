import XCTest
import SnapshotTesting
@testable import GomaUI

final class MarketOutcomesLineViewSnapshotTests: XCTestCase {

    // MARK: - Market Variants

    func testMarketOutcomesLineView_MarketVariants_Light() throws {
        let vc = MarketOutcomesLineViewSnapshotViewController(category: .marketVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMarketOutcomesLineView_MarketVariants_Dark() throws {
        let vc = MarketOutcomesLineViewSnapshotViewController(category: .marketVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - State Variants

    func testMarketOutcomesLineView_StateVariants_Light() throws {
        let vc = MarketOutcomesLineViewSnapshotViewController(category: .stateVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMarketOutcomesLineView_StateVariants_Dark() throws {
        let vc = MarketOutcomesLineViewSnapshotViewController(category: .stateVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
