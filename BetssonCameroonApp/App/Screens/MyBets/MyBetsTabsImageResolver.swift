//
//  AppMarketGroupTabImageResolver.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 05/09/2025.
//


import UIKit
import GomaUI

/// Production image resolver for MarketGroupTabItemView that uses the app's existing image loading logic
struct MyBetsTabsImageResolver: MarketGroupTabImageResolver {
    
    func tabIcon(for tabType: String) -> UIImage? {
        switch tabType {
        case "virtuals":
            return UIImage(named: "virtuals_tab_icon") ?? UIImage(systemName: "flame")
        case "sports":
            return UIImage(named: "sports_tab_icon") ?? UIImage(systemName: "flame")
        default:
            return nil
        }
    }
}
