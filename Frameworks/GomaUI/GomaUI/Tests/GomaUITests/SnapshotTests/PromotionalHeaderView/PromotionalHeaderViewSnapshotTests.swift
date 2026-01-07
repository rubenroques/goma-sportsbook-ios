import XCTest
import SnapshotTesting
@testable import GomaUI

final class PromotionalHeaderViewSnapshotTests: XCTestCase {

    // MARK: - Header Variants

    func testPromotionalHeaderView_HeaderVariants_Light() throws {
        let vc = PromotionalHeaderViewSnapshotViewController(category: .headerVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPromotionalHeaderView_HeaderVariants_Dark() throws {
        let vc = PromotionalHeaderViewSnapshotViewController(category: .headerVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
