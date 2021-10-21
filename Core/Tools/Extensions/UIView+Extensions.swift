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

    enum ViewSide {
        case left, right, top, bottom
    }

    func addBorder(side: ViewSide, color: CGColor, thickness: CGFloat) {

        let border = CALayer()
        border.backgroundColor = color

        switch side {
        case .left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height); break
        case .right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height); break
        case .top: border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness); break
        case .bottom: border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: thickness); break
        }

        layer.addSublayer(border)
    }
}
