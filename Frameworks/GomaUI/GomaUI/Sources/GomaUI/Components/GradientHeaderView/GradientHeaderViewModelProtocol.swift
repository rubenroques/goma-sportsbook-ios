//
//  GradientHeaderViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 12/03/2025.
//

import UIKit

public protocol GradientHeaderViewModelProtocol {
    var title: String { get }
    var gradientColors: [(color: UIColor, location: NSNumber)] { get }
}
