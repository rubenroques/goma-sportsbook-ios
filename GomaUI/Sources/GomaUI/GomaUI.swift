// The Swift Programming Language
// https://docs.swift.org/swift-book

import GomaAssets

class GomaUI {
    // Singleton instance
    private static let shared: GomaUI = GomaUI()

    public static var colorScheme: ColorScheme {
        return Self.shared.colorScheme
    }

    // Shared default color scheme
    public var colorScheme: ColorScheme

    // Private initializer to enforce singleton pattern
    public init<T: CustomFont>(
        colorScheme: ColorScheme = DefaultColorScheme.shared,
        customFont: T.Type = Roboto.self
    ) {
        // Initialize the default color scheme
        self.colorScheme = colorScheme

        try? GomaAssets.registerFont(customFont)
    }
    
}
