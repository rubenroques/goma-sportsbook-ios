//
//  Constants.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/08/2021.
//

import Foundation
import UIKit

enum AnimationDuration {
    static let normal: TimeInterval = 0.30
    static let short: TimeInterval = 0.15
}

enum BorderRadius {
    static let modal: CGFloat = 11.0
    static let headerInput: CGFloat = 10.0
    static let button: CGFloat = 8.0
    static let checkBox: CGFloat = 6.0
}

enum TextSpacing {
    static let subtitle: CGFloat = 1.25
}

enum EveryMatrixInfo {
    static let version: String = "v2"
    static let url: String = "wss://api-phoenix-stage.everymatrix.coeverymatrix.com"
    static let realm: String = "http://www.gomadevelopment.pt"
}
