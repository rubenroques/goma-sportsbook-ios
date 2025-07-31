import Foundation

struct CasinoGamesResponseDTO: Codable {
    let count: Int?
    let total: Int?
    let items: [CasinoGameDTO]?
    let pages: CasinoPagesDTO?
}