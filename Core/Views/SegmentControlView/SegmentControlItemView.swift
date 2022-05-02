//
//  SegmentControlItemView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/04/2022.
//

import UIKit

class SegmentControlItemView: UIView {

    var text: String {
        didSet {
            self.titleLabel.text = text
        }
    }

    var isEnabled: Bool = true {
        didSet {
            if self.isEnabled {
                self.containerView.alpha = 1.0
                self.isUserInteractionEnabled = true
            }
            else {
                self.containerView.alpha = 0.4
                self.isUserInteractionEnabled = false
            }
        }
    }

    var textColor: UIColor = UIColor.gray {
        didSet {
            if isSelected {
                self.titleLabel.textColor = textColor
            }
        }
    }

    var textIdleColor: UIColor = UIColor.gray {
        didSet {
            if !isSelected {
                self.titleLabel.textColor = textIdleColor
            }
        }
    }

    var didTapItemViewAction: () -> Void = {}
    var isSelected: Bool = false {
        didSet {
            if self.isSelected {
                self.titleLabel.textColor = textColor
            }
            else {
                self.titleLabel.textColor = textIdleColor
            }
        }
    }

    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var containerView: UIView = Self.createContainerView()

    private let horizontalMargin: CGFloat = 16
    private let verticalMargin: CGFloat = 7

    // MARK: Lifetime and Cycle
    init(text: String, isEnabled: Bool = true) {
        self.text = text
        self.isEnabled = isEnabled

        super.init(frame: .zero)

        self.commonInit()

    }

    @available(iOS, unavailable)
    override init(frame: CGRect) {
        fatalError()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func commonInit() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapItemView))
        self.containerView.addGestureRecognizer(tapGesture)

        self.setupSubviews()
        self.setupWithTheme()

        self.titleLabel.text = self.text
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = .clear
        if isSelected {
            self.titleLabel.textColor = textColor
        }
        else {
            self.titleLabel.textColor = textIdleColor
        }
    }

    @objc func didTapItemView() {
        self.didTapItemViewAction()
    }

}

extension SegmentControlItemView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: verticalMargin),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -verticalMargin),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: horizontalMargin),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -horizontalMargin),
        ])

    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.titleLabel.intrinsicContentSize.width + (horizontalMargin * 2),
                      height: self.titleLabel.intrinsicContentSize.height + (verticalMargin * 2))
    }

}
