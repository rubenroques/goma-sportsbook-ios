import XCTest
import SnapshotTesting
@testable import GomaUI

final class CodeInputViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testCodeInputView_BasicStates_Light() throws {
        let vc = CodeInputViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCodeInputView_BasicStates_Dark() throws {
        let vc = CodeInputViewSnapshotViewController(category: .basicStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }

    // MARK: - Input States

    func testCodeInputView_InputStates_Light() throws {
        let vc = CodeInputViewSnapshotViewController(category: .inputStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testCodeInputView_InputStates_Dark() throws {
        let vc = CodeInputViewSnapshotViewController(category: .inputStates)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
