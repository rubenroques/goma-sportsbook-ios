//
//  FullRegisterAddressCountryViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 24/09/2021.
//

import UIKit
import Combine

class FullRegisterAddressCountryViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var progressView: UIView!
    @IBOutlet private var progressLabel: UILabel!
    @IBOutlet private var progressImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var securityQuestionTextFieldView: HeaderTextFieldView!
    @IBOutlet private var securityAnswerHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var continueButton: RoundButton!
    
    // Variables
    var cancellables = Set<AnyCancellable>()
    var registerForm: FullRegisterUserInfo

    init(registerForm: FullRegisterUserInfo) {
        self.registerForm = registerForm
        super.init(nibName: "FullRegisterAddressCountryViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
        setupWithTheme()

        setupPublishers()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func commonInit() {

        closeButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        closeButton.setTitle(localized("close"), for: .normal)

        progressLabel.text = localized("complete_signup")
        progressLabel.font = AppFont.with(type: .bold, size: 24)

        titleLabel.text = localized("account_security")
        titleLabel.font = AppFont.with(type: .bold, size: 18)

        securityQuestionTextFieldView.setPlaceholderText(localized("security_question"))

        securityAnswerHeaderTextFieldView.setPlaceholderText(localized("security_answer"))

        continueButton.setTitle(localized("continue_"), for: .normal)
        continueButton.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        continueButton.isEnabled = false

        checkUserInputs()

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

    }

    func setupWithTheme() {
        topView.backgroundColor = UIColor.App.backgroundPrimary

        view.backgroundColor = UIColor.App.backgroundPrimary

        containerView.backgroundColor = UIColor.App.backgroundPrimary

        navigationView.backgroundColor = UIColor.App.backgroundPrimary

        closeButton.setTitleColor( UIColor.App.highlightPrimary, for: .normal)
        closeButton.setTitleColor( UIColor.App.highlightPrimary.withAlphaComponent(0.7), for: .highlighted)
        closeButton.setTitleColor( UIColor.App.highlightPrimary.withAlphaComponent(0.4), for: .disabled)

        progressView.backgroundColor = UIColor.App.backgroundPrimary

        progressLabel.textColor = UIColor.App.textPrimary

        titleLabel.textColor = UIColor.App.textPrimary

        securityQuestionTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        securityQuestionTextFieldView.setHeaderLabelColor(UIColor.App.inputText)
        securityQuestionTextFieldView.setTextFieldColor(UIColor.App.textPrimary)
        securityQuestionTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        securityQuestionTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))

        securityAnswerHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        securityAnswerHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputText)
        securityAnswerHeaderTextFieldView.setTextFieldColor(UIColor.App.textPrimary)
        securityAnswerHeaderTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        securityAnswerHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))

        continueButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        continueButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)
        continueButton.setTitleColor(UIColor.App.buttonTextDisablePrimary, for: .disabled)
        continueButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        continueButton.cornerRadius = CornerRadius.button
    }

    func setupPublishers() {
        self.securityQuestionTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkUserInputs()
            })
            .store(in: &cancellables)

        self.securityAnswerHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkUserInputs()
            })
            .store(in: &cancellables)
    }

    private func checkUserInputs() {
        let securityQuestionText = securityQuestionTextFieldView.text == "" ? false : true
        let securityAnswerText = securityAnswerHeaderTextFieldView.text == "" ? false : true

        if  securityQuestionText && securityAnswerText {
            self.continueButton.isEnabled = true
            continueButton.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.setupFullRegisterUserInfoForm()
        }
        else {
            self.continueButton.isEnabled = false
            continueButton.backgroundColor = UIColor.App.backgroundPrimary
        }
    }

    func setupFullRegisterUserInfoForm() {
        let securityQuestionText = securityQuestionTextFieldView.text
        let securityAnswerText = securityAnswerHeaderTextFieldView.text

        registerForm.securityQuestion = securityQuestionText
        registerForm.securityAnswer = securityAnswerText
    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func continueAction() {
        self.navigationController?.pushViewController(FullRegisterDocumentsViewController(registerForm: registerForm), animated: true)
        // self.present(FullRegisterDocumentsViewController(registerForm: registerForm), animated: true, completion: nil)
    }
    
    @IBAction private func closeAction() {
       // self.dismiss(animated: true, completion: nil)
        
         self.navigationController?.popToRootViewController(animated: true)
    }


    @objc func didTapBackground() {
        self.resignFirstResponder()

        securityQuestionTextFieldView.resignFirstResponder()

        securityAnswerHeaderTextFieldView.resignFirstResponder()
    }

    @objc func keyboardWillShow(notification: NSNotification) {

        guard
            let userInfo = notification.userInfo,
            var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }


        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {

        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

}
