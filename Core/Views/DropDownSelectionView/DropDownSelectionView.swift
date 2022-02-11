//
//  DropDownSelectionView.swift
//  Sportsbook
//
//  Created by Teresa on 08/02/2022.
//

import UIKit
import CombineCocoa
import Combine

class DropDownSelectionView: NibView {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var headerPlaceholderLabel: UILabel!

    @IBOutlet weak var headerLabel: UILabel! // swiftlint:disable:this private_outlet

    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var textField: UITextField!

    var didTapReturn: (() -> Void)?
    var didTapIcon: (() -> Void)?
    var hasText: ((Bool) -> Void)?
    var didSelectPickerIndex: ((Int) -> Void)?
    var shouldBeginEditing: (() -> Bool)?

    // Variables
    
    let pickerView = UIPickerView()
    var selectionArray: [String] = []
    var shouldScalePlaceholder = true
    var isSelect: Bool = false
    var isCurrency: Bool = false
    var isTipPermanent: Bool = false

    var showingTipLabel: Bool = false

    var hasCustomRightLabel: Bool = false


    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setup()
    }

    func setup() {

        if textField.text != "" {
            self.slideUp()
        }

        containerView.backgroundColor = UIColor.App.backgroundSecondary
        containerView.layer.cornerRadius = CornerRadius.headerInput

        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.App.backgroundSecondary.cgColor
        
        self.textField.autocorrectionType = .no
        

        self.headerPlaceholderLabel.alpha = 0.0

        let text = localized("show")

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

    func setText(_ text: String, slideUp: Bool = true) {
        self.textField.text = text
        if slideUp {
            self.slideUp(animated: false)
        }
    }

    func setPlaceholderText(_ placeholder: String) {
        self.textField.placeholder = ""
        self.headerLabel.text = placeholder
    }
  

    func setPlaceholderColor(_ color: UIColor) {
        self.headerLabel.textColor = color
    }

   

    func setHeaderLabelColor(_ color: UIColor) {
        self.headerLabel.textColor = color
    }

    func setTextFieldColor(_ color: UIColor) {
        self.textField.textColor = color
    }

    func setViewColor(_ color: UIColor) {
        self.containerView.backgroundColor = color
    }

    func setViewBorderColor(_ color: UIColor) {
        self.containerView.layer.borderColor = color.cgColor
    }

    @objc func didTapIconImageVIew(_ sender: AnyObject) {

        didTapIcon?()
    }

    func setTextFieldDefaultValue(_ value: String) {
        self.textField.text = value
        self.slideUp(animated: false)
    }

    func setTextFieldFont(_ font: UIFont) {
        self.textField.font = font
    }

    func setHeaderLabelFont(_ font: UIFont) {
        self.headerLabel.font = font
    }

    func setKeyboardType(_ keyboard: UIKeyboardType) {
        self.textField.keyboardType = keyboard
    }


    func setPickerArray(_ array: [String]) {
        selectionArray = array
        pickerView.selectRow(0, inComponent: 0, animated: true)
        textField.text = selectionArray[0]
    }

    func setSelectedPickerOption(option: Int) {
        pickerView.selectRow(option, inComponent: 0, animated: true)
        textField.text = selectionArray[option]
    }

    func setSelectionPicker(_ array: [String], headerVisible: Bool = false, defaultValue: Int = 0) {
        selectionArray = array

        pickerView.delegate = self
        //pickerView.selectRow(defaultValue, inComponent: 0, animated: true)

        if !headerVisible {
            headerLabel.isHidden = true
        }
        else {
            slideUp(animated: false)
        }

        textField.inputView = pickerView
        textField.text = selectionArray[defaultValue]
        

        // Set arrow image
        let arrowDropdownImageView = UIImageView()
        arrowDropdownImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let arrowImageView = UIImageView(image: UIImage(named: "selector_arrow_down_icon"))
        arrowImageView.frame = CGRect(x: -20, y: -4, width: 10, height: 10)
        arrowImageView.contentMode = .scaleAspectFit
        arrowDropdownImageView.addSubview(arrowImageView)
        textField.rightView = arrowDropdownImageView
        textField.rightViewMode = .always

        dismissPickerView()
    }

    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: localized("done"), style: .plain, target: self, action: #selector(pickerAction))

        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), button], animated: true)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }

    @objc func pickerAction() {
        self.endEditing(true)
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
        let selectedItem = selectionArray[row]
        textField.text = selectedItem
    }
}

