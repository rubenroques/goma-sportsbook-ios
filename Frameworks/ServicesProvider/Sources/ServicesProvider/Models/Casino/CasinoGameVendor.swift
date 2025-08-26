
import Foundation

/// Represents a casino game vendor/provider
public struct CasinoGameVendor: Codable, Hashable, Identifiable {
    
    /// Unique identifier for the vendor
    public let id: String
    
    /// Internal vendor name
    public let name: String
    
    /// Display name for the vendor
    public let displayName: String
    
    /// Vendor image URL
    public let image: String?
    
    /// Vendor logo URL
    public let logo: String?
    
    /// Whether this is a top-tier vendor
    public let isTopVendor: Bool
    
    /// API href for vendor details
    public let href: String?
    
    public init(
        id: String,
        name: String,
        displayName: String,
        image: String? = nil,
        logo: String? = nil,
        isTopVendor: Bool = false,
        href: String? = nil
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.image = image
        self.logo = logo
        self.isTopVendor = isTopVendor
        self.href = href
    }
}
