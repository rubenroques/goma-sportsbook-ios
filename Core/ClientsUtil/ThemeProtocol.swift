//
//  ThemeProtocol.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/07/2021.
//

import UIKit

protocol ThemeProtocol {
    var backgroundColor: UIColor { get }
    var secondaryBackgroundColor: UIColor {get}
    var heading: UIColor {get}
    var subHeading: UIColor {get}
    var separatorColor: UIColor { get }
    var tintColor: UIColor { get }
}
