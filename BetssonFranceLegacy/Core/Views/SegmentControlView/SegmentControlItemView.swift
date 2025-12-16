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
            self.setupTextLabel()
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
            self.setupSelectedState()
        }
    }

    var textIdleColor: UIColor = UIColor.gray {
        didSet {
            self.setupSelectedState()
        }
    }

    var didTapItemViewAction: () -> Void = {}
    var isSelected: Bool = false {
        didSet {
            self.setupSelectedState()
        }
    }
    
    var customAttributedString: (SegmentControlItemView) -> NSAttributedString? = { _ in return nil } {
        didSet {
            self.setupTextLabel()
        }
    }
    var customLeftAccessoryImage: (SegmentControlItemView) -> UIImage? = { _ in return nil } {
        didSet {
            self.setupLeftAccessoryView()
        }
    }

    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var leftAccessoryImageView: UIImageView = Self.createLeftAccessoryImageView()
    
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()
    
    private let horizontalMargin: CGFloat = 14
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
                
        self.setupTextLabel()
        self.setupLeftAccessoryView()
    }
    
    private func setupTextLabel() {
        if let attributedText = self.customAttributedString(self) {
            self.titleLabel.text = nil
            self.titleLabel.attributedText = attributedText
        }
        else {
            self.titleLabel.attributedText = nil
            self.titleLabel.text = self.text
        }
    }
    
    private func setupLeftAccessoryView() {
        if let leftAccessoryImage = self.customLeftAccessoryImage(self) {
            
            self.leftAccessoryImageView.isHidden = false
            
            let scale: CGFloat = 1.15  // Adjust the scale factor as needed
            self.leftAccessoryImageView.transform = CGAffineTransform(scaleX: scale, y: scale)

            self.leftAccessoryImageView.image = leftAccessoryImage
        }
        else {
            self.leftAccessoryImageView.isHidden = true
            self.leftAccessoryImageView.image = nil
        }
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = .clear
        
        self.setupSelectedState()
    }
    
    func setupSelectedState() {
        if let attributedText = self.customAttributedString(self) {
            self.setupCustomStringWithState(attributedString: attributedText)
        }
        else {
            if isSelected {
                self.titleLabel.textColor = textColor
                self.leftAccessoryImageView.alpha = 1.0
            }
            else {
                self.titleLabel.textColor = textIdleColor
                self.leftAccessoryImageView.alpha = 0.7
            }
        }
    }
    
    func setupCustomStringWithState(attributedString: NSAttributedString) {
        
        if attributedString.string == "\(localized("mix_match_mix_string"))\(localized("mix_match_match_string"))" {
            
            let mixString = localized("mix_match_mix_string")
            let matchString = localized("mix_match_match_string")
            let fullString = mixString + matchString
            
            let attributedString = NSMutableAttributedString(string: fullString)
            
            let mixAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.App.highlightPrimary
            ]
            
            var matchAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.App.textPrimary
            ]
            
            if self.isSelected {
                matchAttributes = [
                    .foregroundColor: UIColor.App.buttonTextPrimary
                ]
            }
            
            attributedString.addAttributes(mixAttributes, range: NSRange(location: 0, length: mixString.count))
            attributedString.addAttributes(matchAttributes, range: NSRange(location: mixString.count, length: matchString.count))
            
            self.titleLabel.text = nil
            self.titleLabel.attributedText = attributedString
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

    private static func createContainerStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .center
        view.spacing = 9
        return view
    }
    
    private static func createLeftAccessoryImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = false
        imageView.isHidden = true
        return imageView
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = AppFont.with(type: .semibold, size: 13)
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerStackView.addArrangedSubview(self.leftAccessoryImageView)
        self.containerStackView.addArrangedSubview(self.titleLabel)
        
        self.containerView.addSubview(self.containerStackView)

        self.initConstraints()
    }

    private func initConstraints() {
        
        NSLayoutConstraint.activate([
            self.titleLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        NSLayoutConstraint.activate([
            self.leftAccessoryImageView.widthAnchor.constraint(equalTo: self.leftAccessoryImageView.heightAnchor),
            self.leftAccessoryImageView.widthAnchor.constraint(equalToConstant: 14),
        ])
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.containerStackView.topAnchor, constant: -verticalMargin),
            self.containerView.bottomAnchor.constraint(equalTo: self.containerStackView.bottomAnchor, constant: verticalMargin),
            self.containerView.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor, constant: -horizontalMargin),
            self.containerView.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor, constant: horizontalMargin),
        ])
    }
}
