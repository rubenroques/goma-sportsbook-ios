import XCTest
import SnapshotTesting
@testable import GomaUI

final class GeneralFilterBarViewSnapshotTests: XCTestCase {

    // GeneralFilterBarView uses `.receive(on: DispatchQueue.main)` in setupBindings.
    // Need to use waitForCombineRendering to allow async rendering to complete.

    // MARK: - Default Configuration

    func testGeneralFilterBarView_DefaultConfiguration_Light() throws {
        let vc = GeneralFilterBarViewSnapshotViewController(category: .defaultConfiguration)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testGeneralFilterBarView_DefaultConfiguration_Dark() throws {
        let vc = GeneralFilterBarViewSnapshotViewController(category: .defaultConfiguration)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Filter Type Combinations

    func testGeneralFilterBarView_FilterTypeCombinations_Light() throws {
        let vc = GeneralFilterBarViewSnapshotViewController(category: .filterTypeCombinations)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testGeneralFilterBarView_FilterTypeCombinations_Dark() throws {
        let vc = GeneralFilterBarViewSnapshotViewController(category: .filterTypeCombinations)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Item Count Variants

    func testGeneralFilterBarView_ItemCountVariants_Light() throws {
        let vc = GeneralFilterBarViewSnapshotViewController(category: .itemCountVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testGeneralFilterBarView_ItemCountVariants_Dark() throws {
        let vc = GeneralFilterBarViewSnapshotViewController(category: .itemCountVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Main Filter States

    func testGeneralFilterBarView_MainFilterStates_Light() throws {
        let vc = GeneralFilterBarViewSnapshotViewController(category: .mainFilterStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testGeneralFilterBarView_MainFilterStates_Dark() throws {
        let vc = GeneralFilterBarViewSnapshotViewController(category: .mainFilterStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
