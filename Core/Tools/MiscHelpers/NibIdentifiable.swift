//
//  Identifiable.swift
//  AllGoalsFramework
//
//  Created by Ruben Roques on 13/11/2019.
//  Copyright © 2019 GOMA Development. All rights reserved.
//

import Foundation
import UIKit

protocol NibIdentifiable {
    static var identifier: String { get }
    static var nib: UINib { get }
}

extension NibIdentifiable {
    static var identifier: String {
        return String(describing: self)
    }
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}

extension UITableViewCell: NibIdentifiable { }

// extension UICollectionViewCell: NibIdentifiable { } not needed because  UICollectionViewCell: UICollectionReusableView
extension UICollectionReusableView: NibIdentifiable { }

extension UITableViewHeaderFooterView: NibIdentifiable { }
