
import Foundation

enum MyBetsTabType: String, CaseIterable {
    case sports = "sports"
    case virtuals = "virtuals"
    
    var title: String {
        switch self {
        case .sports:
            return "Sports"
        case .virtuals:
            return "Virtuals"
        }
    }
    
    var iconTypeName: String? {
        switch self {
        case .sports:
            return "sports"
        case .virtuals:
            return "virtual"
        }
    }
}
