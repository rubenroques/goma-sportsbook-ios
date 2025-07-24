//
//  NibView.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import UIKit

open class NibView: UIView, NibLoadable {

    public convenience init() {
        self.init(frame: .zero)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        loadFromNib()
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        loadFromNib()
        commonInit()
    }

    public func commonInit() {

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

}

