import UIKit

class NibView: UIView, NibLoadable {

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

    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
