import Foundation

/// Protocol defining the interface for CasinoGameImagePairView's ViewModel
/// Represents a vertical pair of casino game images (top required, bottom optional)
public protocol CasinoGameImagePairViewModelProtocol: AnyObject {
    /// ViewModel for the top game card (required)
    var topGameViewModel: CasinoGameImageViewModelProtocol { get }

    /// ViewModel for the bottom game card (optional - nil if odd game in list)
    var bottomGameViewModel: CasinoGameImageViewModelProtocol? { get }

    /// Unique identifier for this pair (typically derived from top game's ID)
    var pairId: String { get }
}
