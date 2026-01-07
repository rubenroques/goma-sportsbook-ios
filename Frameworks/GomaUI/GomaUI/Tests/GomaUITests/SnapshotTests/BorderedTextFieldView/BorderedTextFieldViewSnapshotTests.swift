import XCTest
import SnapshotTesting
@testable import GomaUI

final class BorderedTextFieldViewSnapshotTests: XCTestCase {

    // MARK: - Basic States

    func testBorderedTextFieldView_BasicStates_Light() throws {
        let vc = BorderedTextFieldViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testBorderedTextFieldView_BasicStates_Dark() throws {
        let vc = BorderedTextFieldViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Input Types

    func testBorderedTextFieldView_InputTypes_Light() throws {
        let vc = BorderedTextFieldViewSnapshotViewController(category: .inputTypes)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testBorderedTextFieldView_InputTypes_Dark() throws {
        let vc = BorderedTextFieldViewSnapshotViewController(category: .inputTypes)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Error States

    func testBorderedTextFieldView_ErrorStates_Light() throws {
        let vc = BorderedTextFieldViewSnapshotViewController(category: .errorStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testBorderedTextFieldView_ErrorStates_Dark() throws {
        let vc = BorderedTextFieldViewSnapshotViewController(category: .errorStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
