//
//  ImageSource.swift
//  GomaUI
//
//  Shared enum for representing image sources across all GomaUI components.
//  Enables type-safe image handling and better testability through explicit source types.
//

import Foundation

/// Represents the source of an image for GomaUI components.
///
/// This enum provides type-safe image source handling, enabling:
/// - Clear distinction between remote URLs and local bundle assets
/// - Better testability (mocks can use `.bundleAsset` instead of network calls)
/// - Explicit handling of missing/unavailable images
///
/// ## Usage with ImageResolver
///
/// ImageResolver protocols should return `ImageSource` instead of `UIImage?`:
///
/// ```swift
/// public protocol GameImageResolver {
///     func imageSource(for gameId: String) -> ImageSource
/// }
///
/// // Production implementation
/// struct ProductionGameImageResolver: GameImageResolver {
///     func imageSource(for gameId: String) -> ImageSource {
///         guard let url = URL(string: "https://cdn.example.com/games/\(gameId).png") else {
///             return .none
///         }
///         return .url(url)
///     }
/// }
///
/// // Mock implementation for testing
/// struct MockGameImageResolver: GameImageResolver {
///     func imageSource(for gameId: String) -> ImageSource {
///         return .bundleAsset("mock_game_image")
///     }
/// }
/// ```
///
/// ## Usage in Views
///
/// Views handle each case explicitly:
///
/// ```swift
/// private func loadImage(from source: ImageSource) {
///     switch source {
///     case .url(let url):
///         loadFromNetwork(url)
///     case .bundleAsset(let name):
///         imageView.image = UIImage(named: name, in: .module, compatibleWith: nil)
///     case .none:
///         showPlaceholderOrEmptyState()
///     }
/// }
/// ```
public enum ImageSource: Equatable, Hashable {

    /// Image loaded from a remote URL (network request required)
    case url(URL)

    /// Image loaded from a bundle asset by name
    /// Use `.module` bundle for GomaUI assets, or specify bundle in the view
    case bundleAsset(String)

    /// No image available - view should show placeholder or empty state
    case none
}

// MARK: - Convenience Initializers

extension ImageSource {

    /// Creates an ImageSource from a URL string.
    /// Returns `.none` if the string is not a valid URL.
    public static func url(string: String) -> ImageSource {
        guard let url = URL(string: string) else {
            return .none
        }
        return .url(url)
    }
}
