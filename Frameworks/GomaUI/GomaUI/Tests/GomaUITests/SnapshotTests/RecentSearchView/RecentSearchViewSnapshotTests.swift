import XCTest
import SnapshotTesting
@testable import GomaUI

final class RecentSearchViewSnapshotTests: XCTestCase {

    // RecentSearchView uses direct property access without Combine bindings.
    // No RunLoop workaround needed.

    // MARK: - Content Variants

    func testRecentSearchView_ContentVariants_Light() throws {
        let vc = RecentSearchViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testRecentSearchView_ContentVariants_Dark() throws {
        let vc = RecentSearchViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Multiple Items

    func testRecentSearchView_MultipleItems_Light() throws {
        let vc = RecentSearchViewSnapshotViewController(category: .multipleItems)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testRecentSearchView_MultipleItems_Dark() throws {
        let vc = RecentSearchViewSnapshotViewController(category: .multipleItems)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
