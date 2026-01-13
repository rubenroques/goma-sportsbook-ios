import XCTest
import SnapshotTesting
@testable import GomaUI

final class PromotionalBonusCardViewSnapshotTests: XCTestCase {

    // PromotionalBonusCardView uses .receive(on: DispatchQueue.main) for Combine bindings.
    // Must use waitForCombineRendering to allow async publisher emissions.

    // MARK: - Gradient States

    func testPromotionalBonusCardView_GradientStates_Light() throws {
        let vc = PromotionalBonusCardViewSnapshotViewController(category: .gradientStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testPromotionalBonusCardView_GradientStates_Dark() throws {
        let vc = PromotionalBonusCardViewSnapshotViewController(category: .gradientStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Content Variants

    func testPromotionalBonusCardView_ContentVariants_Light() throws {
        let vc = PromotionalBonusCardViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testPromotionalBonusCardView_ContentVariants_Dark() throws {
        let vc = PromotionalBonusCardViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
