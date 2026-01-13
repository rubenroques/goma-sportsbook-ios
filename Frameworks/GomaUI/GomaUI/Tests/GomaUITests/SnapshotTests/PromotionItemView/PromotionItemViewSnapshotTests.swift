import XCTest
import SnapshotTesting
@testable import GomaUI

final class PromotionItemViewSnapshotTests: XCTestCase {

    // PromotionItemView uses `.receive(on: DispatchQueue.main)` without synchronous initial rendering.
    // Using waitForCombineRendering workaround to allow publishers to emit before snapshot.

    // MARK: - Selection States

    func testPromotionItemView_SelectionStates_Light() throws {
        let vc = PromotionItemViewSnapshotViewController(category: .selectionStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPromotionItemView_SelectionStates_Dark() throws {
        let vc = PromotionItemViewSnapshotViewController(category: .selectionStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testPromotionItemView_ContentVariants_Light() throws {
        let vc = PromotionItemViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPromotionItemView_ContentVariants_Dark() throws {
        let vc = PromotionItemViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
