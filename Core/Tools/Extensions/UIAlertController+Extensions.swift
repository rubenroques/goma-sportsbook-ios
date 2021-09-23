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

//    static func showSuccessMessage(message: String, on viewController: UIViewController, handler: (() -> Void)? = nil) {
//        let alertViewController = UIAlertController(title: localized("string_success"), message: message, preferredStyle: UIAlertController.Style.alert)
//        let cancelAction = UIAlertAction(title: localized("string_ok"), style: .default) { _ in
//            if let handlerValue = handler { handlerValue() }
//        }
//        alertViewController.addAction(cancelAction)
//        viewController.present(alertViewController, animated: true, completion: nil)
//    }

    static func showServerErrorMessage(on viewController: UIViewController) {
        let alert = UIAlertController(title: localized("string_login_error_title"),
                                      message: localized("string_server_error_message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("string_ok"), style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }

}
