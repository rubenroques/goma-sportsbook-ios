//
//  TallProgressBarView.swift
//  Sportsbook
//
//  Created by André Lascas on 30/01/2025.
//

import Foundation
import UIKit

class TallProgressBarView: UIProgressView {
    
    override func layoutSubviews() {
         super.layoutSubviews()

         let maskLayerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 6.0)
         let maskLayer = CAShapeLayer()
         maskLayer.frame = self.bounds
         maskLayer.path = maskLayerPath.cgPath
         layer.mask = maskLayer
     }
    
}
