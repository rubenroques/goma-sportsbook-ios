//
//  EmailVerificationViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 16/11/2021.
//

import UIKit
import Combine

class EmailVerificationViewController: UIViewController, ChooseEmailActionSheetPresenter {

    @IBOutlet private var topSafeView: UIView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var navigationTitleLabel: UILabel!
    @IBOutlet private var navigationCloseButton: UIButton!
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var checkEmailButton: RoundButton!
    // Variables
    var chooseEmailActionSheet: UIAlertController?
    private var cancellables = Set<AnyCancellable>()

    init() {
        super.init(nibName: "EmailVerificationViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {
        self.navigationTitleLabel.font = AppFont.with(type: .bold, size: 17)
        self.navigationTitleLabel.text = localized("email_verification")

        self.navigationCloseButton.setTitle(localized("close"), for: .normal)

        self.navigationCloseButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        self.navigationCloseButton.setTitle(localized("close"), for: .normal)

        self.logoImageView.image = UIImage(named: "check_email_box_icon")
        self.logoImageView.contentMode = .center

        self.titleLabel.text = localized("verify_email")
        self.titleLabel.font = AppFont.with(type: .bold, size: 22)

        self.descriptionLabel.text = localized("verify_email_description")
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.font = AppFont.with(type: .semibold, size: 16)

        self.checkEmailButton.setTitle(localized("activate_account"), for: .normal)
        self.checkEmailButton.titleLabel?.font = AppFont.with(type: .bold, size: 16)
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary
        self.navigationTitleLabel.textColor = UIColor.App.textPrimary
        self.navigationCloseButton.tintColor = UIColor.App.highlightPrimary
        self.navigationCloseButton.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.logoImageView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.descriptionLabel.textColor = UIColor.App.textPrimary

        self.checkEmailButton.backgroundColor = UIColor.App.highlightPrimary
        self.checkEmailButton.tintColor = UIColor.App.buttonTextPrimary
        self.checkEmailButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
    }

    @IBAction private func closeAction() {
        Env.everyMatrixClient.getSessionInfo()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }, receiveValue: { userSession in
                Env.userSessionStore.isUserEmailVerified.send(userSession.isEmailVerified)
            })
            .store(in: &cancellables)

    }
    @IBAction private func activateAccountAction() {
        chooseEmailActionSheet = setupChooseEmailActionSheet()

        show(chooseEmailActionSheet ?? UIAlertController(), sender: self)

    }

}

protocol ChooseEmailActionSheetPresenter {
   var chooseEmailActionSheet: UIAlertController? { get }
   func setupChooseEmailActionSheet(withTitle title: String?) -> UIAlertController
}

extension ChooseEmailActionSheetPresenter {

    func setupChooseEmailActionSheet(withTitle title: String? = localized("choose_email")) -> UIAlertController {
        let emailActionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        emailActionSheet.addAction(UIAlertAction(title: localized("cancel"), style: .cancel, handler: nil))
        if let action = openAction(withURL: "mailto:", andTitleActionTitle: "Mail") {
            emailActionSheet.addAction(action)
        }

         if let action = openAction(withURL: "googlegmail:///", andTitleActionTitle: "Gmail") {
            emailActionSheet.addAction(action)
         }

         if let action = openAction(withURL: "inbox-gmail://", andTitleActionTitle: "Inbox") {
            emailActionSheet.addAction(action)
         }

         if let action = openAction(withURL: "ms-outlook://", andTitleActionTitle: "Outlook") {
            emailActionSheet.addAction(action)
         }

         if let action = openAction(withURL: "x-dispatch:///", andTitleActionTitle: "Dispatch") {
            emailActionSheet.addAction(action)
         }

        return emailActionSheet
    }

    fileprivate func openAction(withURL: String, andTitleActionTitle: String) -> UIAlertAction? {
         guard let url = URL(string: withURL), UIApplication.shared.canOpenURL(url) else {
              return nil
         }
         let action = UIAlertAction(title: andTitleActionTitle, style: .default) { _ in
             UIApplication.shared.open(url)
         }
         return action
    }

}
