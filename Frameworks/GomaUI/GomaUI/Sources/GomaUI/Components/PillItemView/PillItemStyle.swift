import UIKit

/// Defines the visual style properties for a PillItemView state
public struct PillItemStyle: Equatable {
    /// Text color for the pill title
    public let textColor: UIColor

    /// Background color for the pill container
    public let backgroundColor: UIColor

    /// Border color for the pill container
    public let borderColor: UIColor

    /// Border width for the pill container (0 means no border)
    public let borderWidth: CGFloat

    public init(
        textColor: UIColor,
        backgroundColor: UIColor,
        borderColor: UIColor,
        borderWidth: CGFloat = 2.0
    ) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}

// MARK: - Default Styles
extension PillItemStyle {
    /// Default style for selected state using StyleProvider colors
    public static func defaultSelected() -> PillItemStyle {
        return PillItemStyle(
            textColor: StyleProvider.Color.buttonTextPrimary,
            backgroundColor: StyleProvider.Color.highlightPrimary,
            borderColor: StyleProvider.Color.highlightPrimary,
            borderWidth: 2.0
        )
    }

    /// Default style for unselected state using StyleProvider colors
    public static func defaultUnselected() -> PillItemStyle {
        return PillItemStyle(
            textColor: StyleProvider.Color.textPrimary,
            backgroundColor: StyleProvider.Color.pills,
            borderColor: StyleProvider.Color.highlightPrimary,
            borderWidth: 0.0
        )
    }
}