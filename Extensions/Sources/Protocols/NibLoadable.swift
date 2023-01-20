//
//  NibLoadable.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import UIKit

public protocol NibLoadable {
    var nibFileName: String { get }
    func loadFromNib()
}

public extension NibLoadable where Self: UIView {

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

