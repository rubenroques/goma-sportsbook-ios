import XCTest
import SnapshotTesting
@testable import GomaUI

final class SimpleSquaredFilterBarViewSnapshotTests: XCTestCase {

    // SimpleSquaredFilterBarView renders synchronously via configure(with:) in init.
    // No RunLoop workaround needed.

    // MARK: - Filter Types

    func testSimpleSquaredFilterBarView_FilterTypes_Light() throws {
        let vc = SimpleSquaredFilterBarViewSnapshotViewController(category: .filterTypes)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSimpleSquaredFilterBarView_FilterTypes_Dark() throws {
        let vc = SimpleSquaredFilterBarViewSnapshotViewController(category: .filterTypes)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Selection States

    func testSimpleSquaredFilterBarView_SelectionStates_Light() throws {
        let vc = SimpleSquaredFilterBarViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSimpleSquaredFilterBarView_SelectionStates_Dark() throws {
        let vc = SimpleSquaredFilterBarViewSnapshotViewController(category: .selectionStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Item Count Variants

    func testSimpleSquaredFilterBarView_ItemCountVariants_Light() throws {
        let vc = SimpleSquaredFilterBarViewSnapshotViewController(category: .itemCountVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSimpleSquaredFilterBarView_ItemCountVariants_Dark() throws {
        let vc = SimpleSquaredFilterBarViewSnapshotViewController(category: .itemCountVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
