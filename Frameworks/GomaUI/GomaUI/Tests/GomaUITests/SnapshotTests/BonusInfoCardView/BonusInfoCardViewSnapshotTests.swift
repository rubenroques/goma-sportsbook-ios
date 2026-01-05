import XCTest
import SnapshotTesting
@testable import GomaUI

final class BonusInfoCardViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testBonusInfoCardView_BasicStates_Light() throws {
        let vc = BonusInfoCardViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testBonusInfoCardView_BasicStates_Dark() throws {
        let vc = BonusInfoCardViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Status Variants

    func testBonusInfoCardView_StatusVariants_Light() throws {
        let vc = BonusInfoCardViewSnapshotViewController(category: .statusVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testBonusInfoCardView_StatusVariants_Dark() throws {
        let vc = BonusInfoCardViewSnapshotViewController(category: .statusVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Content Variants

    func testBonusInfoCardView_ContentVariants_Light() throws {
        let vc = BonusInfoCardViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testBonusInfoCardView_ContentVariants_Dark() throws {
        let vc = BonusInfoCardViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
