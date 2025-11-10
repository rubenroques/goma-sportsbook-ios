
import Foundation

enum MyBetsTabType: String, CaseIterable {
    case sports = "sports"
    case virtuals = "virtuals"
    
    var title: String {
        switch self {
        case .sports:
            return localized("sports")
        case .virtuals:
            return localized("virtuals")
        }
    }
    
    var iconTypeName: String? {
        switch self {
        case .sports:
            return "sports"
        case .virtuals:
            return "virtuals"
        }
    }
}
