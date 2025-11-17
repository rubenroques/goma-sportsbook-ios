//
//  UserLimitCardViewModelProtocol.swift
//  GomaUI
//
//  Created by Claude on 11/11/2025.
//

import Foundation

public protocol UserLimitCardViewModelProtocol: AnyObject {
    /// Unique identifier of the user limit.
    var limitId: String { get }
    
    /// Localized type description (e.g. "Daily", "Weekly").
    var typeText: String { get }
    
    /// Localized value description (e.g. "5.0 XAF").
    var valueText: String { get }
    
    /// Button view model used for the trailing action.
    var actionButtonViewModel: ButtonViewModelProtocol { get }
}


