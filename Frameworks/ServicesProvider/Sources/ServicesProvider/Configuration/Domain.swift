import Foundation

/// Represents different service domains in betting and gambling products
public enum Domain: String, CaseIterable {
    /// User account management, profile, and authentication
    case playerAccountManagement
    
    /// Bet history and active bets management
    case myBets
    
    /// Bonus and cashback management
    case bonus
    
    /// pre live and live sports events, markets, outomes and odds
    case events
    
    /// Payment processing and transactions (Deposit/Withdraw)
    case payments
    
    /// Responsible gaming limits and controls
    case responsibleGaming
    
    /// Customer support and communications
    case customerSupport
    
    /// Analytics and tracking
    case analytics
    
    /// Content management (banners, alerts, highlights, home widgets )
    case managedHomeContent
    
    // Static promotional campaigns pages
    case promotionalCampaigns
}
