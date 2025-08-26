
import Foundation

extension EveryMatrix {
    
    /// DTO for recently played games API response
    struct CasinoRecentlyPlayedResponseDTO: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<CasinoRecentlyPlayedItemDTO>]
        let pagination: CasinoPaginationDTO?
        let pages: CasinoPagesDTO?
    }
    
    /// DTO for individual recently played item
    struct CasinoRecentlyPlayedItemDTO: Codable {
        let gameModel: FailableDecodable<CasinoGameDTO>?
    }
    
    /// DTO for pagination information in recently played response
    struct CasinoPaginationDTO: Codable {
        let total: Int?
        let offset: Int?
        let limit: Int?
    }
}
