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
        let offsetX = (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x
        let offsetY = (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        var textContainerOffset = CGPoint(x: offsetX, y: offsetY)

        if alignment == .left {
            let leftOffsetX = (labelSize.width - textBoundingBox.size.width) * 0 - textBoundingBox.origin.x
            let leftOffsetY = (labelSize.height - textBoundingBox.size.height) * 0 - textBoundingBox.origin.y
            textContainerOffset = CGPoint(x: leftOffsetX, y: leftOffsetY)
        } else if alignment == .right {
            let rightOffsetX = (labelSize.width - textBoundingBox.size.width) * 1 - textBoundingBox.origin.x
            let rightOffsetY = (labelSize.height - textBoundingBox.size.height) * 1 - textBoundingBox.origin.y
            textContainerOffset = CGPoint(x: rightOffsetX, y: rightOffsetY)
        }

        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }

}
