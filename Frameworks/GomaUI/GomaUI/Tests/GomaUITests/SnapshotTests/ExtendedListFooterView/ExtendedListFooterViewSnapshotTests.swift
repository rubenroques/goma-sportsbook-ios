import XCTest
import SnapshotTesting
@testable import GomaUI

final class ExtendedListFooterViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testExtendedListFooterView_BasicStates_Light() throws {
        let vc = ExtendedListFooterViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testExtendedListFooterView_BasicStates_Dark() throws {
        let vc = ExtendedListFooterViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Partner Variants

    func testExtendedListFooterView_PartnerVariants_Light() throws {
        let vc = ExtendedListFooterViewSnapshotViewController(category: .partnerVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testExtendedListFooterView_PartnerVariants_Dark() throws {
        let vc = ExtendedListFooterViewSnapshotViewController(category: .partnerVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
