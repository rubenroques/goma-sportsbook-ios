import UIKit

class HeaderTextFieldView: NibView {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private weak var headerPlaceholderLabel: UILabel!

    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!

    @IBOutlet private weak var bottomLineView: UIView!
    @IBOutlet private weak var tipLabel: UILabel!

    @IBOutlet private weak var showPassImageView: UIImageView!
    @IBOutlet private weak var showStateImageView: UIImageView!
    @IBOutlet private weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var centerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var centerTopConstraint: NSLayoutConstraint!
    @IBOutlet private var showLabel: UILabel!
    @IBOutlet private var usernameLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var usernameIconConstraint: NSLayoutConstraint!

    @IBOutlet private var tipImageView: UIImageView!
    // Variables
    let datePicker = UIDatePicker()
    let pickerView = UIPickerView()
    var selectionArray: [String] = []
    var isSelect: Bool = false

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
                tipImageView.image = UIImage(named: "Error_Input")
            case .hidden:
                tipImageView.isHidden = true
                tipImageView.image = nil
            }
        }
    }

    var highlightColor = UIColor.Core
    .buttonMain {
        didSet {

            if self.isActive {
            }

        }
    }

    private var isActive: Bool = false
    
    var isDisabled: Bool = false {
        didSet {
            if self.isDisabled {
                self.textField.textColor = UIColor.Core.headingMain.withAlphaComponent(0.3)
                self.textField.isUserInteractionEnabled = false
            }
            else {
                self.textField.textColor = UIColor.Core.headingMain
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

//        #if DEBUG
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.red.cgColor
//        #endif
        if textField.text != "" {
            self.slideUp()
        }
        containerView.backgroundColor = UIColor.Core.backgroundDarkModal
        containerView.layer.cornerRadius = BorderRadius.headerInput
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.Core.backgroundDarkModal.withAlphaComponent(0).cgColor
        self.textField.autocorrectionType = .no
        self.textField.keyboardType = self.keyboardType

        self.showPassImageView.isUserInteractionEnabled = true
        self.showStateImageView.isUserInteractionEnabled = true

        self.showStateImageView.isHidden = true
        self.showPassImageView.isHidden = true

        self.fieldState = .hidden

        self.tipLabel.alpha = 0.0

        tipImageView.isHidden = true

        self.headerLabel.alpha = 0.7
        self.headerPlaceholderLabel.alpha = 0.0
        self.textField.delegate = self

        self.bottomLineView.isHidden = true

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapShowPassword))
        self.showPassImageView.addGestureRecognizer(tapGestureRecognizer)

        showLabel.text = localized("string_show")
        showLabel.font = AppFont.with(type: .regular, size: 14.0)
        showLabel.textColor =  UIColor.Core.headingMain
        let text = localized("string_show")
        let underlineAttriString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: localized("string_show"))
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        showLabel.attributedText = underlineAttriString
        showLabel.isHidden = true
        showLabel.isUserInteractionEnabled = true
        showLabel.addGestureRecognizer(tapGestureRecognizer)
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

        self.headerLabel.alpha = 1.0

        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        } completion: { _ in

        }
    }

    func slideDown() {

        self.centerBottomConstraint.isActive = true
        self.centerTopConstraint.isActive = false

        self.headerLabel.alpha = 0.7
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.layoutIfNeeded()
        } completion: { _ in

        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

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

    /**
     Creates dismiss action on picker view
     */
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

        self.highlightColor = UIColor.Core.headingMain
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
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.isSelect {
            return false
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
