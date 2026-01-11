import XCTest
import SnapshotTesting
@testable import GomaUI

final class StepInstructionViewSnapshotTests: XCTestCase {

    // TODO: Migrate component to `currentDisplayState + dropFirst()` or scheduler injection for synchronous rendering.

    // MARK: - Instruction Variants

    func testStepInstructionView_InstructionVariants_Light() throws {
        let vc = StepInstructionViewSnapshotViewController(category: .instructionVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testStepInstructionView_InstructionVariants_Dark() throws {
        let vc = StepInstructionViewSnapshotViewController(category: .instructionVariants)
        SnapshotTestConfig.waitForCombineRendering(vc)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
