import UIKit

/// Container for customizing both selected and unselected states of a PillItemView
public struct PillItemCustomization: Equatable {
    /// Style for when the pill is selected
    public let selectedStyle: PillItemStyle

    /// Style for when the pill is unselected
    public let unselectedStyle: PillItemStyle

    public init(
        selectedStyle: PillItemStyle = PillItemStyle.defaultSelected(),
        unselectedStyle: PillItemStyle = PillItemStyle.defaultUnselected()
    ) {
        self.selectedStyle = selectedStyle
        self.unselectedStyle = unselectedStyle
    }
}

// MARK: - Default Customization
extension PillItemCustomization {
    /// Default customization using StyleProvider colors
    public static var `default`: PillItemCustomization {
        return PillItemCustomization(
            selectedStyle: .defaultSelected(),
            unselectedStyle: .defaultUnselected()
        )
    }

    /// Convenience initializer for common use case of changing colors while keeping default border behavior
    public static func colors(
        selectedText: UIColor,
        selectedBackground: UIColor,
        selectedBorder: UIColor,
        unselectedText: UIColor,
        unselectedBackground: UIColor,
        unselectedBorder: UIColor? = nil
    ) -> PillItemCustomization {
        return PillItemCustomization(
            selectedStyle: PillItemStyle(
                textColor: selectedText,
                backgroundColor: selectedBackground,
                borderColor: selectedBorder,
                borderWidth: 2.0
            ),
            unselectedStyle: PillItemStyle(
                textColor: unselectedText,
                backgroundColor: unselectedBackground,
                borderColor: unselectedBorder ?? .clear,
                borderWidth: unselectedBorder != nil ? 2.0 : 0.0
            )
        )
    }
}
