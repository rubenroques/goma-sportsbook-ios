//
//  FullRegisterPersonalInfoViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 24/09/2021.
//

import UIKit

class FullRegisterPersonalInfoViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var firstNameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var lastNameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var continueButton: RoundButton!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var progressView: UIView!
    @IBOutlet private var progressLabel: UILabel!
    @IBOutlet private var progressImageView: UIImageView!

    // Variables
    var buttonEnabled: Bool = false

    init() {
        super.init(nibName: "FullRegisterPersonalInfoViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
        setupWithTheme()

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func commonInit() {

        closeButton.setTitle(localized("string_close"), for: .normal)
        closeButton.titleLabel?.font = AppFont.with(type: .bold, size: 16)

        progressLabel.text = localized("string_complete_signup")
        progressLabel.font = AppFont.with(type: .bold, size: 24)

        titleLabel.text = localized("string_personal_information")
        titleLabel.font = AppFont.with(type: .bold, size: 18)

        firstNameHeaderTextFieldView.setPlaceholderText(localized("string_first_name"))
        firstNameHeaderTextFieldView.showTipWithoutIcon(text: localized("string_names_match_id"), color: UIColor.App.headerTextFieldGray)

        lastNameHeaderTextFieldView.setPlaceholderText(localized("string_last_name"))
        lastNameHeaderTextFieldView.showTipWithoutIcon(text: localized("string_names_match_id"), color: UIColor.App.headerTextFieldGray)

        continueButton.setTitle(localized("string_continue"), for: .normal)
        continueButton.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        continueButton.isEnabled = false

        checkUserInputs()

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    func setupWithTheme() {

        topView.backgroundColor = UIColor.App.backgroundDarkProfile

        view.backgroundColor = UIColor.App.backgroundDarkProfile

        containerView.backgroundColor = UIColor.App.backgroundDarkProfile

        navigationView.backgroundColor = UIColor.App.backgroundDarkProfile

        closeButton.setTitleColor(UIColor.App.headingMain, for: .normal)

        progressView.backgroundColor = UIColor.App.backgroundDarkProfile

        progressLabel.textColor = UIColor.App.headingMain

        titleLabel.textColor = UIColor.App.headingMain

        firstNameHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        firstNameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        firstNameHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        lastNameHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        lastNameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        lastNameHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        continueButton.backgroundColor = UIColor.App.backgroundDarkProfile
        continueButton.setTitleColor(UIColor.App.headerTextFieldGray, for: .disabled)
        continueButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        continueButton.cornerRadius = CornerRadius.button

    }

    private func checkUserInputs() {
        // Check if both fields have data
        firstNameHeaderTextFieldView.hasText = { value in
            if value {
                if self.lastNameHeaderTextFieldView.text != "" {
                    self.continueButton.enableButton()
                }
            }
            else {
                self.continueButton.disableButton()
            }
        }

        lastNameHeaderTextFieldView.hasText = { value in
            if value {
                if self.firstNameHeaderTextFieldView.text != "" {
                    self.continueButton.enableButton()
                }
            }
            else {
                self.continueButton.disableButton()
            }
        }

        firstNameHeaderTextFieldView.didTapReturn = {
            self.view.endEditing(true)
        }

        lastNameHeaderTextFieldView.didTapReturn = {
            self.view.endEditing(true)
        }
    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func continueAction() {
        self.navigationController?.pushViewController(FullRegisterAddressCountryViewController(), animated: true)
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.firstNameHeaderTextFieldView.resignFirstResponder()

        self.lastNameHeaderTextFieldView.resignFirstResponder()

    }

}
