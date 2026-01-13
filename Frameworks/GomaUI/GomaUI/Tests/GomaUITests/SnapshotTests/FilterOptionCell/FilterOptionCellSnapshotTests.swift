import XCTest
import SnapshotTesting
@testable import GomaUI

final class FilterOptionCellSnapshotTests: XCTestCase {

    // MARK: - Filter Types

    func testFilterOptionCell_FilterTypes_Light() throws {
        let vc = FilterOptionCellSnapshotViewController(category: .filterTypes)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testFilterOptionCell_FilterTypes_Dark() throws {
        let vc = FilterOptionCellSnapshotViewController(category: .filterTypes)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Content Variants

    func testFilterOptionCell_ContentVariants_Light() throws {
        let vc = FilterOptionCellSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testFilterOptionCell_ContentVariants_Dark() throws {
        let vc = FilterOptionCellSnapshotViewController(category: .contentVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
