import UIKit
import GomaUI

/*
/// Production image resolver for MatchHeaderView that uses the app's existing image loading logic
struct AppMatchHeaderImageResolver: MatchHeaderImageResolver {
    
    func countryFlagImage(for countryCode: String) -> UIImage? {
        let assetName = Assets.flagName(withCountryCode: countryCode)
        return UIImage(named: assetName) ?? UIImage(systemName: "globe")
    }
    
    func sportIconImage(for sportId: String) -> UIImage? {
        let assetName = "sport_type_icon_\(sportId)"
        return UIImage(named: assetName) ?? UIImage(named: "sport_type_icon_default")
    }
    
    func favoriteIcon(isFavorite: Bool) -> UIImage? {
        let starSymbol = isFavorite ? "star.fill" : "star"
        let configuration = UIImage.SymbolConfiguration(weight: .semibold)
        return UIImage(systemName: starSymbol, withConfiguration: configuration)?.withRenderingMode(.alwaysTemplate)
    }
    
    func liveIndicatorIcon() -> UIImage? {
        return UIImage(systemName: "play.fill")?.withRenderingMode(.alwaysTemplate)
    }
}
*/
