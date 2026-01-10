//
//  TabularScrollView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/05/2024.
//

import UIKit

class TabularScrollView: UIScrollView, UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is MultiSliderCustomPanGestureRecognizer {
            self.isScrollEnabled = false
            return true
        }
        else {
            self.isScrollEnabled = true
            return false
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is MultiSliderCustomPanGestureRecognizer {
            self.isScrollEnabled = false
            return true
        } else {
            self.isScrollEnabled = true
            return false
        }
    }

}
