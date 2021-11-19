//
//  FilterCountView.swift
//  ShowcaseProd
//
//  Created by Teresa on 12/11/2021.
//

import UIKit
import SwiftUI


class FilterCountView: UIView, NibLoadable {

   
    @IBOutlet weak var roundCornerView: UIView!
    @IBOutlet weak var textField: UITextField!
    
    
    var unselectedColor: UIColor = UIColor.systemGray {
           didSet {
               self.drawView()
           }
       }

       var selectedColor: UIColor = UIColor.systemBlue {
           didSet {
               self.drawView()
           }
       }

       var isSelected: Bool = false {
           didSet {
               self.drawView()
           }
       }

       convenience init() {
           self.init(frame: .zero)
       }

       override init(frame: CGRect) {
           super.init(frame: frame)

           loadFromNib()
           commonInit()
       }

       required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
           loadFromNib()
           commonInit()
       }

       func commonInit() {
           self.translatesAutoresizingMaskIntoConstraints = false
           self.backgroundColor = .clear

           self.roundCornerView.layer.cornerRadius = 3
           self.textField.image =  UITextField(named: "filter_count_icon")

           self.drawView()
       }

       override var intrinsicContentSize: CGSize {
           return CGSize(width: 20, height: 20)
       }

       func drawView() {
           if self.isSelected {
               self.textField.isHidden = false
               self.roundCornerView.backgroundColor = selectedColor

               self.roundCornerView.layer.borderWidth = 0.0
           }
           else {
               self.textField.isHidden = true
               self.roundCornerView.backgroundColor = .clear

               self.roundCornerView.layer.borderWidth = 1.5
               self.roundCornerView.layer.borderColor = self.unselectedColor.cgColor
           }
       }
   }
