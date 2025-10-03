//
//  UIViewController+TopBarContainer.swift
//  BetssonCameroonApp
//
//  Created on 16/09/2025.
//

import UIKit

extension UIViewController {
    private struct AssociatedKeys {
        static var topBarContainer = "topBarContainer"
    }

    var topBarContainer: TopBarContainerController? {
        get {
            // First check if we are the container
            if let container = self as? TopBarContainerController {
                return container
            }
            // Then walk up the parent hierarchy
            return parent?.topBarContainer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.topBarContainer,
                                   newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
