//
//  InnerScrollDragDirection.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/03/2025.
//

import Foundation
import UIKit

enum InnerScrollDragDirection {
    case up
    case down
}

protocol InnerTableViewScrollDelegate: AnyObject {
    var currentHeaderHeight: CGFloat { get }
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat)
    func innerTableViewScrollEnded(withScrollDirection scrollDirection: InnerScrollDragDirection)
}
