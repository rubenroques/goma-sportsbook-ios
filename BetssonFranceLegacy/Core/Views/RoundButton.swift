import UIKit

class RoundButton: UIButton {

    var cornerRadius: CGFloat = 2.5 {
        didSet {
            self.setNeedsLayout()
        }
    }

    var isCircular = false {
        didSet {
            self.setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isCircular {
            self.layer.cornerRadius = self.frame.size.width/2
        }
        else {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
}
