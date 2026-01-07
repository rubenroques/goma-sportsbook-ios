//
//  UITapGestureRecognizer+Extensions.swift
//  Sportsbook
//
//  Created by André Lascas on 14/09/2021.
//

import Foundation
import UIKit

extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange, alignment: NSTextAlignment = .center) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)

        // Text align center by default
        var textContainerOffset = CGPoint(
            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )

        if alignment == .left {
            textContainerOffset = CGPoint(
                x: (labelSize.width - textBoundingBox.size.width) * 0 - textBoundingBox.origin.x,
                y: (labelSize.height - textBoundingBox.size.height) * 0 - textBoundingBox.origin.y
            )
        } else if alignment == .right {
            textContainerOffset = CGPoint(
                x: (labelSize.width - textBoundingBox.size.width) * 1 - textBoundingBox.origin.x,
                y: (labelSize.height - textBoundingBox.size.height) * 1 - textBoundingBox.origin.y
            )
        }

        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }

}
