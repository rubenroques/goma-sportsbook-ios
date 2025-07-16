import UIKit
import GomaUI

/// Production image resolver for MarketGroupTabItemView that uses the app's existing image loading logic
struct AppMarketGroupTabImageResolver: MarketGroupTabImageResolver {
    
    func tabIcon(for tabType: String) -> UIImage? {
        switch tabType {
        case "betbuilder":
            // Try to load custom asset first, fallback to system icon
            return UIImage(named: "icon_betbuilder") ?? UIImage(systemName: "square.stack.3d.up")
        case "popular":
            // Try to load custom asset first, fallback to system icon
            return UIImage(named: "icon_popular") ?? UIImage(systemName: "flame")
        case "sets":
            // Try to load custom asset first, fallback to system icon
            return UIImage(named: "icon_sets") ?? UIImage(systemName: "square.grid.2x2")
        case "games":
            // Try to load custom asset first, fallback to system icon
            return UIImage(named: "icon_games") ?? UIImage(systemName: "gamecontroller")
        case "players":
            // Try to load custom asset first, fallback to system icon
            return UIImage(named: "icon_players") ?? UIImage(systemName: "person.2")
        default:
            return nil
        }
    }
}