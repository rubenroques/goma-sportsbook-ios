import XCTest
import SnapshotTesting
@testable import GomaUI

final class DepositBonusInfoViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testDepositBonusInfoView_BasicStates_Light() throws {
        let vc = DepositBonusInfoViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testDepositBonusInfoView_BasicStates_Dark() throws {
        let vc = DepositBonusInfoViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testDepositBonusInfoView_ContentVariants_Light() throws {
        let vc = DepositBonusInfoViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testDepositBonusInfoView_ContentVariants_Dark() throws {
        let vc = DepositBonusInfoViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
