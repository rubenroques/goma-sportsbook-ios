import XCTest
import SnapshotTesting
@testable import GomaUI

final class SeeMoreButtonViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testSeeMoreButtonView_BasicStates_Light() throws {
        let vc = SeeMoreButtonViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSeeMoreButtonView_BasicStates_Dark() throws {
        let vc = SeeMoreButtonViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Display Variants

    func testSeeMoreButtonView_DisplayVariants_Light() throws {
        let vc = SeeMoreButtonViewSnapshotViewController(category: .displayVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSeeMoreButtonView_DisplayVariants_Dark() throws {
        let vc = SeeMoreButtonViewSnapshotViewController(category: .displayVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
