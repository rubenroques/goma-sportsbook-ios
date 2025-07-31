import Foundation

struct CasinoRecentlyPlayedResponseDTO: Codable {
    let count: Int?
    let total: Int?
    let items: [CasinoRecentlyPlayedDTO]?
    let pages: CasinoPagesDTO?
}