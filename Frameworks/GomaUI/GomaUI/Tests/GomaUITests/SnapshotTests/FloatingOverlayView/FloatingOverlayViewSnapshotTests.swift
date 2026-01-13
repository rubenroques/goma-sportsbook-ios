//
//  FloatingOverlayViewSnapshotTests.swift
//  GomaUITests
//
//  Snapshot tests for FloatingOverlayView.
//

import XCTest
import SnapshotTesting
@testable import GomaUI

final class FloatingOverlayViewSnapshotTests: XCTestCase {

    // FloatingOverlayView uses `.receive(on: DispatchQueue.main)` and starts with alpha=0.
    // The SnapshotViewController manually sets alpha=1 and transform=.identity to capture visible state.
    // We also use waitForCombineRendering to let the publisher emit.

    // MARK: - Mode Variants

    func testFloatingOverlayView_ModeVariants_Light() throws {
        let vc = FloatingOverlayViewSnapshotViewController(category: .modeVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testFloatingOverlayView_ModeVariants_Dark() throws {
        let vc = FloatingOverlayViewSnapshotViewController(category: .modeVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
