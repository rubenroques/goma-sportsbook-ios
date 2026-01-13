import XCTest
import SnapshotTesting
@testable import GomaUI

final class PromotionSelectorBarViewSnapshotTests: XCTestCase {

    // PromotionSelectorBarView uses `.receive(on: DispatchQueue.main)` for Combine bindings.
    // MockPromotionSelectorBarViewModel has getCurrentDisplayState() but the view binds asynchronously.
    // Use waitForCombineRendering to ensure the view is rendered before snapshotting.

    // MARK: - Basic Layouts

    func testPromotionSelectorBarView_BasicLayouts_Light() throws {
        let vc = PromotionSelectorBarViewSnapshotViewController(category: .basicLayouts)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPromotionSelectorBarView_BasicLayouts_Dark() throws {
        let vc = PromotionSelectorBarViewSnapshotViewController(category: .basicLayouts)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Selection States

    func testPromotionSelectorBarView_SelectionStates_Light() throws {
        let vc = PromotionSelectorBarViewSnapshotViewController(category: .selectionStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPromotionSelectorBarView_SelectionStates_Dark() throws {
        let vc = PromotionSelectorBarViewSnapshotViewController(category: .selectionStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testPromotionSelectorBarView_ContentVariants_Light() throws {
        let vc = PromotionSelectorBarViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPromotionSelectorBarView_ContentVariants_Dark() throws {
        let vc = PromotionSelectorBarViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Interaction Modes

    func testPromotionSelectorBarView_InteractionModes_Light() throws {
        let vc = PromotionSelectorBarViewSnapshotViewController(category: .interactionModes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPromotionSelectorBarView_InteractionModes_Dark() throws {
        let vc = PromotionSelectorBarViewSnapshotViewController(category: .interactionModes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
