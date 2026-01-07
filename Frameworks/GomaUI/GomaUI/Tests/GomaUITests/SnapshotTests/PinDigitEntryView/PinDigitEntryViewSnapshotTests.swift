import XCTest
import SnapshotTesting
@testable import GomaUI

final class PinDigitEntryViewSnapshotTests: XCTestCase {

    // MARK: - Digit Count

    func testPinDigitEntryView_DigitCount_Light() throws {
        let vc = PinDigitEntryViewSnapshotViewController(category: .digitCount)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPinDigitEntryView_DigitCount_Dark() throws {
        let vc = PinDigitEntryViewSnapshotViewController(category: .digitCount)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Fill States

    func testPinDigitEntryView_FillStates_Light() throws {
        let vc = PinDigitEntryViewSnapshotViewController(category: .fillStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testPinDigitEntryView_FillStates_Dark() throws {
        let vc = PinDigitEntryViewSnapshotViewController(category: .fillStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
