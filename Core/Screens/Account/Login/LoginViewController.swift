import UIKit

class LoginViewController: UIViewController {

    @IBOutlet private weak var usernameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private weak var passwordHeaderTextFieldView: HeaderTextFieldView!

    init() {
        super.init(nibName: "LoginViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "SplashViewController"

        self.usernameHeaderTextFieldView.setPlaceholderText("Username")
        self.passwordHeaderTextFieldView.setPlaceholderText("Password")

        self.usernameHeaderTextFieldView.highlightColor = .black
            self.passwordHeaderTextFieldView.highlightColor = .black

        self.passwordHeaderTextFieldView.setSecureField(true)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        _ = self.usernameHeaderTextFieldView.resignFirstResponder()
        _ = self.passwordHeaderTextFieldView.resignFirstResponder()
    }

    @IBAction private func didTapLoginButton() {
        
    }

    @IBAction private func didTapRecoverPassword() {
        self.navigationController?.pushViewController(RecoverPasswordViewController(), animated: true)
    }
}
