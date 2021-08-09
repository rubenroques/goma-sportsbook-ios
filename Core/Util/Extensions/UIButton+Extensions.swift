import Foundation
import UIKit

extension UIButton {
    private func imageWithColor(_ color: UIColor) -> UIImage? {

        defer {
            UIGraphicsEndImageContext()
        }

        let rect = CGRect(x: 0, y: 0, width: 1, height:1)
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
}

