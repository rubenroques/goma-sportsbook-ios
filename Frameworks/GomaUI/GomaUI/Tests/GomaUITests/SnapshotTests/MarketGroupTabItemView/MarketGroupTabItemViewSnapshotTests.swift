import XCTest
import SnapshotTesting
@testable import GomaUI

final class MarketGroupTabItemViewSnapshotTests: XCTestCase {

    // MarketGroupTabItemView uses Combine with .receive(on: DispatchQueue.main)
    // which causes async rendering. Use waitForCombineRendering workaround.

    // MARK: - Visual States

    func testMarketGroupTabItemView_VisualStates_Light() throws {
        let vc = MarketGroupTabItemViewSnapshotViewController(category: .visualStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testMarketGroupTabItemView_VisualStates_Dark() throws {
        let vc = MarketGroupTabItemViewSnapshotViewController(category: .visualStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Icon Variants

    func testMarketGroupTabItemView_IconVariants_Light() throws {
        let vc = MarketGroupTabItemViewSnapshotViewController(category: .iconVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testMarketGroupTabItemView_IconVariants_Dark() throws {
        let vc = MarketGroupTabItemViewSnapshotViewController(category: .iconVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Badge Variants

    func testMarketGroupTabItemView_BadgeVariants_Light() throws {
        let vc = MarketGroupTabItemViewSnapshotViewController(category: .badgeVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testMarketGroupTabItemView_BadgeVariants_Dark() throws {
        let vc = MarketGroupTabItemViewSnapshotViewController(category: .badgeVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
