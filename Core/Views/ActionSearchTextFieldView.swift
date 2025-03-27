//
//  ActionSearchTextFieldView.swift
//  MultiBet
//
//  Created by André Lascas on 14/11/2024.
//

import UIKit

import UIKit
import Combine

class ActionSearchTextFieldView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var headerLabel: UILabel = Self.createHeaderLabel()
    private lazy var textField: UITextField = Self.createTextField()
    private lazy var clearButton: UIButton = Self.createClearButton()
    private lazy var actionButton: UIButton = Self.createActionButton()

    private lazy var headerLabelCenterConstraint: NSLayoutConstraint = Self.createHeaderLabelCenterConstraint()
    private lazy var headerLabelCenterTopConstraint: NSLayoutConstraint = Self.createHeaderLabelCenterTopConstraint()

    private var isActive: Bool = false

    // MARK: Public Properties
    var shouldScalePlaceholder = true
    var shouldBeginEditing: (() -> Bool)?
    var didTapButtonAction: (() -> Void)?

    var textPublisher: AnyPublisher<String?, Never> {
        return self.textField.textPublisher
    }

    var isActionDisabled: Bool = true {
        didSet {
            if isActionDisabled {
                self.actionButton.isEnabled = false
                self.clearButton.isHidden = true
                
                self.actionButton.layer.borderColor = UIColor.App.buttonBorderDisableTertiary.cgColor
            }
            else {
                self.actionButton.isEnabled = true
                self.clearButton.isHidden = false
                
                self.actionButton.layer.borderColor = UIColor.App.buttonBorderTertiary.cgColor
            }
        }
    }

    var highlightColor = UIColor.App.buttonBorderTertiary {
        didSet {
            if self.isActive {
            }
        }
    }

    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {
        self.textField.delegate = self
        
        self.clearButton.addTarget(self, action: #selector(didTapClearButton), for: .primaryActionTriggered)

        self.actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)

        self.isActionDisabled = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.actionButton.layer.cornerRadius = CornerRadius.button
        self.actionButton.layer.masksToBounds = true
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.inputBackground
        self.containerView.layer.borderColor = UIColor.App.separatorLineSecondary.cgColor

        self.headerLabel.textColor = UIColor.App.textSecondary

        self.textField.backgroundColor = .clear
        
        self.clearButton.backgroundColor = .clear
        self.clearButton.tintColor = UIColor.App.iconSecondary

        self.actionButton.setTitleColor(UIColor.App.buttonTextTertiary, for: .normal)
        self.actionButton.setTitleColor(UIColor.App.buttonTextTertiary.withAlphaComponent(0.7), for: .highlighted)
        self.actionButton.setTitleColor(UIColor.App.buttonTextDisableTertiary, for: .disabled)

        self.actionButton.setBackgroundColor(.clear, for: .normal)
        self.actionButton.setBackgroundColor(.clear, for: .disabled)

    }

    func setPlaceholderText(placeholder: String) {
        self.textField.placeholder = ""
        self.headerLabel.text = placeholder
    }

    func setActionButtonTitle(title: String) {
        self.actionButton.setTitle(title, for: .normal)
    }

    func getTextFieldValue() -> String {
        let text = self.textField.text ?? ""
        return text
    }

    func shouldSlideDown() -> Bool {
        if let text = textField.text, !text.isEmpty {
            return false
        }
        return true
    }

    func slideUp(animated: Bool = true) {

        if headerLabel.text?.isEmpty ?? true {
            return
        }

        self.headerLabelCenterConstraint.isActive = false
        self.headerLabelCenterTopConstraint.isActive = true

        UIView.animate(withDuration: animated ? 0.2 : 0, delay: 0.0, options: .curveEaseOut) {
            self.layoutIfNeeded()

            if self.shouldScalePlaceholder {
                let movingWidthDiff = (self.headerLabel.frame.size.width - (self.headerLabel.frame.size.width * 0.8)) / 2
                self.headerLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).concatenating(CGAffineTransform(translationX: -movingWidthDiff, y: 0))
            }
            self.shouldScalePlaceholder = false
        } completion: { _ in

        }
    }

    func slideDown() {

        if headerLabel.text?.isEmpty ?? true {
            return
        }

        self.headerLabelCenterConstraint.isActive = true
        self.headerLabelCenterTopConstraint.isActive = false

        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.layoutIfNeeded()
            self.headerLabel.transform = CGAffineTransform.identity
            self.shouldScalePlaceholder = true
        } completion: { _ in

        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        self.textField.resignFirstResponder()
        return true
    }
}

//
// MARK: - Actions
//
extension ActionSearchTextFieldView {
    
    @objc private func didTapActionButton() {
        self.didTapButtonAction?()
    }

    @objc private func didTapClearButton() {
        self.textField.text = ""
        self.isActionDisabled = true
    }
}

//
// MARK: Subviews initialization and setup
//
extension ActionSearchTextFieldView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.headerInput
        view.layer.borderWidth = 1
        return view
    }

    private static func createHeaderLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Placeholder"
        label.font = AppFont.with(type: .semibold, size: 16)
        return label
    }

    private static func createTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return textField
    }
    
    private static func createClearButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "small_close_cross_light_icon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        return button
    }

    private static func createActionButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Action", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.layer.borderWidth = 2
        return button
    }

    private static func createHeaderLabelCenterConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createHeaderLabelCenterTopConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.headerLabel)
        self.containerView.addSubview(self.textField)
        self.containerView.addSubview(self.clearButton)
        self.containerView.addSubview(self.actionButton)

        self.containerView.bringSubviewToFront(self.headerLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 60),

            self.headerLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.headerLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -30),

            self.textField.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.textField.trailingAnchor.constraint(equalTo: self.clearButton.leadingAnchor, constant: -10),
            self.textField.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor, constant: 5),
            
            self.clearButton.trailingAnchor.constraint(equalTo: self.actionButton.leadingAnchor, constant: -10),
            self.clearButton.widthAnchor.constraint(equalToConstant: 16),
            self.clearButton.heightAnchor.constraint(equalTo: self.clearButton.widthAnchor),
            self.clearButton.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.actionButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.actionButton.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.actionButton.heightAnchor.constraint(equalToConstant: 35)

        ])

        self.headerLabelCenterConstraint =
        NSLayoutConstraint(item: self.headerLabel,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: self.containerView,
                           attribute: .centerY,
                           multiplier: 1,
                           constant: 0)
        self.headerLabelCenterConstraint.isActive = true

        self.headerLabelCenterTopConstraint =

        NSLayoutConstraint(item: self.headerLabel,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: self.containerView,
                           attribute: .centerY,
                           multiplier: 1,
                           constant: -15)
        self.headerLabelCenterTopConstraint.isActive = false

    }

}

extension ActionSearchTextFieldView: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let shouldBeginEditing = self.shouldBeginEditing?() ?? true
        self.isActive = shouldBeginEditing
        return shouldBeginEditing
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {

        self.isActive = true

        self.highlightColor = UIColor.App.buttonBorderTertiary
        self.containerView.layer.borderColor = self.highlightColor.cgColor

        self.slideUp()

    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.shouldSlideDown() {
            self.slideDown()
        }

        if self.textField.text == "" {
//            self.containerView.layer.borderColor = self.highlightColor.withAlphaComponent(0).cgColor
            self.containerView.layer.borderColor = UIColor.App.separatorLineSecondary.cgColor


        }

        self.isActive = false

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

}
