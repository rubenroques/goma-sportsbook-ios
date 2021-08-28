import UIKit

class RecoverPasswordViewController: UIViewController {

    init() {
        super.init(nibName: "RecoverPasswordViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "RecoverPasswordViewController"
    }
}
