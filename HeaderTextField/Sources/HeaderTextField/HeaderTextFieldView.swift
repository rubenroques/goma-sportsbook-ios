import UIKit
import Extensions
import Theming
import Combine

public class HeaderTextFieldView: NibView {

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

    private enum BorderState {
        case idle
        case firstResponder
        case disabled
        case error
    }

    private var borderState: BorderState = .idle {
        didSet {
            switch self.borderState {
            case .idle:
                self.containerView.layer.borderColor = self.idleColor.cgColor
            case .firstResponder:
                self.containerView.layer.borderColor = self.highlightColor.cgColor
            case .disabled:
                self.containerView.layer.borderColor = self.disabledColor.cgColor
            case .error:
                self.containerView.layer.borderColor = self.errorColor.cgColor
            }
        }
    }

    public var textPublisher: AnyPublisher<String, Never> {
        return self.textField.textPublisher
    }
    
    public var contentCenterYConstraint: NSLayoutYAxisAnchor {
        return self.containerView.centerYAnchor
    }

    public var didTapReturn: (() -> Void) = { }
    public var didEndEditing: (() -> Void) = { }

    public var didSelectPickerIndex: ((Int) -> Void)?
    public var shouldBeginEditing: (() -> Bool)?
    public var didTapRemoveIcon: (() -> Void)?

    //  Variables
    public let datePicker = UIDatePicker()
    public let pickerView = UIPickerView()
    public var selectionArray: [String] = []
    public var shouldScalePlaceholder = true

    public var isTipPermanent: Bool = false
    public var isSlidedUp: Bool = false

    private var isCurrencyMode = false
    private var currencySymbol: String?

    public var showingTipLabel: Bool = false

    public var isManualInput: Bool = false

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

    public var autocorrect = false {
        didSet {
            self.textField.autocorrectionType = .no

            if autocorrect {
                self.textField.autocorrectionType = .yes
            }
        }
    }

    public var keyboardType: UIKeyboardType = .default {
        didSet {
            self.textField.keyboardType = self.keyboardType
        }
    }

    public var shouldShowPassword = false {
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

    public var text: String {
        return self.textField.text ?? ""
    }

    enum TipState {
        case ok
        case error
        case hidden
    }

    var tipState: TipState = .hidden {
        didSet {
            switch self.tipState {
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

    public var idleColor = AppColor.backgroundBorder
    public var highlightColor = AppColor.inputBorderActive
    public var disabledColor = AppColor.inputBackground
    public var errorColor = AppColor.alertError

    private var isActive: Bool = false {
        didSet {
            if isActive {
                self.borderState = .firstResponder
            }
            else {
                self.borderState = .idle
            }
        }
    }

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

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupWithTheme()
        self.configureContainerViewTap()

        self.configureDefault()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupWithTheme()
        self.configureContainerViewTap()

        self.configureDefault()
    }

    private func configureDefault() {

        self.borderState = .idle
        self.tipState = .hidden
    }

    private func configureContainerViewTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapContainerView))
        self.containerView.addGestureRecognizer(tapGesture)
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = AppColor.inputBackground
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

    public override var canBecomeFirstResponder: Bool {
        return true
    }

    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        self.textField.becomeFirstResponder()
    }

    @discardableResult
    public override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        self.textField.resignFirstResponder()
        return true
    }

    public override var isFirstResponder: Bool {
        return self.textField.isFirstResponder
    }

    @objc func didTapContainerView() {
        self.textField.becomeFirstResponder()
    }

    public func setText(_ text: String, slideUp: Bool = true, shouldPublish: Bool = true) {

        self.textField.text = text

        if shouldPublish {
            NotificationCenter.default
                .post(name: UITextField.textDidChangeNotification,
                      object: self.textField)
        }
        
        if !text.isEmpty && slideUp {
            self.slideUp(animated: false)
        }

    }

    public func setPlaceholderText(_ placeholder: String) {
        self.textField.placeholder = ""
        self.headerLabel.text = placeholder
    }

    public func setPlaceholderColor(_ color: UIColor) {
        self.headerLabel.textColor = color
    }

    public func setSecureField(_ isSecure: Bool) {
        self.isSecureField = isSecure
    }

    public func setCurrencyMode(_ isCurrency: Bool, currencySymbol: String?) {
        self.isCurrencyMode = isCurrency
        self.currencySymbol = currencySymbol
    }


    public func showPasswordLabelVisible(visible: Bool) {
        self.showPasswordLabel.isHidden = !visible
    }

    public func setHeaderLabelColor(_ color: UIColor) {
        self.headerLabel.textColor = color
    }

    public func setTextFieldColor(_ color: UIColor) {
        self.textField.textColor = color
    }

    public func setViewColor(_ color: UIColor) {
        self.containerView.backgroundColor = color
    }

    public func setImageTextField(_ image: UIImage, size: CGFloat = 30) {
        self.showStateImageView.image = image
        self.showStateImageView.isHidden = false
        self.imageWidthConstraint.constant = size
    }

    public func setRemoveTextField() {
        self.showRemoveImageView.image = UIImage(named: "trash_icon")
        self.showRemoveImageView.isHidden = false
    }

    public func setTextFieldDefaultValue(_ value: String) {
        self.textField.text = value
        self.slideUp(animated: false)
    }

    public func setTextFieldFont(_ font: UIFont) {
        self.textField.font = font
    }

    public func setHeaderLabelFont(_ font: UIFont) {
        self.headerLabel.font = font
    }

    public func setKeyboardType(_ keyboard: UIKeyboardType) {
        self.textField.keyboardType = keyboard
    }

    public func setContextType(_ textContentType: UITextContentType) {
        self.textField.textContentType = textContentType
    }

    public func setReturnKeyType(_ returnKeyType: UIReturnKeyType) {
        self.textField.returnKeyType = returnKeyType
    }

    public func setDatePickerMode() {
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

    public func setPickerArray(_ array: [String]) {
        selectionArray = array
        pickerView.selectRow(0, inComponent: 0, animated: true)

        self.setText(selectionArray[0])

    }

    public func setSelectedPickerOption(option: Int) {
        pickerView.selectRow(option, inComponent: 0, animated: true)
        self.setText(selectionArray[option])
    }

    public func setSelectionPicker(_ array: [String], headerVisible: Bool = false, defaultValue: Int = 0) {
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

    public func dismissPickerView() {
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

    public func showError(withMessage message: String) {

        self.borderState = .error

        self.tipLabel.text = message
        self.tipLabel.textColor = self.errorColor

        self.tipState = .error

        UIView.animate(withDuration: 0.1) {
            self.tipLabel.alpha = 1.0
        }

        self.showingTipLabel = true
    }

    public func showTip(text: String, color: UIColor = .systemRed) {

        tipLabel.text = text
        tipLabel.textColor = color

        UIView.animate(withDuration: 0.1) {
            self.tipLabel.alpha = 1.0
        }

        self.showingTipLabel = true
    }

    public func showTipWithoutIcon(text: String, color: UIColor = .systemRed) {

        tipLabel.text = text
        tipLabel.textColor = color

        UIView.animate(withDuration: 0.1) {
            self.tipLabel.alpha = 1.0
        }

        tipImageView.isHidden = true

        self.showingTipLabel = true
    }

    public func hideTipAndError() {

        if !self.showingTipLabel {
            return
        }

        showingTipLabel = false

        tipLabel.text = ""
        tipLabel.textColor = .black

        if isActive {
            self.borderState = .firstResponder
        }
        else if isDisabled {
            self.borderState = .disabled
        }
        else {
            self.borderState = .idle
        }

        self.tipState = .hidden

        UIView.animate(withDuration: 0.1) {
            self.tipLabel.alpha = 0.0
        }
    }

    @objc func didTapShowPassword() {
        self.shouldShowPassword.toggle()
    }

}

extension HeaderTextFieldView: UITextFieldDelegate {

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let shouldBeginEditing = self.shouldBeginEditing?() ?? true
        self.isActive = shouldBeginEditing
        return shouldBeginEditing
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.isActive = true

        if !isTipPermanent {
            self.hideTipAndError()
        }

        self.slideUp()

        self.isManualInput = true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        if self.shouldSlideDown() {
            self.slideDown()
        }

        self.isActive = false

        self.didEndEditing()
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.didTapReturn()
        return true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.isCurrencyMode {
            let decimals = CharacterSet(charactersIn: "0123456789.,")
            if string.rangeOfCharacter(from: decimals) == nil && string != "" {
                return false
            }
        }
        return true
    }

}

extension HeaderTextFieldView: UIPickerViewDelegate, UIPickerViewDataSource {

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectionArray.count
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.didSelectPickerIndex?(row)
        return selectionArray[row]
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedItem = selectionArray[row]
        self.setText(selectedItem)
    }

}
