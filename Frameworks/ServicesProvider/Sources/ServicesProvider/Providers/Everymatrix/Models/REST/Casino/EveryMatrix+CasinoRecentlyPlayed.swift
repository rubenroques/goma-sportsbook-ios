
import Foundation

extension EveryMatrix {
    
    /// REST API model for recently played games API response
    struct CasinoRecentlyPlayedResponse: Codable {
        let count: Int
        let total: Int?
        let items: [FailableDecodable<CasinoRecentlyPlayedItem>]
        let pagination: CasinoPagination?
        let pages: CasinoPages?
    }
    
    /// REST API model for individual recently played item
    struct CasinoRecentlyPlayedItem: Codable {
        let gameModel: FailableDecodable<CasinoGame>?
    }
    
    /// REST API model for pagination information in recently played response
    struct CasinoPagination: Codable {
        let total: Int?
        let offset: Int?
        let limit: Int?
    }
}
