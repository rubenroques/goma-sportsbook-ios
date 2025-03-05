import Foundation

/// Represents different service domains in betting and gambling products
public enum Domain: String, CaseIterable {
    /// User account management, profile, and authentication
    case playerAccountManagement
    
    /// Bet history and active bets management
    case myBets
    
    /// Bonus and promotion management
    case bonus
    
    /// Real-time sports events and odds
    case liveEvents
    
    /// Pre-match events and odds
    case preLiveEvents
    
    /// Payment processing and transactions
    case payments
    
    /// Responsible gaming limits and controls
    case responsibleGaming
    
    /// Customer support and communications
    case customerSupport
    
    /// Analytics and tracking
    case analytics
    
    /// Content management (banners, promotions)
    case managedContent
}