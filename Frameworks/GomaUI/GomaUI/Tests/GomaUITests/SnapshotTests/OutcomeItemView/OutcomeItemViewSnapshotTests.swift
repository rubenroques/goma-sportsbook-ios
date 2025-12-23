import XCTest
import SnapshotTesting
@testable import GomaUI

final class OutcomeItemViewSnapshotTests: XCTestCase {

    // OutcomeItemViewModelProtocol has currentOutcomeData for synchronous access.
    // OutcomeItemView calls configureImmediately() which renders synchronously before bindings.
    // No RunLoop workaround needed.

    // MARK: - Basic States

    func testOutcomeItemView_BasicStates_Light() throws {
        let vc = OutcomeItemViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testOutcomeItemView_BasicStates_Dark() throws {
        let vc = OutcomeItemViewSnapshotViewController(category: .basicStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Display States

    func testOutcomeItemView_DisplayStates_Light() throws {
        let vc = OutcomeItemViewSnapshotViewController(category: .displayStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testOutcomeItemView_DisplayStates_Dark() throws {
        let vc = OutcomeItemViewSnapshotViewController(category: .displayStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Odds Change

    func testOutcomeItemView_OddsChange_Light() throws {
        let vc = OutcomeItemViewSnapshotViewController(category: .oddsChange)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testOutcomeItemView_OddsChange_Dark() throws {
        let vc = OutcomeItemViewSnapshotViewController(category: .oddsChange)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Font Customization

    func testOutcomeItemView_FontCustomization_Light() throws {
        let vc = OutcomeItemViewSnapshotViewController(category: .fontCustomization)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testOutcomeItemView_FontCustomization_Dark() throws {
        let vc = OutcomeItemViewSnapshotViewController(category: .fontCustomization)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Size Variants

    func testOutcomeItemView_SizeVariants_Light() throws {
        let vc = OutcomeItemViewSnapshotViewController(category: .sizeVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testOutcomeItemView_SizeVariants_Dark() throws {
        let vc = OutcomeItemViewSnapshotViewController(category: .sizeVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
