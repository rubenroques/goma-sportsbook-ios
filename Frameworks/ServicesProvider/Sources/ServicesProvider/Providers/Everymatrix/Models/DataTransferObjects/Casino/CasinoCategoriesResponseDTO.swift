import Foundation

struct CasinoCategoriesResponseDTO: Codable {
    let count: Int?
    let total: Int?
    let items: [CasinoCategoryDTO]?
    let pages: CasinoPagesDTO?
}

struct CasinoPagesDTO: Codable {
    let first: String?
    let next: String?
    let previous: String?
    let last: String?
}