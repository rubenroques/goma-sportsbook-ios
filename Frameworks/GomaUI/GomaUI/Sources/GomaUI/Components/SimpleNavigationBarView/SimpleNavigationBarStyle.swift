import UIKit

/// Defines the visual style properties for SimpleNavigationBarView.
///
/// This struct provides optional customization for navigation bar appearance,
/// allowing override of default StyleProvider colors for special cases like
/// dark overlays or custom branding.
///
/// ## Usage
/// ```swift
/// let navBar = SimpleNavigationBarView(viewModel: viewModel)
/// navBar.setCustomization(.darkOverlay())
/// ```
public struct SimpleNavigationBarStyle: Equatable {
    /// Background color for the navigation bar
    public let backgroundColor: UIColor

    /// Text color for back label and title
    public let textColor: UIColor

    /// Icon color for back chevron
    public let iconColor: UIColor

    /// Separator line color
    public let separatorColor: UIColor

    public init(
        backgroundColor: UIColor,
        textColor: UIColor,
        iconColor: UIColor,
        separatorColor: UIColor? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.iconColor = iconColor
        self.separatorColor = separatorColor ?? iconColor
    }
}

// MARK: - Default Styles

extension SimpleNavigationBarStyle {
    /// Default style using StyleProvider colors.
    ///
    /// This is the automatic fallback when no customization is applied.
    /// Uses standard theme colors that adapt to light/dark mode.
    public static func defaultStyle() -> SimpleNavigationBarStyle {
        return SimpleNavigationBarStyle(
            backgroundColor: StyleProvider.Color.backgroundPrimary,
            textColor: StyleProvider.Color.textPrimary,
            iconColor: StyleProvider.Color.iconPrimary,
            separatorColor: StyleProvider.Color.separatorLine
        )
    }

    /// Dark overlay style with white text on transparent background.
    ///
    /// **Use case**: Navigation bars overlaid on dark background images
    /// (e.g., casino game preview screens, promotional overlays).
    ///
    /// **Visual**: White text and icons on transparent background.
    public static func darkOverlay() -> SimpleNavigationBarStyle {
        return SimpleNavigationBarStyle(
            backgroundColor: .clear,
            textColor: .white,
            iconColor: .white,
            separatorColor: .clear
        )
    }
}
