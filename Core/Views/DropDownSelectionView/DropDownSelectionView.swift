//
//  DropDownSelectionView.swift
//  Sportsbook
//
//  Created by Teresa on 08/02/2022.
//

import UIKit
import Combine

class DropDownSelectionView: UIView {
    
    // MARK: - Private Properties
    // Sub Views
    private lazy var containerView: UIView = Self.createDropdownView()
    private lazy var baseView: UIView = Self.createBaseView()

    private lazy var textLabel: UILabel = Self.createTextLabel()
    private lazy var textField: UITextField = Self.createTextField()

    private lazy var selectImage: UIImageView = Self.createSelectImageView()
    
    private lazy var bottomStackView: UIStackView = Self.createBottomStackView()
    private lazy var tipImageView: UIImageView = Self.createTipImageView()
    private lazy var tipLabel: UILabel = Self.ceateTipLabel()
    
    var didSelectPickerIndex: ((Int) -> Void)?
    var shouldBeginEditing: (() -> Bool)?
    
    var textPublisher: CurrentValueSubject<String, Never> = .init("")
    
    // Variables
    let datePicker = UIDatePicker()
    let pickerView = UIPickerView()
    var selectionArray: [String] = []

    var text: String {
        return self.textLabel.text ?? ""
    }
    
    private var isActive: Bool = false
    
    var isDisabled: Bool = false {
        didSet {
            if self.isDisabled {
                self.baseView.isUserInteractionEnabled = false
                self.textLabel.isUserInteractionEnabled = false
                self.textField.isUserInteractionEnabled = false
                self.textLabel.alpha = 0.7

            }
            else {
                self.baseView.isUserInteractionEnabled = true
                self.textLabel.isUserInteractionEnabled = true
                self.textField.isUserInteractionEnabled = true
                self.textLabel.alpha = 1.0
            }
        }
    }
    
    enum FieldState {
        case ok
        case error
        case hidden
    }

    var fieldState: FieldState = .hidden {
        didSet {
            switch self.fieldState {
            case .ok:
                self.tipImageView.isHidden = false
                self.tipImageView.image = UIImage(named: "Active")
            case .error:
                self.tipImageView.isHidden = false
                self.tipImageView.image = UIImage(named: "error_input_icon")
            case .hidden:
                self.tipImageView.isHidden = true
                self.tipImageView.image = nil
            }
        }
    }
    
    // MARK: - Lifetime and Cycle

//    @available(iOS, unavailable)
//    convenience init() {
//        self.init(frame: .zero)
//    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
        self.setupSubviews()

        self.fieldState = .hidden

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(makeTextfieldFirstResponder))
        self.baseView.addGestureRecognizer(tapGesture)

    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK: - Date Picker
    //
    func setDatePickerMode() {

        self.datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        self.datePicker.addTarget(self, action: #selector(self.dateChanged), for: .allEvents)

        let doneButton = UIBarButtonItem.init(title: localized("done"), style: .done, target: self, action: #selector(self.datePickerDone))

        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)

        self.textField.inputAccessoryView = toolBar
        self.textField.inputView = self.datePicker
        
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
    
    // MARK: - Errors and Tips
    //
    func showErrorOnField(text: String, color: UIColor = .systemRed) {

        self.tipLabel.text = text
        self.tipLabel.textColor = color

        self.fieldState = .error

        UIView.animate(withDuration: 0.1) {
            self.tipLabel.alpha = 1.0
        }

        self.containerView.layer.borderColor = color.cgColor
    }

    // MARK: - Layout setters
    //

    func setTextFieldColor(_ color: UIColor) {
        self.textLabel.textColor = color
    }

    func setViewColor(_ color: UIColor) {

        self.baseView.backgroundColor = color
        self.containerView.backgroundColor = color

        self.textField.textColor = .clear
        self.textField.backgroundColor = .clear

        self.textLabel.backgroundColor = color

    }

    func setViewBorderColor(_ color: UIColor) {
        self.baseView.layer.borderColor = color.cgColor
    }

    func setTextFieldFont(_ font: UIFont) {
        self.textLabel.font = font
    }
    
    func setText(_ text: String) {
        self.textLabel.text = text
    }

    func setImageTextField(_ image: UIImage, size: CGFloat = 30) {
        self.selectImage.image = image
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

    @objc func dateChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormatter.string(from: datePicker.date)
        self.textLabel.text = "\(selectedDate)"
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
extension DropDownSelectionView {

    private static func createBaseView() -> UIView {
        let baseView = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.backgroundColor = UIColor.App.backgroundSecondary
        baseView.layer.cornerRadius = CornerRadius.headerInput
        baseView.layer.borderWidth = 1
        return baseView
    }
    
    private static func createDropdownView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createPlaceholderLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private static func createTextLabel() -> UILabel {
        let textLabel = UILabel()
        textLabel.textColor = UIColor.App.inputText
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }
    
    private static func createHeaderLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
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
        imageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createBottomStackView() -> UIStackView {
        let bottomStackView = UIStackView()
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillProportionally
        bottomStackView.alignment = .fill
        bottomStackView.spacing = 8
        return bottomStackView
    }
    
    private static func createTipImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "arrow_dropdown_icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func ceateTipLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func setupSubviews() {

        self.containerView.addSubview(self.bottomStackView)

        self.bottomStackView.addArrangedSubview(self.tipImageView)
        self.bottomStackView.addArrangedSubview(self.tipLabel)

        self.containerView.addSubview(self.textField)
        self.containerView.addSubview(self.baseView)

        self.baseView.addSubview(self.textLabel)
        self.baseView.addSubview(self.selectImage)

        self.addSubview(self.containerView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.textField.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 20),
            self.textField.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -20),
            self.textField.centerYAnchor.constraint(equalTo: self.textLabel.centerYAnchor),
            self.textField.centerXAnchor.constraint(equalTo: self.textLabel.centerXAnchor),
            self.textField.heightAnchor.constraint(equalToConstant: 10),

            self.baseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 10),
            self.baseView.heightAnchor.constraint(equalToConstant: 57),

            self.textLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.textLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),
            self.textLabel.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),

            self.selectImage.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -20),
            self.selectImage.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),
            
            self.bottomStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.bottomStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.bottomStackView.topAnchor.constraint(equalTo: self.baseView.bottomAnchor),
            self.bottomStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
        ])
    }
    
}

extension DropDownSelectionView: UIPickerViewDelegate, UIPickerViewDataSource {

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

