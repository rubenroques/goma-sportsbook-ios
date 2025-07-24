//
//  NSLayoutConstraint+Priority.swift
//  Sportsbook
//
//  Created by Ruben Roques on 25/03/2025.
//
import Foundation
import UIKit

extension NSLayoutConstraint {
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
