import XCTest
import SnapshotTesting
@testable import GomaUI

final class MarketNamePillLabelViewSnapshotTests: XCTestCase {

    // MarketNamePillLabelView uses `.receive(on: DispatchQueue.main)` without
    // synchronous initial rendering. Use `waitForCombineRendering` workaround.

    // MARK: - Styles

    func testMarketNamePillLabelView_Styles_Light() throws {
        let vc = MarketNamePillLabelViewSnapshotViewController(category: .styles)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMarketNamePillLabelView_Styles_Dark() throws {
        let vc = MarketNamePillLabelViewSnapshotViewController(category: .styles)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testMarketNamePillLabelView_ContentVariants_Light() throws {
        let vc = MarketNamePillLabelViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMarketNamePillLabelView_ContentVariants_Dark() throws {
        let vc = MarketNamePillLabelViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Interactive States

    func testMarketNamePillLabelView_InteractiveStates_Light() throws {
        let vc = MarketNamePillLabelViewSnapshotViewController(category: .interactiveStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testMarketNamePillLabelView_InteractiveStates_Dark() throws {
        let vc = MarketNamePillLabelViewSnapshotViewController(category: .interactiveStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
