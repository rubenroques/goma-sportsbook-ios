import XCTest
import SnapshotTesting
@testable import GomaUI

final class StepInstructionViewSnapshotTests: XCTestCase {

    // MARK: - Instruction Variants

    func testStepInstructionView_InstructionVariants_Light() throws {
        let vc = StepInstructionViewSnapshotViewController(category: .instructionVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits),
            record: SnapshotTestConfig.record
        )
    }

    func testStepInstructionView_InstructionVariants_Dark() throws {
        let vc = StepInstructionViewSnapshotViewController(category: .instructionVariants)
        assertSnapshot(
            of: vc,
            as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits),
            record: SnapshotTestConfig.record
        )
    }
}
