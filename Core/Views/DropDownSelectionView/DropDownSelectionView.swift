//
//  DropDownSelectionView.swift
//  Sportsbook
//
//  Created by Teresa on 08/02/2022.
//

import UIKit
import CombineCocoa
import Combine

class DropDownSelectionView: UIView {
    
    // MARK: - Private Properties
    // Sub Views
    private lazy var containerView: UIView = Self.createDropdownView()
    private lazy var baseView: UIView = Self.createSimpleView()
    private lazy var textLabel: UILabel = Self.createTextLabel()
    private lazy var headerLabel: UILabel = Self.createHeaderLabel()
    private lazy var placeholderLabel: UILabel = Self.createPlaceholderLabel()
    private lazy var textField: UITextField = Self.createTextField()
    private lazy var selectImage: UIImageView = Self.createSelectImageView()
    
    private lazy var bottomStackView: UIStackView = Self.createBottomStackView()
    private lazy var tipImageView: UIImageView = Self.createTipImageView()
    private lazy var tipLabel: UILabel = Self.ceateTipLabel()
    
    var didSelectPickerIndex: ((Int) -> Void)?
    var shouldBeginEditing: (() -> Bool)?

    var textPublisher: CurrentValueSubject<String, Never> = .init("")

    var showingTipLabel: Bool = false
    
    // Variables
    let datePicker = UIDatePicker()
    let pickerView = UIPickerView()
    var selectionArray: [String] = []
    var shouldScalePlaceholder = true
    var isCurrency: Bool = false
    var isTipPermanent: Bool = false
    var isSlidedUp: Bool = false

    var text: String {
        return self.textLabel.text ?? ""
    }
    
    private var isActive: Bool = false
    
    var isDisabled: Bool = false {
        didSet {
            if self.isDisabled {
                self.textLabel.textColor = UIColor.App.inputText
                self.baseView.isUserInteractionEnabled = false
                self.baseView.alpha = 0.7
            }
            else {
                self.headerLabel.isHidden = false
                self.textLabel.textColor = UIColor.App.inputText
                self.textLabel.isUserInteractionEnabled = true
                self.baseView.alpha = 1
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
                tipImageView.isHidden = false
                tipImageView.image = UIImage(named: "Active")
            case .error:
                tipImageView.isHidden = false
                tipImageView.image = UIImage(named: "error_input_icon")
            case .hidden:
                tipImageView.isHidden = true
                tipImageView.image = nil
            }
        }
    }
    
    // MARK: - Lifetime and Cycle

    @available(iOS, unavailable)
    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
        self.slideDown()
        self.baseView.backgroundColor = UIColor.App.backgroundSecondary
        self.baseView.layer.cornerRadius = CornerRadius.headerInput
        self.baseView.layer.borderWidth = 1
        
        self.baseView.layer.cornerRadius = CornerRadius.headerInput
        self.baseView.layer.borderWidth = 1
      
        self.bottomStackView.addArrangedSubview(self.tipImageView)
        self.bottomStackView.addArrangedSubview(self.tipLabel)
        
        self.fieldState = .hidden
        self.setupSubviews()

    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setDatePickerMode() {
        if text.isEmpty {
            slideUp()
        }
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(self.dateChanged), for: .allEvents)

        let doneButton = UIBarButtonItem.init(title: localized("done"), style: .done, target: self, action: #selector(self.datePickerDone))

        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)

        textField.inputAccessoryView = toolBar
        textField.inputView = datePicker
        slideUp()
        
    }

    @objc func datePickerDone() {
        
        textField.resignFirstResponder()
    }

    @objc func dateChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormatter.string(from: datePicker.date)
        textLabel.text = "\(selectedDate)"
    }
    
    @objc func showPicker() {
      
        textField.becomeFirstResponder()
        
    }
    
    func slideUp(animated: Bool = true) {

        if textLabel.text?.isEmpty ?? true {
            return
        }
        if self.isSlidedUp {
            return
        }
        
        // TODO: Fazer a conta de forma dinâmica
        // let placeholderYPosition = self.headerPlaceholderLabel.center.y
        // let headerYPosition = self.headerLabel.center.y
        NSLayoutConstraint.activate([
            self.headerLabel.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor, constant: -15),
        ])// -(headerYPosition - placeholderYPosition)

        UIView.animate(withDuration: animated ? 0.2 : 0, delay: 0.0, options: .curveEaseOut) {
            self.layoutIfNeeded()

            if self.shouldScalePlaceholder {
                
                let movingWidthDiff = (self.headerLabel.frame.size.width - (self.headerLabel.frame.size.width * 0.8)) / 2
                self.headerLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).concatenating(CGAffineTransform(translationX: -movingWidthDiff, y: 0))
            }
            self.shouldScalePlaceholder = false
        } completion: { _ in
            self.isSlidedUp = true
        }
    }

    func slideDown() {

        if textLabel.text?.isEmpty ?? true {
            return
        }
        if !self.isSlidedUp {
            return
        }

        NSLayoutConstraint.activate([
            self.headerLabel.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor, constant: 0),
        ])
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.layoutIfNeeded()
            self.headerLabel.transform = CGAffineTransform.identity
            self.shouldScalePlaceholder = true
        } completion: { _ in
            self.isSlidedUp = false
        }
    }
    
    func setPickerArray(_ array: [String]) {
        selectionArray = array
        pickerView.selectRow(0, inComponent: 0, animated: true)
        textField.text = selectionArray[0]
    }

    func setSelectedPickerOption(option: Int) {
        pickerView.selectRow(option, inComponent: 0, animated: true)
        textLabel.text = selectionArray[option]
    }

    func setSelectionPicker(_ array: [String], headerVisible: Bool = false, defaultValue: Int = 0) {
        selectionArray = array

        pickerView.delegate = self
        
        if !headerVisible {
            headerLabel.isHidden = true
        }
        
        textField.inputView = pickerView
        textField.text = selectionArray[defaultValue]
        textLabel.text = selectionArray[defaultValue]
        if textLabel.text != "" {
            self.slideUp(animated: true)
        }
        
        let arrowDropdownImageView = UIImageView()
        arrowDropdownImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let arrowImageView = UIImageView(image: UIImage(named: "arrow_dropdown_icon"))
        arrowImageView.frame = CGRect(x: -20, y: -4, width: 10, height: 10)
        arrowImageView.contentMode = .scaleAspectFit
        arrowDropdownImageView.addSubview(arrowImageView)
        textField.rightView = arrowDropdownImageView
        textField.rightViewMode = .always

        dismissPickerView()
    }
    
    func shouldSlideDown() -> Bool {
        if let text = textField.text, !text.isEmpty {
            return false
        }
        return true
    }

    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: localized("done"), style: .plain, target: self, action: #selector(pickerAction))

        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), button], animated: true)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
       
    }
    
    func setHeaderLabelColor(_ color: UIColor) {
        self.headerLabel.textColor = color
    }

    func setTextFieldColor(_ color: UIColor) {
        self.textLabel.textColor = color
    }

    func setViewColor(_ color: UIColor) {
        self.baseView.backgroundColor = color
        self.textField.textColor = .clear
        self.textField.backgroundColor = .clear
        self.textLabel.backgroundColor = color
        self.headerLabel.backgroundColor = color
    }

    func setViewBorderColor(_ color: UIColor) {
        self.baseView.layer.borderColor = color.cgColor
    }
    
    func setPlaceholderText(_ placeholder: String) {
        self.headerLabel.text = placeholder

    }
    
    func setTextFieldFont(_ font: UIFont) {
        self.textLabel.font = font
    }
    
    func setText(_ text: String, slideUp: Bool = true) {
        self.textLabel.text = text
        if slideUp {
            self.slideUp(animated: false)
        }
    }
    
    func setHeaderLabelFont(_ font: UIFont) {
        self.headerLabel.font = font
    }
  
    func setPlaceholderTextColor(_ color: UIColor) {
        self.headerLabel.textColor = color
       
    }
    
    func setImageTextField(_ image: UIImage, size: CGFloat = 30) {
        self.selectImage.image = image
    }
    
    @objc func pickerAction() {
        
       /* self.didSelectPickerIndex = { [weak self ] index in
            if let selectedValue = self?.selectionArray[index] {
                self?.textLabel.text = selectedValue
            }
        }*/
        self.textPublisher.send(self.text)
        self.endEditing(true)
    }

    func showErrorOnField(text: String, color: UIColor = .systemRed) {

        self.tipLabel.text = text
        self.tipLabel.textColor = color

        self.fieldState = .error

        UIView.animate(withDuration: 0.1) {
            self.tipLabel.alpha = 1.0
        }

        self.containerView.layer.borderColor = color.cgColor

        self.showingTipLabel = true
    }

    func showTip(text: String, color: UIColor = .systemRed) {

        tipLabel.text = text
        tipLabel.textColor = color

        UIView.animate(withDuration: 0.1) {
            self.tipLabel.alpha = 1.0
        }

        self.showingTipLabel = true
    }

    func showTipWithoutIcon(text: String, color: UIColor = .systemRed) {

        tipLabel.text = text
        tipLabel.textColor = color

        UIView.animate(withDuration: 0.1) {
            self.tipLabel.alpha = 1.0
        }

        tipImageView.isHidden = true

        self.showingTipLabel = true
    }

    func hideTipAndError() {

        if !self.showingTipLabel {
            return
        }

        showingTipLabel = false

        tipLabel.text = ""
        tipLabel.textColor = .black
        containerView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        fieldState = .hidden

        UIView.animate(withDuration: 0.1) {
            self.tipLabel.alpha = 0.0
        }
    }
}

//
// MARK: - Subviews Initialization and Setup
//
extension DropDownSelectionView {

    private static func createSimpleView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

        // Add subviews to self.view or each other
        //self.containerView.addSubview(self.textField)
        self.containerView.addSubview(self.bottomStackView)
        
        self.baseView.addSubview(self.textField)
        self.baseView.addSubview(self.textLabel)
        self.baseView.addSubview(self.placeholderLabel)
        self.baseView.addSubview(self.headerLabel)
        self.baseView.addSubview(self.selectImage)
        
        self.containerView.addSubview(self.baseView)
        
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
            self.textLabel.topAnchor.constraint(equalTo: self.baseView.centerYAnchor, constant: 2),
            
            self.placeholderLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.placeholderLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),
            self.placeholderLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 10),

            self.headerLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.headerLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),
            self.headerLabel.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),
            self.headerLabel.heightAnchor.constraint(equalToConstant: 24),
            
            self.selectImage.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -20),
            self.selectImage.centerYAnchor.constraint(equalTo: self.baseView.centerYAnchor),
            
            self.bottomStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.bottomStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.bottomStackView.topAnchor.constraint(equalTo: self.baseView.bottomAnchor),
            self.bottomStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            

            
        ])
    }
    
}

extension DropDownSelectionView: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let shouldBeginEditing = self.shouldBeginEditing?() ?? true
        self.isActive = shouldBeginEditing
        return shouldBeginEditing
    }
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.slideUp()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.shouldSlideDown() {
            self.slideDown()
        }
    }


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if self.isCurrency {
            let decimals = CharacterSet(charactersIn: "0123456789.")
            if range.length>0  && range.location == 0 {
                return false

            }
            else if string.rangeOfCharacter(from: decimals) == nil && string != "" {
                    return false
            }
        }
        return true
    }
}


extension DropDownSelectionView: UIPickerViewDelegate, UIPickerViewDataSource {
    // PickerView override methods
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
     
            slideUp()
        
        
        let selectedItem = selectionArray[row]
        textLabel.text = selectedItem
    }
}
