import XCTest
import SnapshotTesting
@testable import GomaUI

final class BetDetailValuesSummaryViewSnapshotTests: XCTestCase {

    // MARK: - Layout Variants

    func testBetDetailValuesSummaryView_LayoutVariants_Light() throws {
        let vc = BetDetailValuesSummaryViewSnapshotViewController(category: .layoutVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testBetDetailValuesSummaryView_LayoutVariants_Dark() throws {
        let vc = BetDetailValuesSummaryViewSnapshotViewController(category: .layoutVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
