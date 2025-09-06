import UIKit
import GomaUI

/// Production image resolver for MarketGroupTabItemView that uses the app's existing image loading logic
struct AppMarketGroupTabImageResolver: MarketGroupTabImageResolver {
    
    func tabIcon(for tabType: String) -> UIImage? {
        switch tabType {
        case "betbuilder":
            // Try to load custom asset first, fallback to system icon
            return UIImage(named: "bet_builder_info") ?? UIImage(systemName: "exclamationmark.circle")
        case "popular":
            return UIImage(named: "most_popular_info") ?? UIImage(systemName: "exclamationmark.circle")
        case "fast":
            return UIImage(named: "most_popular_info") ?? UIImage(systemName: "exclamationmark.circle")
        case "virtuals_tab_icon":
            return UIImage(named: "virtuals_tab_icon") ?? UIImage(systemName: "exclamationmark.circle")
        case "sports_tab_icon":
            return UIImage(named: "sports_tab_icon") ?? UIImage(systemName: "exclamationmark.circle")
            
        default:
            return nil
        }
    }
}
