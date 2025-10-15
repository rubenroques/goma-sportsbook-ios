//
//  PromotionsCoordinatorProtocol.swift
//  BetssonCameroonApp
//
//  Created by Claude on 29/08/2025.
//

import Foundation
import ServicesProvider

/// Protocol defining the interface for promotions navigation coordination
/// Allows view controllers to communicate with coordinator without tight coupling
protocol PromotionsCoordinatorProtocol: AnyObject {
    
    /// Shows the promotion detail screen for a specific promotion
    /// - Parameter promotion: The promotion to show details for
    func showPromotionDetail(promotion: PromotionInfo)
    
    /// Opens a promotion URL in external browser
    /// - Parameter urlString: The URL string to open
    func openPromotionURL(urlString: String)
    
    /// Handles back navigation from promotion detail screen
    func handleDetailBackNavigation()
}
