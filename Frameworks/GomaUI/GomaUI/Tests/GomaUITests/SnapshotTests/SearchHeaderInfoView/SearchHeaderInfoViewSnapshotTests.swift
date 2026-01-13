import XCTest
import SnapshotTesting
@testable import GomaUI

final class SearchHeaderInfoViewSnapshotTests: XCTestCase {

    // SearchHeaderInfoView calls configure() synchronously in commonInit().
    // No async workaround needed for initial render, but loading state has
    // an animated timer which we don't need to wait for.

    // MARK: - Search States

    func testSearchHeaderInfoView_SearchStates_Light() throws {
        let vc = SearchHeaderInfoViewSnapshotViewController(category: .searchStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSearchHeaderInfoView_SearchStates_Dark() throws {
        let vc = SearchHeaderInfoViewSnapshotViewController(category: .searchStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testSearchHeaderInfoView_ContentVariants_Light() throws {
        let vc = SearchHeaderInfoViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSearchHeaderInfoView_ContentVariants_Dark() throws {
        let vc = SearchHeaderInfoViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
