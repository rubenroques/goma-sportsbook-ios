import UIKit
import GomaUI

/// Production image resolver for MarketGroupTabItemView that uses the app's existing image loading logic
struct AppMarketGroupTabImageResolver: MarketGroupTabImageResolver {
    
    func tabIcon(for tabType: String) -> UIImage? {
        switch tabType {
        case "betbuilder":
            // Try to load custom asset first, fallback to system icon
            return UIImage(named: "bet_builder_info") ?? UIImage(systemName: "square.stack.3d.up")
        case "popular":
            // Try to load custom asset first, fallback to system icon
            return UIImage(named: "most_popular_info") ?? UIImage(systemName: "flame")
        case "fast":
            // Try to load custom asset first, fallback to system icon
            return UIImage(named: "most_popular_info") ?? UIImage(systemName: "flame")

        default:
            return nil
        }
    }
}
