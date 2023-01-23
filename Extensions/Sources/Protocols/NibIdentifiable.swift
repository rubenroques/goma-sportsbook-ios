//
//  Identifiable.swift
//  AllGoalsFramework
//
//  Created by Ruben Roques on 13/11/2019.
//  Copyright © 2019 GOMA Development. All rights reserved.
//

import Foundation
import UIKit

public protocol NibIdentifiable {
    static var identifier: String { get }
    static var nib: UINib { get }
}

public extension NibIdentifiable {
    static var identifier: String {
        return String(describing: self)
    }
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}

public extension UITableView {

//    func registerCellNib<T: NibIdentifiable>(_ type: T.Type) {
//        self.register(type.nib, forCellReuseIdentifier: type.identifier)
//    }

//    func registerCellClass<T: NibIdentifiable>(_ type: T.Type) {
//        self.register(type.self, forCellReuseIdentifier: type.identifier)
//    }

    func dequeueCellType<T: NibIdentifiable>(_ type: T.Type) -> T? {
        if let cell = self.dequeueReusableCell(withIdentifier: type.identifier) as? T {
            return cell
        }
        return nil
    }

}

public extension UICollectionView {
    func dequeueCellType<T: NibIdentifiable>(_ type: T.Type, indexPath: IndexPath) -> T? {
        if let cell = self.dequeueReusableCell(withReuseIdentifier: type.identifier,
                                               for: indexPath) as? T {
            return cell
        }
        return nil
    }
}
