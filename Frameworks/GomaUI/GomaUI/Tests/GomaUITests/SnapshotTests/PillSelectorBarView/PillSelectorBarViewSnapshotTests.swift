import XCTest
import SnapshotTesting
@testable import GomaUI

final class PillSelectorBarViewSnapshotTests: XCTestCase {

    // PillSelectorBarView uses `.receive(on: DispatchQueue.main)` without synchronous
    // currentDisplayState in the view. We need waitForCombineRendering workaround.

    // MARK: - Content Types

    func testPillSelectorBarView_ContentTypes_Light() throws {
        let vc = PillSelectorBarViewSnapshotViewController(category: .contentTypes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPillSelectorBarView_ContentTypes_Dark() throws {
        let vc = PillSelectorBarViewSnapshotViewController(category: .contentTypes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Selection States

    func testPillSelectorBarView_SelectionStates_Light() throws {
        let vc = PillSelectorBarViewSnapshotViewController(category: .selectionStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPillSelectorBarView_SelectionStates_Dark() throws {
        let vc = PillSelectorBarViewSnapshotViewController(category: .selectionStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Scroll Configuration

    func testPillSelectorBarView_ScrollConfiguration_Light() throws {
        let vc = PillSelectorBarViewSnapshotViewController(category: .scrollConfiguration)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPillSelectorBarView_ScrollConfiguration_Dark() throws {
        let vc = PillSelectorBarViewSnapshotViewController(category: .scrollConfiguration)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Item Count Variants

    func testPillSelectorBarView_ItemCountVariants_Light() throws {
        let vc = PillSelectorBarViewSnapshotViewController(category: .itemCountVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPillSelectorBarView_ItemCountVariants_Dark() throws {
        let vc = PillSelectorBarViewSnapshotViewController(category: .itemCountVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
