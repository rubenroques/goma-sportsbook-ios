import UIKit

public class TabularBarView: UIView {

    public enum BarDistribution {
        case automatic
        case content
        case parent
    }

    public weak var dataSource: TabularBarDataSource? {
        didSet {
            self.reloadBarButtons()
        }
    }

    public weak var delegate: TabularBarDelegate?

    public var barDistribution = BarDistribution.automatic {
        didSet {
            if barDistribution == .parent {
                self.baseScrollView.removeConstraint(stackViewWithConstraint!)
                stackViewWithConstraint = NSLayoutConstraint(item: self.stackView, attribute: .width, relatedBy: .equal, toItem: self.baseScrollView, attribute: .width, multiplier: 1, constant: 0)
                self.baseScrollView.addConstraint(stackViewWithConstraint!)

            }
            else {
                self.baseScrollView.removeConstraint(stackViewWithConstraint!)
                stackViewWithConstraint = NSLayoutConstraint(item: self.stackView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: self.baseScrollView, attribute: .width, multiplier: 1, constant: 0)
                self.baseScrollView.addConstraint(stackViewWithConstraint!)
            }

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    public var textFont: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            buttonsIndeces.keys.forEach({
                $0.textFont = textFont
            })
        }
    }

    public var textColor: UIColor = .white {
        didSet {
            self.selectedBarButtonView.backgroundColor = barColor
        }
    }

    public var barColor: UIColor = .black {
        didSet {
            self.selectedBarButtonView.backgroundColor = barColor
        }
    }

    private var baseScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.App2.backgroundSecondary
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        return scrollView
    }()

    private var stackViewWithConstraint: NSLayoutConstraint!
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 1
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()

    private var selectedBarButtonBaseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App2.backgroundSecondary
        return view
    }()

    private var selectedBarButtonView: UIView = {
        let view = UIView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.App2.backgroundSecondary
        return view
    }()

    private var selectedBarButton: TabularBarButton?
    private var buttonsIndeces: [TabularBarButton: Int] = [:]

    public init() {
        super.init(frame: CGRect.zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.commonInit()
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

        self.addSubview(baseScrollView)
        baseScrollView.addSubview(stackView)

        self.selectedBarButtonBaseView.addSubview(selectedBarButtonView)
        baseScrollView.addSubview(selectedBarButtonBaseView)

        stackViewWithConstraint = NSLayoutConstraint(item: self.stackView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: self.baseScrollView, attribute: .width, multiplier: 1, constant: 0)

        NSLayoutConstraint.activate([
            baseScrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            baseScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            baseScrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            baseScrollView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),

            baseScrollView.frameLayoutGuide.heightAnchor.constraint(equalTo: stackView.heightAnchor),

            stackViewWithConstraint,

            stackView.leadingAnchor.constraint(equalTo: baseScrollView.contentLayoutGuide.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: baseScrollView.contentLayoutGuide.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: baseScrollView.contentLayoutGuide.trailingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: baseScrollView.contentLayoutGuide.bottomAnchor),

            selectedBarButtonBaseView.leadingAnchor.constraint(equalTo: baseScrollView.contentLayoutGuide.leadingAnchor),
            selectedBarButtonBaseView.heightAnchor.constraint(equalToConstant: 4),
            selectedBarButtonBaseView.trailingAnchor.constraint(equalTo: baseScrollView.contentLayoutGuide.trailingAnchor),
            selectedBarButtonBaseView.bottomAnchor.constraint(equalTo: baseScrollView.contentLayoutGuide.bottomAnchor)

        ])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let intrinsicWidth = self.stackView.subviews.reduce(0.0) { $0 + $1.intrinsicContentSize.width }
        let scrollViewWidth = self.baseScrollView.bounds.size.width
        let currentDistribution = self.stackView.distribution
        if intrinsicWidth > scrollViewWidth {
            self.stackView.distribution = .fill
        }
        else {
            self.stackView.distribution = .fillEqually
        }

        if barDistribution == .content {
            self.stackView.distribution = .fill
        }
        else if barDistribution == .parent {
            self.stackView.distribution = .fillEqually
        }

        if self.stackView.distribution != currentDistribution {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }

        if let selected = self.selectedBarButton {
            self.didSelectButton(button: selected, animated: false)
        }
    }

    internal func reloadBarButtons() {

        self.stackView.removeAllArrangedSubviews()

        self.buttonsIndeces = [:]
        self.selectedBarButton = nil

        let numberOfButtons = dataSource?.numberOfButtons() ?? 0
        for index in 0..<numberOfButtons {
            let title = dataSource?.titleForButton(atIndex: index) ?? ""
            let button = TabularBarButton(title: title)
            button.textColor = self.textColor
            button.textFont = self.textFont
            button.tapAction = { [weak self] button in

                guard let self = self else { return }

                if let index = self.buttonsIndeces[button] {
                    self.delegate?.didTapButton(atIndex: index)
                    self.didSelectButton(button: button, animated: true)
                }
            }
            self.buttonsIndeces[button] = index
            self.stackView.addArrangedSubview(button)

            NSLayoutConstraint.activate([
                button.centerYAnchor.constraint(equalTo: self.stackView.centerYAnchor),
                button.heightAnchor.constraint(equalTo: self.stackView.heightAnchor)
            ])

        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func didSelectButton(button: TabularBarButton, animated: Bool) {
        self.selectedBarButton = button

        var middleXPoint = CGPoint(x: button.frame.origin.x + (button.frame.size.width/2) - (baseScrollView.frame.size.width/2), y: 0)

        if middleXPoint.x < 0 {
            middleXPoint = CGPoint(x: 0, y: 0)
        }
        else if middleXPoint.x + baseScrollView.frame.size.width > self.baseScrollView.contentSize.width {
            middleXPoint = CGPoint(x: self.baseScrollView.contentSize.width - baseScrollView.frame.size.width, y: 0)
        }

        if let selectedBarButtonValue = selectedBarButton {

            UIView.animate(withDuration: animated ? 0.19 : 0.0) {
                self.baseScrollView.setContentOffset(middleXPoint, animated: false)
                self.selectedBarButtonView.frame = CGRect(x: selectedBarButtonValue.frame.origin.x,
                                                     y: 0.0,
                                                     width: selectedBarButtonValue.frame.size.width,
                                                     height: self.selectedBarButtonBaseView.bounds.height)
            }
        }

        self.setNeedsLayout()
    }

    func scrollToIndex(_ index: Int, animated: Bool = true) {
        for (key, value) in self.buttonsIndeces {
            if value == index {
                self.didSelectButton(button: key, animated: animated)
            }
        }
    }

}
