//
//  MarketGroupSelectorTabLayoutMode.swift
//  GomaUI
//
//  Created on 03/09/2025.
//

import Foundation

/// Layout mode for MarketGroupSelectorTabView defining how tabs are distributed
public enum MarketGroupSelectorTabLayoutMode {
    /// Automatic sizing - tabs size to their content (current default behavior)
    /// Tabs may not fill the entire width, particularly with few tabs
    case automatic
    
    /// Stretch mode - tabs stretch to fill the entire available width
    /// Each tab gets equal width, particularly useful for 2-3 tabs
    /// Still scrolls if content exceeds container width
    case stretch
}
