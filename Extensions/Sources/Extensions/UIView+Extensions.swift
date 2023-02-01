//
//  File.swift
//  
//
//  Created by Ruben Roques on 23/01/2023.
//

import Foundation
import UIKit

public extension UIView {
    var viewController: UIViewController? {
        var parent: UIResponder? = self
        while parent != nil {
            parent = parent?.next
            if let viewController = parent as? UIViewController {
                return viewController
            }
        }
        return nil
    }

}
