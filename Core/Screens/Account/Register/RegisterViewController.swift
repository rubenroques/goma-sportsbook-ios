import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet private weak var usernameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private weak var passwordHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private weak var passwordConfirmHeaderTextFieldView: HeaderTextFieldView!

    @IBOutlet private weak var countryBaseView: UIView!
    @IBOutlet private weak var countryRectangularView: UIView!
    @IBOutlet private weak var countryTitleLabel: UILabel!
    @IBOutlet private weak var countrySelectedLabel: UILabel!
    @IBOutlet private weak var countrySelectorImageView: UIImageView!

    @IBOutlet private weak var policyLabel: UILabel!

    init() {
        super.init(nibName: "RegisterViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "RegisterViewController"
        self.policyLabel.textColor = .black

        self.countrySelectorImageView.backgroundColor = .clear

        self.countryBaseView.backgroundColor = .clear
        self.countryRectangularView.backgroundColor = .clear
        self.countryRectangularView.layer.borderColor = UIColor.black.cgColor
        self.countryRectangularView.layer.borderWidth = 1.0
        self.countryRectangularView.layer.cornerRadius = 3

        self.usernameHeaderTextFieldView.textField.autocorrectionType = .no
        self.usernameHeaderTextFieldView.textField.keyboardType = .emailAddress
        self.usernameHeaderTextFieldView.setPlaceholderText("Email Address")
        
        self.passwordHeaderTextFieldView.setPlaceholderText("Type Password")
        self.passwordConfirmHeaderTextFieldView.setPlaceholderText("Re-type Password")

        self.usernameHeaderTextFieldView.highlightColor = .black
        self.passwordHeaderTextFieldView.highlightColor = .black
        self.passwordConfirmHeaderTextFieldView.highlightColor = .black

        self.passwordConfirmHeaderTextFieldView.showTip(text: "Minimum 6 characters", color: .black )

        self.passwordHeaderTextFieldView.setSecureField(true)
        self.passwordConfirmHeaderTextFieldView.setSecureField(true)

        self.countrySelectedLabel.alpha = 0.6
        self.countrySelectedLabel.text = "Select your country"

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

    }

    func validateFields() -> Bool {

        let username = self.usernameHeaderTextFieldView.textField.text ?? ""
        if username.isEmpty {
            self.usernameHeaderTextFieldView.showErrorOnField(text: "Empty email", color: .red)
            return false
        }

        let emailPattern = #"^\S+@\S+\.\S+$"#
        let result = username.range(of: emailPattern, options: .regularExpression)
        let validEmail = (result != nil)
        if !validEmail {
            self.usernameHeaderTextFieldView.showErrorOnField(text: "Invalid email", color: .red)
            return false
        }

        if self.passwordHeaderTextFieldView.textField.text?.count ?? 0 < 6 {
            self.passwordHeaderTextFieldView.showErrorOnField(text: "Password must have a minimum of 6 characters", color: .red)
            return false
        }

        if self.passwordConfirmHeaderTextFieldView.textField.text?.count ?? 0 < 6 {
            self.passwordConfirmHeaderTextFieldView.showErrorOnField(text: "Password must have a minimum of 6 characters", color: .red)
            return false
        }

        if self.passwordHeaderTextFieldView.textField.text
            != self.passwordConfirmHeaderTextFieldView.textField.text {

            self.passwordHeaderTextFieldView.showErrorOnField(text: "Passwords don't match", color: .red)
            self.passwordConfirmHeaderTextFieldView.showErrorOnField(text: "Passwords don't match", color: .red)

            return false
        }
        return true
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        _ = self.usernameHeaderTextFieldView.resignFirstResponder()
        _ = self.passwordHeaderTextFieldView.resignFirstResponder()
        _ = self.passwordConfirmHeaderTextFieldView.resignFirstResponder()

    }

    @IBAction func didTapRegisterButton() {
        self.resignFirstResponder()


        self.usernameHeaderTextFieldView.hideTipAndError()
        self.passwordHeaderTextFieldView.hideTipAndError()
        self.passwordConfirmHeaderTextFieldView.hideTipAndError()


        if !self.validateFields() {
            return
        }

        _ = self.usernameHeaderTextFieldView.resignFirstResponder()
        _ = self.passwordHeaderTextFieldView.resignFirstResponder()
        _ = self.passwordConfirmHeaderTextFieldView.resignFirstResponder()

        executeDelayed(1.0) {
            
        }
        
    }
}
