import XCTest
import SnapshotTesting
@testable import GomaUI

final class MarketGroupSelectorTabViewSnapshotTests: XCTestCase {

    // MarketGroupSelectorTabView uses Combine with .receive(on: DispatchQueue.main) for async rendering.
    // Use waitForCombineRendering to allow publishers to emit before snapshot.

    // MARK: - Basic Layouts

    func testMarketGroupSelectorTabView_BasicLayouts_Light() throws {
        let vc = MarketGroupSelectorTabViewSnapshotViewController(category: .basicLayouts)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testMarketGroupSelectorTabView_BasicLayouts_Dark() throws {
        let vc = MarketGroupSelectorTabViewSnapshotViewController(category: .basicLayouts)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Selection States

    func testMarketGroupSelectorTabView_SelectionStates_Light() throws {
        let vc = MarketGroupSelectorTabViewSnapshotViewController(category: .selectionStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testMarketGroupSelectorTabView_SelectionStates_Dark() throws {
        let vc = MarketGroupSelectorTabViewSnapshotViewController(category: .selectionStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Content Variants

    func testMarketGroupSelectorTabView_ContentVariants_Light() throws {
        let vc = MarketGroupSelectorTabViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testMarketGroupSelectorTabView_ContentVariants_Dark() throws {
        let vc = MarketGroupSelectorTabViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Layout Modes

    func testMarketGroupSelectorTabView_LayoutModes_Light() throws {
        let vc = MarketGroupSelectorTabViewSnapshotViewController(category: .layoutModes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testMarketGroupSelectorTabView_LayoutModes_Dark() throws {
        let vc = MarketGroupSelectorTabViewSnapshotViewController(category: .layoutModes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
