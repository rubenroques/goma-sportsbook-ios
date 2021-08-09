//
//  UIViewController+Extensions.swift
//  All Goals
//
//  Created by Ruben Roques on 19/09/2019.
//  Copyright © 2019 GOMA Development. All rights reserved.
//

import UIKit

extension UIViewController {

    var isModal: Bool {

        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController

        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}


extension UINavigationController {
    var rootViewController : UIViewController? {
        return self.viewControllers.first
    }
}

extension UIViewController {

    func addChildViewController(_ viewController: UIViewController, toView view: UIView) {
        
        guard let subview = viewController.view  else {
            return
        }

        viewController.willMove(toParent: self)
        self.addChild(viewController)

        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subview)

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: subview.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: subview.trailingAnchor),
            view.topAnchor.constraint(equalTo: subview.topAnchor),
            view.bottomAnchor.constraint(equalTo: subview.bottomAnchor),
        ])

        viewController.didMove(toParent: self)
    }


    func removeChildViewController(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }


}
