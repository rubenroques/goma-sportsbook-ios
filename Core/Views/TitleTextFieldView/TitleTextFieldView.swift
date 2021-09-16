import UIKit

class TitleTextFieldView: NibView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!

    var regularBorderColor = UIColor.black
    var activeBorderColor = UIColor.black

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override func commonInit() {
        self.backgroundColor = .black

        self.titleLabel.text = "Title"
        self.titleLabel.font = AppFont.with(type: .bold, size: 20.0)
        self.titleLabel.textColor = .white

        self.textField.delegate = self
        self.textField.placeholder = "Placeholder"
        self.textField.backgroundColor = .black
        self.textField.textColor = .black
        self.textField.layer.cornerRadius = 5.0
        self.textField.layer.borderWidth = 1.0
        self.textField.layer.borderColor = regularBorderColor.cgColor
    }

    func setTitle(title: String) {
        self.titleLabel.text = title
    }

    func setPlaceholder(placeholder: String) {
        self.textField.placeholder = placeholder
    }

    func setKeyboardType(keyboardType: UIKeyboardType) {
        self.textField.keyboardType = keyboardType
    }

    func setSecureTextField(secure: Bool) {
        self.textField.isSecureTextEntry = secure
    }

    var text: String? {
        return self.textField.text
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 80)
    }

}

extension TitleTextFieldView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = activeBorderColor.cgColor
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.layer.borderColor = regularBorderColor.cgColor
    }

}
