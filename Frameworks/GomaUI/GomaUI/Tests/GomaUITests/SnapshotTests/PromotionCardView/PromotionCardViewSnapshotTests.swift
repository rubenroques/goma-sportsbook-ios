//
//  PromotionCardViewSnapshotTests.swift
//  GomaUI
//

import XCTest
import SnapshotTesting
@testable import GomaUI

final class PromotionCardViewSnapshotTests: XCTestCase {

    // PromotionCardView uses `.receive(on: DispatchQueue.main)` without currentDisplayState
    // so we need the RunLoop workaround for initial rendering.

    // MARK: - Content Variants

    func testPromotionCardView_ContentVariants_Light() throws {
        let vc = PromotionCardViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPromotionCardView_ContentVariants_Dark() throws {
        let vc = PromotionCardViewSnapshotViewController(category: .contentVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Button Configurations

    func testPromotionCardView_ButtonConfigurations_Light() throws {
        let vc = PromotionCardViewSnapshotViewController(category: .buttonConfigurations)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPromotionCardView_ButtonConfigurations_Dark() throws {
        let vc = PromotionCardViewSnapshotViewController(category: .buttonConfigurations)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Tag Variants

    func testPromotionCardView_TagVariants_Light() throws {
        let vc = PromotionCardViewSnapshotViewController(category: .tagVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPromotionCardView_TagVariants_Dark() throws {
        let vc = PromotionCardViewSnapshotViewController(category: .tagVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Text Lengths

    func testPromotionCardView_TextLengths_Light() throws {
        let vc = PromotionCardViewSnapshotViewController(category: .textLengths)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPromotionCardView_TextLengths_Dark() throws {
        let vc = PromotionCardViewSnapshotViewController(category: .textLengths)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
