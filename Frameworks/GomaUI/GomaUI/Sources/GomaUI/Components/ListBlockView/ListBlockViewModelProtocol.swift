//
//  ListBlockViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit

public protocol ListBlockViewModelProtocol {
    var iconUrl: String { get }
    var counter: String? { get }
    var views: [UIView] { get }
}
