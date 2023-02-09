import UIKit
import Extensions
import Theming
import Combine

class HeaderTextFieldView: NibView {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var headerPlaceholderLabel: UILabel!

    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!

    @IBOutlet private weak var bottomLineView: UIView!
    @IBOutlet private weak var tipLabel: UILabel!

    @IBOutlet private weak var showPassImageView: UIImageView!
    @IBOutlet private weak var showStateImageView: UIImageView!
    @IBOutlet private weak var showRemoveImageView: UIImageView!

    @IBOutlet private weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var centerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var centerTopConstraint: NSLayoutConstraint!

    @IBOutlet private weak var tipImageView: UIImageView!
    @IBOutlet private weak var showPasswordLabel: UILabel!

    @IBOutlet private weak var usernameLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomStackView: UIStackView!

    var textPublisher: AnyPublisher<String, Never> {
        return self.textField.textPublisher
    }
    
    var contentCenterYConstraint: NSLayoutYAxisAnchor {
        return self.containerView.centerYAnchor
    }

    var didTapReturn: (() -> Void) = { }
    var didEndEditing: (() -> Void) = { }

    var didSelectPickerIndex: ((Int) -> Void)?
    var shouldBeginEditing: (() -> Bool)?
    var didTapRemoveIcon: (() -> Void)?

    // Variables
    let datePicker = UIDatePicker()
    let pickerView = UIPickerView()
    var selectionArray: [String] = []
    var shouldScalePlaceholder = true

    var isTipPermanent: Bool = false
    var isSlidedUp: Bool = false

    private var isCurrencyMode = false
    private var currencySymbol: String?

    var showingTipLabel: Bool = false

    private var isSecureField = false {
        didSet {

            self.textField.isSecureTextEntry = self.isSecureField

            if self.isSecureField {
                self.showPassImageView.isHidden = false
                self.showPasswordLabel.isHidden = false
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
                self.showPasswordLabel.text = Localization.localized("hide")
            }
            else {
                self.textField.isSecureTextEntry = true
                self.showPasswordLabel.text = Localization.localized("show")
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

    var highlightColor = AppColor.highlightPrimary {
        didSet {
            if self.isActive {
            }
        }
    }

    private var isActive: Bool = false

    var isDisabled: Bool = false {
        didSet {
            if self.isDisabled {
                self.textField.textColor = AppColor.inputText
                self.textField.isUserInteractionEnabled = false
                self.containerView.alpha = 0.7
            }
            else {
                self.headerLabel.isHidden = false
                self.textField.textColor = AppColor.inputText
                self.textField.isUserInteractionEnabled = true
                self.containerView.alpha = 1
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupWithTheme()
        self.configureContainerViewTap()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupWithTheme()
        self.configureContainerViewTap()
    }

    func configureContainerViewTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapContainerView))
        self.containerView.addGestureRecognizer(tapGesture)
    }

    func setupWithTheme() {

        self.backgroundColor = .clear

        self.containerView.backgroundColor = AppColor.backgroundSecondary
        self.containerView.layer.cornerRadius = 10.0
        self.containerView.layer.borderWidth = 2
        self.containerView.layer.borderColor = UIColor.clear.cgColor

        self.textField.autocorrectionType = .no
        self.textField.keyboardType = self.keyboardType

        self.showPassImageView.isUserInteractionEnabled = true
        self.showStateImageView.isUserInteractionEnabled = true
        self.showRemoveImageView.isUserInteractionEnabled = true

        self.showStateImageView.isHidden = true
        self.showPassImageView.isHidden = true
        self.showRemoveImageView.isHidden = true

        self.fieldState = .hidden

        self.tipLabel.alpha = 0.0
        self.tipLabel.numberOfLines = 2
        self.tipLabel.adjustsFontSizeToFitWidth = true
        self.tipLabel.minimumScaleFactor = 0.5

        self.tipImageView.isHidden = true

        self.headerPlaceholderLabel.alpha = 0.0
        self.textField.delegate = self

        self.bottomLineView.isHidden = true

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapShowPassword))
        self.showPassImageView.addGestureRecognizer(tapGestureRecognizer)

        self.showPasswordLabel.text = Localization.localized("show")
        self.showPasswordLabel.font = AppFont.with(type: .regular, size: 14.0)
        self.showPasswordLabel.textColor =  AppColor.textPrimary

        let text = Localization.localized("show")
        let underlineAttriString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: Localization.localized("show"))
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        self.showPasswordLabel.attributedText = underlineAttriString
        self.showPasswordLabel.isHidden = true
        self.showPasswordLabel.isUserInteractionEnabled = true
        self.showPasswordLabel.addGestureRecognizer(tapGestureRecognizer)

        self.tipLabel.font = AppFont.with(type: .semibold, size: 12)

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

        if self.isSlidedUp {
            return
        }

        self.highlightColor = AppColor.textPrimary

        // TODO: Fazer a conta de forma dinâmica
        // let placeholderYPosition = self.headerPlaceholderLabel.center.y
        // let headerYPosition = self.headerLabel.center.y
        self.centerBottomConstraint.constant = -15 // -(headerYPosition - placeholderYPosition)

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

        if headerLabel.text?.isEmpty ?? true {
            return
        }
        if !self.isSlidedUp {
            return
        }

        self.centerBottomConstraint.constant = 0

        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.layoutIfNeeded()
            self.headerLabel.transform = CGAffineTransform.identity
            self.shouldScalePlaceholder = true
        } completion: { _ in
            self.isSlidedUp = false
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        self.textField.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        self.textField.resignFirstResponder()
        return true
    }

    override var isFirstResponder: Bool {
        return self.textField.isFirstResponder
    }

    @objc func didTapContainerView() {
        self.textField.becomeFirstResponder()
    }

    func setText(_ text: String, slideUp: Bool = true) {

        self.textField.text = text

        NotificationCenter.default
            .post(name: UITextField.textDidChangeNotification,
                  object: self.textField)

        if !text.isEmpty && slideUp {
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

    func setSecureField(_ isSecure: Bool) {
        self.isSecureField = isSecure
    }

    func setCurrencyMode(_ isCurrency: Bool, currencySymbol: String?) {
        self.isCurrencyMode = isCurrency
        self.currencySymbol = currencySymbol
    }


    func showPasswordLabelVisible(visible: Bool) {
        self.showPasswordLabel.isHidden = !visible
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

    func setImageTextField(_ image: UIImage, size: CGFloat = 30) {
        self.showStateImageView.image = image
        self.showStateImageView.isHidden = false
        self.imageWidthConstraint.constant = size
    }

    func setRemoveTextField() {
        self.showRemoveImageView.image = UIImage(named: "trash_icon")
        self.showRemoveImageView.isHidden = false
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

    func setReturnKeyType(_ returnKeyType: UIReturnKeyType) {
        self.textField.returnKeyType = returnKeyType
    }

    func setDatePickerMode() {
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(self.dateChanged), for: .allEvents)

        let doneButton = UIBarButtonItem.init(title: Localization.localized("done"), style: .done, target: self, action: #selector(self.datePickerDone))

        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)

        textField.inputAccessoryView = toolBar
        textField.inputView = datePicker
    }

    @objc func datePickerDone() {
        self.dateChanged()
        self.textField.resignFirstResponder()
    }

    @objc func dateChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let selectedDate = dateFormatter.string(from: datePicker.date)

        self.setText(selectedDate)
    }

    func setPickerArray(_ array: [String]) {
        selectionArray = array
        pickerView.selectRow(0, inComponent: 0, animated: true)

        self.setText(selectionArray[0])

    }

    func setSelectedPickerOption(option: Int) {
        pickerView.selectRow(option, inComponent: 0, animated: true)
        self.setText(selectionArray[option])
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

        self.setText(selectionArray[defaultValue])

        // Set arrow image
        let arrowDropdownImageView = UIImageView()
        arrowDropdownImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let arrowImageView = UIImageView(image: UIImage(named: "selector_arrow_down_icon"))
        arrowImageView.frame = CGRect(x: -20, y: -4, width: 10, height: 10)
        arrowImageView.contentMode = .scaleAspectFit
        arrowDropdownImageView.addSubview(arrowImageView)
        textField.rightView = arrowDropdownImageView
        textField.rightViewMode = .always

        self.dismissPickerView()
    }

    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: Localization.localized("done"), style: .plain, target: self, action: #selector(pickerAction))

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

        tipLabel.text = Localization.localized("empty_value")
        tipLabel.textColor = .black

        containerView.layer.borderColor = UIColor.clear.cgColor

        fieldState = .hidden

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
        let shouldBeginEditing = self.shouldBeginEditing?() ?? true
        self.isActive = shouldBeginEditing
        return shouldBeginEditing
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.isActive = true
        if !isTipPermanent {
            self.hideTipAndError()
        }
        self.containerView.layer.borderColor = AppColor.inputBorderActive.cgColor
        self.slideUp()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.shouldSlideDown() {
            self.slideDown()
        }

        self.isActive = false

        self.containerView.layer.borderColor = UIColor.clear.cgColor

        self.didEndEditing()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.didTapReturn()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.isCurrencyMode {
            let decimals = CharacterSet(charactersIn: "0123456789.")
            if string.rangeOfCharacter(from: decimals) == nil && string != "" {
                return false
            }
        }
        return true
    }

}

extension HeaderTextFieldView: UIPickerViewDelegate, UIPickerViewDataSource {

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
        self.setText(selectedItem)
    }

}
