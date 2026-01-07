//
//  ActionButtonBlockViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 13/03/2025.
//

import Foundation

public protocol ActionButtonBlockViewModelProtocol {
    var title: String { get }
    var actionName: String { get }
    var actionURL: String? { get }
    var isEnabled: Bool { get }
    
    func didTapActionButton()
}
