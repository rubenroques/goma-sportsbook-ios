import Foundation

/// Represents available service providers for the betting library
public enum Provider: String, CaseIterable {
    /// Goma provider implementation
    case goma
    
    /// Sportsradar provider implementation
    case sportsradar
    
    /// Everymatrix provider implementation (future support)
    case everymatrix
    
    /// Returns the display name of the provider
    public var displayName: String {
        switch self {
        case .goma:
            return "GOMA"
        case .sportsradar:
            return "Sportsradar"
        case .everymatrix:
            return "EveryMatrix"
        }
    }
    
    /// Indicates whether the provider is currently supported
    public var isSupported: Bool {
        switch self {
        case .goma, .sportsradar:
            return true
        case .everymatrix:
            return false
        }
    }
}