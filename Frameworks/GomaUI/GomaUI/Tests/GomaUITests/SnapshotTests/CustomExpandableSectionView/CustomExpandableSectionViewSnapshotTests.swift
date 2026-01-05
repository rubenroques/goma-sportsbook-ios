import XCTest
import SnapshotTesting
@testable import GomaUI

final class CustomExpandableSectionViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testCustomExpandableSectionView_BasicStates_Light() throws {
        let vc = CustomExpandableSectionViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCustomExpandableSectionView_BasicStates_Dark() throws {
        let vc = CustomExpandableSectionViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testCustomExpandableSectionView_ContentVariants_Light() throws {
        let vc = CustomExpandableSectionViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCustomExpandableSectionView_ContentVariants_Dark() throws {
        let vc = CustomExpandableSectionViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
