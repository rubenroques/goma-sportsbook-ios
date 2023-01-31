//
//  File.swift
//  
//
//  Created by Ruben Roques on 17/01/2023.
//

import Foundation
import UIKit

public extension UIButton {
    private func imageWithColor(_ color: UIColor) -> UIImage? {

        defer {
            UIGraphicsEndImageContext()
        }

        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {

            context.setFillColor(color.cgColor)
            context.fill(rect)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                return image
            }
        }
        return nil
    }

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {

        if let image = imageWithColor(color) {
            self.setBackgroundImage(image, for: state)
        }
    }

    func setInsets(forContentPadding contentPadding: UIEdgeInsets, imageTitlePadding: CGFloat) {
        self.contentEdgeInsets = UIEdgeInsets(
            top: contentPadding.top,
            left: contentPadding.left,
            bottom: contentPadding.bottom,
            right: contentPadding.right + imageTitlePadding
        )
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: imageTitlePadding,
            bottom: 0,
            right: -imageTitlePadding
        )
    }
    
}
