import XCTest
import SnapshotTesting
@testable import GomaUI

final class SportTypeSelectorItemViewSnapshotTests: XCTestCase {

    // SportTypeSelectorItemView uses `.receive(on: DispatchQueue.main)` for Combine rendering.
    // The RunLoop workaround is needed to allow async rendering to complete.

    // MARK: - Sport Types

    func testSportTypeSelectorItemView_SportTypes_Light() throws {
        let vc = SportTypeSelectorItemViewSnapshotViewController(category: .sportTypes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSportTypeSelectorItemView_SportTypes_Dark() throws {
        let vc = SportTypeSelectorItemViewSnapshotViewController(category: .sportTypes)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Text Lengths

    func testSportTypeSelectorItemView_TextLengths_Light() throws {
        let vc = SportTypeSelectorItemViewSnapshotViewController(category: .textLengths)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testSportTypeSelectorItemView_TextLengths_Dark() throws {
        let vc = SportTypeSelectorItemViewSnapshotViewController(category: .textLengths)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
