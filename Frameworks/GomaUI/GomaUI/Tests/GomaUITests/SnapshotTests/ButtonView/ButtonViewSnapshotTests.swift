import XCTest
import SnapshotTesting
@testable import GomaUI

final class ButtonViewSnapshotTests: XCTestCase {

    // ButtonViewModelProtocol has currentButtonData for synchronous access.
    // ButtonView calls configureImmediately() which renders synchronously before bindings.
    // No RunLoop workaround needed.

    // MARK: - Basic Styles

    func testButtonView_BasicStyles_Light() throws {
        let vc = ButtonViewSnapshotViewController(category: .basicStyles)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testButtonView_BasicStyles_Dark() throws {
        let vc = ButtonViewSnapshotViewController(category: .basicStyles)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Disabled States

    func testButtonView_DisabledStates_Light() throws {
        let vc = ButtonViewSnapshotViewController(category: .disabledStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testButtonView_DisabledStates_Dark() throws {
        let vc = ButtonViewSnapshotViewController(category: .disabledStates)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Common Actions

    func testButtonView_CommonActions_Light() throws {
        let vc = ButtonViewSnapshotViewController(category: .commonActions)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testButtonView_CommonActions_Dark() throws {
        let vc = ButtonViewSnapshotViewController(category: .commonActions)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Custom Colors

    func testButtonView_CustomColors_Light() throws {
        let vc = ButtonViewSnapshotViewController(category: .customColors)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testButtonView_CustomColors_Dark() throws {
        let vc = ButtonViewSnapshotViewController(category: .customColors)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Theme Variants

    func testButtonView_ThemeVariants_Light() throws {
        let vc = ButtonViewSnapshotViewController(category: .themeVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testButtonView_ThemeVariants_Dark() throws {
        let vc = ButtonViewSnapshotViewController(category: .themeVariants)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }

    // MARK: - Font Customization

    func testButtonView_FontCustomization_Light() throws {
        let vc = ButtonViewSnapshotViewController(category: .fontCustomization)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.lightTraits), record: SnapshotTestConfig.record)
    }

    func testButtonView_FontCustomization_Dark() throws {
        let vc = ButtonViewSnapshotViewController(category: .fontCustomization)
        assertSnapshot(of: vc, as: .image(on: SnapshotTestConfig.device, size: SnapshotTestConfig.size, traits: SnapshotTestConfig.darkTraits), record: SnapshotTestConfig.record)
    }
}
