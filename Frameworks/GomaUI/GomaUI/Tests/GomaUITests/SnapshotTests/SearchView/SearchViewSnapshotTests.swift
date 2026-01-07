import XCTest
import SnapshotTesting
@testable import GomaUI

final class SearchViewSnapshotTests: XCTestCase {

    // MARK: - Search Variants

    func testSearchView_SearchVariants_Light() throws {
        let vc = SearchViewSnapshotViewController(category: .searchVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSearchView_SearchVariants_Dark() throws {
        let vc = SearchViewSnapshotViewController(category: .searchVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
