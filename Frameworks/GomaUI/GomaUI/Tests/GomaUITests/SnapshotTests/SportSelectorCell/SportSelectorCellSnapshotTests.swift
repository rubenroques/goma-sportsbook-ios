import XCTest
import SnapshotTesting
@testable import GomaUI

final class SportSelectorCellSnapshotTests: XCTestCase {

    // SportSelectorCell renders synchronously via configure() - no async workaround needed.

    // MARK: - Filter Types

    func testSportSelectorCell_FilterTypes_Light() throws {
        let vc = SportSelectorCellSnapshotViewController(category: .filterTypes)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSportSelectorCell_FilterTypes_Dark() throws {
        let vc = SportSelectorCellSnapshotViewController(category: .filterTypes)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testSportSelectorCell_ContentVariants_Light() throws {
        let vc = SportSelectorCellSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSportSelectorCell_ContentVariants_Dark() throws {
        let vc = SportSelectorCellSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
