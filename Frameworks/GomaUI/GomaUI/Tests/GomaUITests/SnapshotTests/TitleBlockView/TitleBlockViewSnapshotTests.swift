//
//  TitleBlockViewSnapshotTests.swift
//  GomaUITests
//
//  Snapshot tests for TitleBlockView component.
//

import XCTest
import SnapshotTesting
@testable import GomaUI

final class TitleBlockViewSnapshotTests: XCTestCase {

    // TitleBlockView renders synchronously - no async workaround needed.

    // MARK: - Alignment Variants

    func testTitleBlockView_AlignmentVariants_Light() throws {
        let vc = TitleBlockViewSnapshotViewController(category: .alignmentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTitleBlockView_AlignmentVariants_Dark() throws {
        let vc = TitleBlockViewSnapshotViewController(category: .alignmentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Content Variants

    func testTitleBlockView_ContentVariants_Light() throws {
        let vc = TitleBlockViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testTitleBlockView_ContentVariants_Dark() throws {
        let vc = TitleBlockViewSnapshotViewController(category: .contentVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
