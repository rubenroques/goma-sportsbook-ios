//
//  SegmentControlView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/04/2022.
//

import UIKit

class SegmentControlView: UIView {

    var backgroundContainerColor: UIColor = UIColor.gray {
        didSet {
            self.containerView.backgroundColor = backgroundContainerColor
        }
    }

    var sliderColor: UIColor = UIColor.gray {
        didSet {
            self.sliderView.backgroundColor = sliderColor
        }
    }

    var textColor: UIColor = UIColor.white {
        didSet {
            for itemView in self.itemsViews {
                itemView.textColor = textColor
            }
        }
    }

    var textIdleColor: UIColor = UIColor.gray {
        didSet {
            for itemView in self.itemsViews {
                itemView.textIdleColor = self.textIdleColor
            }
        }
    }

    var didSelectItemAtIndexAction: (Int) -> Void = { _ in }
    var selectedItemIndex = 0
    
    var customItemAttributedString: (Int) -> NSAttributedString? = { _ in return nil }
    
    var customItemLeftAccessoryImage: (Int) -> UIImage? = { _ in return nil }
    
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()

    private lazy var sliderView: UIView = Self.createSliderView()
    private lazy var customSliderViews: [Int: UIView] = [:]
    
    private var sliderLeadingConstraint: NSLayoutConstraint?
    private var sliderTrailingConstraint: NSLayoutConstraint?

    private var options: [String] = []
    private var itemsViews: [SegmentControlItemView] = []

    // MARK: Lifetime and Cycle
    init(options: [String],
         customItemAttributedString: ((Int) -> NSAttributedString?)? = nil,
         customItemLeftAccessoryImage: ((Int) -> UIImage?)? = nil)
    {
        super.init(frame: .zero)

        if let customItemAttributedStringValue = customItemAttributedString {
            self.customItemAttributedString = customItemAttributedStringValue
        }
        
        if let customItemLeftAccessoryImageValue = customItemLeftAccessoryImage {
            self.customItemLeftAccessoryImage = customItemLeftAccessoryImageValue
        }
        
        self.options = options
        self.commonInit()
    }

    @available(iOS, unavailable)
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
    }

    func commonInit() {

        for (index, optionText) in self.options.enumerated() {
            let segmentControlItemView = SegmentControlItemView(text: optionText, isEnabled: true)
            segmentControlItemView.didTapItemViewAction = { [weak self] in
                self?.setSelectedItem(atIndex: index, animated: true)
            }
            
            segmentControlItemView.customAttributedString = { [weak self] _ -> NSAttributedString? in
                return self?.customItemAttributedString(index)
            }
            
            segmentControlItemView.customLeftAccessoryImage = { [weak self] _ -> UIImage? in
                if let customImage = self?.customItemLeftAccessoryImage(index) {
                    let customSliderView = GradientView() // Self.createCustomSliderView()
                    customSliderView.translatesAutoresizingMaskIntoConstraints = false
                    customSliderView.colors = [
                        (UIColor(hex: 0x399504, alpha: 1.0), 0.0),
                        (UIColor(hex: 0x003E01, alpha: 1.0), 1.0),
                    ]
                    customSliderView.startPoint = CGPoint(x: 0.0, y: 0.5)
                    customSliderView.endPoint = CGPoint(x: 1.0, y: 0.5)
                    self?.customSliderViews[index] = customSliderView
                    return customImage
                }
                else {
                    return nil
                }
            }

            self.itemsViews.append(segmentControlItemView)
            self.stackView.addArrangedSubview(segmentControlItemView)
        }
    
        self.setupSubviews()
        self.setupWithTheme()

        self.setSelectedItem(atIndex: 0, animated: false)
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.stackView.backgroundColor = .clear

        self.containerView.backgroundColor = backgroundContainerColor
        self.sliderView.backgroundColor = sliderColor

        for itemView in self.itemsViews {
            itemView.textColor = self.textColor
            itemView.textIdleColor = self.textIdleColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = self.containerView.frame.height / 2
        self.sliderView.layer.cornerRadius = self.containerView.frame.height / 2
    }

    func setSelectedItem(atIndex index: Int, animated: Bool = true) {
        guard
            let itemView = self.itemsViews[safe: index]
        else {
            return
        }

        self.selectedItemIndex = index
        self.didSelectItemAtIndexAction(index)

        self.itemsViews.forEach { itemView in
            itemView.isSelected = false
        }

        itemView.isSelected = true

        self.sliderLeadingConstraint?.isActive = false
        self.sliderTrailingConstraint?.isActive = false

        self.sliderLeadingConstraint = self.sliderView.leadingAnchor.constraint(equalTo: itemView.leadingAnchor)
        self.sliderTrailingConstraint = self.sliderView.trailingAnchor.constraint(equalTo: itemView.trailingAnchor)

        NSLayoutConstraint.activate([
            self.sliderLeadingConstraint!,
            self.sliderTrailingConstraint!,
        ])

        UIView.animate(withDuration: 0.25) {
            if let customSliderViewForIndex = self.customSliderViews[index] {
                customSliderViewForIndex.alpha = 1.0
            }
            let otherCustomSliderViews = self.customSliderViews.filter { $0.key != index }.map { $0.value }
            otherCustomSliderViews.forEach({ $0.alpha = 0.0 })
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }

    }

    func setEnabledItem(atIndex index: Int, isEnabled: Bool) {
        guard
            let itemView = self.itemsViews[safe: index]
        else {
            return
        }

        itemView.isEnabled = isEnabled
    }
    
    func disableAll() {
        for itemIndex in self.itemsViews.indices {
            self.setEnabledItem(atIndex: itemIndex, isEnabled: false)
        }
    }
    
    func enableAll() {
        for itemIndex in self.itemsViews.indices {
            self.setEnabledItem(atIndex: itemIndex, isEnabled: true)
        }
    }

}

extension SegmentControlView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSliderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }
    
    private static func createCustomSliderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        for customSliderView in self.customSliderViews.values {
            self.sliderView.addSubview(customSliderView)
        }
        
        self.containerView.addSubview(self.sliderView)
        self.containerView.addSubview(self.stackView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
        ])

        self.sliderLeadingConstraint = self.sliderView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor)
        self.sliderTrailingConstraint = self.sliderView.trailingAnchor.constraint(equalTo: self.containerView.leadingAnchor)

        NSLayoutConstraint.activate([
            self.sliderView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.sliderView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.sliderLeadingConstraint!,
            self.sliderTrailingConstraint!,
        ])

        for customSliderView in self.customSliderViews.values {
            NSLayoutConstraint.activate([
                customSliderView.leadingAnchor.constraint(equalTo: self.sliderView.leadingAnchor),
                customSliderView.trailingAnchor.constraint(equalTo: self.sliderView.trailingAnchor),
                customSliderView.topAnchor.constraint(equalTo: self.sliderView.topAnchor),
                customSliderView.bottomAnchor.constraint(equalTo: self.sliderView.bottomAnchor),
            ])
        }
        
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.stackView.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor),
            self.containerView.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor),
        ])

    }
}
