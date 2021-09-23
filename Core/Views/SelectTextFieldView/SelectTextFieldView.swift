//
//  SelectTextFieldView.swift
//  Sportsbook
//
//  Created by André Lascas on 22/09/2021.
//

import Foundation
import UIKit
import CombineCocoa
import Combine

class SelectTextFieldView: NibView {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var selectLabel: UILabel!
    @IBOutlet private var selectImageView: UIImageView!
    @IBOutlet private var textField: UITextField!
    @IBOutlet private var iconLabelImageView: UIImageView!
    // Constraints
    @IBOutlet private var labelImageConstraint: NSLayoutConstraint!
    @IBOutlet private var labelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var textFieldLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var textFieldImageConstraint: NSLayoutConstraint!


    // Variables
    let pickerView = UIPickerView()
    var selectionArray: [String] = []
    var selectionIconArray: [UIImage] = []
    var isIconArray: Bool = false
    var didTapReturn: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setup()
    }

    var keyboardType: UIKeyboardType = .default {
        didSet {
            self.textField.keyboardType = self.keyboardType
        }
    }

    func setup() {
        self.backgroundColor = UIColor.App.backgroundDarkProfile
        self.layer.cornerRadius = BorderRadius.headerInput
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.App.headerTextFieldGray.withAlphaComponent(1).cgColor

        containerView.backgroundColor = UIColor.App.backgroundDarkProfile

        selectLabel.text = "Lorem"
        selectLabel.font = AppFont.with(type: .regular, size: 14.0)
        selectLabel.textColor =  UIColor.App.headingMain

        selectImageView.image = UIImage(named: "chevron-down")

        textField.autocorrectionType = .no
        textField.keyboardType = self.keyboardType
        textField.backgroundColor = .clear
        textField.textColor = .clear
        textField.delegate = self

        iconLabelImageView.isHidden = true
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

    func setSelectionPicker(_ array: [String], iconArray: [UIImage] = []) {
        if isIconArray {
            labelLeadingConstraint.isActive = false
            labelImageConstraint.isActive = true
            textFieldLeadingConstraint.isActive = false
            textFieldImageConstraint.isActive = true
            iconLabelImageView.isHidden = false
            iconLabelImageView.image = iconArray[0]
            selectionIconArray = iconArray
        }

        selectionArray = array

        pickerView.delegate = self
        pickerView.selectRow(0, inComponent: 0, animated: true)

        textField.inputView = pickerView
        textField.text = selectionArray[0]
        selectLabel.text = selectionArray[0]
        // Set arrow image
//        let arrowDropdownImageView = UIImageView()
//        arrowDropdownImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
//        let arrowImageView = UIImageView(image: UIImage(named: "selector_arrow_down_icon"))
//        arrowImageView.frame = CGRect(x: -20, y: -4, width: 10, height: 10)
//        arrowImageView.contentMode = .scaleAspectFit
//        arrowDropdownImageView.addSubview(arrowImageView)
//        textField.rightView = arrowDropdownImageView
//        textField.rightViewMode = .always

        dismissPickerView()
    }

    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: localized("string_done"), style: .plain, target: self, action: #selector(pickerAction))

        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), button], animated: true)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }

    @objc func pickerAction() {
        self.endEditing(true)
    }
}

extension SelectTextFieldView: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text
        selectLabel.text = textField.text
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.didTapReturn?()
                return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

extension SelectTextFieldView: UIPickerViewDelegate, UIPickerViewDataSource {
    // PickerView override methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectionArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectionArray[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedItem = selectionArray[row]
        selectLabel.text = selectedItem
        textField.text = selectedItem
        if self.isIconArray {
            iconLabelImageView.image = self.selectionIconArray[row]
        }
    }
}
