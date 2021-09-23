import UIKit
import CombineCocoa
import Combine

class HeaderTextFieldView: NibView {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private weak var headerPlaceholderLabel: UILabel!

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    @IBOutlet private weak var bottomLineView: UIView!
    @IBOutlet private weak var tipLabel: UILabel!

    @IBOutlet private weak var showPassImageView: UIImageView!
    @IBOutlet private weak var showStateImageView: UIImageView!
    @IBOutlet private weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var centerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var centerTopConstraint: NSLayoutConstraint!

    @IBOutlet private weak var tipImageView: UIImageView!
    @IBOutlet private var showLabel: UILabel!

    @IBOutlet private var usernameLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var usernameIconConstraint: NSLayoutConstraint!

    var textPublisher: AnyPublisher<String?, Never> {
        return self.textField.textPublisher
    }

    var didTapReturn: (() -> Void)?
    var didTapIcon: (() -> Void)?

    // Variables
    let datePicker = UIDatePicker()
    let pickerView = UIPickerView()
    var selectionArray: [String] = []
    var shouldScalePlaceholder = true
    var isSelect: Bool = false
    var isCurrency: Bool = false

    private var isSecureField = false {
        didSet {

            self.textField.isSecureTextEntry = self.isSecureField

            if self.isSecureField {
                self.showPassImageView.isHidden = false
                self.showLabel.isHidden = false
            }

            self.showPassImageView.image = UIImage(named: "view_password_icon")
        }
    }

    var autocorrect = false {
        didSet {
            self.textField.autocorrectionType = .no

            if autocorrect {
                self.textField.autocorrectionType = .yes
            }
        }
    }

    var keyboardType: UIKeyboardType = .default {
        didSet {
            self.textField.keyboardType = self.keyboardType
        }
    }

    var shouldShowPassword = false {
        didSet {
            if self.shouldShowPassword {
                self.textField.isSecureTextEntry = false
                self.showLabel.text = localized("string_hide")
            }
            else {
                self.textField.isSecureTextEntry = true
                self.showLabel.text = localized("string_show")
            }
        }
    }

    var text: String {
        return self.textField.text ?? ""
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

    var highlightColor = UIColor.App.buttonMain {
        didSet {
            if self.isActive {
            }
        }
    }

    private var isActive: Bool = false
    
    var isDisabled: Bool = false {
        didSet {
            if self.isDisabled {
                self.textField.textColor = UIColor.App.headingMain.withAlphaComponent(0.3)
                self.textField.isUserInteractionEnabled = false
            }
            else {
                self.headerLabel.isHidden = false
                self.textField.textColor = UIColor.App.headingMain
                self.textField.isUserInteractionEnabled = true
            }
        }
    }

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

        containerView.backgroundColor = UIColor.App.backgroundDarkModal
        containerView.layer.cornerRadius = BorderRadius.headerInput
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.App.backgroundDarkModal.withAlphaComponent(0).cgColor
        
        self.textField.autocorrectionType = .no
        self.textField.keyboardType = self.keyboardType

        self.showPassImageView.isUserInteractionEnabled = true
        self.showStateImageView.isUserInteractionEnabled = true

        self.showStateImageView.isHidden = true
        self.showPassImageView.isHidden = true

        self.fieldState = .hidden

        self.tipLabel.alpha = 0.0

        tipImageView.isHidden = true

        self.headerPlaceholderLabel.alpha = 0.0
        self.textField.delegate = self

        self.bottomLineView.isHidden = true

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapShowPassword))
        self.showPassImageView.addGestureRecognizer(tapGestureRecognizer)

        showLabel.text = localized("string_show")
        showLabel.font = AppFont.with(type: .regular, size: 14.0)
        showLabel.textColor =  UIColor.App.headingMain

        let text = localized("string_show")
        let underlineAttriString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: localized("string_show"))
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        showLabel.attributedText = underlineAttriString
        showLabel.isHidden = true
        showLabel.isUserInteractionEnabled = true
        showLabel.addGestureRecognizer(tapGestureRecognizer)

        tipLabel.font = AppFont.with(type: .semibold, size: 12)

    }

    func shouldSlideDown() -> Bool {
        if let text = textField.text, !text.isEmpty {
            return false
        }
        return true
    }

    func slideUp() {

        self.centerBottomConstraint.isActive = false
        self.centerTopConstraint.isActive = true


        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
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

        self.centerBottomConstraint.isActive = true
        self.centerTopConstraint.isActive = false

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

    func setPlaceholderText(_ placeholder: String) {
        self.textField.placeholder = ""
        self.headerLabel.text = placeholder
    }

    func setSecureField(_ isSecure: Bool) {
        self.isSecureField = isSecure
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

    func setImageTextField(_ image: UIImage, size: CGFloat = 30) {
        self.showStateImageView.image = image
        self.showStateImageView.isHidden = false
        self.imageWidthConstraint.constant = size

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapIconImageVIew(_:)))

        self.showStateImageView.isUserInteractionEnabled = true
        self.showStateImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func didTapIconImageVIew(_ sender:AnyObject){

//        let coordinates = self.frame
//        print(coordinates)
        didTapIcon?()
    }

    func setTextFieldDefaultValue(_ value: String) {
        self.textField.text = value
        self.slideUp()
    }

    func setTextFieldFont(_ font: UIFont) {
        self.textField.font = font
    }

    func setKeyboardType(_ keyboard: UIKeyboardType) {
        self.textField.keyboardType = keyboard
    }

    func setDatePicker() {
        isSelect = true
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.dateChanged), for: .allEvents)

        let doneButton = UIBarButtonItem.init(title: localized("string_done"), style: .done, target: self, action: #selector(self.datePickerDone))

        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)

        textField.inputAccessoryView = toolBar
        textField.inputView = datePicker
    }

    @objc func datePickerDone() {
        textField.resignFirstResponder()
    }

    @objc func dateChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormatter.string(from: datePicker.date)
        textField.text = "\(selectedDate)"
    }

    func setSelectionPicker(_ array: [String], headerVisible: Bool = false) {
        isSelect = true
        selectionArray = array

        pickerView.delegate = self
        pickerView.selectRow(0, inComponent: 0, animated: true)

        if !headerVisible {
            headerLabel.isHidden = true
        }
        else {
            slideUp()
        }

        textField.inputView = pickerView
        textField.text = selectionArray[0]

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
        let button = UIBarButtonItem(title: localized("string_done"), style: .plain, target: self, action: #selector(pickerAction))

        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), button], animated: true)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }

    @objc func pickerAction() {
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
    }

    func showTip(text: String, color: UIColor = .systemRed) {

        tipLabel.text = text
        tipLabel.textColor = color

        UIView.animate(withDuration: 0.1) {
            self.tipLabel.alpha = 1.0
        }
    }

    func showTipWithoutIcon(text: String, color: UIColor = .systemRed) {

        tipLabel.text = text
        tipLabel.textColor = color

        UIView.animate(withDuration: 0.1) {
            self.tipLabel.alpha = 1.0
        }

        tipImageView.isHidden = true
        usernameIconConstraint.isActive = false
        usernameLeadingConstraint.isActive = true
    }

    func hideTipAndError() {

        tipLabel.text = ""
        tipLabel.textColor = .black

        self.fieldState = .hidden

        UIView.animate(withDuration: 0.1) {
            self.tipLabel.alpha = 0.0
        }
    }

    @objc func didTapShowPassword() {
        self.shouldShowPassword.toggle()
    }

}

extension HeaderTextFieldView: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.isActive = true
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {

        self.isActive = true

        self.highlightColor = UIColor.App.headingMain
        self.containerView.layer.borderColor = self.highlightColor.cgColor

        self.slideUp()

    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.shouldSlideDown() {
            self.slideDown()
        }

        if self.textField.text == "" {
            self.containerView.layer.borderColor = self.highlightColor.withAlphaComponent(0).cgColor
        }

        self.isActive = false

        if isCurrency {
            textField.text = textField.text?.currencyFormatting()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.didTapReturn?()
                return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.isSelect {
            return false
        }
        if self.isCurrency {
            print(string)
            let decimals = CharacterSet(charactersIn: "0123456789.")
            if range.length>0  && range.location == 0 {
                return false

            }
            else if (string.rangeOfCharacter(from: decimals) == nil && string != "") {
                    return false
            }
        }
        return true
    }
}

extension HeaderTextFieldView: UIPickerViewDelegate, UIPickerViewDataSource {
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
        textField.text = selectedItem
    }
}
