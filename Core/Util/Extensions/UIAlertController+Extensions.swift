//
//  AlertViewController+Extensions.swift
//  AllGoals
//
//  Created by Ruben Roques on 06/01/2020.
//  Copyright © 2020 GOMA Development. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    static func showSuccessMessage(message: String, on viewController: UIViewController, handler: (() -> Void)? = nil) {
        let alertViewController = UIAlertController(title: localized("string_success"), message: message, preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: localized("string_ok"), style: .default, handler: { _ in
            if let handlerValue = handler { handlerValue() }
        })
        alertViewController.addAction(cancelAction)
        viewController.present(alertViewController, animated: true, completion: nil)
    }

    static func showMessage(title: String, message: String, on viewController: UIViewController) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: localized("string_ok"), style: .cancel, handler: nil)
        alertViewController.addAction(cancelAction)
        viewController.present(alertViewController, animated: true, completion: nil)
    }

    static func showErrorMessage(message: String, on viewController: UIViewController) {
        let alertViewController = UIAlertController(title: localized("string_error_general_title"), message: message, preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: localized("string_ok"), style: .cancel, handler: nil)
        alertViewController.addAction(cancelAction)
        viewController.present(alertViewController, animated: true, completion: nil)
    }

    static func showFailureMessage(message: String, on viewController: UIViewController) {
        let alertViewController = UIAlertController(title: localized("string_error_general_title"), message: message, preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: localized("string_ok"), style: .cancel, handler: nil)
        alertViewController.addAction(cancelAction)
        viewController.present(alertViewController, animated: true, completion: nil)
    }

    static func showLoginMessage(message: String, on viewController: UIViewController) {
        let alertViewController = UIAlertController(title: localized("string_login"), message: message, preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: localized("string_ok"), style: .cancel, handler: nil)
        alertViewController.addAction(cancelAction)
        viewController.present(alertViewController, animated: true, completion: nil)
    }


}
