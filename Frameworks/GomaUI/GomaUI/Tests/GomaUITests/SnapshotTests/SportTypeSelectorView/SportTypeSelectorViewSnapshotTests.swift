import XCTest
import SnapshotTesting
@testable import GomaUI

final class SportTypeSelectorViewSnapshotTests: XCTestCase {

    // SportTypeSelectorView uses `.receive(on: DispatchQueue.main)` without
    // currentDisplayState, so we need the async rendering workaround.

    // MARK: - Default Configuration

    func testSportTypeSelectorView_DefaultConfiguration_Light() throws {
        let vc = SportTypeSelectorViewSnapshotViewController(category: .defaultConfiguration)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSportTypeSelectorView_DefaultConfiguration_Dark() throws {
        let vc = SportTypeSelectorViewSnapshotViewController(category: .defaultConfiguration)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Item Count Variants

    func testSportTypeSelectorView_ItemCountVariants_Light() throws {
        let vc = SportTypeSelectorViewSnapshotViewController(category: .itemCountVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSportTypeSelectorView_ItemCountVariants_Dark() throws {
        let vc = SportTypeSelectorViewSnapshotViewController(category: .itemCountVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
