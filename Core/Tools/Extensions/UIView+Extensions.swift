//
//  UIView+Extensions.swift
//  All Goals
//
//  Created by Ruben Roques on 19/09/2019.
//  Copyright © 2019 GOMA Development. All rights reserved.
//

import UIKit

protocol NibLoadable {
    var nibFileName: String { get }
    func loadFromNib()
}

extension NibLoadable where Self: UIView {

    var nibFileName: String {
        let selfName = String(describing: type(of: self)) as NSString
        guard let name = selfName.components(separatedBy: ".").last else {
            fatalError("Cannot split name \(selfName) to create identifier")
        }
        return name
    }

    func loadFromNib() {
        //let bundle = Bundle(for: Self.self)
        //UINib(nibName: nibFileName, bundle: nil).instantiate(withOwner: nil, options: nil)

        guard let view = Bundle.main.loadNibNamed(nibFileName, owner: self, options: nil)?.first as? UIView else {
            print("Could not load nib with name: \(nibFileName)")
            return
        }

        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        view.frame = bounds
        view.backgroundColor = .clear

        self.addSubview(view)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}


extension UIView {
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




