//
//  PassthroughWindow.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 23/07/2025.
//

import Foundation
import UIKit

class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
