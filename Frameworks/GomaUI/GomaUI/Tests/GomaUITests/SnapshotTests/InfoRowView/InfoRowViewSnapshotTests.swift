import XCTest
import SnapshotTesting
@testable import GomaUI

final class InfoRowViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testInfoRowView_BasicStates_Light() throws {
        let vc = InfoRowViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testInfoRowView_BasicStates_Dark() throws {
        let vc = InfoRowViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Style Variants

    func testInfoRowView_StyleVariants_Light() throws {
        let vc = InfoRowViewSnapshotViewController(category: .styleVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testInfoRowView_StyleVariants_Dark() throws {
        let vc = InfoRowViewSnapshotViewController(category: .styleVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
