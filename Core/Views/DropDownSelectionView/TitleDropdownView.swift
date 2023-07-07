//
//  TitleDropdownView.swift
//  Sportsbook
//
//  Created by André Lascas on 03/07/2023.
//

import UIKit
import Combine

class TitleDropdownView: UIView {

    // MARK: - Private Properties
    private lazy var containerView: UIView = Self.createDropdownView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var textLabel: UILabel = Self.createTextLabel()
    private lazy var textField: UITextField = Self.createTextField()
    private lazy var selectImage: UIImageView = Self.createSelectImageView()

    var didSelectPickerIndex: ((Int) -> Void)?
    var shouldBeginEditing: (() -> Bool)?

    let pickerView = UIPickerView()
    var selectionArray: [String] = []

    var isDisabled: Bool = false {
        didSet {
            if self.isDisabled {
                self.containerView.isUserInteractionEnabled = false
                self.textLabel.isUserInteractionEnabled = false
                self.textField.isUserInteractionEnabled = false
                self.textLabel.alpha = 0.7
                self.titleLabel.alpha = 0.7

            }
            else {
                self.containerView.isUserInteractionEnabled = true
                self.textLabel.isUserInteractionEnabled = true
                self.textField.isUserInteractionEnabled = true
                self.textLabel.alpha = 1.0
                self.titleLabel.alpha = 1.0
            }
        }
    }

    var text: String {
        return self.textLabel.text ?? ""
    }

    var textPublisher: CurrentValueSubject<String, Never> = .init("")

    // MARK: - Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
        self.setupWithTheme()
    }

    private func commonInit() {
        self.setupSubviews()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(makeTextfieldFirstResponder))
        self.containerView.addGestureRecognizer(tapGesture)

    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.containerView.layer.borderColor = UIColor.App.inputTextTitle.cgColor

        self.titleLabel.textColor = UIColor.App.inputTextTitle

        self.textLabel.textColor = UIColor.App.textPrimary

    }

    // MARK: Functions
    func setTitle(_ text: String) {
        self.titleLabel.text = text
    }

    func setViewColor(_ color: UIColor) {

        self.containerView.backgroundColor = color

        self.textField.textColor = .clear
        self.textField.backgroundColor = .clear

        self.textLabel.backgroundColor = color

    }

    func setViewBorderColor(_ color: UIColor) {
        self.containerView.layer.borderColor = color.cgColor
    }

    // MARK: - Config Picker
    //
    func setPickerArray(_ array: [String]) {
        self.selectionArray = array
        self.pickerView.selectRow(0, inComponent: 0, animated: true)
        self.textField.text = selectionArray[0]
    }

    func setSelectedPickerOption(option: Int) {
        self.pickerView.selectRow(option, inComponent: 0, animated: true)
        self.textLabel.text = selectionArray[option]
    }

    func setSelectionPicker(_ array: [String], defaultValue: Int = 0) {
        self.selectionArray = array

        self.pickerView.delegate = self

        self.textField.inputView = pickerView
        self.textField.text = self.selectionArray[defaultValue]
        self.textLabel.text = self.selectionArray[defaultValue]

        self.textPublisher.send(self.selectionArray[defaultValue])

        self.dismissPickerView()
    }

    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: localized("done"), style: .plain, target: self, action: #selector(pickerAction))

        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), button], animated: true)
        toolBar.isUserInteractionEnabled = true
        self.textField.inputAccessoryView = toolBar

    }

    // MARK: - Actions
    //
    @objc func pickerAction() {
        self.textPublisher.send(text)
        self.endEditing(true)
    }

    @objc func datePickerDone() {
        self.textField.resignFirstResponder()
    }

    @objc func makeTextfieldFirstResponder() {
        if self.shouldBeginEditing?() ?? true {
            self.textField.becomeFirstResponder()
        }
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension TitleDropdownView {

    private static func createDropdownView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.headerInput
        view.layer.borderWidth = 1
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .regular, size: 12)
        return label
    }

    private static func createTextLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "---"
        label.font = AppFont.with(type: .regular, size: 16)
        return label
    }

    private static func createTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }

    private static func createSelectImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "arrow_dropdown_icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private func setupSubviews() {

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.textField)
        self.containerView.addSubview(self.textLabel)
        self.containerView.addSubview(self.selectImage)

        self.addSubview(self.containerView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 10),

            self.textLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.textLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.textLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
            self.textLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -10),

            self.textField.leadingAnchor.constraint(equalTo: self.textLabel.leadingAnchor),
            self.textField.trailingAnchor.constraint(equalTo: self.textLabel.trailingAnchor),
            self.textField.centerYAnchor.constraint(equalTo: self.textLabel.centerYAnchor),
            self.textField.heightAnchor.constraint(equalToConstant: 10),

            self.selectImage.widthAnchor.constraint(equalToConstant: 10),
            self.selectImage.heightAnchor.constraint(equalTo: self.selectImage.widthAnchor),
            self.selectImage.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.selectImage.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

        ])
    }

}

extension TitleDropdownView: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectionArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.didSelectPickerIndex?(row)
        return selectionArray[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedItem = selectionArray[row]
        self.textLabel.text = selectedItem
    }
}

