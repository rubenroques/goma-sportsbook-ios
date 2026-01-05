import XCTest
import SnapshotTesting
@testable import GomaUI

final class BonusCardViewSnapshotTests: XCTestCase {

    // MARK: - Content Variants

    func testBonusCardView_ContentVariants_Light() throws {
        let vc = BonusCardViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testBonusCardView_ContentVariants_Dark() throws {
        let vc = BonusCardViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
