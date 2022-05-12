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
    
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()

    private lazy var sliderView: UIView = Self.createSliderView()

    private var sliderLeadingConstraint: NSLayoutConstraint?
    private var sliderTrailingConstraint: NSLayoutConstraint?

    private var options: [String] = []
    private var itemsViews: [SegmentControlItemView] = []

    // MARK: Lifetime and Cycle
    init(options: [String]) {
        super.init(frame: .zero)

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

        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.stackView.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor),
            self.containerView.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor),
        ])

    }
}
