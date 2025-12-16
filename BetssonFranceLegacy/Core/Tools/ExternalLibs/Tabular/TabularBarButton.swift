import UIKit

public class TabularBarButton: UIControl {

    public var title: String = "" {
        didSet {
            self.titleLabel.text = self.title
            self.titleLabel.sizeToFit()
            self.setNeedsLayout()
        }
    }

    public var textFont: UIFont = UIFont.systemFont(ofSize: 13) {
        didSet {
            self.titleLabel.font = textFont
        }
    }

    public var textColor: UIColor = .white {
        didSet {
            self.titleLabel.textColor = textColor
        }
    }

    public var verticalSpacing: Float = 8 {
        didSet {
            leadingAnchorConstraint?.constant = CGFloat(self.verticalSpacing)
            self.layoutIfNeeded()
        }
    }

    public var horizontalSpacing: Float = 0 {
        didSet {
            topAnchorConstraint?.constant = CGFloat(self.verticalSpacing)
            self.layoutIfNeeded()
        }
    }

    public var tapAction: ((TabularBarButton) -> Void)?

    private var leadingAnchorConstraint: NSLayoutConstraint?
    private var topAnchorConstraint: NSLayoutConstraint?

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 1

//        label.setContentCompressionResistancePriority(.defaultHigh, for:.vertical)
//        label.setContentCompressionResistancePriority(.defaultHigh, for:.horizontal)
//        
//        label.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
//        label.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
//        
        label.text = ""
        return label
    }()

    public init(title: String = "") {
        super.init(frame: CGRect.zero)
        self.translatesAutoresizingMaskIntoConstraints = false

        self.commonInit()

        self.title = title
        self.titleLabel.text = self.title
        self.titleLabel.sizeToFit()
        self.setNeedsLayout()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        self.backgroundColor = .clear
        self.addTitleLabel()

        self.titleLabel.textColor = textColor

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    // function which is triggered when handleTap is called
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        self.tapAction?(self)
    }

    private func addTitleLabel() {

        titleLabel.removeFromSuperview()

        self.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        self.setNeedsLayout()
    }

    public override var intrinsicContentSize: CGSize {
        let oldFrame = self.titleLabel.frame
        self.titleLabel.sizeToFit()
        let size = CGSize(width: self.titleLabel.frame.size.width + CGFloat(verticalSpacing * 2),
                      height: self.titleLabel.frame.size.height + CGFloat(horizontalSpacing * 2))
        self.titleLabel.frame = oldFrame
        return size
    }
}
