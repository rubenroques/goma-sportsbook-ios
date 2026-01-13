//
//  SelectOptionsViewSnapshotTests.swift
//  GomaUITests
//
//  Created by Claude on 13/01/2026.
//

import XCTest
import SnapshotTesting
@testable import GomaUI

final class SelectOptionsViewSnapshotTests: XCTestCase {

    // SelectOptionsView uses .receive(on: DispatchQueue.main) for selection binding,
    // but also calls configure() synchronously in init which sets up initial UI state.
    // Using waitForCombineRendering to ensure all publishers have emitted.

    // MARK: - Title Variants

    func testSelectOptionsView_TitleVariants_Light() throws {
        let vc = SelectOptionsViewSnapshotViewController(category: .titleVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSelectOptionsView_TitleVariants_Dark() throws {
        let vc = SelectOptionsViewSnapshotViewController(category: .titleVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Selection States

    func testSelectOptionsView_SelectionStates_Light() throws {
        let vc = SelectOptionsViewSnapshotViewController(category: .selectionStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSelectOptionsView_SelectionStates_Dark() throws {
        let vc = SelectOptionsViewSnapshotViewController(category: .selectionStates)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Item Count Variants

    func testSelectOptionsView_ItemCountVariants_Light() throws {
        let vc = SelectOptionsViewSnapshotViewController(category: .itemCountVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSelectOptionsView_ItemCountVariants_Dark() throws {
        let vc = SelectOptionsViewSnapshotViewController(category: .itemCountVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
