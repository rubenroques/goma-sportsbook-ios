import XCTest
import SnapshotTesting
@testable import GomaUI

final class MatchHeaderViewSnapshotTests: XCTestCase {

    // MARK: - Header Variants

    func testMatchHeaderView_HeaderVariants_Light() throws {
        let vc = MatchHeaderViewSnapshotViewController(category: .headerVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMatchHeaderView_HeaderVariants_Dark() throws {
        let vc = MatchHeaderViewSnapshotViewController(category: .headerVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Visibility Variants

    func testMatchHeaderView_VisibilityVariants_Light() throws {
        let vc = MatchHeaderViewSnapshotViewController(category: .visibilityVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMatchHeaderView_VisibilityVariants_Dark() throws {
        let vc = MatchHeaderViewSnapshotViewController(category: .visibilityVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
