import UIKit

class HeaderTextFieldView: NibView {

    @IBOutlet private weak var headerPlaceholderLabel: UILabel!

    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!

    @IBOutlet private weak var bottomLineView: UIView!
    @IBOutlet private weak var tipLabel: UILabel!

    @IBOutlet private weak var showPassImageView: UIImageView!
    @IBOutlet private weak var showStateImageView: UIImageView!

    @IBOutlet private weak var centerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var centerTopConstraint: NSLayoutConstraint!
    @IBOutlet private var showLabel: UILabel!

    @IBOutlet private var tipImageView: UIImageView!


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
                //self.showPassImageView.image = UIImage(named: "hide_password_icon")
                self.showLabel.text = localized("string_hide")
            }
            else {
                self.textField.isSecureTextEntry = true
                //self.showPassImageView.image = UIImage(named: "view_password_icon")
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

    var highlightColor = UIColor.systemGreen {
        didSet {

            if self.isActive {
                //self.bottomLineView.backgroundColor = self.highlightColor
            }

        }
    }

    private var isActive: Bool = false

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

        //self.bottomLineView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        //self.bottomLineView.alpha = 1.0
        self.bottomLineView.isHidden = true

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapShowPassword))
        self.showPassImageView.addGestureRecognizer(tapGestureRecognizer)

        showLabel.text = localized("string_show")
        showLabel.font = AppFont.with(type: .regular, size: 14.0)
        showLabel.textColor =  UIColor.white
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

    func showErrorOnField(text: String, color: UIColor = .systemRed) {

        self.tipLabel.text = text
        self.tipLabel.textColor = color

        self.fieldState = .error

        UIView.animate(withDuration: 0.1) {
            self.tipLabel.alpha = 1.0
        }

        self.layer.borderColor = color.cgColor
    }

    func showTip(text: String, color: UIColor = .systemRed) {

        tipLabel.text = text
        tipLabel.textColor = color

        UIView.animate(withDuration: 0.1) {
            self.tipLabel.alpha = 1.0
        }
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
        //self.bottomLineView.backgroundColor = self.highlightColor
        self.layer.borderColor = self.highlightColor.cgColor

        self.slideUp()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.shouldSlideDown() {
            self.slideDown()
        }

        //self.bottomLineView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.layer.borderColor = self.highlightColor.withAlphaComponent(0).cgColor

        self.isActive = false
    }
}
