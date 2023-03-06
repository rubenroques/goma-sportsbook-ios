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

    var isRootModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        }
        else {
            let presentingIsModal = presentingViewController != nil
            return presentingIsModal
        }
    }

    func showAlert(type: EditAlertView.AlertState, errorText: String = "") {

        let popup = EditAlertView()
        popup.alertState = type
        if errorText != "" {
            popup.setAlertText(errorText)
        }
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.alpha = 0
        self.view.addSubview(popup)
        NSLayoutConstraint.activate([

            popup.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            popup.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        self.view.bringSubviewToFront(popup)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            popup.alpha = 1
        } completion: { _ in
        }

        popup.onClose = {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                popup.alpha = 0
            } completion: { _ in
                popup.removeFromSuperview()
            }
        }
      }

    func showSimpleAlert(title: String, message: String) {

        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension UINavigationController {
    var rootViewController: UIViewController? {
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
            view.bottomAnchor.constraint(equalTo: subview.bottomAnchor)
        ])

        viewController.didMove(toParent: self)
    }

    func removeChildViewController(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }

}
