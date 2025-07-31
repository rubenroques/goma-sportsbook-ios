import Foundation

enum EveryMatrixCasinoAPIEnvironment {
    case staging
    case production
    
    var baseURL: String {
        switch self {
        case .staging:
            return "https://betsson-api.stage.norway.everymatrix.com"
        case .production:
            return "https://betsson-api.norway.everymatrix.com"
        }
    }
    
    var defaultPlatform: String {
        return "iOS"
    }
    
    var defaultLanguage: String {
        return "en"
    }
    
    var domainId: String {
        switch self {
        case .staging:
            return "4093"
        case .production:
            return "4093"
        }
    }
}