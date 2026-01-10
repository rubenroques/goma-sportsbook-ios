//
//  UIStackView+Extensions.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/08/2021.
//

import UIKit

extension UIStackView {

    func removeAllArrangedSubviews() {

        let removedSubviews = arrangedSubviews.reduce([]) { allSubviews, subview -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }

        NSLayoutConstraint.deactivate(removedSubviews.flatMap { $0.constraints })

        removedSubviews.forEach { $0.removeFromSuperview() }
    }
}
