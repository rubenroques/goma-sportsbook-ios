import Foundation

/// Protocol defining the interface for CasinoGameImageView's ViewModel
public protocol CasinoGameImageViewModelProtocol: AnyObject {
    /// The game's unique identifier
    var gameId: String { get }

    /// The game's URL for launching
    var gameURL: String { get }

    /// The image URL or bundle image name
    var imageURL: String? { get }

    /// Called when the game card is tapped
    func gameSelected()
}
