//
//  HeaderTextViewViewModelProtocol.swift
//  GomaUI
//
//  Created by Assistant on 2025-01-27.
//

import Foundation
import Combine

public protocol HeaderTextViewViewModelProtocol: AnyObject {
    var title: String { get }
    
    var refreshData: (() -> Void)? { get set }
    
    func updateTitle(_ title: String)
}
