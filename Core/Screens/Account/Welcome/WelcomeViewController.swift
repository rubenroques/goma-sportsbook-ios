
import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var contentBaseView: UIView!

    @IBOutlet weak var loginButton: RoundButton!
    @IBOutlet weak var createAccountButton: RoundButton!

    @IBOutlet weak var facebookButton: RoundButton!
    @IBOutlet weak var googleButton: RoundButton!

    @IBOutlet weak var guestButton: RoundButton!

    init() {
        super.init(nibName: "WelcomeViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "WelcomeViewController"

        self.facebookButton.isCircular = true
        self.googleButton.isCircular = true

        let scale = CGAffineTransform.identity.scaledBy(x: 0.90, y: 0.90)
        let translation = CGAffineTransform(translationX: 0, y: 45)

        let merged = scale.concatenating(translation)

        facebookButton.titleLabel?.font = AppFont.with(type: .bold, size: 19)
        googleButton.titleLabel?.font = AppFont.with(type: .bold, size: 19)

        self.contentBaseView.transform = merged
        self.contentBaseView.alpha = 0.0

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.84, initialSpringVelocity: 0.0, options: UIView.AnimationOptions.allowUserInteraction) {

            self.contentBaseView.transform = CGAffineTransform.identity
            self.contentBaseView.alpha = 1.0

        } completion: { _ in }

    }

    @IBAction func goBack() {
        self.navigationController?.popViewController(animated: false)
    }


    @IBAction func didTapLoginButton() {
        self.navigationController?.pushViewController(LoginViewController(), animated: true)
    }


    @IBAction func didTapCreateAccount() {
        self.navigationController?.pushViewController(RegisterViewController(), animated: true)
    }

    @IBAction func didTapContinueAsGuest() {
        
    }

}
